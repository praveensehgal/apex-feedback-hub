CREATE OR REPLACE PACKAGE afh_ui_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_UI_PKG — HTML renderers for the Hub's signature surfaces (decision 009).
  -- Every function returns a CLOB that a Dynamic Content region (function body returning CLOB) prints with
  -- htp.p / sys.htp.prn. All values pass through apex_escape; the markup uses the
  -- .afh-* classes of afh_theme.css only. Reads AFH_V_* views; never writes.
  -- Filters mirror the page-30 items so Board, Queue and Workload always agree.
  -- ---------------------------------------------------------------------------
  TYPE t_queue_filter IS RECORD (
    scope_code      VARCHAR2(10),      -- MINE | OWNER | ALL (NULL = MINE)
    application_id  NUMBER,
    status_codes    VARCHAR2(4000),    -- colon-separated (checkbox group value)
    priority_codes  VARCHAR2(4000),
    type_codes      VARCHAR2(4000),
    overdue_yn      VARCHAR2(1),
    search_text     VARCHAR2(400));

  FUNCTION queue_filter(
    p_scope          IN VARCHAR2,
    p_application_id IN NUMBER,
    p_status_codes   IN VARCHAR2,
    p_priority_codes IN VARCHAR2,
    p_type_codes     IN VARCHAR2,
    p_overdue_yn     IN VARCHAR2,
    p_search         IN VARCHAR2) RETURN t_queue_filter;

  -- Kanban: one column per active non-terminal status, cards carry data-ticket /
  -- data-version / data-status for the drag handler (BOARD_MOVE callback).
  FUNCTION render_board(p_filter IN t_queue_filter, p_app_id IN NUMBER, p_session IN NUMBER) RETURN CLOB;

  -- Queue table with a checkbox per row (value ticket_id:row_version) for bulk actions.
  FUNCTION render_queue(p_filter IN t_queue_filter, p_app_id IN NUMBER, p_session IN NUMBER) RETURN CLOB;

  -- Workload tiles per assignee (afh_v_workload).
  FUNCTION render_workload RETURN CLOB;

  -- Release card for page 40 (state, dates, ticket counts, notes).
  FUNCTION render_release(p_release_id IN NUMBER) RETURN CLOB;

  -- Notification list for page 50: unread rows highlighted, Open and Mark read links
  -- built with apex_util.prepare_url so P50_NOTIFICATION_ID stays checksum-protected.
  FUNCTION render_notifications(p_filter IN VARCHAR2, p_app_id IN NUMBER, p_session IN NUMBER) RETURN CLOB;

  -- Per-event preference table for page 51: one row per event with Email / In-app selects
  -- (Use preset / On / Off) carrying data-event; SAVE_OVERRIDES reads them as f01/f02/f03.
  FUNCTION render_pref_grid(p_application_id IN NUMBER) RETURN CLOB;

  -- Application Health (page 3): value-labelled bar charts rendered as HTML (no chart library).
  FUNCTION render_aging(p_application_id IN NUMBER) RETURN CLOB;
  FUNCTION render_by_dimension(p_dimension IN VARCHAR2, p_application_id IN NUMBER, p_environment_id IN NUMBER) RETURN CLOB;

  -- Taxonomy and Workflow (page 64): editable tables. p_section in TYPES | FIELDS | TYPE_FIELDS |
  -- CATEGORIES | CLASSIFICATION | STATUSES | TRANSITIONS. Rows carry data-id; inputs carry data-col.
  FUNCTION render_taxonomy(p_section IN VARCHAR2) RETURN CLOB;
  -- Applies the rows the page posts as JSON {"rows":[{...}]} through AFH_TAXONOMY_PKG; returns a
  -- one-line message. Every row is one package call so the audit contract holds.
  FUNCTION save_taxonomy(p_section IN VARCHAR2, p_json IN CLOB) RETURN VARCHAR2;

  -- Ticket Detail (page 10) activity timeline from afh_v_ticket_timeline: public events as
  -- compact rows, comments as cards (body already rendered by afh_comment_pkg), attachments.
  FUNCTION render_timeline(p_ticket_id IN NUMBER, p_app_id IN NUMBER, p_session IN NUMBER) RETURN CLOB;

  -- A pill for a status / priority colour token.
  FUNCTION pill(p_label IN VARCHAR2, p_token IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

  -- Ticket link to page 10 (session-aware).
  FUNCTION ticket_link(p_ticket_no IN VARCHAR2, p_app_id IN NUMBER, p_session IN NUMBER) RETURN VARCHAR2;
END afh_ui_pkg;
/
