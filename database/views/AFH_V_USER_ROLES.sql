-- AFH_V_USER_ROLES: role grants with user and application labels (Page 62).
CREATE OR REPLACE FORCE VIEW afh_v_user_roles AS
SELECT r.user_role_id,
       r.user_id,
       u.subject_display,
       u.display_name,
       r.role_code,
       r.application_id,
       a.app_key,
       a.display_name AS application_name,
       r.effective_date,
       r.expiration_date,
       CASE WHEN (r.effective_date IS NULL OR r.effective_date <= SYSTIMESTAMP)
             AND (r.expiration_date IS NULL OR r.expiration_date > SYSTIMESTAMP)
            THEN 'Y' ELSE 'N' END AS is_effective,
       r.creation_date,
       r.created_by
  FROM afh_user_roles r
  JOIN afh_users u ON u.user_id = r.user_id
  LEFT JOIN afh_applications a ON a.application_id = r.application_id;
COMMENT ON TABLE afh_v_user_roles IS 'Role grants per user with application label and an is_effective flag computed from the effective/expiration window';
