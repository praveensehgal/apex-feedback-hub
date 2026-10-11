CREATE OR REPLACE PACKAGE BODY afh_workflow_int_pkg AS
  -- Private engine for afh_workflow_pkg. See the spec header for the contract.

  c_reason_excerpt CONSTANT PLS_INTEGER := 200;

  -- ------------------------------------------------------------------ small helpers
  FUNCTION has_token(p_list IN VARCHAR2, p_token IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    IF p_list IS NULL OR p_token IS NULL THEN
      RETURN FALSE;
    END IF;
    RETURN INSTR(',' || UPPER(REPLACE(p_list, ' ', '')) || ',', ',' || UPPER(p_token) || ',') > 0;
  END has_token;

  FUNCTION is_blank(p_text IN CLOB) RETURN BOOLEAN IS
  BEGIN
    RETURN p_text IS NULL OR DBMS_LOB.getlength(p_text) = 0
           OR TRIM(DBMS_LOB.substr(p_text, 4000, 1)) IS NULL;
  END is_blank;

  FUNCTION excerpt(p_text IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN SUBSTR(p_text, 1, c_reason_excerpt);
  END excerpt;

  PROCEDURE deny(p_message IN VARCHAR2) IS
  BEGIN
    afh_security_pkg.raise_error(afh_security_pkg.c_err_wf_001, p_message);
  END deny;

  FUNCTION status_label(p_status_code IN VARCHAR2) RETURN VARCHAR2 IS
    l_label afh_workflow_statuses.label%TYPE;
  BEGIN
    SELECT label INTO l_label FROM afh_workflow_statuses WHERE status_code = p_status_code;
    RETURN l_label;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN p_status_code;
  END status_label;

  FUNCTION find_rule(p_from_status_code IN VARCHAR2, p_to_status_code IN VARCHAR2) RETURN t_rule IS
    l_rule t_rule;
  BEGIN
    SELECT t.workflow_transition_id, t.from_status_code, t.to_status_code, s.label,
           t.min_role_code, t.alt_actors, t.required_facts, t.reason_required, t.label, t.display_seq
      INTO l_rule
      FROM afh_workflow_transitions t
      JOIN afh_workflow_statuses s ON s.status_code = t.to_status_code
     WHERE t.from_status_code = p_from_status_code
       AND t.to_status_code   = p_to_status_code
       AND t.is_active = 'Y'
       AND s.is_active = 'Y';
    RETURN l_rule;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN l_rule;
  END find_rule;

  -- ------------------------------------------------------------------ actor check
  FUNCTION actor_allowed(p_rule IN t_rule, p_ticket IN afh_tickets%ROWTYPE) RETURN BOOLEAN IS
  BEGIN
    IF has_token(p_rule.alt_actors, c_actor_dev_or_admin) THEN
      RETURN afh_security_pkg.is_admin
          OR afh_security_pkg.has_role(afh_security_pkg.c_role_developer, p_ticket.application_id);
    END IF;
    IF p_rule.min_role_code IS NOT NULL
       AND afh_security_pkg.meets_min_role(p_rule.min_role_code, p_ticket.application_id) THEN
      RETURN TRUE;
    END IF;
    IF has_token(p_rule.alt_actors, afh_workflow_pkg.c_actor_reporter)
       AND afh_security_pkg.is_reporter(p_ticket.ticket_id) THEN
      RETURN TRUE;
    END IF;
    IF has_token(p_rule.alt_actors, afh_workflow_pkg.c_actor_tester)
       AND afh_security_pkg.is_assigned_tester(p_ticket.ticket_id) THEN
      RETURN TRUE;
    END IF;
    RETURN FALSE;   -- SYSTEM is never satisfied by a user call
  END actor_allowed;

  -- ------------------------------------------------------------------ fact predicates
  FUNCTION is_classified(p_ticket IN afh_tickets%ROWTYPE, p_p IN afh_workflow_pkg.t_payload) RETURN BOOLEAN IS
    l_cnt PLS_INTEGER;
  BEGIN
    IF p_p.priority_code IS NOT NULL AND p_p.severity_code IS NOT NULL AND p_p.impact_code IS NOT NULL THEN
      RETURN TRUE;
    END IF;
    -- "Official classification confirmed" (spec §10.2): a developer has classified the ticket.
    SELECT COUNT(*) INTO l_cnt
      FROM afh_audit_events
     WHERE ticket_id = p_ticket.ticket_id
       AND event_code = afh_ticket_pkg.c_ev_classified;
    RETURN l_cnt > 0;
  END is_classified;

  FUNCTION test_result_is(p_ticket_id IN NUMBER, p_test_result_id IN NUMBER, p_result_code IN VARCHAR2) RETURN BOOLEAN IS
    l_cnt PLS_INTEGER;
  BEGIN
    IF p_test_result_id IS NULL THEN
      RETURN FALSE;
    END IF;
    SELECT COUNT(*) INTO l_cnt
      FROM afh_test_results
     WHERE test_result_id = p_test_result_id
       AND ticket_id = p_ticket_id
       AND result_code = p_result_code;
    RETURN l_cnt > 0;
  END test_result_is;

  FUNCTION has_evidence(p_ticket_id IN NUMBER, p_p IN afh_workflow_pkg.t_payload) RETURN BOOLEAN IS
    l_cnt PLS_INTEGER;
  BEGIN
    IF TRIM(p_p.evidence_text) IS NOT NULL THEN
      RETURN TRUE;
    END IF;
    SELECT COUNT(*) INTO l_cnt
      FROM afh_attachments
     WHERE ticket_id = p_ticket_id
       AND is_deleted = 'N'
       AND uploaded_by_user_id = afh_security_pkg.current_user_id
       AND uploaded_at >= SYSTIMESTAMP - NUMTODSINTERVAL(c_evidence_window_min, 'MINUTE');
    RETURN l_cnt > 0;
  END has_evidence;

  FUNCTION has_test_request(p_ticket IN afh_tickets%ROWTYPE, p_p IN afh_workflow_pkg.t_payload) RETURN BOOLEAN IS
  BEGIN
    RETURN p_p.test_assignee_user_id IS NOT NULL
       AND p_p.test_environment_id IS NOT NULL
       AND NOT is_blank(p_p.test_criteria);
  END has_test_request;

  FUNCTION fact_present(
    p_token  IN VARCHAR2,
    p_ticket IN afh_tickets%ROWTYPE,
    p_p      IN afh_workflow_pkg.t_payload) RETURN BOOLEAN IS
  BEGIN
    CASE p_token
      WHEN afh_workflow_pkg.c_fact_assignee THEN
        RETURN COALESCE(p_p.assignee_user_id, p_ticket.assignee_user_id) IS NOT NULL;
      WHEN c_fact_queue THEN
        RETURN COALESCE(p_p.assignee_user_id, p_ticket.assignee_user_id, p_ticket.owner_user_id) IS NOT NULL;
      WHEN afh_workflow_pkg.c_fact_master THEN
        RETURN p_p.master_ticket_id IS NOT NULL;
      WHEN afh_workflow_pkg.c_fact_reason THEN
        RETURN TRIM(p_p.reason) IS NOT NULL;
      WHEN afh_workflow_pkg.c_fact_classification THEN
        RETURN is_classified(p_ticket, p_p);
      WHEN afh_workflow_pkg.c_fact_root_cause THEN
        RETURN NOT is_blank(p_p.root_cause) OR NOT is_blank(p_ticket.root_cause);
      WHEN afh_workflow_pkg.c_fact_resolution THEN
        RETURN NOT is_blank(p_p.resolution) OR NOT is_blank(p_ticket.resolution);
      WHEN afh_workflow_pkg.c_fact_test_request THEN
        RETURN has_test_request(p_ticket, p_p);
      WHEN afh_workflow_pkg.c_fact_release_or_note THEN
        RETURN COALESCE(p_p.release_id, p_ticket.release_id) IS NOT NULL OR TRIM(p_p.reason) IS NOT NULL;
      WHEN afh_workflow_pkg.c_fact_test_passed THEN
        RETURN test_result_is(p_ticket.ticket_id, p_p.test_result_id, 'PASSED');
      WHEN afh_workflow_pkg.c_fact_test_failed THEN
        RETURN test_result_is(p_ticket.ticket_id, p_p.test_result_id, 'FAILED');
      WHEN afh_workflow_pkg.c_fact_evidence THEN
        RETURN has_evidence(p_ticket.ticket_id, p_p);
      WHEN c_fact_unlink THEN
        RETURN p_p.unlink_duplicate_yn IS NOT NULL AND p_p.unlink_duplicate_yn IN ('Y', 'N');   -- NULL never satisfies
      ELSE
        RETURN FALSE;   -- unknown token in the matrix can never be satisfied: fail closed
    END CASE;
  END fact_present;

  FUNCTION missing_facts(
    p_rule    IN t_rule,
    p_ticket  IN afh_tickets%ROWTYPE,
    p_payload IN afh_workflow_pkg.t_payload) RETURN VARCHAR2 IS
    l_tokens  apex_t_varchar2 := apex_string.split(NVL(REPLACE(p_rule.required_facts, ' ', ''), ''), ',');
    l_missing apex_t_varchar2 := apex_t_varchar2();
  BEGIN
    IF p_rule.reason_required = 'Y' AND NOT has_token(p_rule.required_facts, afh_workflow_pkg.c_fact_reason) THEN
      apex_string.push(l_tokens, afh_workflow_pkg.c_fact_reason);
    END IF;
    FOR i IN 1 .. l_tokens.COUNT LOOP
      IF l_tokens(i) IS NOT NULL AND NOT NVL(fact_present(UPPER(l_tokens(i)), p_ticket, p_payload), FALSE) THEN   -- NULL = missing (fail closed)
        apex_string.push(l_missing, UPPER(l_tokens(i)));
      END IF;
    END LOOP;
    RETURN apex_string.join(l_missing, ',');
  END missing_facts;

  -- ------------------------------------------------------------------ duplicate merge (spec §16)
  PROCEDURE validate_merge(p_dup IN afh_tickets%ROWTYPE, p_master_ticket_id IN NUMBER) IS
    l_master afh_tickets%ROWTYPE;
  BEGIN
    IF p_master_ticket_id IS NULL OR p_master_ticket_id = p_dup.ticket_id THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Choose a different ticket as the master.');
    END IF;
    BEGIN
      SELECT * INTO l_master FROM afh_tickets WHERE ticket_id = p_master_ticket_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The master ticket does not exist.');
    END;
    IF NOT afh_security_pkg.can_view_ticket(p_master_ticket_id) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002, 'You cannot use that ticket as the master.');
    END IF;
    IF l_master.is_archived = 'Y' THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The master ticket is archived.');
    END IF;
    -- A master that is itself a duplicate would create a chain or a cycle: refuse, point at the real master.
    IF l_master.status_code = afh_workflow_pkg.c_st_duplicate
       OR afh_search_pkg.master_ticket_id(p_master_ticket_id) IS NOT NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        'Ticket ' || l_master.ticket_no || ' is itself a duplicate; merge into its master ticket instead.');
    END IF;
  END validate_merge;

  PROCEDURE copy_followers_and_affected(p_from_ticket_id IN NUMBER, p_to_ticket_id IN NUMBER) IS
  BEGIN
    INSERT INTO afh_followers (ticket_id, user_id, follow_source_code, is_muted)
    SELECT p_to_ticket_id, f.user_id, 'MERGE', f.is_muted
      FROM afh_followers f
     WHERE f.ticket_id = p_from_ticket_id
       AND NOT EXISTS (SELECT 1 FROM afh_followers m
                        WHERE m.ticket_id = p_to_ticket_id AND m.user_id = f.user_id);
    INSERT INTO afh_affected_users (ticket_id, user_id, comment_text)
    SELECT p_to_ticket_id, a.user_id, a.comment_text
      FROM afh_affected_users a
     WHERE a.ticket_id = p_from_ticket_id
       AND NOT EXISTS (SELECT 1 FROM afh_affected_users m
                        WHERE m.ticket_id = p_to_ticket_id AND m.user_id = a.user_id);
  END copy_followers_and_affected;

  PROCEDURE merge_relations(
    p_duplicate_ticket_id IN NUMBER,
    p_master_ticket_id    IN NUMBER,
    p_reason              IN VARCHAR2) IS
    l_dup       afh_tickets%ROWTYPE;
    l_master_no afh_tickets.ticket_no%TYPE;
    l_facts     CLOB;
  BEGIN
    SELECT * INTO l_dup FROM afh_tickets WHERE ticket_id = p_duplicate_ticket_id;
    validate_merge(l_dup, p_master_ticket_id);
    SELECT ticket_no INTO l_master_no FROM afh_tickets WHERE ticket_id = p_master_ticket_id FOR UPDATE;

    UPDATE afh_ticket_relations
       SET is_active = 'N', deactivated_at = SYSTIMESTAMP
     WHERE source_ticket_id = p_duplicate_ticket_id
       AND relation_code = 'DUPLICATE_OF'
       AND is_active = 'Y';
    INSERT INTO afh_ticket_relations (source_ticket_id, target_ticket_id, relation_code, is_active, reason)
    VALUES (p_duplicate_ticket_id, p_master_ticket_id, 'DUPLICATE_OF', 'Y', SUBSTR(p_reason, 1, 1000));

    copy_followers_and_affected(p_duplicate_ticket_id, p_master_ticket_id);

    l_facts := afh_audit_pkg.json_obj(
      apex_t_varchar2('duplicate_ticket_id', 'duplicate_ticket_no', 'master_ticket_id', 'master_ticket_no', 'reason'),
      apex_t_varchar2(TO_CHAR(p_duplicate_ticket_id), l_dup.ticket_no, TO_CHAR(p_master_ticket_id), l_master_no, excerpt(p_reason)));
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_ticket, p_entity_id => p_duplicate_ticket_id,
      p_event_code  => c_ev_merged, p_ticket_id => p_duplicate_ticket_id, p_after_facts => l_facts,
      p_summary     => 'Merged into ' || l_master_no || ' as a duplicate');
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_ticket, p_entity_id => p_master_ticket_id,
      p_event_code  => c_ev_merged, p_ticket_id => p_master_ticket_id, p_after_facts => l_facts,
      p_summary     => l_dup.ticket_no || ' was merged into this ticket as a duplicate');
    afh_ticket_pkg.bump_version(p_master_ticket_id);
  END merge_relations;

  PROCEDURE unlink_duplicate(p_ticket_id IN NUMBER) IS
  BEGIN
    UPDATE afh_ticket_relations
       SET is_active = 'N', deactivated_at = SYSTIMESTAMP
     WHERE source_ticket_id = p_ticket_id
       AND relation_code = 'DUPLICATE_OF'
       AND is_active = 'Y';
  END unlink_duplicate;

  -- ------------------------------------------------------------------ apply payload facts
  FUNCTION rv(p_ticket_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN afh_ticket_pkg.row_version_of(p_ticket_id);
  END rv;

  FUNCTION test_app_version(p_t IN afh_tickets%ROWTYPE, p_p IN afh_workflow_pkg.t_payload) RETURN VARCHAR2 IS
    l_env_version afh_environments.app_version%TYPE;
  BEGIN
    IF p_p.test_app_version IS NOT NULL THEN
      RETURN p_p.test_app_version;
    END IF;
    IF p_t.app_version IS NOT NULL THEN
      RETURN p_t.app_version;
    END IF;
    SELECT MAX(app_version) INTO l_env_version FROM afh_environments WHERE environment_id = p_p.test_environment_id;
    RETURN l_env_version;
  END test_app_version;

  PROCEDURE apply_facts(p_t IN afh_tickets%ROWTYPE, p_rule IN t_rule, p_p IN afh_workflow_pkg.t_payload) IS
    l_test_id NUMBER;
  BEGIN
    IF p_p.assignee_user_id IS NOT NULL AND NVL(p_t.assignee_user_id, -1) <> p_p.assignee_user_id THEN
      afh_ticket_pkg.assign(p_t.ticket_id, rv(p_t.ticket_id), p_p.assignee_user_id);
    END IF;
    IF p_p.priority_code IS NOT NULL AND p_p.severity_code IS NOT NULL AND p_p.impact_code IS NOT NULL THEN
      afh_ticket_pkg.set_classification(p_t.ticket_id, rv(p_t.ticket_id),
        p_p.priority_code, p_p.severity_code, p_p.impact_code);
    END IF;
    IF p_p.release_id IS NOT NULL AND NVL(p_t.release_id, -1) <> p_p.release_id THEN
      afh_ticket_pkg.set_release(p_t.ticket_id, rv(p_t.ticket_id), p_p.release_id);
    END IF;
    IF NOT is_blank(p_p.root_cause) OR NOT is_blank(p_p.resolution) THEN
      afh_ticket_pkg.set_resolution(p_t.ticket_id, rv(p_t.ticket_id),
        CASE WHEN is_blank(p_p.root_cause) THEN p_t.root_cause ELSE p_p.root_cause END,
        CASE WHEN is_blank(p_p.resolution) THEN p_t.resolution ELSE p_p.resolution END);
    END IF;
    IF has_token(p_rule.required_facts, afh_workflow_pkg.c_fact_test_request) THEN
      l_test_id := afh_workflow_pkg.request_test(
        p_ticket_id => p_t.ticket_id, p_assignee_user_id => p_p.test_assignee_user_id,
        p_environment_id => p_p.test_environment_id, p_app_version => test_app_version(p_t, p_p),
        p_criteria => p_p.test_criteria, p_release_id => COALESCE(p_p.release_id, p_t.release_id));
    END IF;
    IF p_rule.to_status_code = afh_workflow_pkg.c_st_reopened
       AND p_t.status_code = afh_workflow_pkg.c_st_duplicate
       AND p_p.unlink_duplicate_yn = 'Y' THEN
      unlink_duplicate(p_t.ticket_id);
    END IF;
  END apply_facts;

  -- ------------------------------------------------------------------ side effects
  -- Public comment carrying the question / reason. Before the status change for MORE_INFO (so the
  -- comment package's "reporter answered" hook cannot fire), after it for every other target.
  PROCEDURE post_reason_comment(p_t IN afh_tickets%ROWTYPE, p_to IN VARCHAR2, p_p IN afh_workflow_pkg.t_payload) IS
    l_body VARCHAR2(8000 CHAR);
    l_id   NUMBER;
  BEGIN
    IF TRIM(p_p.reason) IS NULL THEN
      RETURN;
    END IF;
    IF p_to NOT IN (afh_workflow_pkg.c_st_more_info, afh_workflow_pkg.c_st_rejected,
                    afh_workflow_pkg.c_st_cannot_rep, afh_workflow_pkg.c_st_closed,
                    afh_workflow_pkg.c_st_reopened) THEN
      RETURN;
    END IF;
    l_body := p_p.reason;
    IF p_to = afh_workflow_pkg.c_st_reopened AND TRIM(p_p.evidence_text) IS NOT NULL THEN
      l_body := l_body || CHR(10) || CHR(10) || p_p.evidence_text;
    END IF;
    l_id := afh_comment_pkg.add_comment(p_t.ticket_id, l_body, afh_comment_pkg.c_vis_public);
  END post_reason_comment;

  PROCEDURE set_status(p_t IN afh_tickets%ROWTYPE, p_to IN VARCHAR2) IS
  BEGIN
    UPDATE afh_tickets
       SET status_code = p_to,
           resolved_at = CASE WHEN p_to = afh_workflow_pkg.c_st_resolved THEN SYSTIMESTAMP
                              WHEN p_to = afh_workflow_pkg.c_st_reopened THEN NULL
                              ELSE resolved_at END,
           closed_at   = CASE WHEN p_to = afh_workflow_pkg.c_st_closed THEN SYSTIMESTAMP
                              WHEN p_to IN (afh_workflow_pkg.c_st_resolved, afh_workflow_pkg.c_st_reopened) THEN NULL
                              ELSE closed_at END
     WHERE ticket_id = p_t.ticket_id;
    afh_ticket_pkg.bump_version(p_t.ticket_id);
  END set_status;

  PROCEDURE cancel_pending_tests(p_ticket_id IN NUMBER, p_keep_test_result_id IN NUMBER) IS
  BEGIN
    UPDATE afh_test_results
       SET result_code = 'CANCELLED', completed_at = SYSTIMESTAMP
     WHERE ticket_id = p_ticket_id
       AND result_code = 'PENDING'
       AND test_result_id <> NVL(p_keep_test_result_id, -1);
  END cancel_pending_tests;

  FUNCTION is_terminal(p_status_code IN VARCHAR2) RETURN BOOLEAN IS
    l_yn afh_workflow_statuses.is_terminal%TYPE;
  BEGIN
    SELECT is_terminal INTO l_yn FROM afh_workflow_statuses WHERE status_code = p_status_code;
    RETURN l_yn = 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN FALSE;
  END is_terminal;

  PROCEDURE manage_tasks(p_t IN afh_tickets%ROWTYPE, p_to IN VARCHAR2, p_p IN afh_workflow_pkg.t_payload) IS
    l_task_id NUMBER;
  BEGIN
    IF p_t.status_code = afh_workflow_pkg.c_st_more_info THEN
      afh_workflow_pkg.cancel_open_tasks(p_t.ticket_id, afh_workflow_pkg.c_task_info_request);
    END IF;
    IF p_t.status_code = afh_workflow_pkg.c_st_ready_test THEN
      afh_workflow_pkg.cancel_open_tasks(p_t.ticket_id, afh_workflow_pkg.c_task_test_request);
      cancel_pending_tests(p_t.ticket_id, p_p.test_result_id);
    END IF;
    IF is_terminal(p_to) THEN
      afh_workflow_pkg.cancel_open_tasks(p_t.ticket_id);
      cancel_pending_tests(p_t.ticket_id, NULL);
    END IF;
    IF p_to = afh_workflow_pkg.c_st_more_info THEN
      l_task_id := afh_workflow_pkg.create_task(
        p_user_id => p_t.reporter_user_id, p_ticket_id => p_t.ticket_id,
        p_task_type_code => afh_workflow_pkg.c_task_info_request,
        p_summary => SUBSTR(p_p.reason, 1, 500));
      afh_notification_pkg.raise_event(
        p_event_code => afh_notification_pkg.c_ev_info_request, p_ticket_id => p_t.ticket_id,
        p_target_user_id => p_t.reporter_user_id, p_task_id => l_task_id,
        p_summary => 'More information requested on ' || p_t.ticket_no);
    END IF;
  END manage_tasks;

  PROCEDURE notify(p_t IN afh_tickets%ROWTYPE, p_to IN VARCHAR2, p_to_label IN VARCHAR2) IS
    l_specific VARCHAR2(30);
  BEGIN
    afh_notification_pkg.raise_event(
      p_event_code => afh_notification_pkg.c_ev_status_change, p_ticket_id => p_t.ticket_id,
      p_summary    => p_t.ticket_no || ' is now ' || p_to_label);
    l_specific := CASE p_to
                    WHEN afh_workflow_pkg.c_st_ready_test THEN afh_notification_pkg.c_ev_ready_test
                    WHEN afh_workflow_pkg.c_st_resolved   THEN afh_notification_pkg.c_ev_resolution
                    WHEN afh_workflow_pkg.c_st_closed     THEN afh_notification_pkg.c_ev_closure
                    WHEN afh_workflow_pkg.c_st_reopened   THEN afh_notification_pkg.c_ev_reopened
                    WHEN afh_workflow_pkg.c_st_duplicate  THEN afh_notification_pkg.c_ev_merge
                  END;
    IF l_specific IS NOT NULL THEN
      afh_notification_pkg.raise_event(
        p_event_code => l_specific, p_ticket_id => p_t.ticket_id,
        p_summary    => p_t.ticket_no || ' is now ' || p_to_label);
    END IF;
  END notify;

  PROCEDURE audit_status(p_t IN afh_tickets%ROWTYPE, p_rule IN t_rule, p_p IN afh_workflow_pkg.t_payload, p_is_system IN BOOLEAN) IS
  BEGIN
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_ticket,
      p_entity_id    => p_t.ticket_id,
      p_event_code   => c_ev_status_changed,
      p_ticket_id    => p_t.ticket_id,
      p_before_facts => afh_audit_pkg.json_obj(apex_t_varchar2('status_code'), apex_t_varchar2(p_t.status_code)),
      p_after_facts  => afh_audit_pkg.json_obj(
                          apex_t_varchar2('status_code', 'reason', 'master_ticket_id', 'test_result_id', 'system'),
                          apex_t_varchar2(p_rule.to_status_code, excerpt(p_p.reason), TO_CHAR(p_p.master_ticket_id),
                                          TO_CHAR(p_p.test_result_id), CASE WHEN p_is_system THEN 'Y' ELSE 'N' END)),
      p_summary      => 'Status changed from ' || status_label(p_t.status_code) || ' to ' || p_rule.to_label);
  END audit_status;

  -- ------------------------------------------------------------------ engine
  PROCEDURE run(
    p_ticket_id      IN NUMBER,
    p_to_status_code IN VARCHAR2,
    p_row_version    IN NUMBER,
    p_payload        IN afh_workflow_pkg.t_payload,
    p_is_system      IN BOOLEAN) IS
    l_t       afh_tickets%ROWTYPE;
    l_rule    t_rule;
    l_p       afh_workflow_pkg.t_payload := p_payload;
    l_missing VARCHAR2(4000);
  BEGIN
    afh_ticket_pkg.lock_ticket(p_ticket_id, p_row_version);
    SELECT * INTO l_t FROM afh_tickets WHERE ticket_id = p_ticket_id;
    l_rule := find_rule(l_t.status_code, p_to_status_code);
    IF l_rule.workflow_transition_id IS NULL THEN
      deny('Cannot move from ' || status_label(l_t.status_code) || ' to ' || status_label(p_to_status_code) || '.');
    END IF;
    IF NOT p_is_system AND NOT actor_allowed(l_rule, l_t) THEN
      deny('You are not allowed to perform this transition.');
    END IF;
    l_missing := missing_facts(l_rule, l_t, l_p);
    IF l_missing IS NOT NULL THEN
      deny('Missing: ' || l_missing);
    END IF;
    -- every check passed: writes start here
    IF p_to_status_code = afh_workflow_pkg.c_st_duplicate THEN
      merge_relations(p_ticket_id, l_p.master_ticket_id, l_p.reason);
    END IF;
    apply_facts(l_t, l_rule, l_p);
    IF p_to_status_code = afh_workflow_pkg.c_st_more_info AND NOT p_is_system THEN
      post_reason_comment(l_t, p_to_status_code, l_p);
    END IF;
    set_status(l_t, p_to_status_code);
    IF p_to_status_code <> afh_workflow_pkg.c_st_more_info AND NOT p_is_system THEN
      post_reason_comment(l_t, p_to_status_code, l_p);
    END IF;
    manage_tasks(l_t, p_to_status_code, l_p);
    notify(l_t, p_to_status_code, l_rule.to_label);
    audit_status(l_t, l_rule, l_p, p_is_system);
  END run;
END afh_workflow_int_pkg;
/
