-- AFH_V_TICKET_TESTS: test requests and results per ticket (Page 10 Testing region, Page 40).
-- Labels resolved for display; no restricted data (criteria and notes are authored by
-- developers/testers for the public timeline). Authorization is the page's: the ticket
-- itself is visible to every authenticated user (spec §9.2).
CREATE OR REPLACE FORCE VIEW afh_v_ticket_tests AS
SELECT r.test_result_id,
       r.ticket_id,
       t.ticket_no,
       t.application_id,
       r.assignee_user_id,
       COALESCE(a.display_name, a.subject_display)                   AS assignee_display_name,
       r.requested_by_user_id,
       COALESCE(q.display_name, q.subject_display)                   AS requested_by_display_name,
       r.requested_at,
       r.environment_id,
       e.label                                                       AS environment_label,
       r.app_version,
       r.acceptance_criteria,
       r.result_code,
       CASE r.result_code
         WHEN 'PENDING'   THEN 'Pending'
         WHEN 'PASSED'    THEN 'Passed'
         WHEN 'FAILED'    THEN 'Failed'
         WHEN 'CANCELLED' THEN 'Cancelled'
         ELSE INITCAP(REPLACE(r.result_code, '_', ' '))
       END                                                           AS result_label,
       CASE WHEN r.result_code = 'PENDING' THEN 'Y' ELSE 'N' END     AS is_open_yn,
       r.notes,
       r.completed_at,
       r.completed_by_user_id,
       COALESCE(c.display_name, c.subject_display)                   AS completed_by_display_name,
       r.release_id,
       rl.label                                                      AS release_label
  FROM afh_test_results r
  JOIN afh_tickets       t  ON t.ticket_id       = r.ticket_id
  LEFT JOIN afh_users    a  ON a.user_id         = r.assignee_user_id
  LEFT JOIN afh_users    q  ON q.user_id         = r.requested_by_user_id
  LEFT JOIN afh_users    c  ON c.user_id         = r.completed_by_user_id
  LEFT JOIN afh_environments e ON e.environment_id = r.environment_id
  LEFT JOIN afh_releases rl ON rl.release_id     = r.release_id;

COMMENT ON TABLE afh_v_ticket_tests IS 'Test requests and results per ticket with assignee, requester, environment, release and result labels; feeds the Ticket Detail Testing region and Page 40.';
