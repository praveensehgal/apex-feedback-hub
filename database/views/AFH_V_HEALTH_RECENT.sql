-- AFH_V_HEALTH_RECENT: tickets resolved or reopened in the last 30 days (Page 3).
CREATE OR REPLACE FORCE VIEW afh_v_health_recent AS
SELECT t.ticket_id, t.ticket_no, t.title, t.application_id, a.display_name AS application_name,
       t.status_code, s.label AS status_label, s.color_token AS status_color,
       'RESOLVED' AS kind, t.resolved_at AS at_time, asg.display_name AS assignee_name
  FROM afh_tickets t
  JOIN afh_applications a ON a.application_id = t.application_id
  JOIN afh_workflow_statuses s ON s.status_code = t.status_code
  LEFT JOIN afh_users asg ON asg.user_id = t.assignee_user_id
 WHERE t.resolved_at >= SYSTIMESTAMP - 30
UNION ALL
SELECT t.ticket_id, t.ticket_no, t.title, t.application_id, a.display_name,
       t.status_code, s.label, s.color_token,
       'REOPENED', ev.event_at, asg.display_name
  FROM afh_audit_events ev
  JOIN afh_tickets t ON t.ticket_id = ev.ticket_id
  JOIN afh_applications a ON a.application_id = t.application_id
  JOIN afh_workflow_statuses s ON s.status_code = t.status_code
  LEFT JOIN afh_users asg ON asg.user_id = t.assignee_user_id
 WHERE ev.event_code = 'STATUS_CHANGED'
   AND ev.event_at >= SYSTIMESTAMP - 30
   AND ev.after_facts IS NOT NULL
   AND JSON_VALUE(ev.after_facts, '$.status_code') = 'REOPENED';
COMMENT ON TABLE afh_v_health_recent IS 'Recently resolved and reopened tickets (30 days)';
