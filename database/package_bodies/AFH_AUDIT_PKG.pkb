CREATE OR REPLACE PACKAGE BODY afh_audit_pkg AS
  -- ---------------------------------------------------------------------------
  -- AFH_AUDIT_PKG body. Spec §12, §20. All writes happen in the caller's
  -- transaction except log_integration_failure (the one documented autonomous
  -- routine). No authorization here: callers already checked.
  -- ---------------------------------------------------------------------------

  g_correlation_id VARCHAR2(64 CHAR);

  c_redacted CONSTANT VARCHAR2(10) := '[redacted]';

  -- Substrings that mark a name as credential-like (matched case-insensitively).
  c_sensitive_tokens CONSTANT apex_t_varchar2 := apex_t_varchar2(
    'password', 'passwd', 'pwd', 'secret', 'token', 'cookie', 'authorization',
    'auth_header', 'session_id', 'sessionid', 'api_key', 'apikey', 'credential',
    'private_key', 'access_key', 'bearer');

  -- ------------------------------------------------------------------ helpers
  -- Subject for the audit row: the trusted session subject, or SYSTEM when the
  -- event is written before identity exists (launch validation, jobs).
  FUNCTION actor_subject RETURN VARCHAR2 IS
  BEGIN
    RETURN afh_security_pkg.current_subject;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = afh_security_pkg.error_number(afh_security_pkg.c_err_auth_001) THEN
        RETURN 'SYSTEM';
      END IF;
      RAISE;
  END actor_subject;

  FUNCTION json_member(p_name IN VARCHAR2, p_value IN VARCHAR2) RETURN VARCHAR2 IS
    l_value VARCHAR2(32767);
  BEGIN
    IF p_value IS NULL THEN
      l_value := 'null';
    ELSIF is_sensitive_name(p_name) THEN
      l_value := '"' || c_redacted || '"';
    ELSE
      l_value := '"' || apex_escape.json(p_value) || '"';
    END IF;
    RETURN '"' || apex_escape.json(p_name) || '":' || l_value;
  END json_member;

  -- ------------------------------------------------------------------ public
  FUNCTION new_correlation_id RETURN VARCHAR2 IS
  BEGIN
    RETURN LOWER(RAWTOHEX(SYS_GUID()));
  END new_correlation_id;

  -- Hyphens and spaces are folded to underscores so header-style names
  -- (Api-Key, Set-Cookie, "private key") match the same tokens.
  FUNCTION is_sensitive_name(p_name IN VARCHAR2) RETURN BOOLEAN IS
    l_name VARCHAR2(4000) := TRANSLATE(LOWER(TRIM(p_name)), '- ', '__');
  BEGIN
    IF l_name IS NULL THEN
      RETURN FALSE;
    END IF;
    FOR i IN 1 .. c_sensitive_tokens.COUNT LOOP
      IF INSTR(l_name, c_sensitive_tokens(i)) > 0 THEN
        RETURN TRUE;
      END IF;
    END LOOP;
    RETURN REGEXP_LIKE(l_name, '(_pwd|_password|_token|_secret)$');
  END is_sensitive_name;

  FUNCTION json_obj(p_names IN apex_t_varchar2, p_values IN apex_t_varchar2) RETURN CLOB IS
    l_clob  CLOB;
    l_count PLS_INTEGER := 0;
  BEGIN
    IF p_names IS NOT NULL AND p_values IS NOT NULL THEN
      l_count := LEAST(p_names.COUNT, p_values.COUNT);
    END IF;
    DBMS_LOB.createtemporary(l_clob, TRUE, DBMS_LOB.call);
    DBMS_LOB.writeappend(l_clob, 1, '{');
    FOR i IN 1 .. l_count LOOP
      IF i > 1 THEN
        DBMS_LOB.writeappend(l_clob, 1, ',');
      END IF;
      DBMS_LOB.append(l_clob, TO_CLOB(json_member(p_names(i), p_values(i))));
    END LOOP;
    DBMS_LOB.writeappend(l_clob, 1, '}');
    RETURN l_clob;
  END json_obj;

  PROCEDURE log_event(
    p_entity_type    IN VARCHAR2,
    p_entity_id      IN NUMBER,
    p_event_code     IN VARCHAR2,
    p_ticket_id      IN NUMBER   DEFAULT NULL,
    p_before_facts   IN CLOB     DEFAULT NULL,
    p_after_facts    IN CLOB     DEFAULT NULL,
    p_summary        IN VARCHAR2 DEFAULT NULL,
    p_is_public      IN VARCHAR2 DEFAULT 'Y',
    p_correlation_id IN VARCHAR2 DEFAULT NULL) IS
    l_subject VARCHAR2(255 CHAR);
    l_user_id NUMBER;
  BEGIN
    IF p_entity_type IS NULL OR p_entity_id IS NULL OR p_event_code IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'An audit event needs an entity type, an entity id, and an event code.');
    END IF;
    l_subject := actor_subject;
    l_user_id := afh_security_pkg.current_user_id;
    INSERT INTO afh_audit_events (
      entity_type, entity_id, ticket_id, event_code, actor_user_id, actor_subject,
      event_at, correlation_id, before_facts, after_facts, summary, is_public)
    VALUES (
      UPPER(p_entity_type), p_entity_id, p_ticket_id, UPPER(p_event_code), l_user_id, l_subject,
      SYSTIMESTAMP, SUBSTR(COALESCE(p_correlation_id, g_correlation_id), 1, 64),
      p_before_facts, p_after_facts, SUBSTR(p_summary, 1, 1000),
      CASE WHEN UPPER(p_is_public) = 'N' THEN 'N' ELSE 'Y' END);
  END log_event;

  PROCEDURE log_integration_event(
    p_event_code      IN VARCHAR2,
    p_result_code     IN VARCHAR2,
    p_app_key         IN VARCHAR2 DEFAULT NULL,
    p_application_id  IN NUMBER   DEFAULT NULL,
    p_environment_id  IN NUMBER   DEFAULT NULL,
    p_correlation_id  IN VARCHAR2 DEFAULT NULL,
    p_adapter_version IN VARCHAR2 DEFAULT NULL,
    p_safe_detail     IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    INSERT INTO afh_integration_events (
      application_id, environment_id, app_key, event_at, event_code, result_code,
      correlation_id, adapter_version, safe_detail)
    VALUES (
      p_application_id, p_environment_id, SUBSTR(p_app_key, 1, 30), SYSTIMESTAMP,
      UPPER(p_event_code), UPPER(p_result_code),
      SUBSTR(COALESCE(p_correlation_id, g_correlation_id), 1, 64),
      SUBSTR(p_adapter_version, 1, 20), SUBSTR(p_safe_detail, 1, 2000));
  END log_integration_event;

  -- The ONE documented autonomous-transaction routine (spec §7.2).
  PROCEDURE log_integration_failure(
    p_event_code      IN VARCHAR2,
    p_app_key         IN VARCHAR2 DEFAULT NULL,
    p_application_id  IN NUMBER   DEFAULT NULL,
    p_environment_id  IN NUMBER   DEFAULT NULL,
    p_correlation_id  IN VARCHAR2 DEFAULT NULL,
    p_adapter_version IN VARCHAR2 DEFAULT NULL,
    p_safe_detail     IN VARCHAR2 DEFAULT NULL) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    log_integration_event(
      p_event_code      => p_event_code,
      p_result_code     => 'FAILED',
      p_app_key         => p_app_key,
      p_application_id  => p_application_id,
      p_environment_id  => p_environment_id,
      p_correlation_id  => p_correlation_id,
      p_adapter_version => p_adapter_version,
      p_safe_detail     => p_safe_detail);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END log_integration_failure;

  PROCEDURE log_denial(
    p_entity_type IN VARCHAR2,
    p_entity_id   IN NUMBER,
    p_ticket_id   IN NUMBER,
    p_summary     IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_subject VARCHAR2(255 CHAR);
    l_user_id NUMBER;
    PROCEDURE ins(p_tid IN NUMBER) IS
    BEGIN
      INSERT INTO afh_audit_events (entity_type, entity_id, ticket_id, event_code, actor_user_id,
                                    actor_subject, event_at, correlation_id, summary, is_public)
      VALUES (p_entity_type, p_entity_id, p_tid, 'RESTRICTED_ACCESS_DENIED', l_user_id,
              l_subject, SYSTIMESTAMP, g_correlation_id, SUBSTR(p_summary, 1, 1000), 'N');
    END;
  BEGIN
    BEGIN
      l_subject := afh_security_pkg.current_subject;
      l_user_id := afh_security_pkg.current_user_id;
    EXCEPTION WHEN OTHERS THEN
      l_subject := 'SYSTEM';
    END;
    BEGIN
      ins(p_ticket_id);
    EXCEPTION WHEN OTHERS THEN   -- FK to an uncommitted ticket or user: keep the event, drop the links
      l_user_id := NULL;
      ins(NULL);
    END;
    COMMIT;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
  END log_denial;

  PROCEDURE set_correlation_id(p_correlation_id IN VARCHAR2) IS
  BEGIN
    g_correlation_id := SUBSTR(p_correlation_id, 1, 64);
  END set_correlation_id;

  FUNCTION get_correlation_id RETURN VARCHAR2 IS
  BEGIN
    RETURN g_correlation_id;
  END get_correlation_id;

END afh_audit_pkg;
/
