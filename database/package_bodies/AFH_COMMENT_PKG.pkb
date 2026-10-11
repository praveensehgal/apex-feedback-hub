CREATE OR REPLACE PACKAGE BODY afh_comment_pkg AS
  -- ---------------------------------------------------------------------------
  -- AFH_COMMENT_PKG body. Spec §17, WU-08.
  -- Rendering model: the stored body is plain text. render_html escapes EVERY
  -- character with APEX_ESCAPE.HTML first (so '<', '"', '&' never reach the output
  -- raw) and only then recognises the mini-markup on the escaped text. The only
  -- raw HTML in the output are the literal tags this package emits.
  -- ---------------------------------------------------------------------------

  c_body_max        CONSTANT PLS_INTEGER := 32000;
  c_escape_chunk    CONSTANT PLS_INTEGER := 4000;   -- raw chars per apex_escape.html call
  c_line_max        CONSTANT PLS_INTEGER := 8000;   -- escaped chars processed per line
  c_mention_max     CONSTANT PLS_INTEGER := 50;
  c_ev_added        CONSTANT VARCHAR2(30) := 'COMMENT_ADDED';
  c_ev_edited       CONSTANT VARCHAR2(30) := 'COMMENT_EDITED';
  c_ev_archived     CONSTANT VARCHAR2(30) := 'COMMENT_ARCHIVED';
  c_nl              CONSTANT VARCHAR2(1)  := CHR(10);
  -- @subject token; an optional @domain part lets e-mail style subjects be mentioned.
  -- The '@' must start the text or follow whitespace / '(' so e-mail addresses in prose
  -- are not treated as mentions.
  c_mention_re      CONSTANT VARCHAR2(100) := '(^|[[:space:](])@([A-Za-z0-9._-]+(@[A-Za-z0-9._-]+)?)';

  TYPE t_comment_row IS RECORD (
    comment_id NUMBER, ticket_id NUMBER, author_user_id NUMBER, visibility_code VARCHAR2(30 CHAR),
    body CLOB, edit_deadline_at TIMESTAMP WITH LOCAL TIME ZONE, edit_count NUMBER, is_archived VARCHAR2(1 CHAR));

  -- ================================================================ private: helpers
  FUNCTION body_length(p_body IN CLOB) RETURN NUMBER IS
  BEGIN
    RETURN CASE WHEN p_body IS NULL THEN 0 ELSE DBMS_LOB.getlength(p_body) END;
  END body_length;

  PROCEDURE validate_body(p_body IN CLOB) IS
    l_len NUMBER := body_length(p_body);
  BEGIN
    IF l_len < 1 OR l_len > c_body_max THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'Enter a comment of 1 to ' || c_body_max || ' characters.');
    END IF;
  END validate_body;

  FUNCTION get_comment(p_comment_id IN NUMBER, p_lock IN BOOLEAN DEFAULT FALSE) RETURN t_comment_row IS
    l_row t_comment_row;
  BEGIN
    IF p_lock THEN
      SELECT comment_id, ticket_id, author_user_id, visibility_code, body, edit_deadline_at, edit_count, is_archived
        INTO l_row FROM afh_comments WHERE comment_id = p_comment_id FOR UPDATE;
    ELSE
      SELECT comment_id, ticket_id, author_user_id, visibility_code, body, edit_deadline_at, edit_count, is_archived
        INTO l_row FROM afh_comments WHERE comment_id = p_comment_id;
    END IF;
    RETURN l_row;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'That comment no longer exists.');
  END get_comment;

  FUNCTION is_public_yn(p_visibility_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_visibility_code = c_vis_public THEN 'Y' ELSE 'N' END;
  END is_public_yn;

  -- Facts for audit: the excerpt is only recorded for PUBLIC comments so internal-note
  -- text never lands in an audit row.
  FUNCTION comment_facts(p_comment_id IN NUMBER, p_visibility_code IN VARCHAR2, p_body IN CLOB,
                         p_edit_count IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_names  apex_t_varchar2 := apex_t_varchar2('comment_id', 'visibility');
    l_values apex_t_varchar2 := apex_t_varchar2(TO_CHAR(p_comment_id), p_visibility_code);
  BEGIN
    IF p_visibility_code = c_vis_public THEN
      apex_string.push(l_names, 'excerpt');
      apex_string.push(l_values, excerpt(p_body, 200));
    END IF;
    IF p_edit_count IS NOT NULL THEN
      apex_string.push(l_names, 'edit_count');
      apex_string.push(l_values, TO_CHAR(p_edit_count));
    END IF;
    RETURN afh_audit_pkg.json_obj(l_names, l_values);
  END comment_facts;

  -- ================================================================ private: side effects of add_comment
  PROCEDURE notify_mentions(p_ticket_id IN NUMBER, p_visibility_code IN VARCHAR2, p_body IN CLOB) IS
    l_subjects apex_t_varchar2 := extract_mentions(p_body);
    l_user_id  NUMBER;
    l_summary  VARCHAR2(500);
  BEGIN
    FOR i IN 1 .. l_subjects.COUNT LOOP
      SELECT MIN(user_id) INTO l_user_id FROM afh_users
       WHERE subject_canonical = l_subjects(i) AND is_active = 'Y';
      IF l_user_id IS NOT NULL THEN
        IF NOT afh_notification_pkg.is_muted(p_ticket_id, l_user_id) THEN
          afh_notification_pkg.follow(p_ticket_id, l_user_id, 'MENTION');
        END IF;
        l_summary := CASE WHEN p_visibility_code = c_vis_public
                          THEN 'You were mentioned: ' || excerpt(p_body, 160)
                          ELSE 'You were mentioned in an internal note' END;
        afh_notification_pkg.raise_event(
          p_event_code => afh_notification_pkg.c_ev_mention, p_ticket_id => p_ticket_id,
          p_target_user_id => l_user_id, p_summary => l_summary);
      END IF;
    END LOOP;
  END notify_mentions;

  -- Spec §17: a public reply by the reporter while MORE_INFO completes the response task
  -- and returns the ticket to UNDER_REVIEW in the same transaction.
  PROCEDURE handle_reporter_response(p_ticket_id IN NUMBER, p_assignee_id IN NUMBER, p_owner_id IN NUMBER) IS
    l_task_id NUMBER;
  BEGIN
    FOR i IN 1 .. 10 LOOP
      l_task_id := afh_workflow_pkg.open_task_id(p_ticket_id, afh_workflow_pkg.c_task_info_request);
      EXIT WHEN l_task_id IS NULL;
      afh_workflow_pkg.complete_task(l_task_id);
    END LOOP;
    afh_workflow_pkg.system_transition(p_ticket_id, afh_workflow_pkg.c_st_review, 'Reporter responded');
    afh_notification_pkg.raise_event(
      p_event_code     => afh_notification_pkg.c_ev_info_response,
      p_ticket_id      => p_ticket_id,
      p_target_user_id => NVL(p_assignee_id, p_owner_id),
      p_summary        => 'The reporter responded to the information request');
  END handle_reporter_response;

  PROCEDURE assert_can_comment(p_ticket_id IN NUMBER, p_visibility_code IN VARCHAR2) IS
  BEGIN
    IF p_visibility_code = c_vis_public THEN
      IF NOT afh_security_pkg.can_view_ticket(p_ticket_id) THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002, 'You do not have access to this ticket.');
      END IF;
    ELSIF p_visibility_code = c_vis_internal THEN
      IF NOT afh_security_pkg.can_add_internal_note(p_ticket_id) THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002, 'Only developers for this application can add internal notes.');
      END IF;
    ELSE
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Choose Public or Internal visibility.');
    END IF;
  END assert_can_comment;

  -- ================================================================ add_comment
  FUNCTION add_comment(
    p_ticket_id       IN NUMBER,
    p_body            IN CLOB,
    p_visibility_code IN VARCHAR2 DEFAULT c_vis_public) RETURN NUMBER IS
    l_vis       VARCHAR2(30) := UPPER(TRIM(p_visibility_code));
    l_status    afh_tickets.status_code%TYPE;
    l_assignee  NUMBER;
    l_owner     NUMBER;
    l_window    NUMBER;
    l_id        NUMBER;
  BEGIN
    afh_security_pkg.assert_authenticated;
    validate_body(p_body);
    BEGIN
      SELECT status_code, assignee_user_id, owner_user_id INTO l_status, l_assignee, l_owner
        FROM afh_tickets WHERE ticket_id = p_ticket_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'That ticket no longer exists.');
    END;
    assert_can_comment(p_ticket_id, l_vis);
    l_window := NVL(afh_security_pkg.config_number('COMMENT_EDIT_WINDOW_MIN', 15), 15);
    INSERT INTO afh_comments (ticket_id, author_user_id, visibility_code, body, posted_at, edit_deadline_at, edit_count, is_archived)
    VALUES (p_ticket_id, afh_security_pkg.current_user_id, l_vis, p_body, SYSTIMESTAMP,
            SYSTIMESTAMP + NUMTODSINTERVAL(l_window, 'MINUTE'), 0, 'N')
    RETURNING comment_id INTO l_id;
    IF l_vis = c_vis_public THEN
      afh_notification_pkg.follow(p_ticket_id, NULL, 'COMMENT');
    END IF;
    notify_mentions(p_ticket_id, l_vis, p_body);
    IF l_vis = c_vis_public AND l_status = afh_workflow_pkg.c_st_more_info
       AND afh_security_pkg.is_reporter(p_ticket_id) THEN
      handle_reporter_response(p_ticket_id, l_assignee, l_owner);
    END IF;
    IF l_vis = c_vis_public THEN
      afh_notification_pkg.raise_event(
        p_event_code => afh_notification_pkg.c_ev_comment, p_ticket_id => p_ticket_id,
        p_summary    => excerpt(p_body, 200));
    END IF;
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_comment, p_entity_id => l_id, p_event_code => c_ev_added,
      p_ticket_id   => p_ticket_id, p_after_facts => comment_facts(l_id, l_vis, p_body),
      p_summary     => CASE WHEN l_vis = c_vis_public THEN 'Comment added' ELSE 'Internal note added' END,
      p_is_public   => is_public_yn(l_vis));
    afh_ticket_pkg.bump_version(p_ticket_id);
    RETURN l_id;
  END add_comment;

  -- ================================================================ edit
  FUNCTION can_edit_row(p_row IN t_comment_row) RETURN BOOLEAN IS
  BEGIN
    RETURN p_row.is_archived = 'N'
       AND p_row.author_user_id = afh_security_pkg.current_user_id
       AND p_row.edit_deadline_at IS NOT NULL
       AND SYSTIMESTAMP < p_row.edit_deadline_at;
  END can_edit_row;

  FUNCTION can_edit(p_comment_id IN NUMBER) RETURN BOOLEAN IS
    l_row t_comment_row;
  BEGIN
    SELECT comment_id, ticket_id, author_user_id, visibility_code, body, edit_deadline_at, edit_count, is_archived
      INTO l_row FROM afh_comments WHERE comment_id = p_comment_id;
    RETURN can_edit_row(l_row);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN FALSE;
  END can_edit;

  PROCEDURE assert_can_edit(p_row IN t_comment_row) IS
  BEGIN
    IF can_edit_row(p_row) THEN RETURN; END IF;
    IF p_row.author_user_id <> afh_security_pkg.current_user_id THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002, 'Only the author can edit this comment.');
    ELSIF p_row.is_archived = 'Y' THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002, 'An archived comment cannot be edited.');
    END IF;
    afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002, 'The edit window for this comment has closed.');
  END assert_can_edit;

  PROCEDURE edit_comment(p_comment_id IN NUMBER, p_body IN CLOB) IS
    l_row t_comment_row;
  BEGIN
    afh_security_pkg.assert_authenticated;
    validate_body(p_body);
    l_row := get_comment(p_comment_id, p_lock => TRUE);
    assert_can_edit(l_row);
    INSERT INTO afh_comment_revisions (comment_id, revision_no, body, edited_by_user_id, edited_at)
    VALUES (p_comment_id, l_row.edit_count + 1, l_row.body, afh_security_pkg.current_user_id, SYSTIMESTAMP);
    UPDATE afh_comments SET body = p_body, edit_count = edit_count + 1 WHERE comment_id = p_comment_id;
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_comment, p_entity_id => p_comment_id, p_event_code => c_ev_edited,
      p_ticket_id    => l_row.ticket_id,
      p_before_facts => comment_facts(p_comment_id, l_row.visibility_code, l_row.body, l_row.edit_count),
      p_after_facts  => comment_facts(p_comment_id, l_row.visibility_code, p_body, l_row.edit_count + 1),
      p_summary      => 'Comment edited', p_is_public => is_public_yn(l_row.visibility_code));
  END edit_comment;

  -- ================================================================ archive
  PROCEDURE archive_comment(p_comment_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_row t_comment_row;
  BEGIN
    afh_security_pkg.assert_admin;
    IF TRIM(p_reason) IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Give a reason for archiving the comment.');
    END IF;
    l_row := get_comment(p_comment_id, p_lock => TRUE);
    IF l_row.is_archived = 'Y' THEN RETURN; END IF;
    UPDATE afh_comments SET is_archived = 'Y' WHERE comment_id = p_comment_id;
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_comment, p_entity_id => p_comment_id, p_event_code => c_ev_archived,
      p_ticket_id   => l_row.ticket_id,
      p_after_facts => afh_audit_pkg.json_obj(apex_t_varchar2('comment_id', 'reason'),
                                              apex_t_varchar2(TO_CHAR(p_comment_id), SUBSTR(p_reason, 1, 1000))),
      p_summary     => 'Comment archived', p_is_public => is_public_yn(l_row.visibility_code));
  END archive_comment;

  -- ================================================================ rendering
  -- CRLF / CR -> LF, then escape in 4,000-char chunks (escaped output can be 6x longer).
  FUNCTION escape_clob(p_body IN CLOB) RETURN CLOB IS
    l_src CLOB;
    l_out CLOB;
    l_len PLS_INTEGER;
    l_pos PLS_INTEGER := 1;
    l_chunk VARCHAR2(32767);
  BEGIN
    DBMS_LOB.createtemporary(l_out, TRUE, DBMS_LOB.call);
    IF p_body IS NULL THEN RETURN l_out; END IF;
    l_src := REPLACE(REPLACE(p_body, CHR(13) || CHR(10), c_nl), CHR(13), c_nl);
    l_len := DBMS_LOB.getlength(l_src);
    WHILE l_pos <= l_len LOOP
      l_chunk := apex_escape.html(DBMS_LOB.substr(l_src, c_escape_chunk, l_pos));
      DBMS_LOB.writeappend(l_out, LENGTH(l_chunk), l_chunk);
      l_pos := l_pos + c_escape_chunk;
    END LOOP;
    RETURN l_out;
  END escape_clob;

  -- Next line of an escaped CLOB. Lines longer than c_line_max escaped characters are
  -- returned in pieces; the pieces are re-emitted adjacent, so the escaped bytes are
  -- unchanged and only inline markup spanning the cut is lost (cosmetic, never unsafe).
  PROCEDURE next_line(p_clob IN CLOB, p_total IN PLS_INTEGER, io_pos IN OUT PLS_INTEGER, o_line OUT VARCHAR2) IS
    l_nl  PLS_INTEGER := DBMS_LOB.instr(p_clob, c_nl, io_pos);
    l_len PLS_INTEGER;
  BEGIN
    l_len := CASE WHEN l_nl = 0 THEN p_total - io_pos + 1 ELSE l_nl - io_pos END;
    IF l_len > c_line_max THEN
      o_line := DBMS_LOB.substr(p_clob, c_line_max, io_pos);
      io_pos := io_pos + c_line_max;
    ELSE
      o_line := CASE WHEN l_len = 0 THEN NULL ELSE DBMS_LOB.substr(p_clob, l_len, io_pos) END;
      io_pos := io_pos + l_len + 1;
    END IF;
  END next_line;

  -- Inline markup on ALREADY-ESCAPED text. Order matters: mentions run before links so a
  -- mention span can never be inserted inside an href; the link regex only accepts
  -- http(s) (with '/' in its escaped &#x2F; or raw form) and mailto schemes.
  FUNCTION inline_markup(p_line IN VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(32767) := p_line;
  BEGIN
    l := REGEXP_REPLACE(l, '`([^`]+)`', '<code>\1</code>');
    l := REGEXP_REPLACE(l, '\*\*([^*]+)\*\*', '<strong>\1</strong>');
    l := REGEXP_REPLACE(l, '\*([^*]+)\*', '<em>\1</em>');
    l := REGEXP_REPLACE(l, c_mention_re, '\1<span class="afh-mention">@\2</span>');
    l := REGEXP_REPLACE(l,
           '\[([^]]+)\]\(((https?:(&#x2F;&#x2F;|//)|mailto:)[^)[:space:]]+)\)',
           '<a href="\2" rel="noopener noreferrer" target="_blank">\1</a>', 1, 0, 'i');
    RETURN l;
  END inline_markup;

  PROCEDURE append(io_out IN OUT NOCOPY CLOB, p_text IN VARCHAR2) IS
  BEGIN
    IF p_text IS NOT NULL THEN
      DBMS_LOB.writeappend(io_out, LENGTH(p_text), p_text);
    END IF;
  END append;

  PROCEDURE close_blocks(io_out IN OUT NOCOPY CLOB, io_in_para IN OUT BOOLEAN, io_in_list IN OUT BOOLEAN) IS
  BEGIN
    IF io_in_para THEN append(io_out, '</p>'); io_in_para := FALSE; END IF;
    IF io_in_list THEN append(io_out, '</ul>'); io_in_list := FALSE; END IF;
  END close_blocks;

  PROCEDURE render_line(io_out IN OUT NOCOPY CLOB, p_line IN VARCHAR2,
                        io_in_para IN OUT BOOLEAN, io_in_list IN OUT BOOLEAN) IS
  BEGIN
    IF TRIM(p_line) IS NULL THEN
      close_blocks(io_out, io_in_para, io_in_list);
    ELSIF p_line LIKE '- %' THEN
      IF io_in_para THEN append(io_out, '</p>'); io_in_para := FALSE; END IF;
      IF NOT io_in_list THEN append(io_out, '<ul>'); io_in_list := TRUE; END IF;
      append(io_out, '<li>' || inline_markup(TRIM(SUBSTR(p_line, 3))) || '</li>');
    ELSE
      IF io_in_list THEN append(io_out, '</ul>'); io_in_list := FALSE; END IF;
      IF io_in_para THEN
        append(io_out, '<br>');
      ELSE
        append(io_out, '<p>'); io_in_para := TRUE;
      END IF;
      append(io_out, inline_markup(p_line));
    END IF;
  END render_line;

  FUNCTION render_html(p_body IN CLOB) RETURN CLOB IS
    l_esc     CLOB := escape_clob(p_body);
    l_out     CLOB;
    l_total   PLS_INTEGER := DBMS_LOB.getlength(l_esc);
    l_pos     PLS_INTEGER := 1;
    l_line    VARCHAR2(32767);
    l_in_para BOOLEAN := FALSE;
    l_in_list BOOLEAN := FALSE;
  BEGIN
    DBMS_LOB.createtemporary(l_out, TRUE, DBMS_LOB.call);
    WHILE l_pos <= l_total LOOP
      next_line(l_esc, l_total, l_pos, l_line);
      render_line(l_out, l_line, l_in_para, l_in_list);
    END LOOP;
    close_blocks(l_out, l_in_para, l_in_list);
    RETURN l_out;
  END render_html;

  -- Plain text: markup characters removed, links reduced to their label, whitespace
  -- collapsed. NOT escaped — callers escape for their own output context.
  FUNCTION excerpt(p_body IN CLOB, p_length IN PLS_INTEGER DEFAULT 200) RETURN VARCHAR2 IS
    l VARCHAR2(32767);
  BEGIN
    IF p_body IS NULL THEN RETURN NULL; END IF;
    l := DBMS_LOB.substr(p_body, 4000, 1);
    l := REGEXP_REPLACE(l, '\[([^]]+)\]\([^)]*\)', '\1');
    l := REGEXP_REPLACE(l, '(^|' || c_nl || ')- ', '\1');
    l := REPLACE(REPLACE(l, '*', ''), '`', '');
    l := TRIM(REGEXP_REPLACE(l, '[[:space:]]+', ' '));
    RETURN SUBSTR(l, 1, NVL(p_length, 200));
  END excerpt;

  -- ================================================================ mentions
  FUNCTION extract_mentions(p_body IN CLOB) RETURN apex_t_varchar2 IS
    l_out   apex_t_varchar2 := apex_t_varchar2();
    l_seen  apex_t_varchar2 := apex_t_varchar2();
    l_token VARCHAR2(255);
    l_exists PLS_INTEGER;
  BEGIN
    IF p_body IS NULL THEN RETURN l_out; END IF;
    FOR i IN 1 .. LEAST(REGEXP_COUNT(p_body, c_mention_re), c_mention_max) LOOP
      l_token := afh_security_pkg.canonical_subject(RTRIM(REGEXP_SUBSTR(p_body, c_mention_re, 1, i, NULL, 2), '.'));
      IF l_token IS NOT NULL AND l_token NOT MEMBER OF l_seen THEN
        apex_string.push(l_seen, l_token);
        SELECT COUNT(*) INTO l_exists FROM afh_users
         WHERE subject_canonical = l_token AND is_active = 'Y';
        IF l_exists > 0 THEN
          apex_string.push(l_out, l_token);
        END IF;
      END IF;
    END LOOP;
    RETURN l_out;
  END extract_mentions;

  -- ================================================================ internal notes
  FUNCTION get_internal_notes(p_ticket_id IN NUMBER) RETURN t_note_tab PIPELINED IS
    l_note t_note;
  BEGIN
    afh_security_pkg.assert_can_view_restricted(p_ticket_id);
    FOR r IN (SELECT c.comment_id, c.author_user_id, NVL(u.display_name, u.subject_display) AS author_name,
                     c.posted_at, c.body, c.edit_count
                FROM afh_comments c
                LEFT JOIN afh_users u ON u.user_id = c.author_user_id
               WHERE c.ticket_id = p_ticket_id AND c.visibility_code = c_vis_internal AND c.is_archived = 'N'
               ORDER BY c.posted_at, c.comment_id) LOOP
      l_note.comment_id     := r.comment_id;
      l_note.author_user_id := r.author_user_id;
      l_note.author_name    := r.author_name;
      l_note.posted_at      := r.posted_at;
      l_note.body           := r.body;
      l_note.body_html      := render_html(r.body);
      l_note.edit_count     := r.edit_count;
      PIPE ROW (l_note);
    END LOOP;
    RETURN;
  END get_internal_notes;
END afh_comment_pkg;
/
