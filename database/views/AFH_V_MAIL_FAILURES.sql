-- AFH_V_MAIL_FAILURES: permanently failed e-mail notifications (Page 67). No addresses.
CREATE OR REPLACE FORCE VIEW afh_v_mail_failures AS
SELECT n.notification_id, n.recipient_user_id, u.display_name AS recipient_name, n.ticket_id, t.ticket_no,
       n.event_code, n.subject, n.delivery_attempts, n.last_attempt_at, n.error_code, n.error_detail, n.creation_date
  FROM afh_notifications n
  JOIN afh_users u ON u.user_id = n.recipient_user_id
  LEFT JOIN afh_tickets t ON t.ticket_id = n.ticket_id
 WHERE n.channel_code = 'EMAIL' AND n.state_code = 'FAILED';
COMMENT ON TABLE afh_v_mail_failures IS 'E-mail notifications that exhausted their retries';
