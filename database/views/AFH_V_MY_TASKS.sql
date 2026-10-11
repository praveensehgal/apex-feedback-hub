-- AFH_V_MY_TASKS: open tasks for the current user (Pages 0, 1, 30).
-- REQUESTED_BY_* is the actor of the TASK_CREATED audit event for the task: the developer who
-- assigned the ticket, asked for information or requested the test. Tasks carry no actor column
-- of their own because the audit trail is the immutable record of who did what.
CREATE OR REPLACE FORCE VIEW afh_v_my_tasks AS
SELECT k.task_id, k.task_type_code,
       CASE k.task_type_code WHEN 'ASSIGNMENT' THEN 'Assigned to you' WHEN 'INFO_REQUEST' THEN 'Information requested' WHEN 'TEST_REQUEST' THEN 'Test requested' ELSE 'Review' END AS task_label,
       k.ticket_id, t.ticket_no, t.title, t.status_code, s.label AS status_label, s.color_token AS status_color,
       ft.type_code, ft.label AS type_label,
       a.display_name AS application_name, a.apex_app_id,
       k.due_date, afh_reporting_pkg.is_overdue(k.due_date, t.status_code) AS is_overdue_yn,
       k.summary, k.related_id, k.creation_date AS created_at, k.created_by,
       rq.actor_user_id AS requested_by_user_id,
       NVL(ru.display_name, ru.subject_display) AS requested_by_name
  FROM afh_tasks k
  JOIN afh_tickets t ON t.ticket_id = k.ticket_id
  JOIN afh_workflow_statuses s ON s.status_code = t.status_code
  JOIN afh_feedback_types ft ON ft.feedback_type_id = t.feedback_type_id
  JOIN afh_applications a ON a.application_id = t.application_id
  LEFT JOIN (SELECT ae.ticket_id, ae.actor_user_id,
                    JSON_VALUE(ae.after_facts, '$.task_id' RETURNING NUMBER) AS task_id
               FROM afh_audit_events ae
              WHERE ae.event_code = 'TASK_CREATED') rq
         ON rq.ticket_id = k.ticket_id AND rq.task_id = k.task_id
  LEFT JOIN afh_users ru ON ru.user_id = rq.actor_user_id
 WHERE k.state_code = 'OPEN'
   AND k.user_id = afh_security_pkg.current_user_id;
COMMENT ON TABLE afh_v_my_tasks IS 'Open direct tasks of the current user with ticket labels and the requesting user';
