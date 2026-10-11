-- AFH_V_MY_WORK_FOLLOWED: tickets the current user follows, with mute state and last
-- activity (Page 1 My Work "Following" region, Page 10 follow button state).
-- Per-user: afh_security_pkg.current_user_id.
CREATE OR REPLACE FORCE VIEW afh_v_my_work_followed AS
SELECT f.follower_id,
       f.ticket_id,
       t.ticket_no,
       t.title,
       t.status_code,
       COALESCE(s.label, INITCAP(REPLACE(t.status_code, '_', ' '))) AS status_label,
       t.priority_code,
       t.application_id,
       a.display_name                                               AS application_name,
       f.follow_source_code,
       f.is_muted,
       f.creation_date                                              AS followed_at,
       t.last_activity_at,
       t.is_archived,
       CASE WHEN EXISTS (SELECT 1
                           FROM afh_tasks k
                          WHERE k.ticket_id = f.ticket_id
                            AND k.user_id = f.user_id
                            AND k.state_code = 'OPEN'
                            AND k.task_type_code IN ('ASSIGNMENT', 'INFO_REQUEST'))
            THEN 'N' ELSE 'Y' END                                   AS can_unfollow_yn
  FROM afh_followers f
  JOIN afh_tickets t        ON t.ticket_id = f.ticket_id
  JOIN afh_applications a   ON a.application_id = t.application_id
  LEFT JOIN afh_workflow_statuses s ON s.status_code = t.status_code
 WHERE f.user_id = afh_security_pkg.current_user_id;

COMMENT ON TABLE afh_v_my_work_followed IS 'Tickets the current user follows with mute flag, last activity, and whether unfollow is currently allowed (no open assignment or information request task).';
