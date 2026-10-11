CREATE OR REPLACE PACKAGE BODY afh_security_int_pkg AS
  -- ---------------------------------------------------------------------------
  -- Administrative mutations behind AFH_SECURITY_PKG. Authorization and error
  -- raising are delegated back to AFH_SECURITY_PKG so role logic stays in one
  -- place. No COMMIT; the caller controls the transaction.
  -- ---------------------------------------------------------------------------

  c_ts_format CONSTANT VARCHAR2(40) := 'YYYY-MM-DD"T"HH24:MI:SS';

  -- =========================================================== configuration
  PROCEDURE validate_config_value(p_key IN VARCHAR2, p_data_type IN VARCHAR2, p_value IN VARCHAR2) IS
    l_num NUMBER;
  BEGIN
    IF p_value IS NULL THEN
      RETURN;
    END IF;
    CASE p_data_type
      WHEN 'NUMBER' THEN
        BEGIN
          l_num := TO_NUMBER(p_value);
        EXCEPTION
          WHEN VALUE_ERROR OR INVALID_NUMBER THEN
            afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, p_key || ' must be a number.');
        END;
      WHEN 'YN' THEN
        IF p_value NOT IN ('Y', 'N') THEN
          afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, p_key || ' must be Y or N.');
        END IF;
      WHEN 'COLOR' THEN
        IF NOT afh_theme_pkg.is_valid_value('COLOR', p_value) THEN
          afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
            p_key || ' must be a hex color such as #1F4E79.');
        END IF;
      WHEN 'LENGTH' THEN
        IF NOT afh_theme_pkg.is_valid_value('LENGTH', p_value) THEN
          afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
            p_key || ' must be a length such as 6px, 0.5rem or 1em.');
        END IF;
      WHEN 'FONT' THEN
        IF NOT afh_theme_pkg.is_valid_value('FONT', p_value) THEN
          afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
            p_key || ' must be a font stack of installed font names.');
        END IF;
      ELSE
        -- TEXT, URL and LIST are unvalidated free text. They must never be rendered into
        -- markup or a stylesheet; only COLOR, LENGTH and FONT may reach a <style> element.
        -- See docs/decisions/007 and afh_theme_pkg.style_block.
        NULL;
    END CASE;
  END validate_config_value;

  FUNCTION config_facts(p_key IN VARCHAR2, p_value IN VARCHAR2, p_is_secret IN VARCHAR2) RETURN CLOB IS
  BEGIN
    RETURN afh_audit_pkg.json_obj(
      apex_t_varchar2('config_key', 'value'),
      apex_t_varchar2(p_key, CASE WHEN p_is_secret = 'Y' AND p_value IS NOT NULL THEN '[redacted]' ELSE p_value END));
  END config_facts;

  PROCEDURE set_config(p_key IN VARCHAR2, p_value IN VARCHAR2) IS
    l_key VARCHAR2(30 CHAR) := UPPER(TRIM(p_key));
    l_row afh_install_config%ROWTYPE;
  BEGIN
    afh_security_pkg.assert_admin;
    BEGIN
      SELECT * INTO l_row FROM afh_install_config WHERE config_key = l_key FOR UPDATE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown configuration setting.');
    END;
    IF l_row.is_editable = 'N' THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Setting ' || l_key || ' cannot be changed.');
    END IF;
    validate_config_value(l_key, l_row.data_type, p_value);
    UPDATE afh_install_config SET config_value = p_value WHERE config_id = l_row.config_id;
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_config,
      p_entity_id    => l_row.config_id,
      p_event_code   => 'CONFIG_CHANGED',
      p_before_facts => config_facts(l_key, l_row.config_value, l_row.is_secret),
      p_after_facts  => config_facts(l_key, p_value, l_row.is_secret),
      p_summary      => 'Setting ' || l_key || ' changed',
      p_is_public    => 'N');
  END set_config;

  -- =========================================================== users
  FUNCTION lock_user(p_user_id IN NUMBER) RETURN afh_users%ROWTYPE IS
    l_row afh_users%ROWTYPE;
  BEGIN
    SELECT * INTO l_row FROM afh_users WHERE user_id = p_user_id FOR UPDATE;
    RETURN l_row;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown user.');
  END lock_user;

  FUNCTION user_facts(p_display_name IN VARCHAR2, p_email IN VARCHAR2, p_is_active IN VARCHAR2) RETURN CLOB IS
  BEGIN
    RETURN afh_audit_pkg.json_obj(
      apex_t_varchar2('display_name', 'email', 'is_active'),
      apex_t_varchar2(p_display_name, p_email, p_is_active));
  END user_facts;

  PROCEDURE update_user(p_user_id IN NUMBER, p_display_name IN VARCHAR2, p_email IN VARCHAR2) IS
    l_row afh_users%ROWTYPE;
  BEGIN
    afh_security_pkg.assert_admin;
    l_row := lock_user(p_user_id);
    UPDATE afh_users
       SET display_name = SUBSTR(p_display_name, 1, 255),
           email        = SUBSTR(p_email, 1, 320)
     WHERE user_id = p_user_id;
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_user,
      p_entity_id    => p_user_id,
      p_event_code   => 'USER_UPDATED',
      p_before_facts => user_facts(l_row.display_name, l_row.email, l_row.is_active),
      p_after_facts  => user_facts(SUBSTR(p_display_name, 1, 255), SUBSTR(p_email, 1, 320), l_row.is_active),
      p_summary      => 'User ' || l_row.subject_canonical || ' updated',
      p_is_public    => 'N');
  END update_user;

  PROCEDURE set_user_active(p_user_id IN NUMBER, p_is_active IN VARCHAR2) IS
    l_row afh_users%ROWTYPE;
  BEGIN
    IF p_is_active IS NULL OR p_is_active NOT IN ('Y', 'N') THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Active flag must be Y or N.');
    END IF;
    afh_security_pkg.assert_admin;
    l_row := lock_user(p_user_id);
    IF l_row.is_active = p_is_active THEN
      RETURN;   -- nothing changes, nothing to audit
    END IF;
    UPDATE afh_users SET is_active = p_is_active WHERE user_id = p_user_id;
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_user,
      p_entity_id    => p_user_id,
      p_event_code   => CASE WHEN p_is_active = 'Y' THEN 'USER_ACTIVATED' ELSE 'USER_DEACTIVATED' END,
      p_before_facts => user_facts(l_row.display_name, l_row.email, l_row.is_active),
      p_after_facts  => user_facts(l_row.display_name, l_row.email, p_is_active),
      p_summary      => 'User ' || l_row.subject_canonical ||
                        CASE WHEN p_is_active = 'Y' THEN ' activated' ELSE ' deactivated' END,
      p_is_public    => 'N');
  END set_user_active;

  -- =========================================================== roles
  FUNCTION role_facts(
    p_user_id         IN NUMBER,
    p_role_code       IN VARCHAR2,
    p_application_id  IN NUMBER,
    p_effective_date  IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_expiration_date IN TIMESTAMP WITH LOCAL TIME ZONE) RETURN CLOB IS
  BEGIN
    RETURN afh_audit_pkg.json_obj(
      apex_t_varchar2('user_id', 'role_code', 'application_id', 'effective_date', 'expiration_date'),
      apex_t_varchar2(TO_CHAR(p_user_id), p_role_code, TO_CHAR(p_application_id),
                      TO_CHAR(p_effective_date, c_ts_format), TO_CHAR(p_expiration_date, c_ts_format)));
  END role_facts;

  PROCEDURE validate_grant(
    p_role_code       IN VARCHAR2,
    p_application_id  IN NUMBER,
    p_effective_date  IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_expiration_date IN TIMESTAMP WITH LOCAL TIME ZONE) IS
    l_cnt PLS_INTEGER;
  BEGIN
    IF p_role_code IS NULL OR p_role_code NOT IN (
         afh_security_pkg.c_role_user, afh_security_pkg.c_role_tester, afh_security_pkg.c_role_developer,
         afh_security_pkg.c_role_app_owner, afh_security_pkg.c_role_admin) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown role code.');
    END IF;
    IF p_role_code = afh_security_pkg.c_role_admin AND p_application_id IS NOT NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'The administrator role applies to the whole installation, not one application.');
    END IF;
    IF p_effective_date IS NOT NULL AND p_expiration_date IS NOT NULL AND p_expiration_date <= p_effective_date THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'The expiration date must be after the effective date.');
    END IF;
    IF p_application_id IS NOT NULL THEN
      SELECT COUNT(*) INTO l_cnt FROM afh_applications WHERE application_id = p_application_id;
      IF l_cnt = 0 THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown application.');
      END IF;
    END IF;
  END validate_grant;

  PROCEDURE grant_role(
    p_user_id        IN NUMBER,
    p_role_code      IN VARCHAR2,
    p_application_id IN NUMBER DEFAULT NULL,
    p_effective_date IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL,
    p_expiration_date IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL) IS
    l_role VARCHAR2(30 CHAR) := UPPER(TRIM(p_role_code));
    l_user afh_users%ROWTYPE;
    l_id   NUMBER;
  BEGIN
    afh_security_pkg.assert_admin;
    validate_grant(l_role, p_application_id, p_effective_date, p_expiration_date);
    l_user := lock_user(p_user_id);
    BEGIN
      INSERT INTO afh_user_roles (user_id, role_code, application_id, effective_date, expiration_date)
      VALUES (p_user_id, l_role, p_application_id, p_effective_date, p_expiration_date)
      RETURNING user_role_id INTO l_id;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
          'This role is already granted to the user for that scope.');
    END;
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_user_role,
      p_entity_id   => l_id,
      p_event_code  => 'ROLE_GRANTED',
      p_after_facts => role_facts(p_user_id, l_role, p_application_id, p_effective_date, p_expiration_date),
      p_summary     => 'Role ' || l_role || ' granted to ' || l_user.subject_canonical,
      p_is_public   => 'N');
  END grant_role;

  PROCEDURE revoke_role(p_user_role_id IN NUMBER) IS
    l_row  afh_user_roles%ROWTYPE;
    l_user afh_users%ROWTYPE;
  BEGIN
    afh_security_pkg.assert_admin;
    BEGIN
      SELECT * INTO l_row FROM afh_user_roles WHERE user_role_id = p_user_role_id FOR UPDATE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown role grant.');
    END;
    l_user := lock_user(l_row.user_id);
    DELETE FROM afh_user_roles WHERE user_role_id = p_user_role_id;
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_user_role,
      p_entity_id    => p_user_role_id,
      p_event_code   => 'ROLE_REVOKED',
      p_before_facts => role_facts(l_row.user_id, l_row.role_code, l_row.application_id,
                                   l_row.effective_date, l_row.expiration_date),
      p_summary      => 'Role ' || l_row.role_code || ' revoked from ' || l_user.subject_canonical,
      p_is_public    => 'N');
  END revoke_role;

END afh_security_int_pkg;
/
