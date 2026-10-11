CREATE OR REPLACE PACKAGE afh_security_int_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_SECURITY_INT_PKG — private helper package for AFH_SECURITY_PKG. Holds the
  -- administrative mutations (configuration, users, roles) so the public security
  -- body stays within the file-size rule. Not a public API: pages and other
  -- packages call the identical subprograms on AFH_SECURITY_PKG, which delegate
  -- here. Every routine asserts AFH_ADMIN and writes one audit event.
  -- ---------------------------------------------------------------------------

  -- Admin only; audits CONFIG_CHANGED with before/after (secret keys redacted).
  -- Errors: AFH-AUTH-002, AFH-VAL-001 (unknown key, not editable, bad value for data_type).
  PROCEDURE set_config(p_key IN VARCHAR2, p_value IN VARCHAR2);

  -- Admin only; audits USER_UPDATED. Errors: AFH-AUTH-002, AFH-VAL-001 (unknown user).
  PROCEDURE update_user(p_user_id IN NUMBER, p_display_name IN VARCHAR2, p_email IN VARCHAR2);

  -- Admin only; audits USER_ACTIVATED / USER_DEACTIVATED; no-op when unchanged.
  -- Errors: AFH-AUTH-002, AFH-VAL-001 (flag not Y/N, unknown user).
  PROCEDURE set_user_active(p_user_id IN NUMBER, p_is_active IN VARCHAR2);

  -- Admin only; audits ROLE_GRANTED (entity USER_ROLE). Errors: AFH-AUTH-002,
  -- AFH-VAL-001 (unknown role/user/application, AFH_ADMIN with an application,
  -- expiration before effective, duplicate grant).
  PROCEDURE grant_role(
    p_user_id        IN NUMBER,
    p_role_code      IN VARCHAR2,
    p_application_id IN NUMBER DEFAULT NULL,
    p_effective_date IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL,
    p_expiration_date IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL);

  -- Admin only; deletes the grant (roles are not history) and audits ROLE_REVOKED.
  -- Errors: AFH-AUTH-002, AFH-VAL-001 (unknown grant).
  PROCEDURE revoke_role(p_user_role_id IN NUMBER);
END afh_security_int_pkg;
/
