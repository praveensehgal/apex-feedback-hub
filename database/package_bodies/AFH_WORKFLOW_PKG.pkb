CREATE OR REPLACE PACKAGE BODY afh_workflow_pkg AS
  -- Public workflow API. The matrix engine lives in afh_workflow_int_pkg (private).
  -- No COMMIT anywhere; every call runs in the caller's transaction.

  FUNCTION empty_payload RETURN t_payload IS
    l_p t_payload;
  BEGIN
    RETURN l_p;
  END empty_payload;

  FUNCTION ticket_row(p_ticket_id IN NUMBER) RETURN afh_tickets%ROWTYPE IS
    l_t afh_tickets%ROWTYPE;
  BEGIN
    SELECT * INTO l_t FROM afh_tickets WHERE ticket_id = p_ticket_id;
    RETURN l_t;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The ticket does not exist.');
  END ticket_row;

  -- ------------------------------------------------------------------ transitions
  PROCEDURE transition(
    p_ticket_id      IN NUMBER,
    p_to_status_code IN VARCHAR2,
    p_row_version    IN NUMBER,
    p_payload        IN t_payload DEFAULT NULL) IS
  BEGIN
    afh_security_pkg.assert_authenticated;
    afh_workflow_int_pkg.run(p_ticket_id, UPPER(TRIM(p_to_status_code)), p_row_version, p_payload, p_is_system => FALSE);
  END transition;

  PROCEDURE system_transition(
    p_ticket_id      IN NUMBER,
    p_to_status_code IN VARCHAR2,
    p_reason         IN VARCHAR2 DEFAULT NULL) IS
    l_p t_payload;
  BEGIN
    l_p.reason := p_reason;
    afh_workflow_int_pkg.run(p_ticket_id, UPPER(TRIM(p_to_status_code)),
      afh_ticket_pkg.row_version_of(p_ticket_id), l_p, p_is_system => TRUE);
  END system_transition;

  FUNCTION allowed_transitions(p_ticket_id IN NUMBER) RETURN t_transition_tab PIPELINED IS
    l_t    afh_tickets%ROWTYPE;
    l_rule afh_workflow_int_pkg.t_rule;
    l_out  t_transition;
  BEGIN
    l_t := ticket_row(p_ticket_id);
    FOR r IN (SELECT t.to_status_code
                FROM afh_workflow_transitions t
                JOIN afh_workflow_statuses s ON s.status_code = t.to_status_code
               WHERE t.from_status_code = l_t.status_code
                 AND t.is_active = 'Y'
                 AND s.is_active = 'Y'
               ORDER BY t.display_seq, t.to_status_code) LOOP
      l_rule := afh_workflow_int_pkg.find_rule(l_t.status_code, r.to_status_code);
      IF afh_workflow_int_pkg.actor_allowed(l_rule, l_t) THEN
        l_out.to_status_code  := l_rule.to_status_code;
        l_out.to_label        := l_rule.to_label;
        l_out.label           := NVL(l_rule.label, l_rule.to_label);
        l_out.required_facts  := l_rule.required_facts;
        l_out.reason_required := l_rule.reason_required;
        l_out.display_seq     := l_rule.display_seq;
        PIPE ROW (l_out);
      END IF;
    END LOOP;
    RETURN;
  END allowed_transitions;

  FUNCTION can_transition(p_ticket_id IN NUMBER, p_to_status_code IN VARCHAR2) RETURN BOOLEAN IS
    l_t    afh_tickets%ROWTYPE;
    l_rule afh_workflow_int_pkg.t_rule;
  BEGIN
    l_t    := ticket_row(p_ticket_id);
    l_rule := afh_workflow_int_pkg.find_rule(l_t.status_code, UPPER(TRIM(p_to_status_code)));
    IF l_rule.workflow_transition_id IS NULL THEN
      RETURN FALSE;
    END IF;
    IF NOT afh_workflow_int_pkg.actor_allowed(l_rule, l_t) THEN
      RETURN FALSE;
    END IF;
    RETURN afh_workflow_int_pkg.missing_facts(l_rule, l_t, empty_payload) IS NULL;
  END can_transition;

  FUNCTION missing_facts(p_ticket_id IN NUMBER, p_to_status_code IN VARCHAR2) RETURN VARCHAR2 IS
    l_t    afh_tickets%ROWTYPE;
    l_rule afh_workflow_int_pkg.t_rule;
  BEGIN
    l_t    := ticket_row(p_ticket_id);
    l_rule := afh_workflow_int_pkg.find_rule(l_t.status_code, UPPER(TRIM(p_to_status_code)));
    IF l_rule.workflow_transition_id IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN afh_workflow_int_pkg.missing_facts(l_rule, l_t, empty_payload);
  END missing_facts;

  -- ------------------------------------------------------------------ duplicate merge (spec §16)
  PROCEDURE merge_duplicate(
    p_duplicate_ticket_id IN NUMBER,
    p_master_ticket_id    IN NUMBER,
    p_reason              IN VARCHAR2,
    p_row_version         IN NUMBER) IS
    l_p t_payload;
  BEGIN
    afh_security_pkg.assert_can_merge(p_duplicate_ticket_id);
    afh_security_pkg.assert_can_merge(p_master_ticket_id);
    IF TRIM(p_reason) IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'A reason for the merge is required.');
    END IF;
    l_p.master_ticket_id := p_master_ticket_id;
    l_p.reason           := p_reason;
    -- The engine validates the merge, writes the relation, moves followers, sets DUPLICATE,
    -- raises DUPLICATE_MERGE and audits — all before returning, all in this transaction.
    afh_workflow_int_pkg.run(p_duplicate_ticket_id, c_st_duplicate, p_row_version, l_p, p_is_system => FALSE);
  END merge_duplicate;

  -- ------------------------------------------------------------------ tasks
  FUNCTION open_task_id(p_ticket_id IN NUMBER, p_task_type_code IN VARCHAR2, p_user_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    SELECT MIN(task_id) INTO l_id
      FROM afh_tasks
     WHERE ticket_id = p_ticket_id
       AND task_type_code = p_task_type_code
       AND state_code = 'OPEN'
       AND (p_user_id IS NULL OR user_id = p_user_id);
    RETURN l_id;
  END open_task_id;

  FUNCTION create_task(
    p_user_id        IN NUMBER,
    p_ticket_id      IN NUMBER,
    p_task_type_code IN VARCHAR2,
    p_summary        IN VARCHAR2 DEFAULT NULL,
    p_due_date       IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL,
    p_related_id     IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    IF p_user_id IS NULL OR p_ticket_id IS NULL OR p_task_type_code IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'A task needs a user, a ticket and a type.');
    END IF;
    l_id := open_task_id(p_ticket_id, p_task_type_code, p_user_id);
    IF l_id IS NOT NULL THEN
      RETURN l_id;
    END IF;
    INSERT INTO afh_tasks (user_id, ticket_id, task_type_code, state_code, due_date, related_id, summary)
    VALUES (p_user_id, p_ticket_id, p_task_type_code, 'OPEN', p_due_date, p_related_id, SUBSTR(p_summary, 1, 500))
    RETURNING task_id INTO l_id;
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_ticket, p_entity_id => p_ticket_id,
      p_event_code  => afh_workflow_int_pkg.c_ev_task_created, p_ticket_id => p_ticket_id,
      p_after_facts => afh_audit_pkg.json_obj(
                         apex_t_varchar2('task_id', 'task_type_code', 'user_id', 'related_id'),
                         apex_t_varchar2(TO_CHAR(l_id), p_task_type_code, TO_CHAR(p_user_id), TO_CHAR(p_related_id))),
      p_summary     => 'Task ' || p_task_type_code || ' created', p_is_public => 'N');
    RETURN l_id;
  END create_task;

  FUNCTION may_complete(p_task afh_tasks%ROWTYPE) RETURN BOOLEAN IS
    l_user_id NUMBER := afh_security_pkg.current_user_id;
  BEGIN
    IF l_user_id IS NULL THEN              -- package / job code without a session subject
      RETURN TRUE;
    END IF;
    IF l_user_id = p_task.user_id THEN
      RETURN TRUE;
    END IF;
    RETURN afh_security_pkg.meets_min_role(afh_security_pkg.c_role_developer,
             afh_ticket_pkg.application_id_of(p_task.ticket_id));
  END may_complete;

  PROCEDURE complete_task(p_task_id IN NUMBER) IS
    l_task afh_tasks%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO l_task FROM afh_tasks WHERE task_id = p_task_id FOR UPDATE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The task does not exist.');
    END;
    IF l_task.state_code <> 'OPEN' THEN
      RETURN;                              -- already done or cancelled: idempotent
    END IF;
    IF NOT may_complete(l_task) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002, 'You cannot complete this task.');
    END IF;
    UPDATE afh_tasks
       SET state_code = 'DONE', completed_at = SYSTIMESTAMP,
           completed_by_user_id = afh_security_pkg.current_user_id
     WHERE task_id = p_task_id;
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_ticket, p_entity_id => l_task.ticket_id,
      p_event_code  => afh_workflow_int_pkg.c_ev_task_completed, p_ticket_id => l_task.ticket_id,
      p_after_facts => afh_audit_pkg.json_obj(
                         apex_t_varchar2('task_id', 'task_type_code', 'user_id'),
                         apex_t_varchar2(TO_CHAR(p_task_id), l_task.task_type_code, TO_CHAR(l_task.user_id))),
      p_summary     => 'Task ' || l_task.task_type_code || ' completed', p_is_public => 'N');
  END complete_task;

  PROCEDURE cancel_open_tasks(p_ticket_id IN NUMBER, p_task_type_code IN VARCHAR2 DEFAULT NULL) IS
    l_cnt PLS_INTEGER;
  BEGIN
    UPDATE afh_tasks
       SET state_code = 'CANCELLED', completed_at = SYSTIMESTAMP
     WHERE ticket_id = p_ticket_id
       AND state_code = 'OPEN'
       AND (p_task_type_code IS NULL OR task_type_code = p_task_type_code);
    l_cnt := SQL%ROWCOUNT;
    IF l_cnt > 0 THEN
      afh_audit_pkg.log_event(
        p_entity_type => afh_audit_pkg.c_entity_ticket, p_entity_id => p_ticket_id,
        p_event_code  => afh_workflow_int_pkg.c_ev_task_cancelled, p_ticket_id => p_ticket_id,
        p_after_facts => afh_audit_pkg.json_obj(
                           apex_t_varchar2('task_type_code', 'cancelled_count'),
                           apex_t_varchar2(NVL(p_task_type_code, 'ALL'), TO_CHAR(l_cnt))),
        p_summary     => l_cnt || ' open task(s) cancelled', p_is_public => 'N');
    END IF;
  END cancel_open_tasks;

  -- ------------------------------------------------------------------ testing (spec WU-11)
  PROCEDURE validate_test_request(
    p_ticket           IN afh_tickets%ROWTYPE,
    p_assignee_user_id IN NUMBER,
    p_environment_id   IN NUMBER,
    p_app_version      IN VARCHAR2,
    p_criteria         IN CLOB) IS
    l_cnt PLS_INTEGER;
  BEGIN
    IF p_assignee_user_id IS NULL OR p_environment_id IS NULL OR TRIM(p_app_version) IS NULL
       OR p_criteria IS NULL OR DBMS_LOB.getlength(p_criteria) = 0 THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'A test request needs a tester, an environment, an application version and acceptance criteria.');
    END IF;
    SELECT COUNT(*) INTO l_cnt FROM afh_users WHERE user_id = p_assignee_user_id AND is_active = 'Y';
    IF l_cnt = 0 THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The tester must be an active user.');
    END IF;
    SELECT COUNT(*) INTO l_cnt
      FROM afh_environments
     WHERE environment_id = p_environment_id AND application_id = p_ticket.application_id;
    IF l_cnt = 0 THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'The test environment must belong to the ticket''s application.');
    END IF;
  END validate_test_request;

  FUNCTION request_test(
    p_ticket_id        IN NUMBER,
    p_assignee_user_id IN NUMBER,
    p_environment_id   IN NUMBER,
    p_app_version      IN VARCHAR2,
    p_criteria         IN CLOB,
    p_release_id       IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_t       afh_tickets%ROWTYPE := ticket_row(p_ticket_id);
    l_id      NUMBER;
    l_task_id NUMBER;
    l_env     afh_environments.label%TYPE;
  BEGIN
    afh_security_pkg.assert_min_role(afh_security_pkg.c_role_developer, l_t.application_id);
    validate_test_request(l_t, p_assignee_user_id, p_environment_id, p_app_version, p_criteria);
    SELECT label INTO l_env FROM afh_environments WHERE environment_id = p_environment_id;

    INSERT INTO afh_test_results (ticket_id, assignee_user_id, environment_id, app_version, requested_by_user_id,
                                  requested_at, acceptance_criteria, result_code, release_id)
    VALUES (p_ticket_id, p_assignee_user_id, p_environment_id, SUBSTR(p_app_version, 1, 50),
            afh_security_pkg.current_user_id, SYSTIMESTAMP, p_criteria, 'PENDING', p_release_id)
    RETURNING test_result_id INTO l_id;

    l_task_id := create_task(
      p_user_id => p_assignee_user_id, p_ticket_id => p_ticket_id, p_task_type_code => c_task_test_request,
      p_summary => 'Test ' || l_t.ticket_no || ' on ' || l_env || ' (' || SUBSTR(p_app_version, 1, 50) || ')',
      p_related_id => l_id);
    afh_notification_pkg.follow(p_ticket_id, p_assignee_user_id, 'TEST');
    afh_notification_pkg.raise_event(
      p_event_code => afh_notification_pkg.c_ev_test_request, p_ticket_id => p_ticket_id,
      p_target_user_id => p_assignee_user_id, p_task_id => l_task_id,
      p_summary => 'Test requested on ' || l_env);
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_test, p_entity_id => l_id,
      p_event_code  => afh_workflow_int_pkg.c_ev_test_requested, p_ticket_id => p_ticket_id,
      p_after_facts => afh_audit_pkg.json_obj(
                         apex_t_varchar2('test_result_id', 'assignee_user_id', 'environment_id', 'app_version', 'release_id'),
                         apex_t_varchar2(TO_CHAR(l_id), TO_CHAR(p_assignee_user_id), TO_CHAR(p_environment_id),
                                         p_app_version, TO_CHAR(p_release_id))),
      p_summary     => 'Test requested on ' || l_env);
    RETURN l_id;
  END request_test;

  PROCEDURE validate_test_result(p_row IN afh_test_results%ROWTYPE, p_result_code IN VARCHAR2, p_notes IN CLOB) IS
  BEGIN
    IF NOT afh_security_pkg.can_record_test(p_row.test_result_id) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002, 'You cannot record this test result.');
    END IF;
    IF p_result_code NOT IN ('PASSED', 'FAILED') THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The result must be PASSED or FAILED.');
    END IF;
    IF p_row.result_code <> 'PENDING' THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'This test result has already been recorded.');
    END IF;
    IF p_result_code = 'FAILED' AND (p_notes IS NULL OR DBMS_LOB.getlength(p_notes) = 0) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'Notes describing what failed are required as evidence.');
    END IF;
  END validate_test_result;

  PROCEDURE record_test_result(
    p_test_result_id IN NUMBER,
    p_result_code    IN VARCHAR2,
    p_notes          IN CLOB,
    p_row_version    IN NUMBER) IS
    l_row     afh_test_results%ROWTYPE;
    l_result  VARCHAR2(30) := UPPER(TRIM(p_result_code));
    l_task_id NUMBER;
    l_p       t_payload;
  BEGIN
    BEGIN
      SELECT * INTO l_row FROM afh_test_results WHERE test_result_id = p_test_result_id FOR UPDATE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The test request does not exist.');
    END;
    validate_test_result(l_row, l_result, p_notes);
    UPDATE afh_test_results
       SET result_code = l_result, notes = p_notes, completed_at = SYSTIMESTAMP,
           completed_by_user_id = afh_security_pkg.current_user_id
     WHERE test_result_id = p_test_result_id;

    SELECT MIN(task_id) INTO l_task_id
      FROM afh_tasks
     WHERE ticket_id = l_row.ticket_id AND task_type_code = c_task_test_request
       AND related_id = p_test_result_id AND state_code = 'OPEN';
    IF l_task_id IS NOT NULL THEN
      complete_task(l_task_id);
    END IF;
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_test, p_entity_id => p_test_result_id,
      p_event_code  => afh_workflow_int_pkg.c_ev_test_recorded, p_ticket_id => l_row.ticket_id,
      p_after_facts => afh_audit_pkg.json_obj(
                         apex_t_varchar2('result_code', 'notes'),
                         apex_t_varchar2(l_result, DBMS_LOB.substr(p_notes, 200, 1))),
      p_summary     => CASE l_result WHEN 'PASSED' THEN 'Test passed' ELSE 'Test failed' END);
    afh_notification_pkg.raise_event(
      p_event_code => afh_notification_pkg.c_ev_test_outcome, p_ticket_id => l_row.ticket_id,
      p_summary    => CASE l_result WHEN 'PASSED' THEN 'Test passed' ELSE 'Test failed' END);

    IF afh_ticket_pkg.status_code_of(l_row.ticket_id) = c_st_ready_test THEN
      l_p.test_result_id := p_test_result_id;
      transition(l_row.ticket_id,
                 CASE l_result WHEN 'PASSED' THEN c_st_resolved ELSE c_st_in_prog END,
                 p_row_version, l_p);
    END IF;
  END record_test_result;

  -- ------------------------------------------------------------------ jobs
  PROCEDURE auto_close_resolved IS
    l_days NUMBER := afh_security_pkg.config_number('AUTO_CLOSE_DAYS');
  BEGIN
    IF l_days IS NULL OR l_days <= 0 THEN
      RETURN;                              -- auto-close disabled or not configured
    END IF;
    FOR r IN (SELECT ticket_id
                FROM afh_tickets
               WHERE status_code = c_st_resolved
                 AND is_archived = 'N'
                 AND resolved_at < SYSTIMESTAMP - NUMTODSINTERVAL(l_days, 'DAY')
               ORDER BY resolved_at) LOOP
      system_transition(r.ticket_id, c_st_closed,
        'Closed automatically after ' || l_days || ' days without being reopened.');
    END LOOP;
  END auto_close_resolved;
END afh_workflow_pkg;
/
