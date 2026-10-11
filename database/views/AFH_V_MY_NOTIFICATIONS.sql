-- AFH_V_MY_NOTIFICATIONS: in-app notifications of the current user (Page 50, Page 0 badge).
-- Per-user: filtered on afh_security_pkg.current_user_id. No restricted data: subject and
-- body are rendered from templates with safe summaries only (spec §19.2).
CREATE OR REPLACE FORCE VIEW afh_v_my_notifications AS
SELECT n.notification_id,
       n.event_code,
       afh_notification_int_pkg.event_label(n.event_code)            AS event_label,
       n.ticket_id,
       t.ticket_no,
       t.title,
       n.subject,
       n.body,
       n.state_code,
       CASE WHEN n.state_code = 'READ' THEN 'Y' ELSE 'N' END           AS is_read_yn,
       n.read_at,
       n.creation_date                                                AS created_at,
       n.actor_user_id,
       COALESCE(a.display_name, a.subject_display, 'System')          AS actor_display_name,
       n.task_id,
       n.link_target
  FROM afh_notifications n
  LEFT JOIN afh_tickets t ON t.ticket_id = n.ticket_id
  LEFT JOIN afh_users   a ON a.user_id = n.actor_user_id
 WHERE n.channel_code = 'IN_APP'
   AND n.recipient_user_id = afh_security_pkg.current_user_id;

COMMENT ON TABLE afh_v_my_notifications IS 'In-app notifications (channel IN_APP) of the current user with ticket and actor display data; feeds Page 50 and the unread badge.';
