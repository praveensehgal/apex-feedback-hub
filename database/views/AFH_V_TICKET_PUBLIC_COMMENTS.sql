-- Public, non-archived comments for Ticket Detail (Page 10). Internal notes are NEVER in
-- this view; they are read only through afh_comment_pkg.get_internal_notes, which
-- authorizes every call.
-- can_edit_yn repeats the rule of afh_comment_pkg.can_edit in SQL because that function
-- returns BOOLEAN and the 19c floor does not allow BOOLEAN in SQL.
CREATE OR REPLACE FORCE VIEW afh_v_ticket_public_comments AS
SELECT c.comment_id,
       c.ticket_id,
       c.author_user_id,
       NVL(u.display_name, u.subject_display)                        AS author_display_name,
       CASE WHEN c.author_user_id = t.reporter_user_id THEN 'Y' ELSE 'N' END AS author_is_reporter_yn,
       c.posted_at,
       c.body,
       afh_comment_pkg.render_html(c.body)                           AS body_html,
       c.edit_count,
       CASE WHEN c.is_archived = 'N'
             AND c.author_user_id = afh_security_pkg.current_user_id
             AND c.edit_deadline_at > SYSTIMESTAMP THEN 'Y' ELSE 'N' END AS can_edit_yn,
       (SELECT COUNT(*) FROM afh_attachments a
         WHERE a.comment_id = c.comment_id AND a.is_deleted = 'N' AND a.is_restricted = 'N') AS attachment_count
  FROM afh_comments c
  JOIN afh_tickets t ON t.ticket_id = c.ticket_id
  LEFT JOIN afh_users u ON u.user_id = c.author_user_id
 WHERE c.visibility_code = 'PUBLIC'
   AND c.is_archived = 'N';

COMMENT ON TABLE afh_v_ticket_public_comments IS 'Public non-archived comments with safe rendered HTML for Ticket Detail. No internal notes.';

