-- AFH_V_NOTIFICATION_PREFS: the current user's notification matrix for Page 51.
-- One row per event code x scope (GLOBAL plus every active application) showing the
-- effective decision for a hypothetical non-direct, non-muted event, the override row
-- (if any) and the preset in force. Per-user: afh_security_pkg.current_user_id.
CREATE OR REPLACE FORCE VIEW afh_v_notification_prefs AS
WITH me AS (
  SELECT afh_security_pkg.current_user_id AS user_id FROM dual
), ev AS (
  SELECT ROWNUM AS event_seq, column_value AS event_code
    FROM TABLE(apex_string.split(
      'NEW_TICKET:ASSIGNMENT:MENTION:COMMENT:INFO_REQUEST:INFO_RESPONSE:STATUS_CHANGE:PRIORITY_CHANGE:'
      || 'RELEASE_CHANGE:READY_TEST:TEST_REQUEST:TEST_OUTCOME:RESOLUTION:CLOSURE:REOPENED:DUPLICATE_MERGE', ':'))
), scope AS (
  SELECT 'GLOBAL' AS scope_code, CAST(NULL AS NUMBER) AS application_id, 'All applications' AS application_name, 0 AS scope_seq
    FROM dual
  UNION ALL
  SELECT 'APP', a.application_id, a.display_name, 1
    FROM afh_applications a
   WHERE a.is_active = 'Y'
)
SELECT me.user_id,
       s.scope_code,
       s.application_id,
       s.application_name,
       e.event_seq,
       e.event_code,
       afh_notification_int_pkg.event_label(e.event_code)                         AS event_label,
       CASE WHEN e.event_code IN ('ASSIGNMENT','MENTION','INFO_REQUEST','TEST_REQUEST','RESOLUTION','REOPENED')
            THEN 'Y' ELSE 'N' END                                                 AS is_important_yn,
       CASE WHEN e.event_code IN ('ASSIGNMENT','INFO_REQUEST','TEST_REQUEST','MENTION')
            THEN 'Y' ELSE 'N' END                                                 AS is_direct_yn,
       o.notification_pref_id                                                     AS override_pref_id,
       o.email_enabled                                                            AS override_email_yn,
       o.in_app_enabled                                                           AS override_in_app_yn,
       p.preset_code                                                              AS scope_preset_code,
       afh_notification_pkg.effective_preset(s.application_id, me.user_id)        AS effective_preset_code,
       afh_notification_int_pkg.channel_decision(me.user_id, s.application_id, e.event_code, 'EMAIL')  AS effective_email_yn,
       afh_notification_int_pkg.channel_decision(me.user_id, s.application_id, e.event_code, 'IN_APP') AS effective_in_app_yn,
       afh_notification_int_pkg.channel_decision(me.user_id, s.application_id, e.event_code, 'DIGEST') AS effective_digest
  FROM me
 CROSS JOIN scope s
 CROSS JOIN ev e
  LEFT JOIN afh_notification_prefs o
         ON o.user_id = me.user_id
        AND o.event_code = e.event_code
        AND ((s.application_id IS NULL AND o.application_id IS NULL) OR o.application_id = s.application_id)
  LEFT JOIN afh_notification_prefs p
         ON p.user_id = me.user_id
        AND p.event_code IS NULL
        AND ((s.application_id IS NULL AND p.application_id IS NULL) OR p.application_id = s.application_id)
 WHERE me.user_id IS NOT NULL;

COMMENT ON TABLE afh_v_notification_prefs IS 'Current user''s notification matrix: one row per event code and scope (global or application) with override flags, preset codes and the effective e-mail / in-app / digest decision; source of Page 51.';
