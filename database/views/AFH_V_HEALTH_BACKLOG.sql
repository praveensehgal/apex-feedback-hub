-- AFH_V_HEALTH_BACKLOG: one row per active application (Page 3).
CREATE OR REPLACE FORCE VIEW afh_v_health_backlog AS
SELECT a.application_id, a.app_key, a.display_name AS application_name, a.owner_user_id, o.display_name AS owner_name,
       (SELECT COUNT(*) FROM afh_v_ticket_queue q WHERE q.application_id = a.application_id) AS open_count,
       (SELECT COUNT(*) FROM afh_v_ticket_queue q WHERE q.application_id = a.application_id AND q.status_code = 'NEW') AS new_count,
       (SELECT COUNT(*) FROM afh_v_ticket_queue q WHERE q.application_id = a.application_id AND q.status_code IN ('UNDER_REVIEW', 'MORE_INFO', 'REOPENED')) AS triage_count,
       (SELECT COUNT(*) FROM afh_v_ticket_queue q WHERE q.application_id = a.application_id AND q.status_code IN ('ACCEPTED', 'PLANNED', 'IN_PROGRESS')) AS in_progress_count,
       (SELECT COUNT(*) FROM afh_v_ticket_queue q WHERE q.application_id = a.application_id AND q.status_code = 'READY_TEST') AS ready_test_count,
       (SELECT COUNT(*) FROM afh_v_ticket_queue q WHERE q.application_id = a.application_id AND q.is_overdue_yn = 'Y') AS overdue_count,
       (SELECT COUNT(*) FROM afh_v_ticket_queue q WHERE q.application_id = a.application_id AND q.priority_code = 'CRITICAL') AS critical_count,
       (SELECT MIN(q.submitted_at) FROM afh_v_ticket_queue q WHERE q.application_id = a.application_id) AS oldest_open_at,
       (SELECT COUNT(*) FROM afh_tickets t WHERE t.application_id = a.application_id AND t.resolved_at >= SYSTIMESTAMP - 30) AS resolved_last_30d,
       (SELECT COUNT(*) FROM afh_audit_events ev JOIN afh_tickets t ON t.ticket_id = ev.ticket_id
         WHERE t.application_id = a.application_id AND ev.event_code = 'STATUS_CHANGED' AND ev.event_at >= SYSTIMESTAMP - 30
           AND ev.after_facts IS NOT NULL AND JSON_VALUE(ev.after_facts, '$.status_code') = 'REOPENED') AS reopened_last_30d,
       (SELECT COUNT(*) FROM afh_tickets t WHERE t.application_id = a.application_id AND t.submitted_at >= SYSTIMESTAMP - 30) AS submitted_last_30d
  FROM afh_applications a
  LEFT JOIN afh_users o ON o.user_id = a.owner_user_id
 WHERE a.is_active = 'Y';
COMMENT ON TABLE afh_v_health_backlog IS 'Backlog summary per active application for Application Health';
