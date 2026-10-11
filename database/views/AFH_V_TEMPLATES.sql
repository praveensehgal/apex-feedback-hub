-- AFH_V_TEMPLATES: notification templates with event labels (Page 65, admin only).
-- Authorization is enforced on the page; the view carries no restricted data.
CREATE OR REPLACE FORCE VIEW afh_v_templates AS
SELECT t.notification_template_id,
       t.event_code,
       afh_notification_int_pkg.event_label(t.event_code) AS event_label,
       t.channel_code,
       t.subject_template,
       t.body_template,
       t.is_active,
       t.description,
       CASE WHEN t.last_updated_by = t.created_by THEN 'N' ELSE 'Y' END AS is_customized_yn,
       t.created_by,
       t.creation_date,
       t.last_updated_by,
       t.last_update_date
  FROM afh_notification_templates t;

COMMENT ON TABLE afh_v_templates IS 'Notification templates per event and channel with a human event label and a flag showing whether an administrator has customized the row since install.';
