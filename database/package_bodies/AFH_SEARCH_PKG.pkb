CREATE OR REPLACE PACKAGE BODY afh_search_pkg AS
  -- ---------------------------------------------------------------------------
  -- AFH_SEARCH_PKG body. Spec §15, WU-07.
  -- Duplicate score (spec §15.2):
  --   score = ROUND( title_sim * DUP_W_TITLE/100
  --                + desc_sim  * DUP_W_DESC/100
  --                + (same application ? DUP_W_APP  : 0)
  --                + (same application AND same page ? DUP_W_PAGE : 0)
  --                + (same type ? DUP_W_TYPE : 0) )
  --   title_sim / desc_sim = UTL_MATCH.JARO_WINKLER_SIMILARITY (0..100) of the
  --   normalized texts; a NULL on either side contributes 0, never 100.
  --   Environment is deliberately absent from the formula.
  -- ---------------------------------------------------------------------------

  c_norm_max       CONSTANT PLS_INTEGER := 4000;   -- normalize_text output cap
  c_desc_norm_max  CONSTANT PLS_INTEGER := 1000;   -- spec §15.2: first 1,000 normalized chars
  -- Raw characters read from a CLOB before normalizing. 8,000 chars is safe under the
  -- 32,767-byte VARCHAR2 limit for 4-byte UTF-8; normalized output never exceeds 4,000.
  c_raw_read_chars CONSTANT PLS_INTEGER := 8000;
  c_max_tokens     CONSTANT PLS_INTEGER := 8;
  c_min_token_len  CONSTANT PLS_INTEGER := 2;
  c_chain_depth    CONSTANT PLS_INTEGER := 20;
  c_weights_ttl_s  CONSTANT PLS_INTEGER := 60;

  TYPE t_weights IS RECORD (
    w_title NUMBER, w_desc NUMBER, w_app NUMBER, w_page NUMBER, w_type NUMBER,
    threshold NUMBER, max_rows NUMBER, loaded_at TIMESTAMP);
  g_w t_weights;

  -- ================================================================ private: config
  -- Weights are read from AFH_INSTALL_CONFIG and cached for c_weights_ttl_s seconds so
  -- score() stays cheap when called once per ticket row from SQL.
  PROCEDURE load_weights IS
  BEGIN
    IF g_w.loaded_at IS NOT NULL
       AND g_w.loaded_at > SYSTIMESTAMP - NUMTODSINTERVAL(c_weights_ttl_s, 'SECOND') THEN
      RETURN;
    END IF;
    g_w.w_title   := NVL(afh_security_pkg.config_number('DUP_W_TITLE',   55), 55);
    g_w.w_desc    := NVL(afh_security_pkg.config_number('DUP_W_DESC',    20), 20);
    g_w.w_app     := NVL(afh_security_pkg.config_number('DUP_W_APP',     15), 15);
    g_w.w_page    := NVL(afh_security_pkg.config_number('DUP_W_PAGE',     5),  5);
    g_w.w_type    := NVL(afh_security_pkg.config_number('DUP_W_TYPE',     5),  5);
    g_w.threshold := NVL(afh_security_pkg.config_number('DUP_THRESHOLD', 65), 65);
    g_w.max_rows  := NVL(afh_security_pkg.config_number('DUP_MAX',        5),  5);
    g_w.loaded_at := SYSTIMESTAMP;
  END load_weights;

  -- ================================================================ normalization
  FUNCTION normalize_text(p_text IN CLOB) RETURN VARCHAR2 IS
    l_raw VARCHAR2(32767);
    l_out VARCHAR2(32767);
  BEGIN
    IF p_text IS NULL OR DBMS_LOB.getlength(p_text) = 0 THEN
      RETURN NULL;
    END IF;
    l_raw := DBMS_LOB.substr(p_text, c_raw_read_chars, 1);
    -- [[:alnum:]] is locale-aware, so non-Latin letters survive; punctuation, symbols and
    -- whitespace runs collapse to a single space. Numbers are kept (spec §15.2).
    l_out := TRIM(REGEXP_REPLACE(UPPER(l_raw), '[^[:alnum:]]+', ' '));
    RETURN SUBSTR(l_out, 1, c_norm_max);
  END normalize_text;

  FUNCTION normalize_description(p_description IN CLOB) RETURN VARCHAR2 IS
  BEGIN
    RETURN SUBSTR(normalize_text(p_description), 1, c_desc_norm_max);
  END normalize_description;

  -- ================================================================ scoring
  FUNCTION text_sim(p_a IN VARCHAR2, p_b IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF p_a IS NULL OR p_b IS NULL THEN
      RETURN 0;
    END IF;
    RETURN UTL_MATCH.jaro_winkler_similarity(p_a, p_b);
  END text_sim;

  FUNCTION same_app(p_a IN NUMBER, p_b IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN p_a IS NOT NULL AND p_b IS NOT NULL AND p_a = p_b;
  END same_app;

  FUNCTION score(
    p_title_norm_a  IN VARCHAR2, p_desc_norm_a IN VARCHAR2, p_application_id_a IN NUMBER, p_page_id_a IN NUMBER, p_type_id_a IN NUMBER,
    p_title_norm_b  IN VARCHAR2, p_desc_norm_b IN VARCHAR2, p_application_id_b IN NUMBER, p_page_id_b IN NUMBER, p_type_id_b IN NUMBER) RETURN NUMBER IS
    l_total NUMBER;
    l_same_app BOOLEAN;
  BEGIN
    load_weights;
    l_same_app := same_app(p_application_id_a, p_application_id_b);
    l_total := text_sim(p_title_norm_a, p_title_norm_b) * g_w.w_title / 100
             + text_sim(p_desc_norm_a,  p_desc_norm_b)  * g_w.w_desc  / 100;
    IF l_same_app THEN
      l_total := l_total + g_w.w_app;
      IF p_page_id_a IS NOT NULL AND p_page_id_b IS NOT NULL AND p_page_id_a = p_page_id_b THEN
        l_total := l_total + g_w.w_page;
      END IF;
    END IF;
    IF p_type_id_a IS NOT NULL AND p_type_id_b IS NOT NULL AND p_type_id_a = p_type_id_b THEN
      l_total := l_total + g_w.w_type;
    END IF;
    RETURN ROUND(l_total);
  END score;

  -- ================================================================ duplicate candidates
  -- 'FB-0042', 'fb 42', '42' -> 'FB-0042'; NULL when the text is not a bare ticket number.
  FUNCTION ticket_no_from_text(p_text IN VARCHAR2) RETURN VARCHAR2 IS
    l_digits VARCHAR2(40);
  BEGIN
    IF NOT REGEXP_LIKE(TRIM(p_text), '^(FB[- ]?)?[0-9]{1,20}$', 'i') THEN
      RETURN NULL;
    END IF;
    l_digits := REGEXP_SUBSTR(TRIM(p_text), '[0-9]+$');
    RETURN 'FB-' || LPAD(TO_NUMBER(l_digits), 4, '0');
  END ticket_no_from_text;

  FUNCTION type_id_of(p_type_code IN VARCHAR2) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    IF p_type_code IS NULL THEN RETURN NULL; END IF;
    SELECT MIN(feedback_type_id) INTO l_id
      FROM afh_feedback_types WHERE type_code = UPPER(TRIM(p_type_code));
    RETURN l_id;
  END type_id_of;

  FUNCTION explain(p_c IN t_candidate) RETURN VARCHAR2 IS
    l_txt VARCHAR2(500);
  BEGIN
    IF p_c.exact_no_match = 'Y' THEN
      l_txt := 'Exact ticket number';
    ELSE
      l_txt := 'Title ' || p_c.title_score || '%';
      IF p_c.desc_score > 0 THEN l_txt := l_txt || ' · Description ' || p_c.desc_score || '%'; END IF;
    END IF;
    IF p_c.same_app_yn  = 'Y' THEN l_txt := l_txt || ' · Same application'; END IF;
    IF p_c.same_page_yn = 'Y' THEN l_txt := l_txt || ' · Same page'; END IF;
    IF p_c.same_type_yn = 'Y' THEN l_txt := l_txt || ' · Same type'; END IF;
    RETURN l_txt;
  END explain;

  -- Full scan with score() evaluated per row. At the target scale (thousands of tickets)
  -- this is fast enough and keeps one formula. At 10x scale the lever is a prefilter on
  -- title_norm (first-word / prefix index) before scoring — not needed yet.
  FUNCTION collect_candidates(
    p_title_norm IN VARCHAR2, p_desc_norm IN VARCHAR2, p_application_id IN NUMBER,
    p_page_id IN NUMBER, p_type_id IN NUMBER, p_exact_no IN VARCHAR2,
    p_exclude_ticket_id IN NUMBER) RETURN t_candidate_tab IS
    l_rows t_candidate_tab := t_candidate_tab();
  BEGIN
    FOR r IN (
      SELECT * FROM (
        SELECT t.ticket_id, t.ticket_no, t.title, t.status_code,
               NVL(s.label, t.status_code) AS status_label, NVL(s.is_terminal, 'N') AS is_terminal,
               a.display_name AS application_name, t.page_name, t.last_activity_at,
               t.title_norm, t.desc_norm, t.application_id, t.page_id, t.feedback_type_id,
               CASE WHEN t.ticket_no = p_exact_no THEN 'Y' ELSE 'N' END AS exact_yn,
               afh_search_pkg.score(p_title_norm, p_desc_norm, p_application_id, p_page_id, p_type_id,
                                    t.title_norm, t.desc_norm, t.application_id, t.page_id, t.feedback_type_id) AS sc
          FROM afh_tickets t
          LEFT JOIN afh_workflow_statuses s ON s.status_code = t.status_code
          LEFT JOIN afh_applications a ON a.application_id = t.application_id
         WHERE (p_exclude_ticket_id IS NULL OR t.ticket_id <> p_exclude_ticket_id))
       WHERE exact_yn = 'Y' OR sc >= g_w.threshold
       ORDER BY exact_yn DESC, sc DESC, is_terminal ASC, last_activity_at DESC NULLS LAST
       FETCH FIRST g_w.max_rows ROWS ONLY) LOOP
      l_rows.EXTEND;
      l_rows(l_rows.COUNT).ticket_id        := r.ticket_id;
      l_rows(l_rows.COUNT).ticket_no        := r.ticket_no;
      l_rows(l_rows.COUNT).title            := r.title;
      l_rows(l_rows.COUNT).status_code      := r.status_code;
      l_rows(l_rows.COUNT).status_label     := r.status_label;
      l_rows(l_rows.COUNT).is_terminal      := r.is_terminal;
      l_rows(l_rows.COUNT).application_name := r.application_name;
      l_rows(l_rows.COUNT).page_name        := r.page_name;
      l_rows(l_rows.COUNT).last_activity_at := r.last_activity_at;
      l_rows(l_rows.COUNT).exact_no_match   := r.exact_yn;
      l_rows(l_rows.COUNT).score            := CASE WHEN r.exact_yn = 'Y' THEN 100 ELSE r.sc END;
      l_rows(l_rows.COUNT).title_score      := text_sim(p_title_norm, r.title_norm);
      l_rows(l_rows.COUNT).desc_score       := text_sim(p_desc_norm, r.desc_norm);
      l_rows(l_rows.COUNT).same_app_yn      := CASE WHEN same_app(p_application_id, r.application_id) THEN 'Y' ELSE 'N' END;
      l_rows(l_rows.COUNT).same_page_yn     := CASE WHEN same_app(p_application_id, r.application_id)
                                                     AND p_page_id IS NOT NULL AND r.page_id = p_page_id THEN 'Y' ELSE 'N' END;
      l_rows(l_rows.COUNT).same_type_yn     := CASE WHEN p_type_id IS NOT NULL AND r.feedback_type_id = p_type_id THEN 'Y' ELSE 'N' END;
      l_rows(l_rows.COUNT).explanation      := explain(l_rows(l_rows.COUNT));
    END LOOP;
    RETURN l_rows;
  END collect_candidates;

  -- Health event for a failed similarity search. log_integration_failure is autonomous,
  -- so it also works when this function is called from SQL (TABLE(...)) and survives a
  -- rollback. Never let the health write itself fail the caller.
  PROCEDURE record_search_failure(p_detail IN VARCHAR2) IS
  BEGIN
    afh_audit_pkg.log_integration_failure(
      p_event_code  => 'CAPTURE',
      p_safe_detail => 'duplicate search failed: ' || SUBSTR(p_detail, 1, 500));
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END record_search_failure;

  FUNCTION duplicate_candidates(
    p_title             IN VARCHAR2,
    p_description       IN CLOB,
    p_application_id    IN NUMBER,
    p_page_id           IN NUMBER,
    p_type_code         IN VARCHAR2,
    p_exclude_ticket_id IN NUMBER   DEFAULT NULL,
    p_raise_on_error    IN VARCHAR2 DEFAULT 'N') RETURN t_candidate_tab PIPELINED IS
    l_rows t_candidate_tab;
  BEGIN
    BEGIN
      load_weights;
      l_rows := collect_candidates(
        p_title_norm        => normalize_text(TO_CLOB(p_title)),
        p_desc_norm         => normalize_description(p_description),
        p_application_id    => p_application_id,
        p_page_id           => p_page_id,
        p_type_id           => type_id_of(p_type_code),
        p_exact_no          => ticket_no_from_text(p_title),
        p_exclude_ticket_id => p_exclude_ticket_id);
    EXCEPTION
      WHEN OTHERS THEN
        record_search_failure(SQLERRM);
        IF p_raise_on_error = 'Y' THEN
          afh_security_pkg.raise_error(afh_security_pkg.c_err_srch_001,
            'Similar-ticket suggestions are unavailable right now. You can submit without them.');
        END IF;
        RETURN;
    END;
    FOR i IN 1 .. l_rows.COUNT LOOP
      PIPE ROW (l_rows(i));
    END LOOP;
    RETURN;
  END duplicate_candidates;

  -- ================================================================ general search
  -- Tokens: the query is normalized like stored facts (UPPER, alnum only), split on
  -- spaces, tokens shorter than 2 characters dropped, at most 8 kept. Because tokens
  -- are alphanumeric they can never carry LIKE wildcards or SQL text.
  FUNCTION tokens_of(p_text IN VARCHAR2) RETURN apex_t_varchar2 IS
    l_parts  apex_t_varchar2;
    l_tokens apex_t_varchar2 := apex_t_varchar2();
    l_norm   VARCHAR2(4000);
  BEGIN
    l_norm := normalize_text(TO_CLOB(p_text));
    IF l_norm IS NULL THEN RETURN l_tokens; END IF;
    l_parts := apex_string.split(l_norm, ' ');
    FOR i IN 1 .. l_parts.COUNT LOOP
      EXIT WHEN l_tokens.COUNT >= c_max_tokens;
      IF LENGTH(l_parts(i)) >= c_min_token_len THEN
        l_tokens.EXTEND;
        l_tokens(l_tokens.COUNT) := l_parts(i);
      END IF;
    END LOOP;
    RETURN l_tokens;
  END tokens_of;

  -- A ticket matches when EVERY token is found in at least one public fact. Comment
  -- bodies are searched with INSTR on the CLOB (no 4,000-char limit) and only PUBLIC,
  -- non-archived comments are considered. Internal notes and context are never read.
  FUNCTION search_tickets(p_text IN VARCHAR2) RETURN t_hit_tab PIPELINED IS
    l_tokens apex_t_varchar2 := tokens_of(p_text);
    l_cnt    PLS_INTEGER := l_tokens.COUNT;
    l_hit    t_hit;
  BEGIN
    IF l_cnt = 0 THEN RETURN; END IF;
    FOR r IN (
      SELECT x.ticket_id, x.title_hits, x.comment_hits
        FROM (
          SELECT t.ticket_id,
                 (SELECT COUNT(*) FROM TABLE(l_tokens) tk
                   WHERE t.title_norm LIKE '%' || tk.column_value || '%') AS title_hits,
                 (SELECT COUNT(*) FROM TABLE(l_tokens) tk
                   WHERE EXISTS (SELECT 1 FROM afh_comments c
                                  WHERE c.ticket_id = t.ticket_id AND c.visibility_code = 'PUBLIC'
                                    AND c.is_archived = 'N'
                                    AND INSTR(UPPER(c.body), tk.column_value) > 0)) AS comment_hits,
                 (SELECT COUNT(*) FROM TABLE(l_tokens) tk
                   WHERE t.title_norm LIKE '%' || tk.column_value || '%'
                      OR t.desc_norm  LIKE '%' || tk.column_value || '%'
                      OR UPPER(t.ticket_no || ' ' || a.display_name || ' ' || t.page_name || ' ' || e.label || ' ' ||
                               ft.label || ' ' || cat.label || ' ' || st.label || ' ' ||
                               ru.display_name || ' ' || ru.subject_display || ' ' ||
                               au.display_name || ' ' || au.subject_display || ' ' || rel.label)
                         LIKE '%' || tk.column_value || '%'
                      OR EXISTS (SELECT 1 FROM afh_comments c
                                  WHERE c.ticket_id = t.ticket_id AND c.visibility_code = 'PUBLIC'
                                    AND c.is_archived = 'N'
                                    AND INSTR(UPPER(c.body), tk.column_value) > 0)) AS all_hits
            FROM afh_tickets t
            LEFT JOIN afh_applications a    ON a.application_id = t.application_id
            LEFT JOIN afh_environments e    ON e.environment_id = t.environment_id
            LEFT JOIN afh_feedback_types ft ON ft.feedback_type_id = t.feedback_type_id
            LEFT JOIN afh_categories cat    ON cat.category_id = t.category_id
            LEFT JOIN afh_workflow_statuses st ON st.status_code = t.status_code
            LEFT JOIN afh_users ru          ON ru.user_id = t.reporter_user_id
            LEFT JOIN afh_users au          ON au.user_id = t.assignee_user_id
            LEFT JOIN afh_releases rel      ON rel.release_id = t.release_id) x
       WHERE x.all_hits = l_cnt) LOOP
      l_hit.ticket_id  := r.ticket_id;
      l_hit.rank       := r.title_hits;
      l_hit.matched_in := CASE WHEN r.title_hits > 0 THEN 'TITLE'
                               WHEN r.comment_hits > 0 THEN 'COMMENT' ELSE 'OTHER' END;
      PIPE ROW (l_hit);
    END LOOP;
    RETURN;
  END search_tickets;

  -- ================================================================ redirection
  FUNCTION master_ticket_id(p_ticket_id IN NUMBER) RETURN NUMBER IS
    l_current NUMBER := p_ticket_id;
    l_next    NUMBER;
    l_master  NUMBER;
  BEGIN
    IF p_ticket_id IS NULL THEN RETURN NULL; END IF;
    FOR i IN 1 .. c_chain_depth LOOP
      BEGIN
        SELECT MIN(target_ticket_id) INTO l_next
          FROM afh_ticket_relations
         WHERE source_ticket_id = l_current AND relation_code = 'DUPLICATE_OF' AND is_active = 'Y';
      END;
      EXIT WHEN l_next IS NULL OR l_next = p_ticket_id;   -- end of chain, or a cycle
      l_master  := l_next;
      l_current := l_next;
    END LOOP;
    RETURN l_master;
  END master_ticket_id;

  FUNCTION resolve_for_navigation(p_ticket_no IN VARCHAR2, p_follow_master IN VARCHAR2 DEFAULT 'Y') RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    l_id := afh_ticket_pkg.get_ticket_id(p_ticket_no);
    IF l_id IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'No ticket exists with that number. Check the number and try again.');
    END IF;
    IF NVL(p_follow_master, 'Y') = 'Y' THEN
      RETURN NVL(master_ticket_id(l_id), l_id);
    END IF;
    RETURN l_id;
  END resolve_for_navigation;

  -- ================================================================ saved filters
  -- Saved filters are personal working state, not material ticket history, so they are
  -- deliberately NOT audited (spec §20 lists what the audit trail must cover; filters
  -- are not in it).
  PROCEDURE validate_filter(p_scope_code IN VARCHAR2, p_filter_name IN VARCHAR2, p_filter_json IN CLOB) IS
    l_ok PLS_INTEGER;
  BEGIN
    IF p_scope_code NOT IN ('WORKBENCH', 'ALL_FEEDBACK', 'MY_WORK') THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Choose a valid filter scope.');
    END IF;
    IF TRIM(p_filter_name) IS NULL OR LENGTH(TRIM(p_filter_name)) > 100 THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Enter a filter name of 1 to 100 characters.');
    END IF;
    -- Same check as constraint AFH_SAVED_FILTERS_CK3, surfaced as a user-safe message.
    SELECT COUNT(*) INTO l_ok FROM dual WHERE p_filter_json IS JSON;
    IF l_ok = 0 THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The filter definition is not valid JSON.');
    END IF;
  END validate_filter;

  FUNCTION save_filter(
    p_scope_code     IN VARCHAR2,
    p_filter_name    IN VARCHAR2,
    p_filter_json    IN CLOB,
    p_is_shared      IN VARCHAR2 DEFAULT 'N',
    p_application_id IN NUMBER   DEFAULT NULL) RETURN NUMBER IS
    l_user   NUMBER;
    l_id     NUMBER;
    l_shared VARCHAR2(1) := CASE WHEN p_is_shared = 'Y' THEN 'Y' ELSE 'N' END;
    l_name   VARCHAR2(4000 CHAR) := TRIM(p_filter_name);   -- validated to 100 in validate_filter
  BEGIN
    afh_security_pkg.assert_authenticated;
    l_user := afh_security_pkg.current_user_id;
    validate_filter(p_scope_code, l_name, p_filter_json);
    IF l_shared = 'Y' AND NOT afh_security_pkg.is_developer_or_above THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002,
        'Only developers, application owners and administrators can share a filter.');
    END IF;
    UPDATE afh_saved_filters
       SET filter_json = p_filter_json, is_shared = l_shared, application_id = p_application_id
     WHERE owner_user_id = l_user AND scope_code = p_scope_code AND filter_name = l_name
     RETURNING saved_filter_id INTO l_id;
    IF SQL%ROWCOUNT = 0 THEN
      INSERT INTO afh_saved_filters (owner_user_id, scope_code, filter_name, filter_json, is_shared, application_id)
      VALUES (l_user, p_scope_code, l_name, p_filter_json, l_shared, p_application_id)
      RETURNING saved_filter_id INTO l_id;
    END IF;
    RETURN l_id;
  END save_filter;

  PROCEDURE delete_filter(p_saved_filter_id IN NUMBER) IS
    l_owner NUMBER;
  BEGIN
    afh_security_pkg.assert_authenticated;
    BEGIN
      SELECT owner_user_id INTO l_owner FROM afh_saved_filters WHERE saved_filter_id = p_saved_filter_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'That saved filter no longer exists.');
    END;
    IF l_owner <> afh_security_pkg.current_user_id AND NOT afh_security_pkg.is_admin THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002, 'Only the owner or an administrator can delete this filter.');
    END IF;
    DELETE FROM afh_saved_filters WHERE saved_filter_id = p_saved_filter_id;
  END delete_filter;

  FUNCTION search_ticket_ids(p_text IN VARCHAR2) RETURN apex_t_number IS
    l_ids apex_t_number := apex_t_number();
  BEGIN
    IF TRIM(p_text) IS NULL THEN
      RETURN l_ids;
    END IF;
    SELECT h.ticket_id BULK COLLECT INTO l_ids
      FROM TABLE(search_tickets(p_text)) h;
    RETURN l_ids;
  END search_ticket_ids;
END afh_search_pkg;
/
