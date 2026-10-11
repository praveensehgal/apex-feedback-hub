CREATE OR REPLACE PACKAGE afh_comment_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_COMMENT_PKG — public comments, internal notes, mentions, edit window,
  -- revision history, and safe rendering. Spec §17, WU-08.
  -- Stored body is plain text with a mini-markup; HTML is ALWAYS derived by
  -- render_html after full escaping. There is no HTML input path.
  -- ---------------------------------------------------------------------------

  c_vis_public   CONSTANT VARCHAR2(30) := 'PUBLIC';
  c_vis_internal CONSTANT VARCHAR2(30) := 'INTERNAL';

  -- Add a comment. PUBLIC: any authenticated user who can view the ticket.
  -- INTERNAL: afh_security_pkg.can_add_internal_note. Side effects in the same transaction:
  --   * author follows the ticket (source COMMENT) unless already following
  --   * @mentions of active users -> MENTION notification + follow (unless muted)
  --   * PUBLIC comment by the reporter while status MORE_INFO -> completes the INFO_REQUEST
  --     task and calls afh_workflow_pkg.system_transition(ticket, 'UNDER_REVIEW')
  --   * COMMENT_ADDED notification to followers (public) or developers (internal)
  --   * audit COMMENT_ADDED (is_public = 'N' for internal notes)
  -- Returns comment_id. Body length 1..32000 characters (AFH-VAL-001 otherwise).
  FUNCTION add_comment(
    p_ticket_id       IN NUMBER,
    p_body            IN CLOB,
    p_visibility_code IN VARCHAR2 DEFAULT c_vis_public) RETURN NUMBER;

  -- Author only, within config COMMENT_EDIT_WINDOW_MIN of posting. Stores the prior body as
  -- a revision, increments edit_count, audits COMMENT_EDITED. Outside the window: AFH-AUTH-002.
  PROCEDURE edit_comment(p_comment_id IN NUMBER, p_body IN CLOB);
  FUNCTION  can_edit(p_comment_id IN NUMBER) RETURN BOOLEAN;

  -- Admin: hide a comment from timelines without deleting (audit COMMENT_ARCHIVED).
  PROCEDURE archive_comment(p_comment_id IN NUMBER, p_reason IN VARCHAR2);

  -- Rendered, safe HTML for a body. Escapes everything with APEX_ESCAPE.HTML first, then
  -- applies: blank line -> <p>, single newline -> <br>, lines starting '- ' -> <ul><li>,
  -- *text* -> <em>, **text** -> <strong>, `code` -> <code>, [label](url) -> <a> with
  -- rel="noopener" and only http/https/mailto schemes, @SUBJECT -> <span class="afh-mention">.
  FUNCTION render_html(p_body IN CLOB) RETURN CLOB;
  -- Plain-text excerpt (first p_length chars, markup stripped) for lists and mail.
  FUNCTION excerpt(p_body IN CLOB, p_length IN PLS_INTEGER DEFAULT 200) RETURN VARCHAR2;

  -- Canonical subjects mentioned as @subject in the body (resolved against active users only).
  FUNCTION extract_mentions(p_body IN CLOB) RETURN apex_t_varchar2;

  -- Internal notes for a ticket, authorized per call (assert_can_view_restricted).
  TYPE t_note IS RECORD (
    comment_id     NUMBER,
    author_user_id NUMBER,
    author_name    VARCHAR2(255 CHAR),
    posted_at      TIMESTAMP WITH LOCAL TIME ZONE,
    body           CLOB,
    body_html      CLOB,
    edit_count     NUMBER);
  TYPE t_note_tab IS TABLE OF t_note;
  FUNCTION get_internal_notes(p_ticket_id IN NUMBER) RETURN t_note_tab PIPELINED;
END afh_comment_pkg;
/
