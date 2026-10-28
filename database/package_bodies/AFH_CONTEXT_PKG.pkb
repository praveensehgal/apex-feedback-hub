CREATE OR REPLACE PACKAGE BODY afh_context_pkg AS
  -- ---------------------------------------------------------------------------
  -- AFH_CONTEXT_PKG body. Spec §13.3, §13.4 steps 6-8, §18, WU-05, DG-04.
  -- Contexts and items are append-only: every fact is decided before the INSERT.
  -- ---------------------------------------------------------------------------

  c_chunk             CONSTANT PLS_INTEGER  := 32000;       -- REGEXP_REPLACE works on VARCHAR2 pieces
  c_value_max         CONSTANT PLS_INTEGER  := 4000;
  c_default_max_bytes CONSTANT NUMBER       := 1048576;     -- CAPTURE_MAX_PAYLOAD_BYTES fallback (1 MB)
  c_partial_truncated CONSTANT VARCHAR2(30) := 'PAYLOAD_TRUNCATED';
  c_excl_credential   CONSTANT VARCHAR2(30) := 'CREDENTIAL_FIELD';
  c_srv_available     CONSTANT VARCHAR2(30) := 'AVAILABLE';
  c_srv_unavailable   CONSTANT VARCHAR2(30) := 'UNAVAILABLE';
  c_srv_excluded      CONSTANT VARCHAR2(30) := 'EXCLUDED';
  c_evt_captured      CONSTANT VARCHAR2(30) := 'CONTEXT_CAPTURED';
  c_evt_viewed        CONSTANT VARCHAR2(30) := 'CONTEXT_VIEWED';

  TYPE t_item_rows IS TABLE OF afh_context_items%ROWTYPE INDEX BY PLS_INTEGER;

  -- =========================================================================== lookups
  FUNCTION ctx_row(p_ticket_context_id IN NUMBER) RETURN afh_ticket_contexts%ROWTYPE IS
    l_row afh_ticket_contexts%ROWTYPE;
  BEGIN
    SELECT * INTO l_row FROM afh_ticket_contexts WHERE ticket_context_id = p_ticket_context_id;
    RETURN l_row;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Diagnostic context not found.');
    RETURN l_row;
  END ctx_row;

  FUNCTION ticket_of(p_ticket_id IN NUMBER) RETURN afh_tickets%ROWTYPE IS
    l_row afh_tickets%ROWTYPE;
  BEGIN
    SELECT * INTO l_row FROM afh_tickets WHERE ticket_id = p_ticket_id;
    RETURN l_row;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Ticket not found.');
    RETURN l_row;
  END ticket_of;

  FUNCTION json_text(p_vals IN apex_json.t_values, p_path IN VARCHAR2, p_max IN PLS_INTEGER,
                     p0 IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    RETURN SUBSTR(apex_json.get_varchar2(p_path => p_path, p0 => p0, p_values => p_vals), 1, p_max);
  END json_text;

  -- =========================================================================== sanitation
  FUNCTION is_excluded_item(p_item_name IN VARCHAR2, p_item_type IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    IF INSTR(UPPER(p_item_type), 'PASSWORD') > 0 THEN
      RETURN TRUE;
    END IF;
    IF p_item_name IS NULL THEN
      RETURN FALSE;
    END IF;
    IF afh_audit_pkg.is_sensitive_name(p_item_name) THEN
      RETURN TRUE;
    END IF;
    RETURN REGEXP_LIKE(p_item_name,
      '(COOKIE|AUTHORIZATION|AUTH[_-]?TOKEN|CREDENTIAL|PASSW|SECRET|API[_-]?KEY|BEARER|SESSION[_-]?ID)', 'i');
  END is_excluded_item;

  -- One VARCHAR2 piece: JWT shapes, Bearer tokens, and key/token/secret/password values.
  FUNCTION sanitize_chunk(p_text IN VARCHAR2) RETURN VARCHAR2 IS
    l_text VARCHAR2(32767) := p_text;
  BEGIN
    l_text := REGEXP_REPLACE(l_text, 'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+', '[redacted]');
    l_text := REGEXP_REPLACE(l_text, '(Bearer[[:space:]]+)[A-Za-z0-9._~+/=-]+', '\1[redacted]', 1, 0, 'i');
    l_text := REGEXP_REPLACE(l_text,
      '([A-Za-z0-9_.-]*(key|token|secret|password|passwd|pwd)"?[[:space:]]*[=:][[:space:]]*"?)([^[:space:],;"]+)',
      '\1[redacted]', 1, 0, 'i');
    RETURN l_text;
  END sanitize_chunk;

  FUNCTION sanitize_text(p_text IN CLOB) RETURN CLOB IS
    l_out   CLOB;
    l_len   PLS_INTEGER;
    l_pos   PLS_INTEGER := 1;
    l_take  PLS_INTEGER;
    l_cut   PLS_INTEGER;
    l_piece VARCHAR2(32767);
  BEGIN
    IF p_text IS NULL THEN
      RETURN NULL;
    END IF;
    l_len := DBMS_LOB.getlength(p_text);
    DBMS_LOB.createtemporary(l_out, TRUE, DBMS_LOB.call);
    WHILE l_pos <= l_len LOOP
      l_take  := LEAST(c_chunk, l_len - l_pos + 1);
      l_piece := DBMS_LOB.substr(p_text, l_take, l_pos);
      IF l_pos + l_take <= l_len THEN
        -- not the last piece: cut at a whitespace so a token never straddles two pieces
        l_cut := GREATEST(INSTR(l_piece, ' ', -1), INSTR(l_piece, CHR(10), -1));
        IF l_cut > c_chunk / 2 THEN
          l_piece := SUBSTR(l_piece, 1, l_cut);
          l_take  := l_cut;
        END IF;
      END IF;
      l_piece := sanitize_chunk(l_piece);
      IF l_piece IS NOT NULL THEN
        DBMS_LOB.writeappend(l_out, LENGTH(l_piece), l_piece);
      END IF;
      l_pos := l_pos + l_take;
    END LOOP;
    RETURN l_out;
  END sanitize_text;

  -- =========================================================================== host session reads (DG-04)
  PROCEDURE attach_session(p_app_id IN NUMBER, p_page_id IN NUMBER, p_session_id IN NUMBER) IS
  BEGIN
    IF p_session_id IS NULL THEN
      RETURN;                       -- no Hub session to return to (e.g. a SQL*Plus test run)
    END IF;
    apex_session.attach(p_app_id => p_app_id, p_page_id => p_page_id, p_session_id => p_session_id);
  END attach_session;

  PROCEDURE write_host_item(p_name IN VARCHAR2, p_type IN VARCHAR2) IS
    l_val VARCHAR2(32767);
  BEGIN
    apex_json.open_object;
    apex_json.write('name', p_name);
    apex_json.write('type', p_type);
    IF is_excluded_item(p_name, p_type) THEN
      apex_json.write('result', c_srv_excluded);
    ELSE
      BEGIN
        l_val := v(p_name);
        apex_json.write('serverValue', SUBSTR(l_val, 1, c_value_max));
        apex_json.write('result', c_srv_available);
      EXCEPTION WHEN OTHERS THEN
        apex_json.write('result', c_res_failed);
      END;
    END IF;
    apex_json.close_object;
  END write_host_item;

  PROCEDURE write_host_items(p_host_app_id IN NUMBER, p_page_id IN NUMBER) IS
  BEGIN
    FOR r IN (SELECT item_name, display_as_code AS item_type
                FROM apex_application_page_items
               WHERE application_id = p_host_app_id
                 AND page_id        = p_page_id
              UNION ALL
              SELECT item_name, 'APPLICATION_ITEM'
                FROM apex_application_items
               WHERE application_id = p_host_app_id
               ORDER BY 1) LOOP
      write_host_item(r.item_name, r.item_type);
    END LOOP;
  END write_host_items;

  -- apex_session.attach on an unknown session id raises ORA-20987 AND rolls back the
  -- caller's transaction (verified on 24.2). Check existence first so a failed host
  -- read can never discard the work in flight.
  FUNCTION host_session_exists(p_host_session_id IN NUMBER) RETURN BOOLEAN IS
    l_cnt PLS_INTEGER;
  BEGIN
    IF p_host_session_id IS NULL THEN
      RETURN FALSE;
    END IF;
    SELECT COUNT(*) INTO l_cnt FROM apex_workspace_sessions WHERE apex_session_id = p_host_session_id;
    RETURN l_cnt > 0;
  END host_session_exists;

  FUNCTION read_host_session_items(
    p_host_session_id IN  NUMBER,
    p_host_app_id     IN  NUMBER,
    p_page_id         IN  NUMBER,
    o_result_code     OUT VARCHAR2) RETURN CLOB IS
    l_saved_app  NUMBER := apex_application.g_flow_id;
    l_saved_page NUMBER := apex_application.g_flow_step_id;
    l_saved_sess NUMBER := apex_application.g_instance;
    l_out        CLOB;
  BEGIN
    IF NOT host_session_exists(p_host_session_id) THEN
      o_result_code := c_srv_unavailable;
      RETURN '[]';
    END IF;
    apex_json.initialize_clob_output;
    apex_json.open_array;
    apex_session.attach(p_app_id => p_host_app_id, p_page_id => p_page_id, p_session_id => p_host_session_id);
    write_host_items(p_host_app_id, p_page_id);
    attach_session(l_saved_app, l_saved_page, l_saved_sess);
    apex_json.close_array;
    l_out := apex_json.get_clob_output;
    apex_json.free_output;
    apex_json.initialize_output(p_http_header => FALSE);  -- back to HTP: free_output leaves output detached
    o_result_code := c_res_success;
    RETURN l_out;
  EXCEPTION WHEN OTHERS THEN
    o_result_code := CASE WHEN REGEXP_LIKE(SQLERRM, 'session', 'i') THEN c_srv_unavailable ELSE c_res_failed END;
    BEGIN apex_json.free_output; apex_json.initialize_output(p_http_header => FALSE); EXCEPTION WHEN OTHERS THEN NULL; END;
    BEGIN attach_session(l_saved_app, l_saved_page, l_saved_sess); EXCEPTION WHEN OTHERS THEN NULL; END;
    RETURN '[]';
  END read_host_session_items;

  -- =========================================================================== store: validation
  PROCEDURE check_result_codes(p_capture IN VARCHAR2, p_item IN VARCHAR2,
                               p_screenshot IN VARCHAR2, p_debug IN VARCHAR2) IS
  BEGIN
    IF p_capture NOT IN ('SUCCESS','PARTIAL','UNSUPPORTED','FAILED')
       OR p_item NOT IN ('SUCCESS','PARTIAL','UNSUPPORTED','FAILED')
       OR p_screenshot NOT IN ('SUCCESS','PARTIAL','DENIED','UNSUPPORTED','FAILED')
       OR p_debug NOT IN ('AVAILABLE','DISABLED','UNAVAILABLE','FAILED') THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Capture result codes are not valid.');
    END IF;
  END check_result_codes;

  PROCEDURE assert_can_store(p_ticket IN afh_tickets%ROWTYPE) IS
  BEGIN
    afh_security_pkg.assert_authenticated;
    IF afh_security_pkg.is_reporter(p_ticket.ticket_id)
       OR afh_security_pkg.is_developer(p_ticket.application_id)
       OR afh_security_pkg.is_admin THEN
      RETURN;
    END IF;
    afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002,
      'You are not permitted to add diagnostic context to this ticket.');
  END assert_can_store;

  PROCEDURE parse_meta(p_json IN CLOB, p_label IN VARCHAR2, p_vals IN OUT NOCOPY apex_json.t_values) IS
  BEGIN
    apex_json.parse(p_values => p_vals, p_source => p_json);
  EXCEPTION WHEN OTHERS THEN
    afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, p_label || ' is not valid JSON.');
  END parse_meta;

  PROCEDURE apply_client_meta(p_row IN OUT NOCOPY afh_ticket_contexts%ROWTYPE) IS
    l_vals apex_json.t_values;
  BEGIN
    parse_meta(p_row.client_meta, 'Client metadata', l_vals);
    p_row.browser_name    := json_text(l_vals, 'browser', 100);
    p_row.browser_version := json_text(l_vals, 'browserVersion', 50);
    p_row.os_name         := json_text(l_vals, 'os', 100);
    p_row.device_type     := json_text(l_vals, 'device', 30);
    p_row.viewport        := json_text(l_vals, 'viewport', 30);
    p_row.locale          := json_text(l_vals, 'locale', 20);
    p_row.time_zone       := json_text(l_vals, 'timeZone', 64);
    p_row.apex_version    := json_text(l_vals, 'apexVersion', 20);
    p_row.request_mode    := json_text(l_vals, 'requestMode', 50);
    parse_meta(p_row.source_meta, 'Source metadata', l_vals);
  END apply_client_meta;

  -- =========================================================================== store: items
  FUNCTION values_differ(p_a IN VARCHAR2, p_b IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    IF p_a IS NULL AND p_b IS NULL THEN RETURN FALSE; END IF;
    IF p_a IS NULL OR p_b IS NULL THEN RETURN TRUE; END IF;
    RETURN p_a <> p_b;
  END values_differ;

  FUNCTION server_result(p_declared IN VARCHAR2, p_has_value IN BOOLEAN) RETURN VARCHAR2 IS
  BEGIN
    IF UPPER(p_declared) IN ('AVAILABLE','UNAVAILABLE','FAILED','EXCLUDED') THEN
      RETURN UPPER(p_declared);
    ELSIF p_has_value THEN
      RETURN c_srv_available;
    END IF;
    RETURN c_srv_unavailable;
  END server_result;

  PROCEDURE mark_excluded(p_item IN OUT NOCOPY afh_context_items%ROWTYPE) IS
  BEGIN
    p_item.browser_value       := NULL;
    p_item.server_value        := NULL;
    p_item.server_result_code  := c_srv_excluded;
    p_item.capture_result_code := c_srv_excluded;
    p_item.exclusion_reason    := c_excl_credential;
    p_item.is_changed          := 'N';
  END mark_excluded;

  PROCEDURE read_item_values(p_vals IN apex_json.t_values, p_i IN PLS_INTEGER,
                             p_item IN OUT NOCOPY afh_context_items%ROWTYPE) IS
    l_has_server BOOLEAN;
    l_capture    VARCHAR2(30);
  BEGIN
    p_item.browser_value := json_text(p_vals, '[%d].browserValue', c_value_max, p_i);
    l_has_server := apex_json.does_exist(p_path => '[%d].serverValue', p0 => p_i, p_values => p_vals);
    p_item.server_result_code := server_result(json_text(p_vals, '[%d].serverResult', 30, p_i), l_has_server);
    IF p_item.server_result_code = c_srv_excluded THEN
      mark_excluded(p_item);
      RETURN;
    END IF;
    IF p_item.server_result_code = c_srv_available THEN
      p_item.server_value := json_text(p_vals, '[%d].serverValue', c_value_max, p_i);
    END IF;
    p_item.is_changed := CASE WHEN p_item.server_result_code = c_srv_available
                               AND values_differ(p_item.browser_value, p_item.server_value)
                              THEN 'Y' ELSE 'N' END;
    l_capture := UPPER(json_text(p_vals, '[%d].captureResult', 30, p_i));
    p_item.capture_result_code := CASE WHEN l_capture IN ('SUCCESS','FAILED') THEN l_capture ELSE c_res_success END;
    p_item.failure_reason := json_text(p_vals, '[%d].failureReason', 500, p_i);
  END read_item_values;

  -- Charge the item's stored characters against the remaining budget; past the budget the
  -- item keeps its name and type only (spec §13.4 step 6: partial context, safe parts kept).
  PROCEDURE apply_budget(p_item IN OUT NOCOPY afh_context_items%ROWTYPE,
                         p_budget IN OUT NUMBER, p_truncated IN OUT BOOLEAN) IS
  BEGIN
    p_budget := p_budget - NVL(LENGTH(p_item.browser_value), 0) - NVL(LENGTH(p_item.server_value), 0);
    IF p_budget >= 0 THEN
      RETURN;
    END IF;
    p_truncated                := TRUE;
    p_item.browser_value       := NULL;
    p_item.server_value        := NULL;
    p_item.is_changed          := 'N';
    p_item.capture_result_code := c_res_failed;
    p_item.failure_reason      := c_partial_truncated;
    IF p_item.server_result_code = c_srv_available THEN
      p_item.server_result_code := c_srv_unavailable;
    END IF;
  END apply_budget;

  FUNCTION build_item(p_vals IN apex_json.t_values, p_i IN PLS_INTEGER,
                      p_budget IN OUT NUMBER, p_truncated IN OUT BOOLEAN) RETURN afh_context_items%ROWTYPE IS
    l_item afh_context_items%ROWTYPE;
  BEGIN
    l_item.item_name   := NVL(json_text(p_vals, '[%d].name', 255, p_i), 'ITEM_' || p_i);
    l_item.item_type   := json_text(p_vals, '[%d].type', 100, p_i);
    l_item.display_seq := p_i;
    IF is_excluded_item(l_item.item_name, l_item.item_type) THEN
      mark_excluded(l_item);
      RETURN l_item;
    END IF;
    read_item_values(p_vals, p_i, l_item);
    IF l_item.capture_result_code <> c_srv_excluded THEN
      apply_budget(l_item, p_budget, p_truncated);
    END IF;
    RETURN l_item;
  END build_item;

  FUNCTION build_items(p_items_json IN CLOB, p_budget IN OUT NUMBER,
                       p_truncated IN OUT BOOLEAN) RETURN t_item_rows IS
    l_vals apex_json.t_values;
    l_rows t_item_rows;
    l_n    PLS_INTEGER;
  BEGIN
    IF p_items_json IS NULL OR DBMS_LOB.getlength(p_items_json) = 0 THEN
      RETURN l_rows;
    END IF;
    parse_meta(p_items_json, 'Context items', l_vals);
    l_n := NVL(apex_json.get_count(p_path => '.', p_values => l_vals), 0);
    FOR i IN 1 .. l_n LOOP
      l_rows(i) := build_item(l_vals, i, p_budget, p_truncated);
    END LOOP;
    RETURN l_rows;
  END build_items;

  PROCEDURE insert_items(p_ticket_context_id IN NUMBER, p_rows IN t_item_rows) IS
    l_row afh_context_items%ROWTYPE;
    i     PLS_INTEGER := p_rows.FIRST;
  BEGIN
    WHILE i IS NOT NULL LOOP
      l_row := p_rows(i);
      l_row.ticket_context_id := p_ticket_context_id;
      INSERT INTO afh_context_items VALUES l_row;
      i := p_rows.NEXT(i);
    END LOOP;
  END insert_items;

  -- Sanitized debug text trimmed to the remaining budget (sanitize first, cut second).
  FUNCTION fit_debug(p_text IN CLOB, p_budget IN OUT NUMBER, p_truncated IN OUT BOOLEAN) RETURN CLOB IS
    l_len PLS_INTEGER;
    l_out CLOB;
  BEGIN
    IF p_text IS NULL THEN
      RETURN NULL;
    END IF;
    l_len := DBMS_LOB.getlength(p_text);
    IF l_len <= GREATEST(p_budget, 0) THEN
      p_budget := p_budget - l_len;
      RETURN p_text;
    END IF;
    p_truncated := TRUE;
    IF p_budget <= 0 OR l_len = 0 THEN
      p_budget := 0;
      RETURN NULL;
    END IF;
    DBMS_LOB.createtemporary(l_out, TRUE, DBMS_LOB.call);
    DBMS_LOB.copy(l_out, p_text, p_budget, 1, 1);
    p_budget := 0;
    RETURN l_out;
  END fit_debug;

  PROCEDURE downgrade(p_row IN OUT NOCOPY afh_ticket_contexts%ROWTYPE, p_items_truncated IN BOOLEAN) IS
  BEGIN
    IF INSTR(NVL(p_row.partial_reason, ' '), c_partial_truncated) = 0 THEN
      -- CASE, not NVL2: NVL2 is SQL-only in 19c PL/SQL.
      p_row.partial_reason := SUBSTR(CASE WHEN p_row.partial_reason IS NOT NULL THEN p_row.partial_reason || '; ' END
                                     || c_partial_truncated, 1, 1000);
    END IF;
    IF p_row.capture_result_code = c_res_success THEN
      p_row.capture_result_code := c_res_partial;
    END IF;
    IF p_items_truncated AND p_row.item_result_code = c_res_success THEN
      p_row.item_result_code := c_res_partial;
    END IF;
  END downgrade;

  -- =========================================================================== store: audit
  PROCEDURE audit_capture(p_row IN afh_ticket_contexts%ROWTYPE, p_ticket IN afh_tickets%ROWTYPE) IS
    l_total NUMBER; l_changed NUMBER; l_excluded NUMBER; l_failed NUMBER;
    l_app_key afh_applications.app_key%TYPE;
  BEGIN
    item_counts(p_row.ticket_context_id, l_total, l_changed, l_excluded, l_failed);
    afh_audit_pkg.log_event(
      p_entity_type    => afh_audit_pkg.c_entity_context,
      p_entity_id      => p_row.ticket_context_id,
      p_event_code     => c_evt_captured,
      p_ticket_id      => p_row.ticket_id,
      p_after_facts    => afh_audit_pkg.json_obj(
        apex_t_varchar2('captureResult','itemResult','screenshotResult','debugResult',
                        'itemTotal','itemChanged','itemExcluded','itemFailed','partialReason'),
        apex_t_varchar2(p_row.capture_result_code, p_row.item_result_code, p_row.screenshot_result_code,
                        p_row.debug_result_code, l_total, l_changed, l_excluded, l_failed, p_row.partial_reason)),
      p_summary        => 'Diagnostic context captured (' || p_row.capture_result_code || ')',
      p_is_public      => 'N',
      p_correlation_id => p_row.correlation_id);
    BEGIN
      SELECT app_key INTO l_app_key FROM afh_applications WHERE application_id = p_ticket.application_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN l_app_key := NULL;
    END;
    afh_audit_pkg.log_integration_event(
      p_event_code     => 'CAPTURE',
      p_result_code    => CASE p_row.capture_result_code WHEN c_res_success THEN 'OK'
                                                         WHEN c_res_failed  THEN 'FAILED' ELSE 'PARTIAL' END,
      p_app_key        => l_app_key,
      p_application_id => p_ticket.application_id,
      p_environment_id => p_ticket.environment_id,
      p_correlation_id => p_row.correlation_id,
      p_safe_detail    => 'items=' || p_row.item_result_code || ';screenshot=' || p_row.screenshot_result_code
                          || ';debug=' || p_row.debug_result_code || ';itemTotal=' || l_total
                          || ';excluded=' || l_excluded || ';failed=' || l_failed
                          || CASE WHEN p_row.partial_reason IS NOT NULL THEN ';partial=' || p_row.partial_reason END);
  END audit_capture;

  FUNCTION new_context_row(
    p_ticket_id IN NUMBER, p_correlation_id IN VARCHAR2, p_contract_version IN VARCHAR2,
    p_capture IN VARCHAR2, p_item IN VARCHAR2, p_screenshot IN VARCHAR2, p_debug IN VARCHAR2,
    p_client_meta_json IN CLOB, p_source_meta_json IN CLOB, p_partial_reason IN VARCHAR2)
    RETURN afh_ticket_contexts%ROWTYPE IS
    l_row afh_ticket_contexts%ROWTYPE;
  BEGIN
    check_result_codes(p_capture, p_item, p_screenshot, p_debug);
    l_row.ticket_id              := p_ticket_id;
    l_row.correlation_id         := SUBSTR(p_correlation_id, 1, 64);
    l_row.contract_version       := SUBSTR(p_contract_version, 1, 20);
    l_row.capture_result_code    := p_capture;
    l_row.item_result_code       := p_item;
    l_row.screenshot_result_code := p_screenshot;
    l_row.debug_result_code      := p_debug;
    l_row.captured_at            := SYSTIMESTAMP;
    l_row.client_meta            := NVL(p_client_meta_json, '{}');
    l_row.source_meta            := NVL(p_source_meta_json, '{}');
    l_row.is_restricted          := 'Y';
    l_row.partial_reason         := SUBSTR(p_partial_reason, 1, 1000);
    apply_client_meta(l_row);
    RETURN l_row;
  END new_context_row;

  -- =========================================================================== store: public
  FUNCTION store_context(
    p_ticket_id              IN NUMBER,
    p_correlation_id         IN VARCHAR2,
    p_contract_version       IN VARCHAR2,
    p_capture_result_code    IN VARCHAR2,
    p_item_result_code       IN VARCHAR2,
    p_screenshot_result_code IN VARCHAR2,
    p_debug_result_code      IN VARCHAR2,
    p_client_meta_json       IN CLOB,
    p_source_meta_json       IN CLOB,
    p_items_json             IN CLOB,
    p_debug_payload          IN CLOB     DEFAULT NULL,
    p_partial_reason         IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_ticket     afh_tickets%ROWTYPE;
    l_row        afh_ticket_contexts%ROWTYPE;
    l_items      t_item_rows;
    l_budget     NUMBER;
    l_items_cut  BOOLEAN := FALSE;
    l_debug_cut  BOOLEAN := FALSE;
  BEGIN
    l_ticket := ticket_of(p_ticket_id);
    assert_can_store(l_ticket);
    l_row := new_context_row(p_ticket_id, p_correlation_id, p_contract_version,
                             p_capture_result_code, p_item_result_code, p_screenshot_result_code,
                             p_debug_result_code, p_client_meta_json, p_source_meta_json, p_partial_reason);
    l_budget := afh_security_pkg.config_number('CAPTURE_MAX_PAYLOAD_BYTES', c_default_max_bytes)
                - DBMS_LOB.getlength(l_row.client_meta) - DBMS_LOB.getlength(l_row.source_meta);
    l_items := build_items(p_items_json, l_budget, l_items_cut);
    l_row.sanitized_payload := fit_debug(sanitize_text(p_debug_payload), l_budget, l_debug_cut);
    l_row.debug_payload     := NULL;                 -- the raw payload is never kept
    IF l_items_cut OR l_debug_cut THEN
      downgrade(l_row, l_items_cut);
    END IF;
    INSERT INTO afh_ticket_contexts VALUES l_row RETURNING ticket_context_id INTO l_row.ticket_context_id;
    insert_items(l_row.ticket_context_id, l_items);
    UPDATE afh_tickets
       SET context_result_code = overall_result(l_row.item_result_code, l_row.screenshot_result_code,
                                                l_row.debug_result_code)
     WHERE ticket_id = p_ticket_id;
    audit_capture(l_row, l_ticket);
    RETURN l_row.ticket_context_id;
  END store_context;

  -- Result matrix (spec §13.2 / §21 CTX-002):
  --   items      screenshot          debug                  -> overall
  --   SUCCESS    SUCCESS             AVAILABLE or DISABLED  -> SUCCESS   (DISABLED never downgrades)
  --   FAILED     FAILED or DENIED    any                    -> FAILED    (nothing usable was captured)
  --   FAILED     anything else       any                    -> PARTIAL   (screenshot still usable)
  --   UNSUPPORTED UNSUPPORTED        not AVAILABLE          -> UNSUPPORTED (the host cannot capture)
  --   anything else                                         -> PARTIAL
  FUNCTION overall_result(
    p_item_result_code       IN VARCHAR2,
    p_screenshot_result_code IN VARCHAR2,
    p_debug_result_code      IN VARCHAR2) RETURN VARCHAR2 IS
    l_item VARCHAR2(30) := NVL(UPPER(p_item_result_code), c_res_failed);
    l_shot VARCHAR2(30) := NVL(UPPER(p_screenshot_result_code), c_res_failed);
    l_dbg  VARCHAR2(30) := NVL(UPPER(p_debug_result_code), c_srv_unavailable);
  BEGIN
    IF l_item = c_res_success AND l_shot = c_res_success AND l_dbg IN ('AVAILABLE','DISABLED') THEN
      RETURN c_res_success;
    ELSIF l_item = c_res_failed THEN
      RETURN CASE WHEN l_shot IN (c_res_failed, c_res_denied) THEN c_res_failed ELSE c_res_partial END;
    ELSIF l_item = c_res_unsupported AND l_shot = c_res_unsupported AND l_dbg <> 'AVAILABLE' THEN
      RETURN c_res_unsupported;
    END IF;
    RETURN c_res_partial;
  END overall_result;

  -- =========================================================================== authorized reads
  PROCEDURE audit_view(p_row IN afh_ticket_contexts%ROWTYPE, p_part IN VARCHAR2) IS
  BEGIN
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_context,
      p_entity_id   => p_row.ticket_context_id,
      p_event_code  => c_evt_viewed,
      p_ticket_id   => p_row.ticket_id,
      p_after_facts => afh_audit_pkg.json_obj(apex_t_varchar2('part'), apex_t_varchar2(p_part)),
      p_summary     => 'Diagnostic context viewed (' || p_part || ')',
      p_is_public   => 'N');
  END audit_view;

  PROCEDURE open_context_view(p_ticket_context_id IN NUMBER) IS
    l_row afh_ticket_contexts%ROWTYPE := ctx_row(p_ticket_context_id);
  BEGIN
    afh_security_pkg.assert_can_view_restricted(l_row.ticket_id);
    audit_view(l_row, 'ITEMS');
  END open_context_view;

  -- Pipelined: runs inside SQL, so it cannot write audit rows (ORA-14551). The page
  -- process calls open_context_view first; this function only re-checks the permission.
  FUNCTION get_items(p_ticket_context_id IN NUMBER) RETURN t_item_tab PIPELINED IS
    l_row  afh_ticket_contexts%ROWTYPE;
    l_item t_item;
  BEGIN
    IF p_ticket_context_id IS NULL THEN
      RETURN;   -- no capture for this ticket: an empty set, not an error (page 10 region)
    END IF;
    l_row := ctx_row(p_ticket_context_id);
    IF NOT afh_security_pkg.can_view_restricted(l_row.ticket_id) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002,
        'You are not permitted to view diagnostic context for this ticket.');
    END IF;
    FOR r IN (SELECT context_item_id, item_name, item_type, browser_value, server_value,
                     server_result_code, is_changed, capture_result_code, failure_reason, exclusion_reason
                FROM afh_context_items
               WHERE ticket_context_id = p_ticket_context_id
               ORDER BY display_seq, context_item_id) LOOP
      l_item.context_item_id     := r.context_item_id;
      l_item.item_name           := r.item_name;
      l_item.item_type           := r.item_type;
      l_item.browser_value       := r.browser_value;
      l_item.server_value        := r.server_value;
      l_item.server_result_code  := r.server_result_code;
      l_item.is_changed          := r.is_changed;
      l_item.capture_result_code := r.capture_result_code;
      l_item.failure_reason      := r.failure_reason;
      l_item.exclusion_reason    := r.exclusion_reason;
      PIPE ROW (l_item);
    END LOOP;
    RETURN;
  END get_items;

  FUNCTION get_payload(p_ticket_context_id IN NUMBER, p_part IN VARCHAR2) RETURN CLOB IS
    l_row  afh_ticket_contexts%ROWTYPE;
    l_part VARCHAR2(30) := UPPER(TRIM(p_part));
  BEGIN
    IF l_part NOT IN ('SOURCE_META','CLIENT_META','DEBUG','SANITIZED') THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown context part requested.');
    END IF;
    l_row := ctx_row(p_ticket_context_id);
    afh_security_pkg.assert_can_view_restricted(l_row.ticket_id);
    audit_view(l_row, l_part);
    RETURN CASE l_part
             WHEN 'SOURCE_META' THEN l_row.source_meta
             WHEN 'CLIENT_META' THEN l_row.client_meta
             WHEN 'DEBUG'       THEN NVL(l_row.debug_payload, l_row.sanitized_payload)  -- raw is never stored
             ELSE l_row.sanitized_payload
           END;
  END get_payload;

  FUNCTION latest_context_id(p_ticket_id IN NUMBER) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    SELECT MAX(ticket_context_id) KEEP (DENSE_RANK LAST ORDER BY captured_at, ticket_context_id)
      INTO l_id
      FROM afh_ticket_contexts
     WHERE ticket_id = p_ticket_id;
    RETURN l_id;
  END latest_context_id;

  PROCEDURE item_counts(
    p_ticket_context_id IN  NUMBER,
    o_total             OUT NUMBER,
    o_changed           OUT NUMBER,
    o_excluded          OUT NUMBER,
    o_failed            OUT NUMBER) IS
  BEGIN
    SELECT COUNT(*),
           COUNT(CASE WHEN is_changed = 'Y' THEN 1 END),
           COUNT(CASE WHEN capture_result_code = c_srv_excluded THEN 1 END),
           COUNT(CASE WHEN capture_result_code = c_res_failed THEN 1 END)
      INTO o_total, o_changed, o_excluded, o_failed
      FROM afh_context_items
     WHERE ticket_context_id = p_ticket_context_id;
  END item_counts;
END afh_context_pkg;
/
