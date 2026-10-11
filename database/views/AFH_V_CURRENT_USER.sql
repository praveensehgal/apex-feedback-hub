-- AFH_V_CURRENT_USER: exactly one row for the trusted session subject (Global Page,
-- header). Flags come from AFH_SECURITY_PKG; no role logic is duplicated here except
-- the TESTER ladder membership, for which the package exposes no Y/N variant.
CREATE OR REPLACE FORCE VIEW afh_v_current_user AS
SELECT u.user_id,
       u.subject_canonical AS subject,
       u.subject_display,
       u.display_name,
       u.email,
       u.is_active,
       u.last_seen_at,
       afh_security_pkg.is_admin_yn                       AS is_admin_yn,
       afh_security_pkg.is_developer_yn(NULL)             AS is_developer_yn,
       afh_security_pkg.is_app_owner_yn(NULL)             AS is_app_owner_yn,
       CASE WHEN afh_security_pkg.is_admin_yn = 'Y'
              OR afh_security_pkg.is_developer_yn(NULL) = 'Y'
              OR afh_security_pkg.is_app_owner_yn(NULL) = 'Y'
              OR EXISTS (SELECT 1
                           FROM afh_user_roles r
                          WHERE r.user_id = u.user_id
                            AND r.role_code = 'TESTER'
                            AND (r.effective_date IS NULL OR r.effective_date <= SYSTIMESTAMP)
                            AND (r.expiration_date IS NULL OR r.expiration_date > SYSTIMESTAMP))
            THEN 'Y' ELSE 'N' END                          AS is_tester_yn
  FROM afh_users u
 WHERE u.user_id = (SELECT afh_security_pkg.current_user_id FROM dual);
COMMENT ON TABLE afh_v_current_user IS 'One row describing the current trusted session user and their role flags; empty when the subject has no user row';
