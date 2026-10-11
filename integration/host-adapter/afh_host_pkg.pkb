-- AFH_HOST_PKG body. Installed in the HOST schema. Requires EXECUTE on
-- <hub_schema>.afh_launch_pkg (grant_host_schema.sql). Change the DEFINE below when
-- the Hub is installed in a schema other than AFH.
DEFINE hub_schema = AFH

CREATE OR REPLACE PACKAGE BODY afh_host_pkg AS

  c_max_value_len CONSTANT PLS_INTEGER := 4000;
  -- Credential-looking item names are never read (spec §13.3)
  c_credential_re CONSTANT VARCHAR2(200) :=
    '(password|passwd|pwd|token|secret|cookie|authorization|api_?key|credential)';

  -- ------------------------------------------------------------------ helpers
  FUNCTION current_app_user RETURN VARCHAR2 IS
    l_user VARCHAR2(255 CHAR) := SYS_CONTEXT('APEX$SESSION', 'APP_USER');
  BEGIN
    IF l_user IS NULL OR UPPER(l_user) IN ('NOBODY', 'APEX_PUBLIC_USER', 'ANONYMOUS') THEN
      RAISE_APPLICATION_ERROR(-20001, 'AFH-AUTH-001: Sign in to continue.');
    END IF;
    RETURN l_user;
  END current_app_user;

  FUNCTION is_credential_item(p_item_name IN VARCHAR2, p_display_as_code IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN REGEXP_LIKE(p_item_name, c_credential_re, 'i')
        OR INSTR(UPPER(NVL(p_display_as_code, ' ')), 'PASSWORD') > 0;
  END is_credential_item;

  PROCEDURE write_item(p_item_name IN VARCHAR2, p_item_type IN VARCHAR2, p_display_as_code IN VARCHAR2) IS
  BEGIN
    apex_json.open_object;
    apex_json.write('name', p_item_name);
    apex_json.write('type', p_item_type, p_write_null => TRUE);
    IF is_credential_item(p_item_name, p_display_as_code) THEN
      apex_json.write('result', 'EXCLUDED');
    ELSE
      apex_json.write('serverValue', SUBSTR(v(p_item_name), 1, c_max_value_len), p_write_null => TRUE);
      apex_json.write('result', 'AVAILABLE');
    END IF;
    apex_json.close_object;
  END write_item;

  -- ------------------------------------------------------------------ public
  FUNCTION get_launch_token(
    p_app_key    IN VARCHAR2,
    p_env_code   IN VARCHAR2,
    p_page_id    IN NUMBER,
    p_page_name  IN VARCHAR2,
    p_source_url IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN &hub_schema..afh_launch_pkg.issue(
      p_app_key     => p_app_key,
      p_subject     => current_app_user,
      p_env_code    => p_env_code,
      p_apex_app_id => apex_application.g_flow_id,
      p_page_id     => p_page_id,
      p_page_name   => p_page_name,
      p_source_url  => p_source_url);
  END get_launch_token;

  FUNCTION hub_dialog_url(
    p_hub_app_id     IN NUMBER,
    p_mode           IN VARCHAR2 DEFAULT c_mode_signed,
    p_token          IN VARCHAR2 DEFAULT NULL,
    p_correlation_id IN VARCHAR2 DEFAULT NULL,
    p_session_id     IN NUMBER   DEFAULT NULL) RETURN VARCHAR2 IS
    l_base VARCHAR2(200);
  BEGIN
    IF p_hub_app_id IS NULL THEN
      RAISE_APPLICATION_ERROR(-20100, 'AFH-VAL-001: The Hub application id is required.');
    END IF;
    l_base := 'f?p=' || TO_CHAR(p_hub_app_id) || ':' || TO_CHAR(c_hub_launch_page) || ':';
    -- Both values are URL-safe by construction (hex / base64url + '.'); anything else is refused
    -- rather than encoded, so no untrusted text can reach the URL.
    IF UPPER(p_mode) = c_mode_shared THEN
      IF p_correlation_id IS NULL OR NOT REGEXP_LIKE(p_correlation_id, '^[A-Za-z0-9_-]{1,64}$') THEN
        RAISE_APPLICATION_ERROR(-20100, 'AFH-VAL-001: A valid correlation id is required in shared-session mode.');
      END IF;
      RETURN l_base || TO_CHAR(NVL(p_session_id, apex_application.g_instance))
          || '::NO::P20_CORR,P20_HOST_APP,P20_HOST_PAGE:'
          || p_correlation_id || ','
          || TO_CHAR(apex_application.g_flow_id) || ','
          || TO_CHAR(apex_application.g_flow_step_id);
    END IF;
    IF p_token IS NULL OR NOT REGEXP_LIKE(p_token, '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$') THEN
      RAISE_APPLICATION_ERROR(-20100, 'AFH-VAL-001: A valid launch token is required in signed-envelope mode.');
    END IF;
    RETURN l_base || TO_CHAR(NVL(p_session_id, 0)) || '::NO::P20_TOKEN:' || p_token;
  END hub_dialog_url;

  FUNCTION server_items_json(p_page_id IN NUMBER) RETURN CLOB IS
    l_app_id NUMBER := apex_application.g_flow_id;
    l_json   CLOB;
  BEGIN
    apex_json.initialize_clob_output(p_indent => 0);
    apex_json.open_array;
    FOR r IN (SELECT item_name, display_as_code
                FROM apex_application_page_items
               WHERE application_id = l_app_id
                 AND page_id = p_page_id
               ORDER BY item_name) LOOP
      write_item(r.item_name, r.display_as_code, r.display_as_code);
    END LOOP;
    FOR r IN (SELECT item_name
                FROM apex_application_items
               WHERE application_id = l_app_id
               ORDER BY item_name) LOOP
      write_item(r.item_name, 'APPLICATION_ITEM', NULL);
    END LOOP;
    apex_json.close_array;
    l_json := apex_json.get_clob_output;
    apex_json.free_output;
    -- APEX_JSON line breaks are insignificant whitespace; values carry escaped \n.
    RETURN REPLACE(REPLACE(l_json, CHR(13)), CHR(10));
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        apex_json.free_output;
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
      RETURN TO_CLOB('[]');
  END server_items_json;

END afh_host_pkg;
/
