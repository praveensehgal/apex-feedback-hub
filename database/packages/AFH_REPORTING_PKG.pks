CREATE OR REPLACE PACKAGE afh_reporting_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_REPORTING_PKG — My Work and Application Health datasets and
  -- export-safe filters. Spec WU-13. Most data comes from AFH_V_* views; this
  -- package holds the computed pieces pages cannot express declaratively.
  -- Exports (CSV/PDF) are produced by APEX Interactive Reports over the views,
  -- so restricted facts are never in the export dataset by construction.
  -- ---------------------------------------------------------------------------

  -- Aging bucket label for an open ticket: '0-2d','3-7d','8-14d','15-30d','31-90d','90d+'
  FUNCTION aging_bucket(p_submitted_at IN TIMESTAMP WITH LOCAL TIME ZONE) RETURN VARCHAR2;
  FUNCTION aging_bucket_seq(p_submitted_at IN TIMESTAMP WITH LOCAL TIME ZONE) RETURN NUMBER;
  -- 'Y' when due_date passed and status is nonterminal and not RESOLVED.
  FUNCTION is_overdue(p_due_date IN TIMESTAMP WITH LOCAL TIME ZONE, p_status_code IN VARCHAR2) RETURN VARCHAR2;

  -- Counts for the Global Page / My Work header
  TYPE t_my_counts IS RECORD (
    assigned_open   NUMBER,
    info_requests   NUMBER,
    test_requests   NUMBER,
    following       NUMBER,
    unread_notifs   NUMBER,
    reported_open   NUMBER);
  FUNCTION my_counts(p_user_id IN NUMBER DEFAULT NULL) RETURN t_my_counts;

  -- Application Health: open tickets grouped by one dimension for visible applications.
  TYPE t_dim_count IS RECORD (
    dim_code   VARCHAR2(255 CHAR),
    dim_label  VARCHAR2(255 CHAR),
    dim_seq    NUMBER,
    open_count NUMBER,
    overdue_count NUMBER);
  TYPE t_dim_count_tab IS TABLE OF t_dim_count;
  -- p_dimension: APPLICATION | ENVIRONMENT | PAGE | TYPE | STATUS | SEVERITY | PRIORITY | RELEASE | OWNER | AGING
  FUNCTION health_by_dimension(
    p_dimension      IN VARCHAR2,
    p_application_id IN NUMBER DEFAULT NULL,
    p_environment_id IN NUMBER DEFAULT NULL) RETURN t_dim_count_tab PIPELINED;

  -- Pages with >= p_min_reports tickets in the last p_days days (repeated-report summary).
  TYPE t_page_hot IS RECORD (
    application_id NUMBER, application_name VARCHAR2(255 CHAR), page_id NUMBER, page_name VARCHAR2(255 CHAR),
    ticket_count NUMBER, open_count NUMBER, last_reported_at TIMESTAMP WITH LOCAL TIME ZONE);
  TYPE t_page_hot_tab IS TABLE OF t_page_hot;
  FUNCTION repeated_pages(p_days IN NUMBER DEFAULT 90, p_min_reports IN NUMBER DEFAULT 2, p_application_id IN NUMBER DEFAULT NULL) RETURN t_page_hot_tab PIPELINED;

  -- Filename for an export: 'feedback-' || scope || '-' || yyyymmdd-hh24miss || '.csv'
  FUNCTION export_file_name(p_scope IN VARCHAR2, p_extension IN VARCHAR2 DEFAULT 'csv') RETURN VARCHAR2;
END afh_reporting_pkg;
/
