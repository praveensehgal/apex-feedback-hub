CREATE OR REPLACE PACKAGE afh_search_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_SEARCH_PKG — text normalization, duplicate scoring, general search,
  -- saved filters, archived lookup, and master-ticket redirection.
  -- Spec §15, WU-07. Merge itself lives in afh_workflow_pkg.merge_duplicate.
  -- Oracle 19c only: UTL_MATCH.JARO_WINKLER_SIMILARITY, no external service.
  -- ---------------------------------------------------------------------------

  -- Spec §15.2: UPPER, non-alphanumeric -> space, collapse spaces, TRIM. Numbers kept.
  FUNCTION normalize_text(p_text IN CLOB) RETURN VARCHAR2;          -- max 4000 chars
  -- First 1,000 characters of the normalized description (stored in afh_tickets.desc_norm).
  FUNCTION normalize_description(p_description IN CLOB) RETURN VARCHAR2;

  -- Weighted score 0..100 (rounded) for one candidate against the input facts.
  -- Weights and threshold come from config DUP_W_TITLE/DUP_W_DESC/DUP_W_APP/DUP_W_PAGE/
  -- DUP_W_TYPE/DUP_THRESHOLD/DUP_MAX (defaults 55/20/15/5/5/65/5). A NULL description on
  -- either side contributes 0 for the description term.
  FUNCTION score(
    p_title_norm_a  IN VARCHAR2, p_desc_norm_a IN VARCHAR2, p_application_id_a IN NUMBER, p_page_id_a IN NUMBER, p_type_id_a IN NUMBER,
    p_title_norm_b  IN VARCHAR2, p_desc_norm_b IN VARCHAR2, p_application_id_b IN NUMBER, p_page_id_b IN NUMBER, p_type_id_b IN NUMBER) RETURN NUMBER;

  TYPE t_candidate IS RECORD (
    ticket_id        NUMBER,
    ticket_no        VARCHAR2(20 CHAR),
    title            VARCHAR2(120 CHAR),
    status_code      VARCHAR2(30 CHAR),
    status_label     VARCHAR2(255 CHAR),
    is_terminal      VARCHAR2(1 CHAR),
    application_name VARCHAR2(255 CHAR),
    page_name        VARCHAR2(255 CHAR),
    score            NUMBER,
    title_score      NUMBER,     -- 0..100 raw similarity
    desc_score       NUMBER,
    same_app_yn      VARCHAR2(1 CHAR),
    same_page_yn     VARCHAR2(1 CHAR),
    same_type_yn     VARCHAR2(1 CHAR),
    exact_no_match   VARCHAR2(1 CHAR),
    last_activity_at TIMESTAMP WITH LOCAL TIME ZONE,
    explanation      VARCHAR2(500 CHAR));
  TYPE t_candidate_tab IS TABLE OF t_candidate;

  -- Up to DUP_MAX candidates scoring >= DUP_THRESHOLD, ordered: exact ticket-number match
  -- first, then score desc, nonterminal before terminal, newest activity first.
  -- Archived tickets are included; internal notes and context are never read.
  -- On an internal error returns no rows and records a health event (AFH-SRCH-001 is
  -- raised only when p_raise_on_error = 'Y').
  FUNCTION duplicate_candidates(
    p_title             IN VARCHAR2,
    p_description       IN CLOB,
    p_application_id    IN NUMBER,
    p_page_id           IN NUMBER,
    p_type_code         IN VARCHAR2,
    p_exclude_ticket_id IN NUMBER   DEFAULT NULL,
    p_raise_on_error    IN VARCHAR2 DEFAULT 'N') RETURN t_candidate_tab PIPELINED;

  -- ----------------------------------------------------------------- general search (spec §15.1)
  TYPE t_hit IS RECORD (ticket_id NUMBER, rank NUMBER, matched_in VARCHAR2(30 CHAR));
  TYPE t_hit_tab IS TABLE OF t_hit;
  -- Ticket IDs whose public facts match p_text (ticket number, title, description, public
  -- comments, application, page, environment, type, category, status label, reporter,
  -- assignee, release). Never internal notes or context. Use with
  --   WHERE v.ticket_id IN (SELECT ticket_id FROM TABLE(afh_search_pkg.search_tickets(:P2_SEARCH)))
  FUNCTION search_tickets(p_text IN VARCHAR2) RETURN t_hit_tab PIPELINED;
  -- Same hit list as a SQL-level collection (apex_t_number) for region sources that APEX
  -- re-parses through apex_exec - Faceted Search facet counts raise ORA-22905 on a
  -- pipelined function whose collection type is package-declared. The CAST is mandatory:
  -- the facet-count wrapper (grouping sets over the region query) raises ORA-22905 at
  -- execute time on a bare TABLE(function) even though the region itself renders
  -- (Oracle 23ai, found 2026-09-05; AFH_TEST_SRC_PKG.t_src_011 pins the shape). Use with
  --   WHERE :P2_SEARCH IS NULL OR v.ticket_id IN (SELECT column_value FROM TABLE(CAST(afh_search_pkg.search_ticket_ids(:P2_SEARCH) AS apex_t_number)))
  FUNCTION search_ticket_ids(p_text IN VARCHAR2) RETURN apex_t_number;

  -- ----------------------------------------------------------------- redirection
  -- Active DUPLICATE_OF target for a ticket, following chains; NULL when not a duplicate.
  FUNCTION master_ticket_id(p_ticket_id IN NUMBER) RETURN NUMBER;
  -- ticket_id to open for a public ticket number: the master when the ticket is a
  -- duplicate and p_follow_master = 'Y'. Raises AFH-VAL-001 for an unknown number.
  FUNCTION resolve_for_navigation(p_ticket_no IN VARCHAR2, p_follow_master IN VARCHAR2 DEFAULT 'Y') RETURN NUMBER;

  -- ----------------------------------------------------------------- saved filters
  FUNCTION save_filter(
    p_scope_code     IN VARCHAR2,      -- WORKBENCH | ALL_FEEDBACK | MY_WORK
    p_filter_name    IN VARCHAR2,
    p_filter_json    IN CLOB,
    p_is_shared      IN VARCHAR2 DEFAULT 'N',   -- sharing requires developer+
    p_application_id IN NUMBER   DEFAULT NULL) RETURN NUMBER;   -- upserts on (owner, scope, name)
  PROCEDURE delete_filter(p_saved_filter_id IN NUMBER);           -- owner or admin
END afh_search_pkg;
/
