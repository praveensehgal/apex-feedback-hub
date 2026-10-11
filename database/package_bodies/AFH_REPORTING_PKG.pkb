CREATE OR REPLACE PACKAGE BODY afh_reporting_pkg AS
  -- ---------------------------------------------------------------------------
  -- AFH_REPORTING_PKG body. Spec WU-13, PRD §7.12.
  --
  -- Visibility: spec §9.2 grants "search and view public tickets" to every
  -- authenticated role, so Application Health datasets are not filtered per
  -- role. Only the caller-supplied application / environment filters apply.
  -- Open ticket = not archived and in a non-terminal workflow status.
  --
  -- health_by_dimension uses one static SQL per dimension (no dynamic SQL);
  -- each query lives in its own private function so every subprogram stays
  -- under the 50-line limit, and the pipelined wrapper only pipes rows.
  -- ---------------------------------------------------------------------------

  c_day CONSTANT INTERVAL DAY TO SECOND := NUMTODSINTERVAL(1, 'DAY');

  -- ------------------------------------------------------------- aging buckets
  FUNCTION days_since(p_at IN TIMESTAMP WITH LOCAL TIME ZONE) RETURN NUMBER IS
  BEGIN
    IF p_at IS NULL THEN
      RETURN NULL;
    END IF;
    -- Both sides in the session time zone: CAST(TSLTZ AS DATE) is session-local, and
    -- SYSDATE is server-local (UTC on the dev host), which shifted buckets after 20:00 ET.
    RETURN GREATEST(TRUNC(CAST(LOCALTIMESTAMP AS DATE)) - TRUNC(CAST(p_at AS DATE)), 0);
  END days_since;

  FUNCTION aging_bucket_seq(p_submitted_at IN TIMESTAMP WITH LOCAL TIME ZONE) RETURN NUMBER IS
    l_days NUMBER := days_since(p_submitted_at);
  BEGIN
    RETURN CASE
             WHEN l_days IS NULL THEN NULL
             WHEN l_days <= 2  THEN 1
             WHEN l_days <= 7  THEN 2
             WHEN l_days <= 14 THEN 3
             WHEN l_days <= 30 THEN 4
             WHEN l_days <= 90 THEN 5
             ELSE 6
           END;
  END aging_bucket_seq;

  FUNCTION aging_bucket(p_submitted_at IN TIMESTAMP WITH LOCAL TIME ZONE) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE aging_bucket_seq(p_submitted_at)
             WHEN 1 THEN '0-2d'
             WHEN 2 THEN '3-7d'
             WHEN 3 THEN '8-14d'
             WHEN 4 THEN '15-30d'
             WHEN 5 THEN '31-90d'
             WHEN 6 THEN '90d+'
             ELSE NULL
           END;
  END aging_bucket;

  FUNCTION is_overdue(p_due_date IN TIMESTAMP WITH LOCAL TIME ZONE, p_status_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_due_date IS NULL OR p_due_date >= SYSTIMESTAMP THEN
      RETURN 'N';
    END IF;
    IF UPPER(p_status_code) IN ('RESOLVED', 'CLOSED', 'DUPLICATE', 'REJECTED', 'CANNOT_REPRODUCE') THEN
      RETURN 'N';
    END IF;
    RETURN 'Y';
  END is_overdue;

  -- ------------------------------------------------------------- my work counts
  FUNCTION resolve_user(p_user_id IN NUMBER) RETURN NUMBER IS
    l_current NUMBER := afh_security_pkg.current_user_id;
  BEGIN
    IF p_user_id IS NULL THEN
      RETURN l_current;
    END IF;
    -- Another user's counts are an administrative view only.
    IF p_user_id <> NVL(l_current, -1) AND NOT afh_security_pkg.is_admin THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002,
        'You can only view your own work counts.');
    END IF;
    RETURN p_user_id;
  END resolve_user;

  FUNCTION open_task_count(p_user_id IN NUMBER, p_task_type_code IN VARCHAR2) RETURN NUMBER IS
    l_cnt NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO l_cnt
      FROM afh_tasks t
     WHERE t.user_id = p_user_id
       AND t.task_type_code = p_task_type_code
       AND t.state_code = 'OPEN';
    RETURN l_cnt;
  END open_task_count;

  FUNCTION my_counts(p_user_id IN NUMBER DEFAULT NULL) RETURN t_my_counts IS
    l_uid NUMBER := resolve_user(p_user_id);
    l_res t_my_counts;
  BEGIN
    l_res.assigned_open := 0; l_res.info_requests := 0; l_res.test_requests := 0;
    l_res.following := 0; l_res.unread_notifs := 0; l_res.reported_open := 0;
    IF l_uid IS NULL THEN
      RETURN l_res;
    END IF;
    l_res.assigned_open := open_task_count(l_uid, 'ASSIGNMENT');
    l_res.info_requests := open_task_count(l_uid, 'INFO_REQUEST');
    l_res.test_requests := open_task_count(l_uid, 'TEST_REQUEST');
    SELECT COUNT(*)
      INTO l_res.following
      FROM afh_followers f
      JOIN afh_tickets t ON t.ticket_id = f.ticket_id
     WHERE f.user_id = l_uid
       AND t.is_archived = 'N';
    SELECT COUNT(*)
      INTO l_res.unread_notifs
      FROM afh_notifications n
     WHERE n.recipient_user_id = l_uid
       AND n.channel_code = 'IN_APP'
       AND n.state_code = 'NEW';
    SELECT COUNT(*)
      INTO l_res.reported_open
      FROM afh_tickets t
      JOIN afh_workflow_statuses s ON s.status_code = t.status_code
     WHERE t.reporter_user_id = l_uid
       AND t.is_archived = 'N'
       AND s.is_terminal = 'N';
    RETURN l_res;
  END my_counts;

  -- ------------------------------------------------------------- health by dimension
  -- Every dim_* function shares the same open-ticket predicate and filters.
  FUNCTION dim_application(p_app IN NUMBER, p_env IN NUMBER) RETURN t_dim_count_tab IS
    l_tab t_dim_count_tab;
  BEGIN
    SELECT TO_CHAR(a.application_id), a.display_name, 0, COUNT(*),
           SUM(CASE WHEN is_overdue(t.due_date, t.status_code) = 'Y' THEN 1 ELSE 0 END)
      BULK COLLECT INTO l_tab
      FROM afh_tickets t
      JOIN afh_workflow_statuses s ON s.status_code = t.status_code
      JOIN afh_applications a ON a.application_id = t.application_id
     WHERE t.is_archived = 'N' AND s.is_terminal = 'N'
       AND (p_app IS NULL OR t.application_id = p_app)
       AND (p_env IS NULL OR t.environment_id = p_env)
     GROUP BY a.application_id, a.display_name
     ORDER BY a.display_name;
    RETURN l_tab;
  END dim_application;

  FUNCTION dim_environment(p_app IN NUMBER, p_env IN NUMBER) RETURN t_dim_count_tab IS
    l_tab t_dim_count_tab;
  BEGIN
    SELECT TO_CHAR(e.environment_id), a.display_name || ' · ' || e.label, NVL(e.display_seq, 10), COUNT(*),
           SUM(CASE WHEN is_overdue(t.due_date, t.status_code) = 'Y' THEN 1 ELSE 0 END)
      BULK COLLECT INTO l_tab
      FROM afh_tickets t
      JOIN afh_workflow_statuses s ON s.status_code = t.status_code
      JOIN afh_applications a ON a.application_id = t.application_id
      JOIN afh_environments e ON e.environment_id = t.environment_id
     WHERE t.is_archived = 'N' AND s.is_terminal = 'N'
       AND (p_app IS NULL OR t.application_id = p_app)
       AND (p_env IS NULL OR t.environment_id = p_env)
     GROUP BY e.environment_id, a.display_name, e.label, e.display_seq
     ORDER BY a.display_name, NVL(e.display_seq, 10), e.label;
    RETURN l_tab;
  END dim_environment;

  FUNCTION dim_page(p_app IN NUMBER, p_env IN NUMBER) RETURN t_dim_count_tab IS
    l_tab t_dim_count_tab;
  BEGIN
    SELECT TO_CHAR(a.application_id) || ':' || NVL(TO_CHAR(t.page_id), '-'),
           a.display_name || ' · ' || COALESCE(t.page_name, 'Page ' || TO_CHAR(t.page_id), 'Unknown page'),
           NVL(t.page_id, 0), COUNT(*),
           SUM(CASE WHEN is_overdue(t.due_date, t.status_code) = 'Y' THEN 1 ELSE 0 END)
      BULK COLLECT INTO l_tab
      FROM afh_tickets t
      JOIN afh_workflow_statuses s ON s.status_code = t.status_code
      JOIN afh_applications a ON a.application_id = t.application_id
     WHERE t.is_archived = 'N' AND s.is_terminal = 'N'
       AND (p_app IS NULL OR t.application_id = p_app)
       AND (p_env IS NULL OR t.environment_id = p_env)
     GROUP BY a.application_id, a.display_name, t.page_id, t.page_name
     ORDER BY COUNT(*) DESC, a.display_name, NVL(t.page_id, 0);
    RETURN l_tab;
  END dim_page;

  FUNCTION dim_type(p_app IN NUMBER, p_env IN NUMBER) RETURN t_dim_count_tab IS
    l_tab t_dim_count_tab;
  BEGIN
    SELECT ft.type_code, ft.label, ft.display_seq, COUNT(*),
           SUM(CASE WHEN is_overdue(t.due_date, t.status_code) = 'Y' THEN 1 ELSE 0 END)
      BULK COLLECT INTO l_tab
      FROM afh_tickets t
      JOIN afh_workflow_statuses s ON s.status_code = t.status_code
      JOIN afh_feedback_types ft ON ft.feedback_type_id = t.feedback_type_id
     WHERE t.is_archived = 'N' AND s.is_terminal = 'N'
       AND (p_app IS NULL OR t.application_id = p_app)
       AND (p_env IS NULL OR t.environment_id = p_env)
     GROUP BY ft.type_code, ft.label, ft.display_seq
     ORDER BY ft.display_seq, ft.label;
    RETURN l_tab;
  END dim_type;

  FUNCTION dim_status(p_app IN NUMBER, p_env IN NUMBER) RETURN t_dim_count_tab IS
    l_tab t_dim_count_tab;
  BEGIN
    SELECT s.status_code, s.label, s.display_seq, COUNT(*),
           SUM(CASE WHEN is_overdue(t.due_date, t.status_code) = 'Y' THEN 1 ELSE 0 END)
      BULK COLLECT INTO l_tab
      FROM afh_tickets t
      JOIN afh_workflow_statuses s ON s.status_code = t.status_code
     WHERE t.is_archived = 'N' AND s.is_terminal = 'N'
       AND (p_app IS NULL OR t.application_id = p_app)
       AND (p_env IS NULL OR t.environment_id = p_env)
     GROUP BY s.status_code, s.label, s.display_seq
     ORDER BY s.display_seq, s.label;
    RETURN l_tab;
  END dim_status;

  -- SEVERITY and PRIORITY share one query over afh_classification_values.
  FUNCTION dim_classification(p_class_type IN VARCHAR2, p_app IN NUMBER, p_env IN NUMBER) RETURN t_dim_count_tab IS
    l_tab t_dim_count_tab;
  BEGIN
    SELECT x.code, NVL(cv.label, INITCAP(REPLACE(x.code, '_', ' '))), NVL(cv.display_seq, 999), x.cnt, x.overdue
      BULK COLLECT INTO l_tab
      FROM (SELECT CASE WHEN p_class_type = 'SEVERITY' THEN t.severity_code ELSE t.priority_code END AS code,
                   COUNT(*) AS cnt,
                   SUM(CASE WHEN is_overdue(t.due_date, t.status_code) = 'Y' THEN 1 ELSE 0 END) AS overdue
              FROM afh_tickets t
              JOIN afh_workflow_statuses s ON s.status_code = t.status_code
             WHERE t.is_archived = 'N' AND s.is_terminal = 'N'
               AND (p_app IS NULL OR t.application_id = p_app)
               AND (p_env IS NULL OR t.environment_id = p_env)
             GROUP BY CASE WHEN p_class_type = 'SEVERITY' THEN t.severity_code ELSE t.priority_code END) x
      LEFT JOIN afh_classification_values cv
             ON cv.class_type = p_class_type AND cv.value_code = x.code
     ORDER BY NVL(cv.display_seq, 999), x.code;
    RETURN l_tab;
  END dim_classification;

  FUNCTION dim_release(p_app IN NUMBER, p_env IN NUMBER) RETURN t_dim_count_tab IS
    l_tab t_dim_count_tab;
  BEGIN
    SELECT NVL(TO_CHAR(r.release_id), 'UNSCHEDULED'), NVL(r.label, 'Unscheduled'),
           CASE WHEN r.release_id IS NULL THEN 0 ELSE 1 END, COUNT(*),
           SUM(CASE WHEN is_overdue(t.due_date, t.status_code) = 'Y' THEN 1 ELSE 0 END)
      BULK COLLECT INTO l_tab
      FROM afh_tickets t
      JOIN afh_workflow_statuses s ON s.status_code = t.status_code
      LEFT JOIN afh_releases r ON r.release_id = t.release_id
     WHERE t.is_archived = 'N' AND s.is_terminal = 'N'
       AND (p_app IS NULL OR t.application_id = p_app)
       AND (p_env IS NULL OR t.environment_id = p_env)
     GROUP BY r.release_id, r.label, r.target_date
     ORDER BY CASE WHEN r.release_id IS NULL THEN 0 ELSE 1 END, r.target_date NULLS LAST, r.label;
    RETURN l_tab;
  END dim_release;

  FUNCTION dim_owner(p_app IN NUMBER, p_env IN NUMBER) RETURN t_dim_count_tab IS
    l_tab t_dim_count_tab;
  BEGIN
    SELECT NVL(TO_CHAR(u.user_id), 'UNASSIGNED'),
           COALESCE(u.display_name, u.subject_display, 'Unassigned queue'),
           CASE WHEN u.user_id IS NULL THEN 0 ELSE 1 END, COUNT(*),
           SUM(CASE WHEN is_overdue(t.due_date, t.status_code) = 'Y' THEN 1 ELSE 0 END)
      BULK COLLECT INTO l_tab
      FROM afh_tickets t
      JOIN afh_workflow_statuses s ON s.status_code = t.status_code
      LEFT JOIN afh_users u ON u.user_id = t.owner_user_id
     WHERE t.is_archived = 'N' AND s.is_terminal = 'N'
       AND (p_app IS NULL OR t.application_id = p_app)
       AND (p_env IS NULL OR t.environment_id = p_env)
     GROUP BY u.user_id, u.display_name, u.subject_display
     ORDER BY CASE WHEN u.user_id IS NULL THEN 0 ELSE 1 END, COUNT(*) DESC,
              COALESCE(u.display_name, u.subject_display);
    RETURN l_tab;
  END dim_owner;

  FUNCTION dim_aging(p_app IN NUMBER, p_env IN NUMBER) RETURN t_dim_count_tab IS
    l_tab t_dim_count_tab;
  BEGIN
    SELECT x.bucket, x.bucket, x.seq, COUNT(*), SUM(x.overdue)
      BULK COLLECT INTO l_tab
      FROM (SELECT aging_bucket(t.submitted_at) AS bucket,
                   aging_bucket_seq(t.submitted_at) AS seq,
                   CASE WHEN is_overdue(t.due_date, t.status_code) = 'Y' THEN 1 ELSE 0 END AS overdue
              FROM afh_tickets t
              JOIN afh_workflow_statuses s ON s.status_code = t.status_code
             WHERE t.is_archived = 'N' AND s.is_terminal = 'N'
               AND (p_app IS NULL OR t.application_id = p_app)
               AND (p_env IS NULL OR t.environment_id = p_env)) x
     GROUP BY x.bucket, x.seq
     ORDER BY x.seq;
    RETURN l_tab;
  END dim_aging;

  FUNCTION dimension_rows(p_dimension IN VARCHAR2, p_app IN NUMBER, p_env IN NUMBER) RETURN t_dim_count_tab IS
    l_dim VARCHAR2(30) := UPPER(TRIM(p_dimension));
  BEGIN
    IF    l_dim = 'APPLICATION' THEN RETURN dim_application(p_app, p_env);
    ELSIF l_dim = 'ENVIRONMENT' THEN RETURN dim_environment(p_app, p_env);
    ELSIF l_dim = 'PAGE'        THEN RETURN dim_page(p_app, p_env);
    ELSIF l_dim = 'TYPE'        THEN RETURN dim_type(p_app, p_env);
    ELSIF l_dim = 'STATUS'      THEN RETURN dim_status(p_app, p_env);
    ELSIF l_dim = 'SEVERITY'    THEN RETURN dim_classification('SEVERITY', p_app, p_env);
    ELSIF l_dim = 'PRIORITY'    THEN RETURN dim_classification('PRIORITY', p_app, p_env);
    ELSIF l_dim = 'RELEASE'     THEN RETURN dim_release(p_app, p_env);
    ELSIF l_dim = 'OWNER'       THEN RETURN dim_owner(p_app, p_env);
    ELSIF l_dim = 'AGING'       THEN RETURN dim_aging(p_app, p_env);
    END IF;
    afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
      'Unknown health dimension. Choose application, environment, page, type, status, severity, priority, release, owner, or aging.');
    RETURN NULL;
  END dimension_rows;

  FUNCTION health_by_dimension(
    p_dimension      IN VARCHAR2,
    p_application_id IN NUMBER DEFAULT NULL,
    p_environment_id IN NUMBER DEFAULT NULL) RETURN t_dim_count_tab PIPELINED IS
    l_tab t_dim_count_tab := dimension_rows(p_dimension, p_application_id, p_environment_id);
  BEGIN
    IF l_tab IS NOT NULL THEN
      FOR i IN 1 .. l_tab.COUNT LOOP
        PIPE ROW (l_tab(i));
      END LOOP;
    END IF;
    RETURN;
  END health_by_dimension;

  -- ------------------------------------------------------------- repeated pages
  FUNCTION repeated_pages(p_days IN NUMBER DEFAULT 90, p_min_reports IN NUMBER DEFAULT 2, p_application_id IN NUMBER DEFAULT NULL)
    RETURN t_page_hot_tab PIPELINED IS
    l_since TIMESTAMP WITH LOCAL TIME ZONE := SYSTIMESTAMP - (NVL(p_days, 90) * c_day);
    l_min   NUMBER := GREATEST(NVL(p_min_reports, 2), 1);
    l_row   t_page_hot;
  BEGIN
    FOR r IN (SELECT t.application_id, a.display_name, t.page_id, t.page_name,
                     COUNT(*) AS ticket_count,
                     SUM(CASE WHEN t.is_archived = 'N' AND s.is_terminal = 'N' THEN 1 ELSE 0 END) AS open_count,
                     MAX(t.submitted_at) AS last_reported_at
                FROM afh_tickets t
                JOIN afh_applications a ON a.application_id = t.application_id
                JOIN afh_workflow_statuses s ON s.status_code = t.status_code
               WHERE t.submitted_at >= l_since
                 AND (p_application_id IS NULL OR t.application_id = p_application_id)
               GROUP BY t.application_id, a.display_name, t.page_id, t.page_name
              HAVING COUNT(*) >= l_min
               ORDER BY COUNT(*) DESC, MAX(t.submitted_at) DESC, a.display_name, t.page_id) LOOP
      l_row.application_id   := r.application_id;
      l_row.application_name := r.display_name;
      l_row.page_id          := r.page_id;
      l_row.page_name        := r.page_name;
      l_row.ticket_count     := r.ticket_count;
      l_row.open_count       := r.open_count;
      l_row.last_reported_at := r.last_reported_at;
      PIPE ROW (l_row);
    END LOOP;
    RETURN;
  END repeated_pages;

  -- ------------------------------------------------------------- export naming
  FUNCTION export_file_name(p_scope IN VARCHAR2, p_extension IN VARCHAR2 DEFAULT 'csv') RETURN VARCHAR2 IS
    l_scope VARCHAR2(200);
    l_ext   VARCHAR2(20);
  BEGIN
    l_scope := LOWER(TRIM(BOTH '-' FROM REGEXP_REPLACE(NVL(p_scope, 'all'), '[^A-Za-z0-9]+', '-')));
    IF l_scope IS NULL THEN
      l_scope := 'all';
    END IF;
    l_ext := LOWER(REGEXP_REPLACE(NVL(p_extension, 'csv'), '[^A-Za-z0-9]', ''));
    IF l_ext IS NULL THEN
      l_ext := 'csv';
    END IF;
    RETURN 'feedback-' || SUBSTR(l_scope, 1, 60) || '-' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDD-HH24MISS') || '.' || l_ext;
  END export_file_name;
END afh_reporting_pkg;
/
