CREATE OR REPLACE PACKAGE BODY afh_ui_pkg AS

  C_COLORS CONSTANT VARCHAR2(200) := 'neutral;Neutral,info;Info,success;Success,warning;Warning,danger;Danger';
  C_DTYPES CONSTANT VARCHAR2(200) := 'TEXT;Text,TEXTAREA;Text area,NUMBER;Number,DATE;Date,SELECT;Select list,YN;Yes/No';
  C_CLASS  CONSTANT VARCHAR2(200) := 'PRIORITY;Priority,SEVERITY;Severity,IMPACT;Impact';

  -- The one queue cursor every surface shares (spec WU-10: the three views always agree).
  CURSOR c_queue(p_scope VARCHAR2, p_application_id NUMBER, p_status_codes VARCHAR2, p_priority_codes VARCHAR2,
                 p_type_codes VARCHAR2, p_overdue_yn VARCHAR2, p_search_text VARCHAR2, p_status VARCHAR2) IS
    SELECT q.ticket_id, q.ticket_no, q.title, q.type_label, q.application_name, q.page_name,
           q.status_code, q.status_label, q.status_color, q.priority_code, q.priority_label, q.priority_color, q.priority_seq,
           q.severity_label, q.assignee_name, q.owner_name, q.release_label, q.due_date, q.is_overdue_yn, q.days_open,
           q.open_task_count, q.pending_test_count, q.comment_count, q.attachment_count, q.last_activity_at, q.row_version
      FROM afh_v_ticket_queue q
     WHERE (p_status IS NULL OR q.status_code = p_status)
       AND (p_scope = 'ALL' OR (p_scope = 'MINE' AND q.is_mine_yn = 'Y') OR (p_scope = 'OWNER' AND q.is_my_queue_yn = 'Y'))
       AND (p_application_id IS NULL OR q.application_id = p_application_id)
       AND (p_status_codes IS NULL OR q.status_code IN (SELECT column_value FROM TABLE(apex_string.split(p_status_codes, ':'))))
       AND (p_priority_codes IS NULL OR q.priority_code IN (SELECT column_value FROM TABLE(apex_string.split(p_priority_codes, ':'))))
       AND (p_type_codes IS NULL OR q.type_code IN (SELECT column_value FROM TABLE(apex_string.split(p_type_codes, ':'))))
       AND (p_overdue_yn = 'N' OR q.is_overdue_yn = 'Y')
       AND (p_search_text IS NULL OR q.ticket_id IN (SELECT column_value FROM TABLE(afh_search_pkg.search_ticket_ids(p_search_text))))
     ORDER BY q.priority_seq DESC, q.last_activity_at DESC;


  FUNCTION h(p IN VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN apex_escape.html(p); END;
  FUNCTION a(p IN VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN apex_escape.html_attribute(p); END;

  PROCEDURE put(p_clob IN OUT NOCOPY CLOB, p_text IN VARCHAR2) IS
  BEGIN
    IF p_text IS NOT NULL THEN
      DBMS_LOB.writeappend(p_clob, LENGTH(p_text), p_text);
    END IF;
  END put;

  FUNCTION new_clob RETURN CLOB IS
    l CLOB;
  BEGIN
    DBMS_LOB.createtemporary(l, TRUE, DBMS_LOB.call);
    RETURN l;
  END new_clob;

  FUNCTION queue_filter(
    p_scope          IN VARCHAR2,
    p_application_id IN NUMBER,
    p_status_codes   IN VARCHAR2,
    p_priority_codes IN VARCHAR2,
    p_type_codes     IN VARCHAR2,
    p_overdue_yn     IN VARCHAR2,
    p_search         IN VARCHAR2) RETURN t_queue_filter IS
    f t_queue_filter;
  BEGIN
    f.scope_code     := NVL(UPPER(p_scope), 'MINE');
    f.application_id := p_application_id;
    f.status_codes   := p_status_codes;
    f.priority_codes := p_priority_codes;
    f.type_codes     := p_type_codes;
    f.overdue_yn     := NVL(p_overdue_yn, 'N');
    f.search_text    := TRIM(p_search);
    RETURN f;
  END queue_filter;

  FUNCTION pill(p_label IN VARCHAR2, p_token IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    IF p_label IS NULL THEN RETURN NULL; END IF;
    RETURN '<span class="afh-chip' || CASE WHEN p_token IS NOT NULL THEN ' afh-chip--' || a(LOWER(p_token)) END || '">' || h(p_label) || '</span>';
  END pill;

  FUNCTION ticket_link(p_ticket_no IN VARCHAR2, p_app_id IN NUMBER, p_session IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN apex_util.prepare_url('f?p=' || p_app_id || ':10:' || p_session || '::NO::P10_TICKET_NO:' || p_ticket_no);
  END ticket_link;

  FUNCTION card_meta(r c_queue%ROWTYPE) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="afh-card-meta">' || pill(r.priority_label, r.priority_color)
        || '<span>' || h(r.application_name) || '</span><span>·</span><span>' || h(NVL(r.assignee_name, 'Unassigned')) || '</span>'
        || CASE WHEN r.is_overdue_yn = 'Y' THEN '<span class="afh-overdue">overdue</span>' END
        || CASE WHEN r.pending_test_count > 0 THEN '<span class="afh-meta-icon" title="Tests pending"><span class="fa fa-flask" aria-hidden="true"></span> ' || r.pending_test_count || '</span>' END
        || CASE WHEN r.comment_count > 0 THEN '<span class="afh-meta-icon" title="Comments"><span class="fa fa-comment-o" aria-hidden="true"></span> ' || r.comment_count || '</span>' END
        || '</div>';
  END card_meta;

  FUNCTION render_board(p_filter IN t_queue_filter, p_app_id IN NUMBER, p_session IN NUMBER) RETURN CLOB IS
    l CLOB := new_clob();
    l_n PLS_INTEGER;
  BEGIN
    put(l, '<div id="afh-board-alert" class="t-Alert t-Alert--warning afh-board-alert" role="alert" hidden></div>');
    put(l, '<div class="afh-board" id="afh-board-grid" role="list">');
    FOR s IN (SELECT status_code, label, color_token FROM afh_v_workflow_statuses
               WHERE is_terminal = 'N' AND is_active = 'Y' ORDER BY display_seq) LOOP
      l_n := 0;
      put(l, '<section class="afh-board-col" data-status="' || a(s.status_code) || '" role="listitem" aria-label="' || a(s.label) || '">');
      put(l, '<h3 class="afh-board-head afh-status--' || a(LOWER(s.color_token)) || '"><span>' || h(s.label) || '</span><span class="afh-board-count" data-count></span></h3><div class="afh-board-cards">');
      FOR r IN c_queue(p_filter.scope_code, p_filter.application_id, p_filter.status_codes, p_filter.priority_codes, p_filter.type_codes, p_filter.overdue_yn, p_filter.search_text, s.status_code) LOOP
        l_n := l_n + 1;
        put(l, '<article class="afh-card" draggable="true" tabindex="0" data-ticket="' || r.ticket_id || '" data-version="' || r.row_version || '" data-status="' || a(s.status_code) || '">'
             || '<a class="afh-card-no" href="' || ticket_link(r.ticket_no, p_app_id, p_session) || '">' || h(r.ticket_no) || '</a>'
             || '<h4 class="afh-card-title">' || h(r.title) || '</h4>' || card_meta(r) || '</article>');
      END LOOP;
      IF l_n = 0 THEN
        put(l, '<div class="afh-board-empty">Nothing here</div>');
      END IF;
      put(l, '</div></section>');
    END LOOP;
    put(l, '</div>');
    RETURN l;
  END render_board;

  FUNCTION render_queue(p_filter IN t_queue_filter, p_app_id IN NUMBER, p_session IN NUMBER) RETURN CLOB IS
    l CLOB := new_clob();
    l_n PLS_INTEGER := 0;
  BEGIN
    put(l, '<div class="afh-queue-wrap"><table class="afh-queue" id="afh-queue-table"><thead><tr>'
         || '<th class="afh-queue-check"><input type="checkbox" id="afh-queue-all" aria-label="Select all" title="Select all"></th>'
         || '<th>Ticket</th><th>Title</th><th>Status</th><th>Priority</th><th>Application</th><th>Assignee</th><th>Due</th><th class="afh-num">Open</th><th>Activity</th></tr></thead><tbody>');
    FOR r IN c_queue(p_filter.scope_code, p_filter.application_id, p_filter.status_codes, p_filter.priority_codes, p_filter.type_codes, p_filter.overdue_yn, p_filter.search_text, NULL) LOOP
      l_n := l_n + 1;
      put(l, '<tr data-ticket="' || r.ticket_id || '" data-version="' || r.row_version || '"' || CASE WHEN r.is_overdue_yn = 'Y' THEN ' class="afh-row--overdue"' END || '>'
           || '<td class="afh-queue-check"><input type="checkbox" class="afh-queue-pick" value="' || r.ticket_id || ':' || r.row_version || '" aria-label="Select ' || a(r.ticket_no) || '"></td>'
           || '<td><a class="afh-card-no" href="' || ticket_link(r.ticket_no, p_app_id, p_session) || '">' || h(r.ticket_no) || '</a></td>'
           || '<td class="afh-queue-title"><span class="afh-card-title">' || h(r.title) || '</span><span class="afh-meta">' || h(r.type_label) || ' · ' || h(r.page_name) || '</span></td>'
           || '<td>' || pill(r.status_label, r.status_color) || '</td>'
           || '<td>' || pill(r.priority_label, r.priority_color) || '</td>'
           || '<td>' || h(r.application_name) || '</td>'
           || '<td>' || h(NVL(r.assignee_name, 'Unassigned')) || '</td>'
           || '<td>' || CASE WHEN r.due_date IS NULL THEN '<span class="afh-meta">-</span>' ELSE
                          CASE WHEN r.is_overdue_yn = 'Y' THEN '<span class="afh-overdue">' ELSE '<span>' END || TO_CHAR(r.due_date, 'DD Mon') || '</span>' END || '</td>'
           || '<td class="afh-num">' || r.days_open || 'd</td>'
           || '<td><span class="afh-meta">' || TO_CHAR(r.last_activity_at, 'DD Mon HH24:MI') || '</span></td></tr>');
    END LOOP;
    IF l_n = 0 THEN
      put(l, '<tr><td colspan="10" class="afh-queue-empty">No tickets match these filters.</td></tr>');
    END IF;
    put(l, '</tbody></table></div>');
    RETURN l;
  END render_queue;

  FUNCTION render_workload RETURN CLOB IS
    l CLOB := new_clob();
    l_n PLS_INTEGER := 0;
  BEGIN
    put(l, '<div class="afh-workload">');
    FOR w IN (SELECT user_id, display_name, open_count, in_progress_count, ready_test_count, triage_count, overdue_count, critical_count, last_activity_at
                FROM afh_v_workload ORDER BY open_count DESC, display_name) LOOP
      l_n := l_n + 1;
      put(l, '<article class="afh-card afh-workload-card"><div class="afh-workload-head"><span class="afh-avatar" aria-hidden="true">' || h(UPPER(SUBSTR(w.display_name, 1, 1))) || '</span>'
           || '<span class="afh-card-title">' || h(w.display_name) || '</span>'
           || CASE WHEN w.critical_count > 0 THEN '<span class="afh-chip afh-chip--danger" title="Critical tickets">' || w.critical_count || ' critical</span>' END || '</div>'
           || '<div class="afh-workload-big">' || w.open_count || '<span class="afh-meta"> open</span></div>'
           || '<div class="afh-workload-bar" aria-hidden="true">'
           || CASE WHEN w.open_count > 0 THEN
                  '<span class="afh-bar afh-bar--triage" style="width:' || ROUND(100 * w.triage_count / w.open_count) || '%"></span>'
               || '<span class="afh-bar afh-bar--progress" style="width:' || ROUND(100 * w.in_progress_count / w.open_count) || '%"></span>'
               || '<span class="afh-bar afh-bar--test" style="width:' || ROUND(100 * w.ready_test_count / w.open_count) || '%"></span>' END
           || '</div>'
           || '<div class="afh-card-meta"><span>' || w.triage_count || ' to triage</span><span>·</span><span>' || w.in_progress_count || ' in progress</span><span>·</span><span>' || w.ready_test_count || ' in test</span>'
           || CASE WHEN w.overdue_count > 0 THEN '<span class="afh-overdue">' || w.overdue_count || ' overdue</span>' END || '</div></article>');
    END LOOP;
    IF l_n = 0 THEN
      put(l, '<div class="afh-queue-empty">No open work is assigned yet.</div>');
    END IF;
    put(l, '</div>');
    RETURN l;
  END render_workload;

  FUNCTION render_release(p_release_id IN NUMBER) RETURN CLOB IS
    l CLOB := new_clob();
    r afh_v_releases%ROWTYPE;
    l_token VARCHAR2(20);
  BEGIN
    SELECT * INTO r FROM afh_v_releases WHERE release_id = p_release_id;
    l_token := CASE r.state_code WHEN 'COMPLETED' THEN 'success' WHEN 'IN_PROGRESS' THEN 'warning' WHEN 'CANCELLED' THEN 'danger' ELSE 'info' END;
    put(l, '<div class="afh-release"><div class="afh-release-head">'
         || '<span class="afh-eyebrow">' || h(r.application_name) || '</span>'
         || '<h2 class="afh-release-title">' || h(r.release_code) || ' <span class="afh-release-label">' || h(r.label) || '</span></h2>'
         || pill(INITCAP(REPLACE(r.state_code, '_', ' ')), l_token) || '</div>');
    put(l, '<div class="afh-release-stats">'
         || '<div class="afh-stat"><span class="afh-stat-value">' || r.ticket_count || '</span><span class="afh-stat-label">tickets</span></div>'
         || '<div class="afh-stat"><span class="afh-stat-value">' || r.resolved_count || '</span><span class="afh-stat-label">resolved</span></div>'
         || '<div class="afh-stat' || CASE WHEN r.unresolved_count > 0 THEN ' afh-stat--alert' END || '"><span class="afh-stat-value">' || r.unresolved_count || '</span><span class="afh-stat-label">unresolved</span></div>'
         || '<div class="afh-stat"><span class="afh-stat-value">' || NVL(TO_CHAR(r.target_date, 'DD Mon YYYY'), '-') || '</span><span class="afh-stat-label">target</span></div>'
         || '<div class="afh-stat"><span class="afh-stat-value">' || NVL(TO_CHAR(r.completed_date, 'DD Mon YYYY'), '-') || '</span><span class="afh-stat-label">completed</span></div>'
         || '</div>');
    IF r.ticket_count > 0 THEN
      put(l, '<div class="afh-workload-bar afh-release-bar" aria-hidden="true"><span class="afh-bar afh-bar--test" style="width:' || ROUND(100 * r.resolved_count / r.ticket_count) || '%"></span></div>');
    END IF;
    IF r.notes IS NOT NULL THEN
      put(l, '<p class="afh-release-notes">' || REPLACE(h(r.notes), CHR(10), '<br>') || '</p>');
    END IF;
    put(l, '</div>');
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    put(l, '<p class="afh-queue-empty">That release no longer exists.</p>');
    RETURN l;
  END render_release;

  FUNCTION render_notifications(p_filter IN VARCHAR2, p_app_id IN NUMBER, p_session IN NUMBER) RETURN CLOB IS
    l CLOB := new_clob();
    l_n PLS_INTEGER := 0;
    l_icon VARCHAR2(40);
  BEGIN
    put(l, '<ul class="afh-notifs" role="list">');
    FOR n IN (SELECT notification_id, event_code, event_label, ticket_no, title, subject, body, is_read_yn, created_at, actor_display_name, link_target
                FROM afh_v_my_notifications
               WHERE (NVL(p_filter, 'UNREAD') = 'ALL' OR is_read_yn = 'N')
               ORDER BY is_read_yn, created_at DESC
               FETCH FIRST 100 ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_icon := CASE n.event_code WHEN 'ASSIGNMENT' THEN 'fa-user-plus' WHEN 'MENTION' THEN 'fa-at' WHEN 'INFO_REQUEST' THEN 'fa-question-circle'
                  WHEN 'INFO_RESPONSE' THEN 'fa-reply' WHEN 'TEST_REQUEST' THEN 'fa-flask' WHEN 'TEST_OUTCOME' THEN 'fa-check-square-o'
                  WHEN 'RESOLUTION' THEN 'fa-check-circle' WHEN 'REOPENED' THEN 'fa-undo' WHEN 'CLOSURE' THEN 'fa-lock' WHEN 'COMMENT' THEN 'fa-comment-o'
                  WHEN 'DUPLICATE_MERGE' THEN 'fa-compress' ELSE 'fa-bell-o' END;
      put(l, '<li class="afh-notif' || CASE WHEN n.is_read_yn = 'N' THEN ' afh-notif--unread' ELSE ' afh-notif--read' END || '">'
           || '<span class="afh-notif-icon"><span class="fa ' || l_icon || '" aria-hidden="true"></span></span>'
           || '<div class="afh-notif-body">'
           || '<div class="afh-notif-top"><span class="afh-notif-subject">' || h(n.subject) || '</span>'
           || '<span class="afh-meta">' || h(n.event_label) || CASE WHEN n.actor_display_name IS NOT NULL THEN ' · ' || h(n.actor_display_name) END
           || ' · ' || TO_CHAR(n.created_at, 'DD Mon HH24:MI') || '</span></div>'
           || CASE WHEN n.body IS NOT NULL THEN '<p class="afh-notif-text">' || h(SUBSTR(n.body, 1, 400)) || '</p>' END
           || CASE WHEN n.ticket_no IS NOT NULL THEN '<span class="afh-meta"><span class="afh-card-no">' || h(n.ticket_no) || '</span> ' || h(n.title) || '</span>' END
           || '</div><div class="afh-notif-actions">'
           || CASE WHEN n.link_target IS NOT NULL THEN '<a class="t-Button t-Button--small t-Button--hot" href="'
                || apex_util.prepare_url('f?p=' || p_app_id || ':50:' || p_session || ':OPEN:NO::P50_NOTIFICATION_ID:' || n.notification_id) || '">Open</a> ' END
           || CASE WHEN n.is_read_yn = 'N' THEN '<a class="t-Button t-Button--small t-Button--simple" href="'
                || apex_util.prepare_url('f?p=' || p_app_id || ':50:' || p_session || ':MARK_READ:NO::P50_NOTIFICATION_ID:' || n.notification_id) || '">Mark read</a>' END
           || '</div></li>');
    END LOOP;
    IF l_n = 0 THEN
      put(l, '<li class="afh-queue-empty">' || CASE WHEN NVL(p_filter, 'UNREAD') = 'ALL' THEN 'No notifications yet.' ELSE 'Nothing unread. Switch to All to see earlier notifications.' END || '</li>');
    END IF;
    put(l, '</ul>');
    RETURN l;
  END render_notifications;

  FUNCTION render_pref_grid(p_application_id IN NUMBER) RETURN CLOB IS
    l CLOB := new_clob();
    FUNCTION sel(p_name IN VARCHAR2, p_event IN VARCHAR2, p_value IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      RETURN '<select class="afh-pref-select" data-event="' || a(p_event) || '" data-channel="' || p_name || '" aria-label="' || p_name || ' for ' || a(p_event) || '">'
          || '<option value=""' || CASE WHEN p_value IS NULL THEN ' selected' END || '>Use preset</option>'
          || '<option value="Y"' || CASE WHEN p_value = 'Y' THEN ' selected' END || '>On</option>'
          || '<option value="N"' || CASE WHEN p_value = 'N' THEN ' selected' END || '>Off</option></select>';
    END;
  BEGIN
    put(l, '<div class="afh-queue-wrap"><table class="afh-queue afh-prefs" id="afh-pref-table"><thead><tr><th>Event</th><th>Kind</th><th>Email</th><th>In-app</th><th>Preset in force</th><th>Effective</th></tr></thead><tbody>');
    FOR p IN (SELECT event_code, event_label, is_important_yn, is_direct_yn, override_email_yn, override_in_app_yn,
                     effective_preset_code, effective_email_yn, effective_in_app_yn, effective_digest
                FROM afh_v_notification_prefs
               WHERE (p_application_id IS NULL AND scope_code = 'GLOBAL') OR (scope_code = 'APP' AND application_id = p_application_id)
               ORDER BY event_seq) LOOP
      put(l, '<tr data-event="' || a(p.event_code) || '"><td><span class="afh-card-title">' || h(p.event_label) || '</span></td>'
           || '<td>' || CASE WHEN p.is_direct_yn = 'Y' THEN pill('Direct task', 'info') END || ' ' || CASE WHEN p.is_important_yn = 'Y' THEN pill('Important', 'warning') END || '</td>'
           || '<td>' || sel('EMAIL', p.event_code, p.override_email_yn) || '</td>'
           || '<td>' || sel('IN_APP', p.event_code, p.override_in_app_yn) || '</td>'
           || '<td>' || h(p.effective_preset_code) || '</td>'
           || '<td><span class="afh-meta">email ' || CASE p.effective_email_yn WHEN 'Y' THEN 'on' ELSE 'off' END
           || ' · in-app ' || CASE p.effective_in_app_yn WHEN 'Y' THEN 'on' ELSE 'off' END
           || CASE WHEN p.effective_digest IS NOT NULL THEN ' · ' || h(LOWER(p.effective_digest)) END || '</span></td></tr>');
    END LOOP;
    put(l, '</tbody></table></div>');
    RETURN l;
  END render_pref_grid;

  FUNCTION bar_row(p_label IN VARCHAR2, p_value IN NUMBER, p_max IN NUMBER, p_second IN NUMBER DEFAULT NULL, p_second_label IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    l_pct NUMBER := CASE WHEN NVL(p_max, 0) = 0 THEN 0 ELSE ROUND(100 * p_value / p_max) END;
    l_pct2 NUMBER := CASE WHEN NVL(p_max, 0) = 0 OR p_second IS NULL THEN 0 ELSE ROUND(100 * p_second / p_max) END;
  BEGIN
    RETURN '<div class="afh-hbar"><div class="afh-hbar-label">' || h(p_label) || '</div>'
        || '<div class="afh-hbar-track"><span class="afh-hbar-fill" style="width:' || l_pct || '%"></span>'
        || CASE WHEN p_second IS NOT NULL THEN '<span class="afh-hbar-fill afh-hbar-fill--alt" style="width:' || l_pct2 || '%" title="' || a(p_second_label) || '"></span>' END
        || '</div><div class="afh-hbar-value">' || NVL(p_value, 0)
        || CASE WHEN p_second > 0 THEN ' <span class="afh-overdue">(' || p_second || ' ' || h(p_second_label) || ')</span>' END || '</div></div>';
  END bar_row;

  FUNCTION render_aging(p_application_id IN NUMBER) RETURN CLOB IS
    l CLOB := new_clob();
    l_max NUMBER;
    l_n PLS_INTEGER := 0;
  BEGIN
    SELECT NVL(MAX(open_count), 0) INTO l_max FROM afh_v_health_aging WHERE p_application_id IS NULL OR application_id = p_application_id;
    put(l, '<div class="afh-hbars" role="img" aria-label="Open tickets by age">');
    FOR r IN (SELECT age_bucket, SUM(open_count) AS open_count, MIN(age_bucket_seq) AS seq
                FROM afh_v_health_aging WHERE p_application_id IS NULL OR application_id = p_application_id
               GROUP BY age_bucket ORDER BY seq) LOOP
      l_n := l_n + 1;
      put(l, bar_row(r.age_bucket, r.open_count, GREATEST(l_max, r.open_count)));
    END LOOP;
    IF l_n = 0 THEN put(l, '<div class="afh-queue-empty">No open tickets.</div>'); END IF;
    put(l, '</div>');
    RETURN l;
  END render_aging;

  FUNCTION render_by_dimension(p_dimension IN VARCHAR2, p_application_id IN NUMBER, p_environment_id IN NUMBER) RETURN CLOB IS
    l CLOB := new_clob();
    l_max NUMBER := 0;
    l_n PLS_INTEGER := 0;
  BEGIN
    SELECT NVL(MAX(open_count), 0) INTO l_max FROM TABLE(afh_reporting_pkg.health_by_dimension(NVL(p_dimension, 'STATUS'), p_application_id, p_environment_id));
    put(l, '<div class="afh-hbars" role="img" aria-label="Open tickets by ' || a(LOWER(NVL(p_dimension, 'status'))) || '">');
    FOR r IN (SELECT dim_label, open_count, overdue_count, dim_seq
                FROM TABLE(afh_reporting_pkg.health_by_dimension(NVL(p_dimension, 'STATUS'), p_application_id, p_environment_id))
               ORDER BY dim_seq) LOOP
      l_n := l_n + 1;
      put(l, bar_row(NVL(r.dim_label, '-'), r.open_count, l_max, r.overdue_count, 'overdue'));
    END LOOP;
    IF l_n = 0 THEN put(l, '<div class="afh-queue-empty">No open tickets for these filters.</div>'); END IF;
    put(l, '</div>');
    RETURN l;
  END render_by_dimension;

  -- ---------------------------------------------------------------- taxonomy editor (page 64)
  FUNCTION t_text(p_col IN VARCHAR2, p_val IN VARCHAR2, p_ro IN BOOLEAN DEFAULT FALSE, p_size IN PLS_INTEGER DEFAULT 24) RETURN VARCHAR2 IS
  BEGIN
    IF p_ro THEN RETURN '<td><span class="afh-tax-ro" data-col="' || p_col || '">' || h(p_val) || '</span></td>'; END IF;
    RETURN '<td><input type="text" class="afh-tax-input" data-col="' || p_col || '" value="' || a(p_val) || '" size="' || p_size || '"></td>';
  END t_text;
  FUNCTION t_num(p_col IN VARCHAR2, p_val IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<td><input type="number" class="afh-tax-input afh-tax-num" data-col="' || p_col || '" value="' || p_val || '" size="5"></td>';
  END t_num;
  FUNCTION t_select(p_col IN VARCHAR2, p_val IN VARCHAR2, p_options IN VARCHAR2, p_ro IN BOOLEAN DEFAULT FALSE, p_null_label IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    l VARCHAR2(32767);
  BEGIN
    -- p_options: code;label,code;label ...
    IF p_ro THEN
      FOR i IN 1 .. NVL(REGEXP_COUNT(p_options, ','), 0) + 1 LOOP
        IF REGEXP_SUBSTR(REGEXP_SUBSTR(p_options, '[^,]+', 1, i), '^[^;]*') = p_val THEN
          RETURN '<td><span class="afh-tax-ro" data-col="' || p_col || '">' || h(REGEXP_SUBSTR(REGEXP_SUBSTR(p_options, '[^,]+', 1, i), '[^;]+$')) || '</span></td>';
        END IF;
      END LOOP;
      RETURN '<td><span class="afh-tax-ro" data-col="' || p_col || '">' || h(p_val) || '</span></td>';
    END IF;
    l := '<td><select class="afh-tax-input" data-col="' || p_col || '">';
    IF p_null_label IS NOT NULL THEN l := l || '<option value=""' || CASE WHEN p_val IS NULL THEN ' selected' END || '>' || h(p_null_label) || '</option>'; END IF;
    FOR i IN 1 .. NVL(REGEXP_COUNT(p_options, ','), 0) + 1 LOOP
      DECLARE
        l_pair VARCHAR2(4000) := REGEXP_SUBSTR(p_options, '[^,]+', 1, i);
        l_code VARCHAR2(4000) := REGEXP_SUBSTR(l_pair, '^[^;]*');
        l_lab  VARCHAR2(4000) := REGEXP_SUBSTR(l_pair, '[^;]+$');
      BEGIN
        IF l_pair IS NOT NULL THEN
          l := l || '<option value="' || a(l_code) || '"' || CASE WHEN l_code = p_val THEN ' selected' END || '>' || h(l_lab) || '</option>';
        END IF;
      END;
    END LOOP;
    RETURN l || '</select></td>';
  END t_select;
  FUNCTION t_yn(p_col IN VARCHAR2, p_val IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN t_select(p_col, NVL(p_val, 'N'), 'Y;Yes,N;No');
  END t_yn;
  FUNCTION opt_list(p_sql IN VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(32767);
    c SYS_REFCURSOR; l_code VARCHAR2(400); l_lab VARCHAR2(400);
  BEGIN
    OPEN c FOR p_sql;
    LOOP
      FETCH c INTO l_code, l_lab; EXIT WHEN c%NOTFOUND;
      l := l || CASE WHEN l IS NOT NULL THEN ',' END || REPLACE(REPLACE(l_code, ',', ' '), ';', ' ') || ';' || REPLACE(REPLACE(l_lab, ',', ' '), ';', ' ');
    END LOOP;
    CLOSE c;
    RETURN l;
  END opt_list;

  FUNCTION render_taxonomy(p_section IN VARCHAR2) RETURN CLOB IS
    l CLOB := new_clob();
    l_types  VARCHAR2(32767); l_fields VARCHAR2(32767); l_apps VARCHAR2(32767); l_cats VARCHAR2(32767);
    PROCEDURE head(p_cols IN VARCHAR2, p_can_add IN BOOLEAN, p_can_delete IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      put(l, '<div class="afh-queue-wrap"><table class="afh-queue afh-tax" data-section="' || p_section || '"><thead><tr>');
      FOR i IN 1 .. REGEXP_COUNT(p_cols, '\|') + 1 LOOP
        put(l, '<th>' || h(REGEXP_SUBSTR(p_cols, '[^|]+', 1, i)) || '</th>');
      END LOOP;
      IF p_can_delete THEN put(l, '<th>Remove</th>'); END IF;
      put(l, '</tr></thead><tbody>');
    END head;
    PROCEDURE tail(p_can_add IN BOOLEAN, p_template IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      IF p_can_add AND p_template IS NOT NULL THEN
        put(l, '<tr class="afh-tax-template" hidden data-id="">' || p_template || '</tr>');
      END IF;
      put(l, '</tbody></table></div>');
    END tail;
    FUNCTION del_cell RETURN VARCHAR2 IS
    BEGIN RETURN '<td><input type="checkbox" class="afh-tax-input afh-tax-del" data-col="_DELETE" value="Y" aria-label="Remove"></td>'; END;
  BEGIN
    CASE p_section
      WHEN 'TYPES' THEN
        head('Code|Label|Help text|Icon|Order|Active|Fields|Tickets', TRUE);
        FOR r IN (SELECT * FROM afh_v_taxonomy_types ORDER BY display_seq) LOOP
          put(l, '<tr data-id="' || r.feedback_type_id || '">' || t_text('TYPE_CODE', r.type_code, TRUE) || t_text('LABEL', r.label) || t_text('HELP_TEXT', r.help_text, FALSE, 40)
               || t_text('ICON_TOKEN', r.icon_token, FALSE, 14) || t_num('DISPLAY_SEQ', r.display_seq) || t_yn('IS_ACTIVE', r.is_active)
               || '<td class="afh-num">' || r.field_count || '</td><td class="afh-num">' || r.ticket_count || '</td></tr>');
        END LOOP;
        tail(TRUE, t_text('TYPE_CODE', NULL, FALSE, 14) || t_text('LABEL', NULL) || t_text('HELP_TEXT', NULL, FALSE, 40) || t_text('ICON_TOKEN', NULL, FALSE, 14) || t_num('DISPLAY_SEQ', 100) || t_yn('IS_ACTIVE', 'Y') || '<td></td><td></td>');
      WHEN 'FIELDS' THEN
        head('Code|Label|Type|Max length|Help text|List values (CODE:Label;...)|Active|Used by', TRUE);
        FOR r IN (SELECT * FROM afh_v_taxonomy_fields ORDER BY field_code) LOOP
          put(l, '<tr data-id="' || r.field_definition_id || '">' || t_text('FIELD_CODE', r.field_code, TRUE) || t_text('LABEL', r.label) || t_select('DATA_TYPE', r.data_type, C_DTYPES)
               || t_num('MAX_LENGTH', r.max_length) || t_text('HELP_TEXT', r.help_text, FALSE, 30) || t_text('LOV_VALUES', r.lov_values, FALSE, 30) || t_yn('IS_ACTIVE', r.is_active)
               || '<td>' || h(r.type_codes) || '</td></tr>');
        END LOOP;
        tail(TRUE, t_text('FIELD_CODE', NULL, FALSE, 14) || t_text('LABEL', NULL) || t_select('DATA_TYPE', 'TEXT', C_DTYPES) || t_num('MAX_LENGTH', NULL) || t_text('HELP_TEXT', NULL, FALSE, 30) || t_text('LOV_VALUES', NULL, FALSE, 30) || t_yn('IS_ACTIVE', 'Y') || '<td></td>');
      WHEN 'TYPE_FIELDS' THEN
        l_types := opt_list('SELECT type_code, label || '' ('' || type_code || '')'' FROM afh_feedback_types ORDER BY display_seq');
        l_fields := opt_list('SELECT field_code, label || '' ('' || field_code || '')'' FROM afh_field_definitions WHERE is_active = ''Y'' ORDER BY label');
        head('Type|Field|Required|Order|Label override|Effective label|Data type', TRUE, TRUE);
        FOR r IN (SELECT * FROM afh_v_type_fields ORDER BY type_label, display_seq) LOOP
          put(l, '<tr data-id="' || r.type_field_id || '">' || t_select('TYPE_CODE', r.type_code, l_types, TRUE) || t_select('FIELD_CODE', r.field_code, l_fields, TRUE)
               || t_yn('IS_REQUIRED', r.is_required) || t_num('DISPLAY_SEQ', r.display_seq) || t_text('LABEL_OVERRIDE', r.label_override)
               || '<td>' || h(r.effective_label) || '</td><td>' || h(r.data_type) || '</td>' || del_cell || '</tr>');
        END LOOP;
        tail(TRUE, t_select('TYPE_CODE', NULL, l_types, FALSE, '- type -') || t_select('FIELD_CODE', NULL, l_fields, FALSE, '- field -') || t_yn('IS_REQUIRED', 'N') || t_num('DISPLAY_SEQ', 100) || t_text('LABEL_OVERRIDE', NULL) || '<td></td><td></td><td></td>');
      WHEN 'CATEGORIES' THEN
        l_apps := opt_list('SELECT TO_CHAR(application_id), display_name FROM afh_v_applications ORDER BY display_name');
        l_cats := opt_list('SELECT TO_CHAR(category_id), label FROM afh_categories ORDER BY label');
        head('Scope|Code|Label|Parent|Order|Active|Tickets', TRUE);
        FOR r IN (SELECT * FROM afh_v_categories ORDER BY scope, display_seq, label) LOOP
          put(l, '<tr data-id="' || r.category_id || '">' || t_select('APPLICATION_ID', TO_CHAR(r.application_id), l_apps, TRUE, 'Global') || t_text('CATEGORY_CODE', r.category_code, TRUE)
               || t_text('LABEL', r.label) || t_select('PARENT_CATEGORY_ID', TO_CHAR(r.parent_category_id), l_cats, FALSE, '- none -') || t_num('DISPLAY_SEQ', r.display_seq)
               || t_yn('IS_ACTIVE', r.is_active) || '<td class="afh-num">' || r.ticket_count || '</td></tr>');
        END LOOP;
        tail(TRUE, t_select('APPLICATION_ID', NULL, l_apps, FALSE, 'Global') || t_text('CATEGORY_CODE', NULL, FALSE, 14) || t_text('LABEL', NULL) || t_select('PARENT_CATEGORY_ID', NULL, l_cats, FALSE, '- none -') || t_num('DISPLAY_SEQ', 100) || t_yn('IS_ACTIVE', 'Y') || '<td></td>');
      WHEN 'CLASSIFICATION' THEN
        head('Class|Code|Label|Order|Active|Default|Colour', TRUE);
        FOR r IN (SELECT * FROM afh_v_classification_values ORDER BY class_type, display_seq) LOOP
          put(l, '<tr data-id="' || r.classification_value_id || '">' || t_select('CLASS_TYPE', r.class_type, C_CLASS, TRUE) || t_text('VALUE_CODE', r.value_code, TRUE)
               || t_text('LABEL', r.label) || t_num('DISPLAY_SEQ', r.display_seq) || t_yn('IS_ACTIVE', r.is_active) || t_yn('IS_DEFAULT', r.is_default)
               || t_select('COLOR_TOKEN', r.color_token, C_COLORS) || '</tr>');
        END LOOP;
        tail(TRUE, t_select('CLASS_TYPE', 'PRIORITY', C_CLASS) || t_text('VALUE_CODE', NULL, FALSE, 14) || t_text('LABEL', NULL) || t_num('DISPLAY_SEQ', 100) || t_yn('IS_ACTIVE', 'Y') || t_yn('IS_DEFAULT', 'N') || t_select('COLOR_TOKEN', 'neutral', C_COLORS));
      WHEN 'STATUSES' THEN
        head('Code|Label|Order|Colour|Description|Terminal|Active|Tickets', FALSE);
        FOR r IN (SELECT * FROM afh_v_workflow_statuses ORDER BY display_seq) LOOP
          put(l, '<tr data-id="' || r.workflow_status_id || '">' || t_text('STATUS_CODE', r.status_code, TRUE) || t_text('LABEL', r.label) || t_num('DISPLAY_SEQ', r.display_seq)
               || t_select('COLOR_TOKEN', r.color_token, C_COLORS) || t_text('DESCRIPTION', r.description, FALSE, 40) || '<td>' || h(r.is_terminal) || '</td>'
               || t_yn('IS_ACTIVE', r.is_active) || '<td class="afh-num">' || r.ticket_count || '</td></tr>');
        END LOOP;
        tail(FALSE);
      WHEN 'TRANSITIONS' THEN
        head('From|To|Button label|Actors|Required facts|Reason required|Active|Order|Description', FALSE);
        FOR r IN (SELECT * FROM afh_v_workflow_transitions ORDER BY from_seq, display_seq, to_seq) LOOP
          put(l, '<tr data-id="' || r.workflow_transition_id || '"><td>' || h(r.from_label) || '</td><td>' || h(r.to_label) || '</td>' || t_text('LABEL', r.label)
               || '<td>' || h(r.actors_text) || '</td><td>' || h(r.required_facts) || '</td>' || t_yn('REASON_REQUIRED', r.reason_required) || t_yn('IS_ACTIVE', r.is_active)
               || t_num('DISPLAY_SEQ', r.display_seq) || t_text('DESCRIPTION', r.description, FALSE, 30) || '</tr>');
        END LOOP;
        tail(FALSE);
      ELSE
        put(l, '<p class="afh-queue-empty">Unknown section.</p>');
    END CASE;
    RETURN l;
  END render_taxonomy;

  FUNCTION save_taxonomy(p_section IN VARCHAR2, p_json IN CLOB) RETURN VARCHAR2 IS
    l_n PLS_INTEGER; l_saved PLS_INTEGER := 0; l_removed PLS_INTEGER := 0;
    FUNCTION v(p_path IN VARCHAR2, p_i IN PLS_INTEGER) RETURN VARCHAR2 IS
    BEGIN RETURN apex_json.get_varchar2(p_path => 'rows[%d].' || p_path, p0 => p_i); END;
    FUNCTION n(p_path IN VARCHAR2, p_i IN PLS_INTEGER) RETURN NUMBER IS
    BEGIN RETURN TO_NUMBER(v(p_path, p_i)); END;
  BEGIN
    afh_security_pkg.assert_admin;
    apex_json.parse(p_json);
    l_n := apex_json.get_count(p_path => 'rows');
    FOR i IN 1 .. NVL(l_n, 0) LOOP
      CASE p_section
        WHEN 'TYPES' THEN
          afh_taxonomy_pkg.save_type(n('ID', i), v('TYPE_CODE', i), v('LABEL', i), v('HELP_TEXT', i), v('ICON_TOKEN', i), n('DISPLAY_SEQ', i), NVL(v('IS_ACTIVE', i), 'Y'));
        WHEN 'FIELDS' THEN
          afh_taxonomy_pkg.save_field(n('ID', i), v('FIELD_CODE', i), v('LABEL', i), v('DATA_TYPE', i), n('MAX_LENGTH', i), v('HELP_TEXT', i), v('LOV_VALUES', i), NVL(v('IS_ACTIVE', i), 'Y'));
        WHEN 'TYPE_FIELDS' THEN
          IF v('_DELETE', i) = 'Y' AND n('ID', i) IS NOT NULL THEN
            afh_taxonomy_pkg.remove_type_field(n('ID', i)); l_removed := l_removed + 1; CONTINUE;
          END IF;
          afh_taxonomy_pkg.save_type_field(n('ID', i), v('TYPE_CODE', i), v('FIELD_CODE', i), NVL(v('IS_REQUIRED', i), 'N'), n('DISPLAY_SEQ', i), v('LABEL_OVERRIDE', i));
        WHEN 'CATEGORIES' THEN
          afh_taxonomy_pkg.save_category(n('ID', i), n('APPLICATION_ID', i), v('CATEGORY_CODE', i), v('LABEL', i), n('PARENT_CATEGORY_ID', i), n('DISPLAY_SEQ', i), NVL(v('IS_ACTIVE', i), 'Y'));
        WHEN 'CLASSIFICATION' THEN
          afh_taxonomy_pkg.save_classification_value(n('ID', i), v('CLASS_TYPE', i), v('VALUE_CODE', i), v('LABEL', i), n('DISPLAY_SEQ', i), NVL(v('IS_ACTIVE', i), 'Y'), NVL(v('IS_DEFAULT', i), 'N'), v('COLOR_TOKEN', i));
        WHEN 'STATUSES' THEN
          afh_taxonomy_pkg.save_status(n('ID', i), v('LABEL', i), n('DISPLAY_SEQ', i), v('COLOR_TOKEN', i), v('DESCRIPTION', i), NVL(v('IS_ACTIVE', i), 'Y'));
        WHEN 'TRANSITIONS' THEN
          afh_taxonomy_pkg.save_transition(n('ID', i), v('LABEL', i), NVL(v('REASON_REQUIRED', i), 'N'), NVL(v('IS_ACTIVE', i), 'Y'), n('DISPLAY_SEQ', i), v('DESCRIPTION', i));
        ELSE
          afh_security_pkg.raise_error('AFH-VAL-001', 'Unknown taxonomy section.');
      END CASE;
      l_saved := l_saved + 1;
    END LOOP;
    RETURN l_saved || ' row(s) saved' || CASE WHEN l_removed > 0 THEN ', ' || l_removed || ' removed' END || '.';
  END save_taxonomy;

  -- ---------------------------------------------------------------- timeline (page 10)
  FUNCTION event_icon(p_event_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE
      WHEN p_event_code = 'TICKET_CREATED'          THEN 'fa-plus-circle'
      WHEN p_event_code = 'STATUS_CHANGED'          THEN 'fa-exchange'
      WHEN p_event_code = 'TICKET_ASSIGNED'         THEN 'fa-user'
      WHEN p_event_code = 'TICKET_CLASSIFIED'       THEN 'fa-tag'
      WHEN p_event_code = 'TICKET_RELEASE_CHANGED'  THEN 'fa-rocket'
      WHEN p_event_code = 'TICKET_RELATION_CHANGED' THEN 'fa-link'
      WHEN p_event_code LIKE 'TEST%'                THEN 'fa-check-square-o'
      WHEN p_event_code LIKE '%FOLLOW%'             THEN 'fa-eye'
      ELSE 'fa-history' END;
  END event_icon;

  FUNCTION render_timeline(p_ticket_id IN NUMBER, p_app_id IN NUMBER, p_session IN NUMBER) RETURN CLOB IS
    l       CLOB := new_clob;
    l_n     PLS_INTEGER := 0;
    l_label VARCHAR2(255);
  BEGIN
    put(l, '<ol class="afh-timeline" aria-label="Activity">');
    FOR r IN (SELECT entry_type, entry_id, event_at, actor_display_name, event_code, summary, body_html, file_name
                FROM afh_v_ticket_timeline
               WHERE ticket_id = p_ticket_id
               ORDER BY event_at, entry_type, entry_id) LOOP
      l_n := l_n + 1;
      l_label := CASE r.entry_type WHEN 'COMMENT' THEN 'Comment' WHEN 'ATTACHMENT' THEN 'Attachment'
                 ELSE INITCAP(REPLACE(r.event_code, '_', ' ')) END;
      put(l, '<li class="afh-tl afh-tl--' || LOWER(r.entry_type) || '" data-entry="' || a(r.entry_type || ':' || r.entry_id) || '">'
          || '<span class="afh-tl-dot" aria-hidden="true">'
          || CASE r.entry_type
               WHEN 'COMMENT'    THEN h(UPPER(SUBSTR(NVL(r.actor_display_name, '?'), 1, 1)))
               WHEN 'ATTACHMENT' THEN '<span class="fa fa-paperclip"></span>'
               ELSE '<span class="fa ' || event_icon(r.event_code) || '"></span>' END
          || '</span><div class="afh-tl-main"><div class="afh-tl-meta"><strong>' || h(NVL(r.actor_display_name, 'System'))
          || '</strong><span class="afh-tl-time">' || TO_CHAR(r.event_at, 'DD Mon YYYY HH24:MI') || '</span>'
          || '<span class="afh-eyebrow">' || h(l_label) || '</span></div>');
      IF r.entry_type = 'COMMENT' THEN
        put(l, '<div class="afh-tl-body">');
        IF r.body_html IS NOT NULL THEN
          DBMS_LOB.append(l, r.body_html);
        END IF;
        put(l, '</div>');
      ELSIF r.entry_type = 'ATTACHMENT' THEN
        put(l, '<div class="afh-tl-text">Attached <strong>' || h(r.file_name) || '</strong>'
            || CASE WHEN r.summary IS NOT NULL AND r.summary <> r.file_name THEN ' <span class="afh-meta">' || h(r.summary) || '</span>' END
            || '</div>');
      ELSE
        put(l, '<div class="afh-tl-text">' || h(r.summary) || '</div>');
      END IF;
      put(l, '</div></li>');
    END LOOP;
    IF l_n = 0 THEN
      put(l, '<li class="afh-tl-empty">No activity yet.</li>');
    END IF;
    put(l, '</ol>');
    RETURN l;
  END render_timeline;

END afh_ui_pkg;
/
