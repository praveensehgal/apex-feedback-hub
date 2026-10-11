-- AFH_V_TICKET_QUEUE: one row per open (non-archived, nonterminal) ticket for the Developer
-- Workbench (Page 30). No restricted data: context values, internal notes and bytes stay out.
CREATE OR REPLACE FORCE VIEW afh_v_ticket_queue AS
SELECT t.ticket_id,
       t.ticket_no,
       t.title,
       ft.type_code,
       ft.label AS type_label,
       ft.icon_token AS type_icon,
       t.application_id,
       a.display_name AS application_name,
       a.app_key,
       t.environment_id,
       e.env_code,
       e.label AS env_label,
       t.page_id,
       t.page_name,
       t.category_id,
       c.label AS category_label,
       t.status_code,
       s.label AS status_label,
       s.color_token AS status_color,
       s.display_seq AS status_seq,
       t.priority_code,
       pv.label AS priority_label,
       pv.color_token AS priority_color,
       pv.display_seq AS priority_seq,
       t.severity_code,
       sv.label AS severity_label,
       sv.color_token AS severity_color,
       t.impact_code,
       iv.label AS impact_label,
       t.reporter_user_id,
       rep.display_name AS reporter_name,
       t.assignee_user_id,
       asg.display_name AS assignee_name,
       t.owner_user_id,
       own.display_name AS owner_name,
       t.release_id,
       r.label AS release_label,
       t.due_date,
       afh_reporting_pkg.is_overdue(t.due_date, t.status_code) AS is_overdue_yn,
       TRUNC(CAST(SYSTIMESTAMP AS DATE) - CAST(t.submitted_at AS DATE)) AS days_open,
       afh_reporting_pkg.aging_bucket(t.submitted_at) AS age_bucket,
       afh_reporting_pkg.aging_bucket_seq(t.submitted_at) AS age_bucket_seq,
       t.submitted_at,
       t.last_activity_at,
       t.row_version,
       t.context_result_code,
       (SELECT COUNT(*) FROM afh_tasks k WHERE k.ticket_id = t.ticket_id AND k.state_code = 'OPEN') AS open_task_count,
       (SELECT COUNT(*) FROM afh_test_results x WHERE x.ticket_id = t.ticket_id AND x.result_code = 'PENDING') AS pending_test_count,
       (SELECT COUNT(*) FROM afh_followers f WHERE f.ticket_id = t.ticket_id) AS follower_count,
       (SELECT COUNT(*) FROM afh_affected_users u WHERE u.ticket_id = t.ticket_id) AS affected_count,
       (SELECT COUNT(*) FROM afh_comments m WHERE m.ticket_id = t.ticket_id AND m.visibility_code = 'PUBLIC' AND m.is_archived = 'N') AS comment_count,
       (SELECT COUNT(*) FROM afh_comments m WHERE m.ticket_id = t.ticket_id AND m.visibility_code = 'INTERNAL' AND m.is_archived = 'N') AS internal_note_count,
       (SELECT COUNT(*) FROM afh_attachments at WHERE at.ticket_id = t.ticket_id AND at.is_deleted = 'N') AS attachment_count,
       CASE WHEN EXISTS (SELECT 1 FROM afh_ticket_contexts x WHERE x.ticket_id = t.ticket_id) THEN 'Y' ELSE 'N' END AS has_context_yn,
       (SELECT MAX(x.ticket_no) FROM afh_ticket_relations rl JOIN afh_tickets x ON x.ticket_id = rl.target_ticket_id
         WHERE rl.source_ticket_id = t.ticket_id AND rl.relation_code = 'DUPLICATE_OF' AND rl.is_active = 'Y') AS master_ticket_no,
       CASE WHEN t.assignee_user_id = afh_security_pkg.current_user_id THEN 'Y' ELSE 'N' END AS is_mine_yn,
       CASE WHEN t.owner_user_id = afh_security_pkg.current_user_id THEN 'Y' ELSE 'N' END AS is_my_queue_yn
  FROM afh_tickets t
  JOIN afh_feedback_types ft ON ft.feedback_type_id = t.feedback_type_id
  JOIN afh_applications a ON a.application_id = t.application_id
  JOIN afh_environments e ON e.environment_id = t.environment_id
  JOIN afh_workflow_statuses s ON s.status_code = t.status_code
  JOIN afh_users rep ON rep.user_id = t.reporter_user_id
  LEFT JOIN afh_categories c ON c.category_id = t.category_id
  LEFT JOIN afh_classification_values pv ON pv.class_type = 'PRIORITY' AND pv.value_code = t.priority_code
  LEFT JOIN afh_classification_values sv ON sv.class_type = 'SEVERITY' AND sv.value_code = t.severity_code
  LEFT JOIN afh_classification_values iv ON iv.class_type = 'IMPACT' AND iv.value_code = t.impact_code
  LEFT JOIN afh_users asg ON asg.user_id = t.assignee_user_id
  LEFT JOIN afh_users own ON own.user_id = t.owner_user_id
  LEFT JOIN afh_releases r ON r.release_id = t.release_id
 WHERE t.is_archived = 'N'
   AND s.is_terminal = 'N';
COMMENT ON TABLE afh_v_ticket_queue IS 'Open tickets with labels, ages, counts and current-user flags for the Developer Workbench';
