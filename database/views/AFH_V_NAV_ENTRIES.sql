-- Navigation entries visible to the current session user. Drives the two APEX
-- dynamic lists (menu and navigation bar) in Plan P00; nothing else queries it.
-- Visibility is decided here (afh_security_pkg.audience_yn), so the lists carry
-- no per-entry authorization schemes. Because the hierarchy (CONNECT BY in the
-- list SQL) runs over this filtered view, a child whose parent is not visible
-- never renders. ACCOUNT is the one presentation special case: its label is the
-- signed-in user's display name.
--
-- ACT_AS (development aid, Release 1.0.28): the seeded NAVBAR parent shows only
-- while afh_security_pkg.act_as_allowed_yn = 'Y' (install setting ACT_AS_ENABLED).
-- Its children are not seeded rows: one REQUEST entry per active user, labelled
-- with the user's roles, plus a Revert entry while the session is switched. A
-- REQUEST entry carries request_value; the list SQL turns it into f?p=...:REQUEST.
CREATE OR REPLACE FORCE VIEW afh_v_nav_entries AS
SELECT n.nav_entry_id,
       n.list_code,
       n.entry_code,
       n.parent_entry_code,
       CASE
         WHEN n.entry_code = 'ACCOUNT' THEN
           COALESCE((SELECT NVL(u.display_name, u.subject_display)
                       FROM afh_users u
                      WHERE u.user_id = afh_security_pkg.current_user_id), n.label)
         WHEN n.entry_code = 'ACT_AS' AND afh_security_pkg.is_acting_yn = 'Y' THEN
           'Acting as ' || (SELECT NVL(u.display_name, u.subject_display)
                              FROM afh_users u
                             WHERE u.user_id = afh_security_pkg.current_user_id)
         ELSE n.label
       END                                        AS label,
       n.target_type,
       n.page_no,
       CAST(NULL AS VARCHAR2(40 CHAR))            AS request_value,
       n.icon_css,
       n.display_seq,
       CASE n.badge_source
         WHEN 'UNREAD_NOTIFICATIONS' THEN NULLIF(afh_notification_pkg.unread_count, 0)
       END                                        AS badge_value
  FROM afh_nav_entries n
 WHERE n.is_active = 'Y'
   AND afh_security_pkg.audience_yn(n.audience_code) = 'Y'
   AND (n.entry_code <> 'ACT_AS' OR afh_security_pkg.act_as_allowed_yn = 'Y')
UNION ALL
SELECT NULL                                       AS nav_entry_id,
       'NAVBAR'                                   AS list_code,
       'ACT_AS_REVERT'                            AS entry_code,
       'ACT_AS'                                   AS parent_entry_code,
       'Revert to ' || COALESCE((SELECT NVL(u.display_name, u.subject_display)
                                   FROM afh_users u
                                  WHERE u.subject_canonical = afh_security_pkg.real_subject),
                                afh_security_pkg.real_subject) AS label,
       'REQUEST'                                  AS target_type,
       NULL                                       AS page_no,
       CAST('ACT_AS_REVERT' AS VARCHAR2(40 CHAR)) AS request_value,
       'fa-undo'                                  AS icon_css,
       0                                          AS display_seq,
       NULL                                       AS badge_value
  FROM dual
 WHERE afh_security_pkg.act_as_allowed_yn = 'Y'
   AND afh_security_pkg.is_acting_yn = 'Y'
UNION ALL
SELECT NULL                                       AS nav_entry_id,
       'NAVBAR'                                   AS list_code,
       'ACT_AS_U' || u.user_id                    AS entry_code,
       'ACT_AS'                                   AS parent_entry_code,
       NVL(u.display_name, u.subject_display) || ' (' ||
       COALESCE((SELECT LISTAGG(CASE r.role_code
                                  WHEN 'AFH_ADMIN' THEN 'Administrator'
                                  WHEN 'APP_OWNER' THEN 'Application owner'
                                  ELSE INITCAP(r.role_code)
                                END || CASE WHEN a.display_name IS NOT NULL THEN ' - ' || a.display_name END,
                                ', ') WITHIN GROUP (ORDER BY r.role_code, a.display_name)
                   FROM afh_user_roles r
                   LEFT JOIN afh_applications a ON a.application_id = r.application_id
                  WHERE r.user_id = u.user_id
                    AND (r.effective_date  IS NULL OR r.effective_date  <= SYSTIMESTAMP)
                    AND (r.expiration_date IS NULL OR r.expiration_date >  SYSTIMESTAMP)),
                'Submitter') || ')'               AS label,
       'REQUEST'                                  AS target_type,
       NULL                                       AS page_no,
       CAST('ACT_AS_U' || u.user_id AS VARCHAR2(40 CHAR)) AS request_value,
       'fa-user'                                  AS icon_css,
       ROW_NUMBER() OVER (ORDER BY NVL(u.display_name, u.subject_display)) AS display_seq,
       NULL                                       AS badge_value
  FROM afh_users u
 WHERE u.is_active = 'Y'
   AND afh_security_pkg.act_as_allowed_yn = 'Y';

COMMENT ON TABLE afh_v_nav_entries IS 'Navigation entries visible to the current user; source of the dynamic navigation lists (Plan P00). ACT_AS children are generated from AFH_USERS while ACT_AS_ENABLED is Y.';
