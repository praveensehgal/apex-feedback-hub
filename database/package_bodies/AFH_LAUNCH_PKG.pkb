CREATE OR REPLACE PACKAGE BODY afh_launch_pkg AS
  -- ---------------------------------------------------------------------------
  -- AFH_LAUNCH_PKG body. Spec §13, §21, §22.2, §22.4; design §4.1; DG-01/DG-02.
  -- Token  = b64url(utf8(json)) || '.' || b64url(HMAC-SHA256(secret, json)).
  -- JSON members, fixed order: v, cid, nonce, iat, exp, sub, app, apexApp, page,
  -- pageName, env, url. iat/exp are ISO-8601 UTC strings.
  -- validate() never raises for a bad launch: it returns REJECTED and writes one
  -- autonomous integration FAILED event whose safe_detail names the reason.
  -- See docs/security/launch-handoff.md.
  -- ---------------------------------------------------------------------------

  c_ttl_default   CONSTANT PLS_INTEGER := 120;   -- spec §13.2: never more than 120 s
  c_ttl_max       CONSTANT PLS_INTEGER := 120;
  c_skew_seconds  CONSTANT PLS_INTEGER := 5;     -- clock skew allowance on exp
  c_form_minutes  CONSTANT PLS_INTEGER := 15;    -- time allowed to fill Page 20 after VALIDATED
  c_ts_format     CONSTANT VARCHAR2(30) := 'YYYY-MM-DD"T"HH24:MI:SS"Z"';
  c_event_launch  CONSTANT VARCHAR2(30) := 'LAUNCH';

  c_msg_invalid   CONSTANT VARCHAR2(200) := 'This feedback launch is invalid. Close and open Feedback again.';
  c_msg_contract  CONSTANT VARCHAR2(200) := 'The host application''s feedback adapter needs an update.';
  c_msg_signin    CONSTANT VARCHAR2(200) := 'Sign in to continue.';

  -- Signed claims as carried by the token
  TYPE t_claims IS RECORD (
    v           VARCHAR2(20 CHAR),
    cid         VARCHAR2(64 CHAR),
    nonce       VARCHAR2(64 CHAR),
    iat         TIMESTAMP,
    exp         TIMESTAMP,
    sub         VARCHAR2(255 CHAR),
    app         VARCHAR2(30 CHAR),
    apex_app    NUMBER,
    page        NUMBER,
    page_name   VARCHAR2(255 CHAR),
    env         VARCHAR2(30 CHAR),
    url         VARCHAR2(2000 CHAR));

  -- Rejection channel: reject() stores the outcome and raises e_rejected; validate() catches it.
  e_rejected       EXCEPTION;
  g_reject_reason  VARCHAR2(30 CHAR);
  g_reject_code    VARCHAR2(12 CHAR);
  g_reject_message VARCHAR2(500 CHAR);
  -- Well-formed app key claimed by a token that could not be verified (APP_UNKNOWN);
  -- recorded on the FAILED event so operators see which key was presented.
  g_claimed_app_key VARCHAR2(30 CHAR);

  -- ------------------------------------------------------------------ helpers
  PROCEDURE reject(
    p_reason  IN VARCHAR2,
    p_code    IN VARCHAR2 DEFAULT afh_security_pkg.c_err_ctx_001,
    p_message IN VARCHAR2 DEFAULT c_msg_invalid) IS
  BEGIN
    g_reject_reason  := p_reason;
    g_reject_code    := p_code;
    g_reject_message := p_message;
    RAISE e_rejected;
  END reject;

  FUNCTION ttl_seconds RETURN PLS_INTEGER IS
    l_ttl NUMBER := afh_security_pkg.config_number('HANDOFF_TTL_SECONDS', c_ttl_default);
  BEGIN
    IF l_ttl IS NULL OR l_ttl <= 0 THEN
      l_ttl := c_ttl_default;
    END IF;
    RETURN LEAST(TRUNC(l_ttl), c_ttl_max);
  END ttl_seconds;

  FUNCTION now_utc RETURN TIMESTAMP IS
  BEGIN
    RETURN SYS_EXTRACT_UTC(SYSTIMESTAMP);
  END now_utc;

  FUNCTION fmt_utc(p_ts IN TIMESTAMP) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(p_ts, c_ts_format);
  END fmt_utc;

  FUNCTION parse_utc(p_text IN VARCHAR2) RETURN TIMESTAMP IS
  BEGIN
    RETURN TO_TIMESTAMP(p_text, c_ts_format);
  END parse_utc;

  FUNCTION safe_correlation(p_correlation_id IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_correlation_id IS NULL OR NOT REGEXP_LIKE(p_correlation_id, '^[A-Za-z0-9_-]{1,64}$') THEN
      RETURN NULL;
    END IF;
    RETURN p_correlation_id;
  END safe_correlation;

  -- Canonical JSON text for the claims (APEX_JSON, fixed member order, nulls written).
  FUNCTION build_json(p_c IN t_claims) RETURN VARCHAR2 IS
    l_json CLOB;
  BEGIN
    apex_json.initialize_clob_output(p_indent => 0);
    apex_json.open_object;
    apex_json.write('v',        p_c.v,              p_write_null => TRUE);
    apex_json.write('cid',      p_c.cid,            p_write_null => TRUE);
    apex_json.write('nonce',    p_c.nonce,          p_write_null => TRUE);
    apex_json.write('iat',      fmt_utc(p_c.iat),   p_write_null => TRUE);
    apex_json.write('exp',      fmt_utc(p_c.exp),   p_write_null => TRUE);
    apex_json.write('sub',      p_c.sub,            p_write_null => TRUE);
    apex_json.write('app',      p_c.app,            p_write_null => TRUE);
    apex_json.write('apexApp',  p_c.apex_app,       p_write_null => TRUE);
    apex_json.write('page',     p_c.page,           p_write_null => TRUE);
    apex_json.write('pageName', p_c.page_name,      p_write_null => TRUE);
    apex_json.write('env',      p_c.env,            p_write_null => TRUE);
    apex_json.write('url',      p_c.url,            p_write_null => TRUE);
    apex_json.close_object;
    l_json := apex_json.get_clob_output;
    apex_json.free_output;
    apex_json.initialize_output(p_http_header => FALSE);  -- back to HTP: free_output leaves output detached
    -- APEX_JSON breaks lines between members even at indent 0; string values carry
    -- escaped \n, so removing raw line breaks only touches insignificant whitespace.
    RETURN REPLACE(REPLACE(DBMS_LOB.substr(l_json, 32000, 1), CHR(13)), CHR(10));
  END build_json;

  -- Split "payload.signature" into the decoded JSON text and the raw signature.
  -- Any structural problem raises; the caller maps that to SIGNATURE.
  PROCEDURE split_token(p_token IN VARCHAR2, o_json OUT VARCHAR2, o_sig OUT RAW) IS
    l_token VARCHAR2(32767) := TRIM(p_token);
    l_dot   PLS_INTEGER := INSTR(l_token, '.');
    l_raw   RAW(32767);
  BEGIN
    IF l_token IS NULL OR l_dot <= 1 OR l_dot = LENGTH(l_token)
       OR INSTR(l_token, '.', l_dot + 1) > 0 THEN
      reject('SIGNATURE');
    END IF;
    l_raw  := afh_security_pkg.b64url_decode(SUBSTR(l_token, 1, l_dot - 1));
    o_sig  := afh_security_pkg.b64url_decode(SUBSTR(l_token, l_dot + 1));
    o_json := UTL_I18N.raw_to_char(l_raw, 'AL32UTF8');
    IF o_json IS NULL OR o_sig IS NULL OR UTL_RAW.length(o_sig) <> 32 THEN
      reject('SIGNATURE');
    END IF;
  END split_token;

  FUNCTION read_claims(p_json IN VARCHAR2) RETURN t_claims IS
    l_values apex_json.t_values;
    l_c      t_claims;
  BEGIN
    apex_json.parse(p_values => l_values, p_source => p_json);
    l_c.v         := SUBSTR(apex_json.get_varchar2('v',        p_values => l_values), 1, 20);
    l_c.cid       := SUBSTR(apex_json.get_varchar2('cid',      p_values => l_values), 1, 64);
    l_c.nonce     := SUBSTR(apex_json.get_varchar2('nonce',    p_values => l_values), 1, 64);
    l_c.iat       := parse_utc(apex_json.get_varchar2('iat',   p_values => l_values));
    l_c.exp       := parse_utc(apex_json.get_varchar2('exp',   p_values => l_values));
    l_c.sub       := SUBSTR(apex_json.get_varchar2('sub',      p_values => l_values), 1, 255);
    l_c.app       := SUBSTR(apex_json.get_varchar2('app',      p_values => l_values), 1, 30);
    l_c.apex_app  := apex_json.get_number('apexApp',           p_values => l_values);
    l_c.page      := apex_json.get_number('page',              p_values => l_values);
    l_c.page_name := SUBSTR(apex_json.get_varchar2('pageName', p_values => l_values), 1, 255);
    l_c.env       := SUBSTR(apex_json.get_varchar2('env',      p_values => l_values), 1, 30);
    l_c.url       := SUBSTR(apex_json.get_varchar2('url',      p_values => l_values), 1, 2000);
    RETURN l_c;
  END read_claims;

  -- Registry row by app key, inactive included so step 4 can classify APP_INACTIVE.
  FUNCTION fetch_app(p_app_key IN VARCHAR2, o_app OUT afh_applications%ROWTYPE) RETURN BOOLEAN IS
  BEGIN
    SELECT * INTO o_app FROM afh_applications WHERE app_key = UPPER(TRIM(p_app_key));
    RETURN TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN FALSE;
  END fetch_app;

  FUNCTION fetch_app_by_apex(p_apex_app_id IN NUMBER, o_app OUT afh_applications%ROWTYPE) RETURN BOOLEAN IS
  BEGIN
    SELECT * INTO o_app FROM afh_applications WHERE apex_app_id = p_apex_app_id;
    RETURN TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN FALSE;
  END fetch_app_by_apex;

  -- Decode, parse, resolve the application, and verify the HMAC over the decoded
  -- JSON bytes. Every failure in here is a tamper case -> SIGNATURE (or APP_UNKNOWN
  -- when the claimed key has no registry row, so no key exists to verify with).
  PROCEDURE parse_token(p_token IN VARCHAR2, o_claims OUT t_claims, o_app OUT afh_applications%ROWTYPE) IS
    l_json VARCHAR2(32767);
    l_sig  RAW(64);
    l_mac  RAW(64);
  BEGIN
    split_token(p_token, l_json, l_sig);
    o_claims := read_claims(l_json);
    IF REGEXP_LIKE(o_claims.app, '^[A-Z][A-Z0-9_]{0,29}$') THEN
      g_claimed_app_key := o_claims.app;
    END IF;
    IF o_claims.app IS NULL OR NOT fetch_app(o_claims.app, o_app) THEN
      reject('APP_UNKNOWN');
    END IF;
    IF o_app.shared_secret IS NULL THEN
      reject('SIGNATURE');
    END IF;
    l_mac := afh_security_pkg.hmac_sha256(o_app.shared_secret, l_json);
    IF NOT afh_security_pkg.raw_equals(l_mac, l_sig) THEN
      reject('SIGNATURE');
    END IF;
  EXCEPTION
    WHEN e_rejected THEN RAISE;
    WHEN OTHERS THEN reject('SIGNATURE');
  END parse_token;

  -- Step 1
  PROCEDURE check_contract(p_version IN VARCHAR2) IS
  BEGIN
    IF p_version IS NULL OR p_version <> c_contract_version THEN
      reject('CONTRACT', afh_security_pkg.c_err_ctx_003, c_msg_contract);
    END IF;
  END check_contract;

  -- Step 2a: the handoff row the token points at. A signed token without a row was
  -- purged (older than a day) or never issued here: treated as a replay.
  FUNCTION find_handoff(p_c IN t_claims) RETURN afh_launch_handoffs%ROWTYPE IS
    l_row afh_launch_handoffs%ROWTYPE;
  BEGIN
    IF p_c.cid IS NULL OR p_c.nonce IS NULL OR p_c.iat IS NULL OR p_c.exp IS NULL THEN
      reject('CONTRACT');
    END IF;
    SELECT * INTO l_row FROM afh_launch_handoffs WHERE correlation_id = p_c.cid;
    RETURN l_row;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN reject('REPLAY');
  END find_handoff;

  -- Step 2b: expiry with a small skew allowance, and the claimed lifetime must not
  -- exceed the configured TTL (a token cannot grant itself a longer life).
  PROCEDURE check_expiry(p_c IN t_claims) IS
    l_now TIMESTAMP := now_utc;
  BEGIN
    IF p_c.exp + NUMTODSINTERVAL(c_skew_seconds, 'SECOND') < l_now THEN
      reject('EXPIRED');
    END IF;
    IF p_c.exp > p_c.iat + NUMTODSINTERVAL(ttl_seconds + c_skew_seconds, 'SECOND') THEN
      reject('EXPIRED');
    END IF;
  END check_expiry;

  -- Step 2c: nonce unused. ISSUED -> first validation. VALIDATED -> page refresh by the
  -- same subject inside the token's own expiry. Anything else is a replay.
  PROCEDURE check_nonce(p_c IN t_claims, p_row IN afh_launch_handoffs%ROWTYPE) IS
  BEGIN
    IF p_row.nonce <> p_c.nonce OR p_row.consumed_at IS NOT NULL THEN
      reject('REPLAY');
    END IF;
    IF p_row.result_code = 'VALIDATED' THEN
      IF p_row.subject_canonical IS NULL
         OR p_row.subject_canonical <> afh_security_pkg.canonical_subject(p_c.sub) THEN
        reject('REPLAY');
      END IF;
    ELSIF p_row.result_code <> 'ISSUED' THEN
      reject('REPLAY');
    END IF;
  END check_nonce;

  -- Step 4: active application, APEX app id and identity mode match, active environment.
  FUNCTION check_registry(
    p_app           IN afh_applications%ROWTYPE,
    p_apex_app_id   IN NUMBER,
    p_expected_mode IN VARCHAR2,
    p_env_code      IN VARCHAR2) RETURN NUMBER IS
    l_env_id NUMBER;
  BEGIN
    IF p_app.is_active <> 'Y' THEN
      reject('APP_INACTIVE');
    END IF;
    IF p_apex_app_id IS NULL OR p_apex_app_id <> p_app.apex_app_id THEN
      reject('APP_UNKNOWN');
    END IF;
    IF p_app.identity_mode <> p_expected_mode THEN
      reject('CONTRACT');
    END IF;
    l_env_id := afh_registry_pkg.find_environment_id(p_app.application_id, p_env_code, 'N');
    IF l_env_id IS NULL THEN
      reject('ENV_UNKNOWN');
    END IF;
    RETURN l_env_id;
  END check_registry;

  -- Adapter version: always recorded; rejected with CTX-003 when below the minimum.
  PROCEDURE check_adapter(p_application_id IN NUMBER, p_adapter_version IN VARCHAR2) IS
  BEGIN
    afh_registry_pkg.record_adapter_version(p_application_id, p_adapter_version);
    IF NOT afh_registry_pkg.is_adapter_supported(p_application_id, p_adapter_version) THEN
      reject('CONTRACT', afh_security_pkg.c_err_ctx_003, c_msg_contract);
    END IF;
  END check_adapter;

  -- Step 5
  PROCEDURE check_url(p_environment_id IN NUMBER, p_url IN VARCHAR2) IS
  BEGIN
    IF NOT afh_registry_pkg.source_url_allowed(p_environment_id, p_url) THEN
      reject('URL_POLICY');
    END IF;
  END check_url;

  -- Registry facts for the returned record.
  PROCEDURE fill_registry(io_l IN OUT NOCOPY t_launch, p_application_id IN NUMBER, p_environment_id IN NUMBER) IS
  BEGIN
    SELECT a.application_id, a.app_key, a.display_name, a.apex_app_id, a.identity_mode,
           e.environment_id, e.env_code, e.label, e.app_version
      INTO io_l.application_id, io_l.app_key, io_l.application_name, io_l.apex_app_id, io_l.identity_mode,
           io_l.environment_id, io_l.env_code, io_l.env_label, io_l.app_version
      FROM afh_applications a
      JOIN afh_environments e ON e.application_id = a.application_id
     WHERE a.application_id = p_application_id
       AND e.environment_id = p_environment_id;
  END fill_registry;

  FUNCTION launch_from_row(p_row IN afh_launch_handoffs%ROWTYPE) RETURN t_launch IS
    l t_launch;
  BEGIN
    fill_registry(l, p_row.application_id, p_row.environment_id);
    l.correlation_id    := p_row.correlation_id;
    l.subject_canonical := p_row.subject_canonical;
    l.user_id           := afh_security_pkg.current_user_id;
    l.page_id           := p_row.page_id;
    l.page_name         := p_row.page_name;
    l.source_url        := p_row.source_url;
    l.result_code       := p_row.result_code;
    RETURN l;
  END launch_from_row;

  PROCEDURE mark_validated(p_launch_handoff_id IN NUMBER, p_l IN t_launch) IS
  BEGIN
    UPDATE afh_launch_handoffs
       SET result_code       = 'VALIDATED',
           subject_canonical = p_l.subject_canonical,
           environment_id    = p_l.environment_id,
           page_id           = p_l.page_id,
           page_name         = p_l.page_name,
           source_url        = p_l.source_url
     WHERE launch_handoff_id = p_launch_handoff_id;
  END mark_validated;

  -- A rejected token's ISSUED row is closed so the nonce can never be presented again.
  PROCEDURE close_rejected_row(p_launch_handoff_id IN NUMBER, p_reason IN VARCHAR2) IS
  BEGIN
    IF p_launch_handoff_id IS NULL THEN
      RETURN;
    END IF;
    UPDATE afh_launch_handoffs
       SET result_code = CASE p_reason WHEN 'EXPIRED' THEN 'EXPIRED' WHEN 'REPLAY' THEN 'REPLAYED' ELSE 'REJECTED' END
     WHERE launch_handoff_id = p_launch_handoff_id
       AND result_code = 'ISSUED';
  END close_rejected_row;

  -- Autonomous FAILED event. The registry ids are the only FK-bearing values; when the
  -- rows are not yet visible to the autonomous transaction (uncommitted fixtures) the
  -- event is written again keyed by app_key only, so a rejection is never lost.
  PROCEDURE log_rejection(p_l IN t_launch, p_adapter_version IN VARCHAR2, p_reason IN VARCHAR2) IS
  BEGIN
    afh_audit_pkg.log_integration_failure(
      p_event_code => c_event_launch, p_app_key => p_l.app_key,
      p_application_id => p_l.application_id, p_environment_id => p_l.environment_id,
      p_correlation_id => p_l.correlation_id, p_adapter_version => p_adapter_version,
      p_safe_detail => p_reason);
  EXCEPTION
    WHEN OTHERS THEN
      afh_audit_pkg.log_integration_failure(
        p_event_code => c_event_launch, p_app_key => p_l.app_key,
        p_correlation_id => p_l.correlation_id, p_adapter_version => p_adapter_version,
        p_safe_detail => p_reason);
  END log_rejection;

  PROCEDURE log_validated(p_l IN t_launch, p_adapter_version IN VARCHAR2) IS
  BEGIN
    afh_audit_pkg.set_correlation_id(p_l.correlation_id);
    afh_audit_pkg.log_integration_event(
      p_event_code => c_event_launch, p_result_code => 'OK', p_app_key => p_l.app_key,
      p_application_id => p_l.application_id, p_environment_id => p_l.environment_id,
      p_correlation_id => p_l.correlation_id, p_adapter_version => p_adapter_version,
      p_safe_detail => p_l.identity_mode);
  END log_validated;

  -- ------------------------------------------------------------------ signed mode
  -- The Hub page that validates a signed token runs inside the Hub's own authenticated
  -- session. The signed subject (issued by trusted host PL/SQL) must be the same human
  -- as the Hub session's APP_USER, or a user could present another user's token.
  -- Outside APEX (test runs) there is no Hub session; the check is then skipped.
  PROCEDURE check_hub_session_subject(p_signed_subject IN VARCHAR2) IS
    l_hub_subject VARCHAR2(255 CHAR);
  BEGIN
    BEGIN
      l_hub_subject := afh_security_pkg.current_subject;
    EXCEPTION WHEN OTHERS THEN
      l_hub_subject := NULL;   -- AFH-AUTH-001: no Hub session yet (login will follow)
    END;
    IF l_hub_subject IS NOT NULL
       AND SYS_CONTEXT('APEX$SESSION', 'APP_SESSION') IS NOT NULL
       AND l_hub_subject <> p_signed_subject THEN
      reject('SUBJECT_MISMATCH');
    END IF;
  END check_hub_session_subject;

  PROCEDURE validate_signed(p_token IN VARCHAR2, p_adapter_version IN VARCHAR2, io_l IN OUT NOCOPY t_launch) IS
    l_c   t_claims;
    l_app afh_applications%ROWTYPE;
    l_row afh_launch_handoffs%ROWTYPE;
    l_env NUMBER;
  BEGIN
    parse_token(p_token, l_c, l_app);
    io_l.correlation_id := l_c.cid;
    io_l.app_key        := l_app.app_key;
    io_l.application_id := l_app.application_id;
    BEGIN
      check_contract(l_c.v);                                             -- 1
      l_row := find_handoff(l_c);                                        -- 2
      check_expiry(l_c);
      check_nonce(l_c, l_row);
      IF TRIM(l_c.sub) IS NULL THEN                                      -- 3
        reject('SUBJECT_MISSING');
      END IF;
      io_l.subject_canonical := afh_security_pkg.canonical_subject(l_c.sub);
      check_hub_session_subject(io_l.subject_canonical);                 -- 3b (DG-01 bullet 1)
      io_l.user_id := afh_security_pkg.ensure_user(io_l.subject_canonical);
      l_env := check_registry(l_app, l_c.apex_app, afh_registry_pkg.c_mode_signed_envelope, l_c.env);  -- 4
      io_l.environment_id := l_env;
      check_adapter(l_app.application_id, p_adapter_version);
      check_url(l_env, l_c.url);                                         -- 5
    EXCEPTION
      WHEN e_rejected THEN
        close_rejected_row(l_row.launch_handoff_id, g_reject_reason);
        RAISE;
    END;
    fill_registry(io_l, l_app.application_id, l_env);
    io_l.page_id     := l_c.page;
    io_l.page_name   := l_c.page_name;
    io_l.source_url  := afh_registry_pkg.sanitize_url(l_c.url);
    io_l.result_code := 'VALIDATED';
    mark_validated(l_row.launch_handoff_id, io_l);
  END validate_signed;

  -- ------------------------------------------------------------------ shared mode
  -- Outside APEX (tests) apex_application.g_instance is NULL; then p_host_session_id must
  -- also be NULL and the session check is skipped. That is test-only behaviour.
  PROCEDURE check_shared_session(p_host_session_id IN NUMBER) IS
    l_instance NUMBER := apex_application.g_instance;
  BEGIN
    IF l_instance IS NULL THEN
      IF p_host_session_id IS NOT NULL THEN
        reject('SESSION');
      END IF;
    ELSIF p_host_session_id IS NULL OR p_host_session_id <> l_instance THEN
      reject('SESSION');
    END IF;
  END check_shared_session;

  FUNCTION resolve_shared_app(p_app_key IN VARCHAR2, p_apex_app_id IN NUMBER) RETURN afh_applications%ROWTYPE IS
    l_app afh_applications%ROWTYPE;
    l_ok  BOOLEAN := FALSE;
  BEGIN
    IF p_app_key IS NOT NULL THEN
      l_ok := fetch_app(p_app_key, l_app);
    ELSIF p_apex_app_id IS NOT NULL THEN
      l_ok := fetch_app_by_apex(p_apex_app_id, l_app);
    END IF;
    IF NOT l_ok THEN
      reject('APP_UNKNOWN');
    END IF;
    RETURN l_app;
  END resolve_shared_app;

  FUNCTION insert_shared_row(p_l IN t_launch, p_correlation_id IN VARCHAR2) RETURN VARCHAR2 IS
    l_cid VARCHAR2(64 CHAR) := safe_correlation(p_correlation_id);
    l_cnt PLS_INTEGER := 0;
    l_now TIMESTAMP WITH LOCAL TIME ZONE := SYSTIMESTAMP;
    l_expires TIMESTAMP WITH LOCAL TIME ZONE := l_now + NUMTODSINTERVAL(ttl_seconds, 'SECOND');
  BEGIN
    IF l_cid IS NOT NULL THEN
      SELECT COUNT(*) INTO l_cnt FROM afh_launch_handoffs WHERE correlation_id = l_cid;
    END IF;
    IF l_cid IS NULL OR l_cnt > 0 THEN
      l_cid := afh_audit_pkg.new_correlation_id;
    END IF;
    INSERT INTO afh_launch_handoffs (
      correlation_id, nonce, application_id, environment_id, subject_canonical, contract_version,
      issued_at, expires_at, result_code, page_id, page_name, source_url, identity_mode)
    VALUES (
      l_cid, afh_audit_pkg.new_correlation_id, p_l.application_id, p_l.environment_id,
      p_l.subject_canonical, c_contract_version, l_now,
      l_expires, 'VALIDATED',
      p_l.page_id, p_l.page_name, p_l.source_url, afh_registry_pkg.c_mode_shared_session);
    RETURN l_cid;
  END insert_shared_row;

  PROCEDURE validate_shared(
    p_correlation_id  IN VARCHAR2,
    p_host_session_id IN NUMBER,
    p_apex_app_id     IN NUMBER,
    p_app_key         IN VARCHAR2,
    p_env_code        IN VARCHAR2,
    p_page_id         IN NUMBER,
    p_page_name       IN VARCHAR2,
    p_source_url      IN VARCHAR2,
    p_adapter_version IN VARCHAR2,
    io_l              IN OUT NOCOPY t_launch) IS
    l_app afh_applications%ROWTYPE;
    l_env NUMBER;
  BEGIN
    io_l.correlation_id  := safe_correlation(p_correlation_id);
    io_l.app_key         := SUBSTR(UPPER(TRIM(p_app_key)), 1, 30);
    io_l.host_session_id := p_host_session_id;
    check_shared_session(p_host_session_id);
    io_l.subject_canonical := afh_security_pkg.current_subject;               -- 3 (AUTH-001 if none)
    io_l.user_id           := afh_security_pkg.ensure_user(io_l.subject_canonical);
    l_app := resolve_shared_app(p_app_key, p_apex_app_id);                    -- 4
    io_l.app_key        := l_app.app_key;
    io_l.application_id := l_app.application_id;
    l_env := check_registry(l_app, NVL(p_apex_app_id, l_app.apex_app_id),
                            afh_registry_pkg.c_mode_shared_session, p_env_code);
    io_l.environment_id := l_env;
    check_adapter(l_app.application_id, p_adapter_version);
    check_url(l_env, p_source_url);                                           -- 5
    fill_registry(io_l, l_app.application_id, l_env);
    io_l.page_id        := p_page_id;
    io_l.page_name      := SUBSTR(p_page_name, 1, 255);
    io_l.source_url     := afh_registry_pkg.sanitize_url(p_source_url);
    io_l.result_code    := 'VALIDATED';
    io_l.correlation_id := insert_shared_row(io_l, p_correlation_id);
  END validate_shared;

  -- ------------------------------------------------------------------ issue (signed mode)
  -- Host-side preconditions. These raise to the host's PL/SQL (trusted code), not to a
  -- browser, so the messages may say what is wrong with the registration.
  PROCEDURE check_issue_inputs(
    p_app_key     IN  VARCHAR2,
    p_subject     IN  VARCHAR2,
    p_env_code    IN  VARCHAR2,
    p_apex_app_id IN  NUMBER,
    o_app         OUT afh_applications%ROWTYPE,
    o_env_id      OUT NUMBER) IS
  BEGIN
    IF TRIM(p_subject) IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_001, c_msg_signin);
    END IF;
    IF TRIM(p_app_key) IS NULL OR TRIM(p_env_code) IS NULL OR p_apex_app_id IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'Application key, environment code, and APEX application id are required.');
    END IF;
    IF NOT fetch_app(p_app_key, o_app) OR o_app.is_active <> 'Y' OR o_app.apex_app_id <> p_apex_app_id THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The application is not registered for feedback.');
    END IF;
    IF o_app.identity_mode <> afh_registry_pkg.c_mode_signed_envelope OR o_app.shared_secret IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The application is not configured for signed launches.');
    END IF;
    o_env_id := afh_registry_pkg.find_environment_id(o_app.application_id, p_env_code, 'N');
    IF o_env_id IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The environment is not registered for feedback.');
    END IF;
  END check_issue_inputs;

  PROCEDURE insert_issued_row(
    p_c      IN t_claims,
    p_app_id IN NUMBER,
    p_env_id IN NUMBER,
    p_now    IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_ttl    IN PLS_INTEGER) IS
  BEGIN
    INSERT INTO afh_launch_handoffs (
      correlation_id, nonce, application_id, environment_id, subject_canonical, contract_version,
      issued_at, expires_at, result_code, page_id, page_name, source_url, identity_mode)
    VALUES (
      p_c.cid, p_c.nonce, p_app_id, p_env_id, p_c.sub, p_c.v,
      p_now, p_now + NUMTODSINTERVAL(p_ttl, 'SECOND'), 'ISSUED',
      p_c.page, p_c.page_name, p_c.url, afh_registry_pkg.c_mode_signed_envelope);
  END insert_issued_row;

  -- ------------------------------------------------------------------ public
  FUNCTION issue(
    p_app_key     IN VARCHAR2,
    p_subject     IN VARCHAR2,
    p_env_code    IN VARCHAR2,
    p_apex_app_id IN NUMBER,
    p_page_id     IN NUMBER,
    p_page_name   IN VARCHAR2,
    p_source_url  IN VARCHAR2) RETURN VARCHAR2 IS
    l_app    afh_applications%ROWTYPE;
    l_env_id NUMBER;
    l_c      t_claims;
    l_json   VARCHAR2(32767);
    l_now    TIMESTAMP WITH LOCAL TIME ZONE := SYSTIMESTAMP;
    l_ttl    PLS_INTEGER := ttl_seconds;
  BEGIN
    check_issue_inputs(p_app_key, p_subject, p_env_code, p_apex_app_id, l_app, l_env_id);
    l_c.v         := c_contract_version;
    l_c.cid       := afh_audit_pkg.new_correlation_id;
    l_c.nonce     := afh_audit_pkg.new_correlation_id;
    l_c.iat       := SYS_EXTRACT_UTC(l_now);
    l_c.exp       := l_c.iat + NUMTODSINTERVAL(l_ttl, 'SECOND');
    l_c.sub       := afh_security_pkg.canonical_subject(p_subject);
    l_c.app       := l_app.app_key;
    l_c.apex_app  := l_app.apex_app_id;
    l_c.page      := p_page_id;
    l_c.page_name := SUBSTR(TRIM(p_page_name), 1, 255);
    l_c.env       := UPPER(TRIM(p_env_code));
    l_c.url       := afh_registry_pkg.sanitize_url(p_source_url);   -- credentials never enter the token
    insert_issued_row(l_c, l_app.application_id, l_env_id, l_now, l_ttl);
    l_json := build_json(l_c);
    RETURN afh_security_pkg.b64url_encode(UTL_I18N.string_to_raw(l_json, 'AL32UTF8'))
        || '.' || afh_security_pkg.b64url_encode(afh_security_pkg.hmac_sha256(l_app.shared_secret, l_json));
  END issue;

  FUNCTION validate(
    p_token           IN VARCHAR2 DEFAULT NULL,
    p_correlation_id  IN VARCHAR2 DEFAULT NULL,
    p_host_session_id IN NUMBER   DEFAULT NULL,
    p_apex_app_id     IN NUMBER   DEFAULT NULL,
    p_app_key         IN VARCHAR2 DEFAULT NULL,
    p_env_code        IN VARCHAR2 DEFAULT NULL,
    p_page_id         IN NUMBER   DEFAULT NULL,
    p_page_name       IN VARCHAR2 DEFAULT NULL,
    p_source_url      IN VARCHAR2 DEFAULT NULL,
    p_adapter_version IN VARCHAR2 DEFAULT NULL) RETURN t_launch IS
    l t_launch;
  BEGIN
    g_reject_reason := NULL; g_reject_code := NULL; g_reject_message := NULL; g_claimed_app_key := NULL;
    l.result_code := 'REJECTED';
    BEGIN
      IF TRIM(p_token) IS NOT NULL THEN
        validate_signed(p_token, p_adapter_version, l);
      ELSE
        validate_shared(p_correlation_id, p_host_session_id, p_apex_app_id, p_app_key, p_env_code,
                        p_page_id, p_page_name, p_source_url, p_adapter_version, l);
      END IF;
    EXCEPTION
      WHEN e_rejected THEN
        NULL;
      WHEN OTHERS THEN
        IF SQLCODE = afh_security_pkg.error_number(afh_security_pkg.c_err_auth_001) THEN
          g_reject_reason := 'SUBJECT_MISSING'; g_reject_code := afh_security_pkg.c_err_auth_001;
          g_reject_message := c_msg_signin;
        ELSE
          RAISE;
        END IF;
    END;
    IF g_reject_reason IS NOT NULL THEN
      l.result_code   := 'REJECTED';
      l.error_code    := g_reject_code;
      l.error_message := g_reject_message;
      l.app_key := NVL(l.app_key, g_claimed_app_key);
      log_rejection(l, p_adapter_version, g_reject_reason);
      RETURN l;
    END IF;
    log_validated(l, p_adapter_version);
    RETURN l;
  END validate;

  -- VALIDATED rows are readable until issued_at + TTL + c_form_minutes (the 120 s budget
  -- is for the handoff; the form has its own window). CONSUMED rows come back with their
  -- ticket so the page can follow the idempotent-retry path.
  -- The handoff row does not persist the host session id. In shared-session mode the host
  -- session IS the current APEX session (check_shared_session enforced the equality at
  -- validation), so restore it here; without it store_capture skipped the server-state read
  -- (DG-04) and every item came back UNAVAILABLE - found 2026-09-06 on ticket FB-2482.
  FUNCTION with_host_session(p_l IN t_launch) RETURN t_launch IS
    l t_launch := p_l;
  BEGIN
    IF l.identity_mode = afh_registry_pkg.c_mode_shared_session AND l.host_session_id IS NULL THEN
      l.host_session_id := apex_application.g_instance;
    END IF;
    RETURN l;
  END with_host_session;

  FUNCTION get_validated(p_correlation_id IN VARCHAR2) RETURN t_launch IS
    l_row     afh_launch_handoffs%ROWTYPE;
    l_cid     VARCHAR2(64 CHAR);
    l_subject VARCHAR2(255 CHAR) := afh_security_pkg.current_subject;
    l_ok      BOOLEAN := FALSE;
  BEGIN
    BEGIN
      l_cid := safe_correlation(p_correlation_id);
      SELECT * INTO l_row FROM afh_launch_handoffs
       WHERE correlation_id = l_cid;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN afh_security_pkg.raise_error(afh_security_pkg.c_err_ctx_001, c_msg_invalid);
    END;
    IF l_row.subject_canonical = l_subject THEN
      IF l_row.result_code = 'VALIDATED' AND l_row.consumed_at IS NULL
         AND SYSTIMESTAMP <= l_row.issued_at + NUMTODSINTERVAL(ttl_seconds + c_form_minutes * 60, 'SECOND') THEN
        l_ok := TRUE;
      ELSIF l_row.result_code = 'CONSUMED' AND l_row.ticket_id IS NOT NULL THEN
        l_ok := TRUE;
      END IF;
    END IF;
    IF NOT l_ok THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_ctx_001, c_msg_invalid);
    END IF;
    RETURN with_host_session(launch_from_row(l_row));
  END get_validated;

  PROCEDURE consume(p_correlation_id IN VARCHAR2, p_ticket_id IN NUMBER) IS
    l_row     afh_launch_handoffs%ROWTYPE;
    l_cid     VARCHAR2(64 CHAR);
    l_subject VARCHAR2(255 CHAR) := afh_security_pkg.current_subject;
  BEGIN
    IF p_ticket_id IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'A ticket is required to consume a launch.');
    END IF;
    BEGIN
      l_cid := safe_correlation(p_correlation_id);
      SELECT * INTO l_row FROM afh_launch_handoffs
       WHERE correlation_id = l_cid FOR UPDATE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN afh_security_pkg.raise_error(afh_security_pkg.c_err_ctx_001, c_msg_invalid);
    END;
    IF l_row.subject_canonical <> l_subject THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_ctx_001, c_msg_invalid);
    END IF;
    IF l_row.result_code = 'CONSUMED' THEN
      IF l_row.ticket_id = p_ticket_id THEN
        RETURN;                                                   -- idempotent
      END IF;
      afh_security_pkg.raise_error(afh_security_pkg.c_err_ctx_001, c_msg_invalid);
    END IF;
    IF l_row.result_code <> 'VALIDATED'
       OR SYSTIMESTAMP > l_row.issued_at + NUMTODSINTERVAL(ttl_seconds + c_form_minutes * 60, 'SECOND') THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_ctx_001, c_msg_invalid);
    END IF;
    UPDATE afh_launch_handoffs
       SET consumed_at = SYSTIMESTAMP, result_code = 'CONSUMED', ticket_id = p_ticket_id
     WHERE launch_handoff_id = l_row.launch_handoff_id;
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_launch, p_entity_id => l_row.launch_handoff_id,
      p_event_code => 'LAUNCH_CONSUMED', p_ticket_id => p_ticket_id,
      p_after_facts => afh_audit_pkg.json_obj(
        apex_t_varchar2('correlation_id', 'ticket_id', 'identity_mode'),
        apex_t_varchar2(l_row.correlation_id, TO_CHAR(p_ticket_id), l_row.identity_mode)),
      p_is_public => 'N', p_correlation_id => l_row.correlation_id);
  END consume;

  FUNCTION ticket_for_correlation(p_correlation_id IN VARCHAR2) RETURN NUMBER IS
    l_ticket_id NUMBER;
    l_cid       VARCHAR2(64 CHAR);
  BEGIN
    l_cid := safe_correlation(p_correlation_id);
    SELECT ticket_id INTO l_ticket_id
      FROM afh_launch_handoffs
     WHERE correlation_id = l_cid
       AND result_code = 'CONSUMED'
       AND subject_canonical = afh_security_pkg.current_subject;
    RETURN l_ticket_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END ticket_for_correlation;

  FUNCTION purge_expired RETURN NUMBER IS
  BEGIN
    DELETE FROM afh_launch_handoffs
     WHERE issued_at < SYSTIMESTAMP - INTERVAL '1' DAY;
    RETURN SQL%ROWCOUNT;
  END purge_expired;

END afh_launch_pkg;
/
