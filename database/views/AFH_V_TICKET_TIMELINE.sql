-- Combined public activity timeline for Ticket Detail (Page 10): public audit events,
-- public non-archived comments, and public non-deleted attachments. Ordering is left to
-- the page (ORDER BY event_at, entry_type, entry_id). Nothing restricted is exposed:
-- non-public audit rows, internal notes and restricted attachments are excluded.
CREATE OR REPLACE FORCE VIEW afh_v_ticket_timeline AS
SELECT e.ticket_id,
       'EVENT'                                                   AS entry_type,
       e.audit_event_id                                          AS entry_id,
       e.event_at,
       e.actor_user_id,
       NVL(u.display_name, NVL(u.subject_display, e.actor_subject)) AS actor_display_name,
       e.event_code,
       e.summary,
       TO_CLOB(NULL)                                        AS body_html,
       CAST(NULL AS NUMBER)                                      AS attachment_id,
       CAST(NULL AS VARCHAR2(255 CHAR))                          AS file_name
  FROM afh_audit_events e
  LEFT JOIN afh_users u ON u.user_id = e.actor_user_id
 WHERE e.is_public = 'Y'
   AND e.ticket_id IS NOT NULL
UNION ALL
SELECT c.ticket_id,
       'COMMENT',
       c.comment_id,
       c.posted_at,
       c.author_user_id,
       NVL(u.display_name, u.subject_display),
       'COMMENT',
       CAST(afh_comment_pkg.excerpt(c.body, 200) AS VARCHAR2(1000 CHAR)),
       afh_comment_pkg.render_html(c.body),
       CAST(NULL AS NUMBER),
       CAST(NULL AS VARCHAR2(255 CHAR))
  FROM afh_comments c
  LEFT JOIN afh_users u ON u.user_id = c.author_user_id
 WHERE c.visibility_code = 'PUBLIC'
   AND c.is_archived = 'N'
UNION ALL
SELECT a.ticket_id,
       'ATTACHMENT',
       a.attachment_id,
       a.uploaded_at,
       a.uploaded_by_user_id,
       NVL(u.display_name, u.subject_display),
       a.kind_code,
       CAST(NVL(a.caption, a.file_name) AS VARCHAR2(1000 CHAR)),
       TO_CLOB(NULL),
       a.attachment_id,
       a.file_name
  FROM afh_attachments a
  LEFT JOIN afh_users u ON u.user_id = a.uploaded_by_user_id
 WHERE a.is_deleted = 'N'
   AND a.is_restricted = 'N';

COMMENT ON TABLE afh_v_ticket_timeline IS 'Public ticket timeline: public audit events, public comments (rendered), public attachments. Page orders by event_at.';

