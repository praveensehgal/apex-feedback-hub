-- AFH_V_WORKLOAD: open work per assignee for the compact workload view (Page 30).
CREATE OR REPLACE FORCE VIEW afh_v_workload AS
SELECT u.user_id, u.display_name, u.subject_display,
       COUNT(q.ticket_id) AS open_count,
       SUM(CASE WHEN q.status_code = 'IN_PROGRESS' THEN 1 ELSE 0 END) AS in_progress_count,
       SUM(CASE WHEN q.status_code = 'READY_TEST' THEN 1 ELSE 0 END) AS ready_test_count,
       SUM(CASE WHEN q.status_code IN ('NEW', 'UNDER_REVIEW', 'REOPENED') THEN 1 ELSE 0 END) AS triage_count,
       SUM(CASE WHEN q.is_overdue_yn = 'Y' THEN 1 ELSE 0 END) AS overdue_count,
       SUM(CASE WHEN q.priority_code = 'CRITICAL' THEN 1 ELSE 0 END) AS critical_count,
       MAX(q.last_activity_at) AS last_activity_at
  FROM afh_users u
  LEFT JOIN afh_v_ticket_queue q ON q.assignee_user_id = u.user_id
 WHERE u.is_active = 'Y'
   AND (q.ticket_id IS NOT NULL
        OR EXISTS (SELECT 1 FROM afh_user_roles r WHERE r.user_id = u.user_id AND r.role_code IN ('DEVELOPER', 'APP_OWNER', 'AFH_ADMIN')))
 GROUP BY u.user_id, u.display_name, u.subject_display;
COMMENT ON TABLE afh_v_workload IS 'Open ticket counts per assignee (developers, owners, admins, and anyone holding work)';
