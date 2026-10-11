-- AFH_V_USERS: administration list of known users (Page 62). No restricted data.
CREATE OR REPLACE FORCE VIEW afh_v_users AS
SELECT u.user_id,
       u.subject_canonical,
       u.subject_display,
       u.display_name,
       u.email,
       u.is_active,
       u.last_seen_at,
       (SELECT MAX(CASE r.role_code
                     WHEN 'AFH_ADMIN' THEN 'AFH_ADMIN'
                     WHEN 'APP_OWNER' THEN 'APP_OWNER'
                     WHEN 'DEVELOPER' THEN 'DEVELOPER'
                     WHEN 'TESTER'    THEN 'TESTER'
                     ELSE 'USER' END)
                 KEEP (DENSE_RANK LAST ORDER BY
                       CASE r.role_code
                         WHEN 'AFH_ADMIN' THEN 5
                         WHEN 'APP_OWNER' THEN 4
                         WHEN 'DEVELOPER' THEN 3
                         WHEN 'TESTER'    THEN 2
                         ELSE 1 END)
          FROM afh_user_roles r
         WHERE r.user_id = u.user_id
           AND r.application_id IS NULL
           AND (r.effective_date IS NULL OR r.effective_date <= SYSTIMESTAMP)
           AND (r.expiration_date IS NULL OR r.expiration_date > SYSTIMESTAMP)) AS install_role,
       (SELECT COUNT(*)
          FROM afh_tickets t
         WHERE t.assignee_user_id = u.user_id
           AND t.is_archived = 'N'
           AND t.status_code NOT IN (SELECT s.status_code FROM afh_workflow_statuses s WHERE s.is_terminal = 'Y')) AS assigned_open_count,
       u.creation_date,
       u.last_update_date
  FROM afh_users u;
COMMENT ON TABLE afh_v_users IS 'Known users with their highest installation-level role and open assigned ticket count (administration list)';
