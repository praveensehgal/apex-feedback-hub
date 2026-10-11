-- AFH_V_RELEASE_TICKETS: tickets targeted at a release (Page 40 detail region).
CREATE OR REPLACE FORCE VIEW afh_v_release_tickets AS
SELECT t.release_id,
       t.ticket_id,
       t.ticket_no,
       t.title,
       t.status_code,
       NVL(s.label, t.status_code)                                   AS status_label,
       t.assignee_user_id,
       NVL(au.display_name, au.subject_display)                      AS assignee_display_name,
       t.severity_code,
       t.priority_code,
       t.last_activity_at
  FROM afh_tickets t
  LEFT JOIN afh_workflow_statuses s ON s.status_code = t.status_code
  LEFT JOIN afh_users au            ON au.user_id    = t.assignee_user_id
 WHERE t.release_id IS NOT NULL;

COMMENT ON TABLE afh_v_release_tickets IS 'Tickets included in a release with status label and assignee, for the release detail region on Page 40. Public ticket facts only.';

