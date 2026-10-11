CREATE OR REPLACE PACKAGE BODY afh_registry_pkg AS
  -- ---------------------------------------------------------------------------
  -- AFH_REGISTRY_PKG body — applications, environments, source-URL policy,
  -- adapter versions and lookups. Routing rules and releases are implemented in
  -- AFH_REGISTRY_INT_PKG (private helper, keeps this file under 800 lines); the
  -- public contract and its documentation stay in this package's spec.
  -- The shared secret is never written to an audit fact or returned by any
  -- subprogram other than register_application / rotate_secret (base64url, once).
  -- ---------------------------------------------------------------------------

  c_evt_app_registered  CONSTANT VARCHAR2(30) := 'APPLICATION_REGISTERED';
  c_evt_app_updated     CONSTANT VARCHAR2(30) := 'APPLICATION_UPDATED';
  c_evt_app_activated   CONSTANT VARCHAR2(30) := 'APPLICATION_ACTIVATED';
  c_evt_app_deactivated CONSTANT VARCHAR2(30) := 'APPLICATION_DEACTIVATED';
  c_evt_secret_rotated  CONSTANT VARCHAR2(30) := 'SECRET_ROTATED';
  c_evt_env_added       CONSTANT VARCHAR2(30) := 'ENVIRONMENT_ADDED';
  c_evt_env_updated     CONSTANT VARCHAR2(30) := 'ENVIRONMENT_UPDATED';
  c_evt_env_activated   CONSTANT VARCHAR2(30) := 'ENVIRONMENT_ACTIVATED';
  c_evt_env_deactivated CONSTANT VARCHAR2(30) := 'ENVIRONMENT_DEACTIVATED';

  -- ================================================================= private helpers
  PROCEDURE assert_identity_mode(p_mode IN VARCHAR2) IS
  BEGIN
    IF p_mode IS NULL OR p_mode NOT IN (c_mode_shared_session, c_mode_signed_envelope) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'Identity mode must be SHARED_SESSION or SIGNED_ENVELOPE.');
    END IF;
  END assert_identity_mode;

  -- Audit facts for an application. shared_secret is deliberately never included.
  FUNCTION app_facts(p_row IN afh_applications%ROWTYPE) RETURN CLOB IS
  BEGIN
    RETURN afh_audit_pkg.json_obj(
      apex_t_varchar2('app_key', 'apex_app_id', 'display_name', 'owner_user_id',
                      'identity_mode', 'min_adapter_version', 'is_active', 'description'),
      apex_t_varchar2(p_row.app_key, TO_CHAR(p_row.apex_app_id), p_row.display_name,
                      TO_CHAR(p_row.owner_user_id), p_row.identity_mode,
                      p_row.min_adapter_version, p_row.is_active, p_row.description));
  END app_facts;

  FUNCTION env_facts(p_row IN afh_environments%ROWTYPE) RETURN CLOB IS
  BEGIN
    RETURN afh_audit_pkg.json_obj(
      apex_t_varchar2('application_id', 'env_code', 'label', 'source_identifier',
                      'base_url_pattern', 'app_version', 'display_seq', 'is_active'),
      apex_t_varchar2(TO_CHAR(p_row.application_id), p_row.env_code, p_row.label,
                      p_row.source_identifier, p_row.base_url_pattern, p_row.app_version,
                      TO_CHAR(p_row.display_seq), p_row.is_active));
  END env_facts;

  PROCEDURE audit_app(p_application_id IN NUMBER, p_event_code IN VARCHAR2,
                      p_before IN CLOB, p_after IN CLOB, p_summary IN VARCHAR2) IS
  BEGIN
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_application,
      p_entity_id    => p_application_id,
      p_event_code   => p_event_code,
      p_before_facts => p_before,
      p_after_facts  => p_after,
      p_summary      => p_summary);
  END audit_app;

  PROCEDURE audit_env(p_environment_id IN NUMBER, p_event_code IN VARCHAR2,
                      p_before IN CLOB, p_after IN CLOB, p_summary IN VARCHAR2) IS
  BEGIN
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_environment,
      p_entity_id    => p_environment_id,
      p_event_code   => p_event_code,
      p_before_facts => p_before,
      p_after_facts  => p_after,
      p_summary      => p_summary);
  END audit_env;

  -- Escape LIKE metacharacters other than '%' so that '_' in a pattern is literal.
  FUNCTION like_pattern(p_pattern IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REPLACE(REPLACE(p_pattern, '\', '\\'), '_', '\_');
  END like_pattern;

  -- Numeric value of the n-th dotted part of a version; missing or non-numeric = 0.
  FUNCTION version_part(p_version IN VARCHAR2, p_idx IN PLS_INTEGER) RETURN NUMBER IS
    l_part VARCHAR2(100) := REGEXP_SUBSTR(p_version, '[^.]+', 1, p_idx);
  BEGIN
    IF l_part IS NULL OR NOT REGEXP_LIKE(l_part, '^[0-9]+$') THEN
      RETURN 0;
    END IF;
    RETURN TO_NUMBER(l_part);
  END version_part;

  -- ================================================================= applications (admin)
  FUNCTION register_application(
    p_app_key         IN  VARCHAR2,
    p_apex_app_id     IN  NUMBER,
    p_display_name    IN  VARCHAR2,
    p_owner_user_id   IN  NUMBER,
    p_identity_mode   IN  VARCHAR2,
    p_description     IN  VARCHAR2,
    o_secret_b64url   OUT VARCHAR2) RETURN NUMBER IS
    l_key    afh_applications.app_key%TYPE       := UPPER(TRIM(p_app_key));
    l_mode   afh_applications.identity_mode%TYPE := UPPER(TRIM(p_identity_mode));
    l_secret RAW(32);
    l_id     NUMBER;
    l_row    afh_applications%ROWTYPE;
  BEGIN
    afh_security_pkg.assert_admin;
    afh_registry_int_pkg.assert_code(l_key, 'Application key');
    assert_identity_mode(l_mode);
    afh_registry_int_pkg.assert_not_null(TO_CHAR(p_apex_app_id), 'APEX application ID');
    afh_registry_int_pkg.assert_not_null(p_display_name, 'Display name');
    afh_registry_int_pkg.assert_user_exists(p_owner_user_id, 'Owner');
    l_secret := afh_security_pkg.new_secret;
    BEGIN
      INSERT INTO afh_applications (app_key, apex_app_id, display_name, owner_user_id,
                                    identity_mode, shared_secret, description, is_active)
      VALUES (l_key, p_apex_app_id, TRIM(p_display_name), p_owner_user_id,
              l_mode, l_secret, p_description, 'Y')
      RETURNING application_id INTO l_id;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
          'An application with that key or APEX application ID is already registered.');
    END;
    o_secret_b64url := afh_security_pkg.b64url_encode(l_secret);
    l_row := afh_registry_int_pkg.app_row(l_id);
    audit_app(l_id, c_evt_app_registered, NULL, app_facts(l_row),
              'Application ' || l_key || ' registered');
    RETURN l_id;
  END register_application;

  PROCEDURE update_application(
    p_application_id  IN NUMBER,
    p_display_name    IN VARCHAR2,
    p_owner_user_id   IN NUMBER,
    p_identity_mode   IN VARCHAR2,
    p_description     IN VARCHAR2,
    p_min_adapter_version IN VARCHAR2) IS
    l_old  afh_applications%ROWTYPE;
    l_new  afh_applications%ROWTYPE;
    l_mode afh_applications.identity_mode%TYPE := UPPER(TRIM(p_identity_mode));
  BEGIN
    afh_security_pkg.assert_admin;
    l_old := afh_registry_int_pkg.app_row(p_application_id, 'Y');
    assert_identity_mode(l_mode);
    afh_registry_int_pkg.assert_not_null(p_display_name, 'Display name');
    afh_registry_int_pkg.assert_user_exists(p_owner_user_id, 'Owner');
    UPDATE afh_applications
       SET display_name        = TRIM(p_display_name),
           owner_user_id       = p_owner_user_id,
           identity_mode       = l_mode,
           description         = p_description,
           min_adapter_version = TRIM(p_min_adapter_version)
     WHERE application_id = p_application_id;
    l_new := afh_registry_int_pkg.app_row(p_application_id);
    audit_app(p_application_id, c_evt_app_updated, app_facts(l_old), app_facts(l_new),
              'Application ' || l_old.app_key || ' updated');
  END update_application;

  PROCEDURE set_application_active(p_application_id IN NUMBER, p_is_active IN VARCHAR2) IS
    l_old  afh_applications%ROWTYPE;
    l_flag VARCHAR2(1) := UPPER(TRIM(p_is_active));
  BEGIN
    afh_security_pkg.assert_admin;
    afh_registry_int_pkg.assert_yn(l_flag, 'Active flag');
    l_old := afh_registry_int_pkg.app_row(p_application_id, 'Y');
    IF l_old.is_active = l_flag THEN
      RETURN;  -- no material change, no audit
    END IF;
    UPDATE afh_applications SET is_active = l_flag WHERE application_id = p_application_id;
    audit_app(p_application_id,
              CASE l_flag WHEN 'Y' THEN c_evt_app_activated ELSE c_evt_app_deactivated END,
              afh_registry_int_pkg.yn_facts(l_old.is_active), afh_registry_int_pkg.yn_facts(l_flag),
              'Application ' || l_old.app_key || CASE l_flag WHEN 'Y' THEN ' activated' ELSE ' deactivated' END);
  END set_application_active;

  FUNCTION rotate_secret(p_application_id IN NUMBER) RETURN VARCHAR2 IS
    l_row    afh_applications%ROWTYPE;
    l_secret RAW(32);
  BEGIN
    afh_security_pkg.assert_admin;
    l_row := afh_registry_int_pkg.app_row(p_application_id, 'Y');
    l_secret := afh_security_pkg.new_secret;
    UPDATE afh_applications SET shared_secret = l_secret WHERE application_id = p_application_id;
    audit_app(p_application_id, c_evt_secret_rotated, NULL,
              afh_audit_pkg.json_obj(apex_t_varchar2('app_key'), apex_t_varchar2(l_row.app_key)),
              'Shared secret rotated for ' || l_row.app_key);
    RETURN afh_security_pkg.b64url_encode(l_secret);
  END rotate_secret;

  PROCEDURE record_adapter_version(p_application_id IN NUMBER, p_adapter_version IN VARCHAR2) IS
    l_version afh_applications.adapter_version%TYPE := SUBSTR(TRIM(p_adapter_version), 1, 20);
  BEGIN
    IF l_version IS NULL THEN
      RETURN;
    END IF;
    UPDATE afh_applications
       SET adapter_version = l_version
     WHERE application_id = p_application_id
       AND (adapter_version IS NULL OR adapter_version <> l_version);
  END record_adapter_version;

  -- ================================================================= lookups
  FUNCTION find_application_id(p_app_key IN VARCHAR2, p_include_inactive IN VARCHAR2) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    SELECT application_id INTO l_id
      FROM afh_applications
     WHERE app_key = UPPER(TRIM(p_app_key))
       AND (is_active = 'Y' OR NVL(UPPER(p_include_inactive), 'N') = 'Y');
    RETURN l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END find_application_id;

  FUNCTION find_application_id_by_apex(p_apex_app_id IN NUMBER, p_include_inactive IN VARCHAR2) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    SELECT application_id INTO l_id
      FROM afh_applications
     WHERE apex_app_id = p_apex_app_id
       AND (is_active = 'Y' OR NVL(UPPER(p_include_inactive), 'N') = 'Y');
    RETURN l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END find_application_id_by_apex;

  FUNCTION application_name(p_application_id IN NUMBER) RETURN VARCHAR2 IS
    l_name afh_applications.display_name%TYPE;
  BEGIN
    SELECT display_name INTO l_name FROM afh_applications WHERE application_id = p_application_id;
    RETURN l_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END application_name;

  FUNCTION identity_mode(p_application_id IN NUMBER) RETURN VARCHAR2 IS
    l_mode afh_applications.identity_mode%TYPE;
  BEGIN
    SELECT identity_mode INTO l_mode FROM afh_applications WHERE application_id = p_application_id;
    RETURN l_mode;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END identity_mode;

  -- ================================================================= environments (admin)
  FUNCTION add_environment(
    p_application_id    IN NUMBER,
    p_env_code          IN VARCHAR2,
    p_label             IN VARCHAR2,
    p_source_identifier IN VARCHAR2,
    p_base_url_pattern  IN VARCHAR2,
    p_app_version       IN VARCHAR2,
    p_display_seq       IN NUMBER) RETURN NUMBER IS
    l_code afh_environments.env_code%TYPE := UPPER(TRIM(p_env_code));
    l_app  afh_applications%ROWTYPE;
    l_row  afh_environments%ROWTYPE;
    l_id   NUMBER;
  BEGIN
    afh_security_pkg.assert_admin;
    l_app := afh_registry_int_pkg.app_row(p_application_id);
    afh_registry_int_pkg.assert_code(l_code, 'Environment code');
    afh_registry_int_pkg.assert_not_null(p_label, 'Label');
    BEGIN
      INSERT INTO afh_environments (application_id, env_code, label, source_identifier,
                                    base_url_pattern, app_version, display_seq, is_active)
      VALUES (p_application_id, l_code, TRIM(p_label), TRIM(p_source_identifier),
              TRIM(p_base_url_pattern), TRIM(p_app_version), NVL(p_display_seq, 10), 'Y')
      RETURNING environment_id INTO l_id;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
          'Environment code ' || l_code || ' already exists for this application.');
    END;
    l_row := afh_registry_int_pkg.env_row(l_id);
    audit_env(l_id, c_evt_env_added, NULL, env_facts(l_row),
              'Environment ' || l_code || ' added to ' || l_app.app_key);
    RETURN l_id;
  END add_environment;

  PROCEDURE update_environment(
    p_environment_id    IN NUMBER,
    p_label             IN VARCHAR2,
    p_source_identifier IN VARCHAR2,
    p_base_url_pattern  IN VARCHAR2,
    p_app_version       IN VARCHAR2,
    p_display_seq       IN NUMBER) IS
    l_old afh_environments%ROWTYPE;
    l_new afh_environments%ROWTYPE;
  BEGIN
    afh_security_pkg.assert_admin;
    l_old := afh_registry_int_pkg.env_row(p_environment_id, 'Y');
    afh_registry_int_pkg.assert_not_null(p_label, 'Label');
    UPDATE afh_environments
       SET label             = TRIM(p_label),
           source_identifier = TRIM(p_source_identifier),
           base_url_pattern  = TRIM(p_base_url_pattern),
           app_version       = TRIM(p_app_version),
           display_seq       = NVL(p_display_seq, 10)
     WHERE environment_id = p_environment_id;
    l_new := afh_registry_int_pkg.env_row(p_environment_id);
    audit_env(p_environment_id, c_evt_env_updated, env_facts(l_old), env_facts(l_new),
              'Environment ' || l_old.env_code || ' updated');
  END update_environment;

  PROCEDURE set_environment_active(p_environment_id IN NUMBER, p_is_active IN VARCHAR2) IS
    l_old  afh_environments%ROWTYPE;
    l_flag VARCHAR2(1) := UPPER(TRIM(p_is_active));
  BEGIN
    afh_security_pkg.assert_admin;
    afh_registry_int_pkg.assert_yn(l_flag, 'Active flag');
    l_old := afh_registry_int_pkg.env_row(p_environment_id, 'Y');
    IF l_old.is_active = l_flag THEN
      RETURN;
    END IF;
    UPDATE afh_environments SET is_active = l_flag WHERE environment_id = p_environment_id;
    audit_env(p_environment_id,
              CASE l_flag WHEN 'Y' THEN c_evt_env_activated ELSE c_evt_env_deactivated END,
              afh_registry_int_pkg.yn_facts(l_old.is_active), afh_registry_int_pkg.yn_facts(l_flag),
              'Environment ' || l_old.env_code || CASE l_flag WHEN 'Y' THEN ' activated' ELSE ' deactivated' END);
  END set_environment_active;

  FUNCTION find_environment_id(p_application_id IN NUMBER, p_env_code IN VARCHAR2, p_include_inactive IN VARCHAR2) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    SELECT environment_id INTO l_id
      FROM afh_environments
     WHERE application_id = p_application_id
       AND env_code = UPPER(TRIM(p_env_code))
       AND (is_active = 'Y' OR NVL(UPPER(p_include_inactive), 'N') = 'Y');
    RETURN l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END find_environment_id;

  -- ================================================================= source-URL policy
  -- Returns scheme://host[:port][/path][?query] with control characters, userinfo and
  -- the fragment removed. NULL for anything that is not an absolute http/https URL
  -- (javascript:, data:, ftp:, relative paths, blank input).
  FUNCTION sanitize_url(p_url IN VARCHAR2) RETURN VARCHAR2 IS
    l_url    VARCHAR2(4000);
    l_scheme VARCHAR2(10);
    l_rest   VARCHAR2(4000);
    l_auth   VARCHAR2(4000);
    l_tail   VARCHAR2(4000);
    l_pos    PLS_INTEGER;
  BEGIN
    l_url := TRIM(REGEXP_REPLACE(p_url, '[[:cntrl:]]', ''));
    IF l_url IS NULL OR NOT REGEXP_LIKE(l_url, '^https?://', 'i') THEN
      RETURN NULL;
    END IF;
    l_pos := INSTR(l_url, '#');
    IF l_pos > 0 THEN
      l_url := SUBSTR(l_url, 1, l_pos - 1);
    END IF;
    l_pos    := INSTR(l_url, '://');
    l_scheme := LOWER(SUBSTR(l_url, 1, l_pos - 1));
    l_rest   := SUBSTR(l_url, l_pos + 3);
    l_pos    := REGEXP_INSTR(l_rest, '[/?]');
    IF l_pos = 0 THEN
      l_auth := l_rest;
    ELSE
      l_auth := SUBSTR(l_rest, 1, l_pos - 1);
      l_tail := SUBSTR(l_rest, l_pos);
    END IF;
    l_pos := INSTR(l_auth, '@', -1);
    IF l_pos > 0 THEN
      l_auth := SUBSTR(l_auth, l_pos + 1);  -- drop user:password@
    END IF;
    IF l_auth IS NULL THEN
      RETURN NULL;  -- no host
    END IF;
    RETURN SUBSTR(l_scheme || '://' || LOWER(l_auth) || l_tail, 1, 2000);
  END sanitize_url;

  FUNCTION source_url_allowed(p_environment_id IN NUMBER, p_url IN VARCHAR2) RETURN BOOLEAN IS
    l_active  afh_environments.is_active%TYPE;
    l_pattern afh_environments.base_url_pattern%TYPE;
    l_url     VARCHAR2(2000);
  BEGIN
    BEGIN
      SELECT is_active, base_url_pattern INTO l_active, l_pattern
        FROM afh_environments WHERE environment_id = p_environment_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN RETURN FALSE;
    END;
    IF l_active <> 'Y' THEN
      RETURN FALSE;
    END IF;
    l_url := sanitize_url(p_url);
    IF l_url IS NULL THEN
      RETURN FALSE;
    END IF;
    IF l_pattern IS NULL THEN
      RETURN TRUE;
    END IF;
    RETURN UPPER(l_url) LIKE UPPER(like_pattern(TRIM(l_pattern))) ESCAPE '\';
  END source_url_allowed;

  -- ================================================================= adapter versions
  FUNCTION version_compare(p_a IN VARCHAR2, p_b IN VARCHAR2) RETURN PLS_INTEGER IS
    l_a     VARCHAR2(100) := TRIM(p_a);
    l_b     VARCHAR2(100) := TRIM(p_b);
    l_parts PLS_INTEGER;
    l_va    NUMBER;
    l_vb    NUMBER;
  BEGIN
    l_parts := GREATEST(NVL(REGEXP_COUNT(l_a, '[^.]+'), 0), NVL(REGEXP_COUNT(l_b, '[^.]+'), 0));
    FOR i IN 1 .. l_parts LOOP
      l_va := version_part(l_a, i);
      l_vb := version_part(l_b, i);
      IF l_va < l_vb THEN
        RETURN -1;
      ELSIF l_va > l_vb THEN
        RETURN 1;
      END IF;
    END LOOP;
    RETURN 0;
  END version_compare;

  FUNCTION is_adapter_supported(p_application_id IN NUMBER, p_adapter_version IN VARCHAR2) RETURN BOOLEAN IS
    l_min afh_applications.min_adapter_version%TYPE;
  BEGIN
    BEGIN
      SELECT min_adapter_version INTO l_min FROM afh_applications WHERE application_id = p_application_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN l_min := NULL;
    END;
    l_min := NVL(l_min, afh_security_pkg.config_value('MIN_ADAPTER_VERSION'));
    IF l_min IS NULL THEN
      RETURN TRUE;
    END IF;
    IF TRIM(p_adapter_version) IS NULL THEN
      RETURN FALSE;
    END IF;
    RETURN version_compare(p_adapter_version, l_min) >= 0;
  END is_adapter_supported;

  -- ================================================================= routing (delegated)
  FUNCTION add_routing_rule(
    p_application_id   IN NUMBER,
    p_page_id          IN NUMBER,
    p_category_id      IN NUMBER,
    p_environment_id   IN NUMBER,
    p_type_code        IN VARCHAR2,
    p_assignee_user_id IN NUMBER,
    p_owner_user_id    IN NUMBER,
    p_priority_order   IN NUMBER,
    p_description      IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN afh_registry_int_pkg.add_routing_rule(
      p_application_id, p_page_id, p_category_id, p_environment_id, p_type_code,
      p_assignee_user_id, p_owner_user_id, p_priority_order, p_description);
  END add_routing_rule;

  PROCEDURE update_routing_rule(
    p_routing_rule_id  IN NUMBER,
    p_page_id          IN NUMBER,
    p_category_id      IN NUMBER,
    p_environment_id   IN NUMBER,
    p_type_code        IN VARCHAR2,
    p_assignee_user_id IN NUMBER,
    p_owner_user_id    IN NUMBER,
    p_priority_order   IN NUMBER,
    p_description      IN VARCHAR2) IS
  BEGIN
    afh_registry_int_pkg.update_routing_rule(
      p_routing_rule_id, p_page_id, p_category_id, p_environment_id, p_type_code,
      p_assignee_user_id, p_owner_user_id, p_priority_order, p_description);
  END update_routing_rule;

  PROCEDURE set_routing_rule_active(p_routing_rule_id IN NUMBER, p_is_active IN VARCHAR2) IS
  BEGIN
    afh_registry_int_pkg.set_routing_rule_active(p_routing_rule_id, p_is_active);
  END set_routing_rule_active;

  PROCEDURE delete_routing_rule(p_routing_rule_id IN NUMBER) IS
  BEGIN
    afh_registry_int_pkg.delete_routing_rule(p_routing_rule_id);
  END delete_routing_rule;

  PROCEDURE resolve_route(
    p_application_id   IN  NUMBER,
    p_page_id          IN  NUMBER,
    p_category_id      IN  NUMBER,
    p_environment_id   IN  NUMBER,
    p_type_code        IN  VARCHAR2,
    o_assignee_user_id OUT NUMBER,
    o_owner_user_id    OUT NUMBER,
    o_routing_rule_id  OUT NUMBER) IS
  BEGIN
    afh_registry_int_pkg.resolve_route(
      p_application_id, p_page_id, p_category_id, p_environment_id, p_type_code,
      o_assignee_user_id, o_owner_user_id, o_routing_rule_id);
  END resolve_route;

  -- ================================================================= releases (delegated)
  FUNCTION add_release(
    p_application_id IN NUMBER,
    p_release_code   IN VARCHAR2,
    p_label          IN VARCHAR2,
    p_target_date    IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_notes          IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN afh_registry_int_pkg.add_release(p_application_id, p_release_code, p_label, p_target_date, p_notes);
  END add_release;

  PROCEDURE update_release(
    p_release_id   IN NUMBER,
    p_label        IN VARCHAR2,
    p_target_date  IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_state_code   IN VARCHAR2,
    p_notes        IN VARCHAR2) IS
  BEGIN
    afh_registry_int_pkg.update_release(p_release_id, p_label, p_target_date, p_state_code, p_notes);
  END update_release;

  FUNCTION unresolved_ticket_count(p_release_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN afh_registry_int_pkg.unresolved_ticket_count(p_release_id);
  END unresolved_ticket_count;

  PROCEDURE complete_release(p_release_id IN NUMBER, p_force IN VARCHAR2) IS
  BEGIN
    afh_registry_int_pkg.complete_release(p_release_id, p_force);
  END complete_release;
END afh_registry_pkg;
/
