CREATE OR REPLACE PACKAGE afh_workflow_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_WORKFLOW_PKG — status transitions, required facts, tasks, test requests
  -- and results, duplicate merge, and status audit. Spec §10, §16, WU-09, WU-11.
  -- The transition matrix is DATA (afh_workflow_transitions); this package
  -- enforces it. Denied transitions raise AFH-WF-001 before any write.
  -- ---------------------------------------------------------------------------

  -- Status codes (spec §10.1)
  c_st_new        CONSTANT VARCHAR2(30) := 'NEW';
  c_st_review     CONSTANT VARCHAR2(30) := 'UNDER_REVIEW';
  c_st_more_info  CONSTANT VARCHAR2(30) := 'MORE_INFO';
  c_st_accepted   CONSTANT VARCHAR2(30) := 'ACCEPTED';
  c_st_planned    CONSTANT VARCHAR2(30) := 'PLANNED';
  c_st_in_prog    CONSTANT VARCHAR2(30) := 'IN_PROGRESS';
  c_st_ready_test CONSTANT VARCHAR2(30) := 'READY_TEST';
  c_st_resolved   CONSTANT VARCHAR2(30) := 'RESOLVED';
  c_st_closed     CONSTANT VARCHAR2(30) := 'CLOSED';
  c_st_duplicate  CONSTANT VARCHAR2(30) := 'DUPLICATE';
  c_st_rejected   CONSTANT VARCHAR2(30) := 'REJECTED';
  c_st_cannot_rep CONSTANT VARCHAR2(30) := 'CANNOT_REPRODUCE';
  c_st_reopened   CONSTANT VARCHAR2(30) := 'REOPENED';

  -- Required-fact tokens used in afh_workflow_transitions.required_facts
  c_fact_assignee      CONSTANT VARCHAR2(30) := 'ASSIGNEE';
  c_fact_master        CONSTANT VARCHAR2(30) := 'MASTER_TICKET';
  c_fact_reason        CONSTANT VARCHAR2(30) := 'REASON';           -- public reason / question / closure note
  c_fact_classification CONSTANT VARCHAR2(30) := 'CLASSIFICATION'; -- official priority+severity+impact set
  c_fact_root_cause    CONSTANT VARCHAR2(30) := 'ROOT_CAUSE';
  c_fact_resolution    CONSTANT VARCHAR2(30) := 'RESOLUTION';
  c_fact_test_request  CONSTANT VARCHAR2(30) := 'TEST_REQUEST';     -- assignee + environment + criteria
  c_fact_release_or_note CONSTANT VARCHAR2(30) := 'RELEASE_OR_NOTE';
  c_fact_test_passed   CONSTANT VARCHAR2(30) := 'TEST_PASSED';
  c_fact_test_failed   CONSTANT VARCHAR2(30) := 'TEST_FAILED';
  c_fact_evidence      CONSTANT VARCHAR2(30) := 'EVIDENCE';         -- reopen: reason + evidence or explanation

  -- Actor predicates used in afh_workflow_transitions.alt_actors
  c_actor_reporter  CONSTANT VARCHAR2(30) := 'REPORTER';
  c_actor_tester    CONSTANT VARCHAR2(30) := 'ASSIGNED_TESTER';
  c_actor_system    CONSTANT VARCHAR2(30) := 'SYSTEM';

  -- All facts a transition may need, passed as one record so the API is stable.
  TYPE t_payload IS RECORD (
    reason                VARCHAR2(4000 CHAR),   -- public question (MORE_INFO), public reason (REJECTED/CANNOT_REPRODUCE/DUPLICATE/REOPENED), closure note (CLOSED), planning note (PLANNED)
    assignee_user_id      NUMBER,
    master_ticket_id      NUMBER,
    release_id            NUMBER,
    priority_code         VARCHAR2(30 CHAR),
    severity_code         VARCHAR2(30 CHAR),
    impact_code           VARCHAR2(30 CHAR),
    root_cause            CLOB,
    resolution            CLOB,
    test_assignee_user_id NUMBER,
    test_environment_id   NUMBER,
    test_app_version      VARCHAR2(50 CHAR),
    test_criteria         CLOB,
    test_result_id        NUMBER,                -- READY_TEST -> IN_PROGRESS / RESOLVED: the completed test
    evidence_text         VARCHAR2(4000 CHAR),
    unlink_duplicate_yn   VARCHAR2(1 CHAR));     -- DUPLICATE -> REOPENED: 'Y' deactivates the master relation

  FUNCTION empty_payload RETURN t_payload;

  -- ----------------------------------------------------------------- transitions
  -- Perform one transition for the current user. Steps: lock + row_version check ->
  -- matrix lookup (from, to, active) -> actor check (meets_min_role OR alt_actors
  -- predicate) -> required facts present -> apply facts (assignment, classification,
  -- release, resolution, test request, relation) -> update status/dates -> tasks ->
  -- notifications (STATUS_CHANGED + specific events) -> audit STATUS_CHANGED.
  PROCEDURE transition(
    p_ticket_id      IN NUMBER,
    p_to_status_code IN VARCHAR2,
    p_row_version    IN NUMBER,
    p_payload        IN t_payload DEFAULT NULL);

  -- System-initiated transition without actor checks (MORE_INFO -> UNDER_REVIEW after the
  -- reporter responds; RESOLVED -> CLOSED by the auto-close job). Only from package code.
  PROCEDURE system_transition(
    p_ticket_id      IN NUMBER,
    p_to_status_code IN VARCHAR2,
    p_reason         IN VARCHAR2 DEFAULT NULL);

  TYPE t_transition IS RECORD (
    to_status_code  VARCHAR2(30 CHAR),
    to_label        VARCHAR2(255 CHAR),
    label           VARCHAR2(255 CHAR),      -- button label, e.g. 'Accept'
    required_facts  VARCHAR2(200 CHAR),
    reason_required VARCHAR2(1 CHAR),
    display_seq     NUMBER);
  TYPE t_transition_tab IS TABLE OF t_transition;
  -- Transitions the current user may perform now (for buttons / select lists).
  FUNCTION allowed_transitions(p_ticket_id IN NUMBER) RETURN t_transition_tab PIPELINED;
  FUNCTION can_transition(p_ticket_id IN NUMBER, p_to_status_code IN VARCHAR2) RETURN BOOLEAN;
  -- Facts still missing on the ticket for a transition (comma list) — lets Page 10 explain
  -- why a button is disabled. NULL when nothing is missing.
  FUNCTION missing_facts(p_ticket_id IN NUMBER, p_to_status_code IN VARCHAR2) RETURN VARCHAR2;

  -- ----------------------------------------------------------------- duplicate merge (spec §16)
  -- Authorization can_merge on both tickets. Validates distinct tickets, visible scope, no
  -- cycle; sets the single active DUPLICATE_OF relation; moves followers and affected users
  -- to the master without duplicates; transitions the duplicate to DUPLICATE; adds public
  -- MERGE audit on both timelines; notifies duplicate reporter/followers. One transaction.
  PROCEDURE merge_duplicate(
    p_duplicate_ticket_id IN NUMBER,
    p_master_ticket_id    IN NUMBER,
    p_reason              IN VARCHAR2,
    p_row_version         IN NUMBER);

  -- ----------------------------------------------------------------- tasks
  c_task_assignment   CONSTANT VARCHAR2(30) := 'ASSIGNMENT';
  c_task_info_request CONSTANT VARCHAR2(30) := 'INFO_REQUEST';
  c_task_test_request CONSTANT VARCHAR2(30) := 'TEST_REQUEST';
  c_task_review       CONSTANT VARCHAR2(30) := 'REVIEW';

  -- Create an OPEN task (idempotent per user/ticket/type while one is open). Returns task_id.
  FUNCTION create_task(
    p_user_id        IN NUMBER,
    p_ticket_id      IN NUMBER,
    p_task_type_code IN VARCHAR2,
    p_summary        IN VARCHAR2 DEFAULT NULL,
    p_due_date       IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL,
    p_related_id     IN NUMBER DEFAULT NULL) RETURN NUMBER;
  PROCEDURE complete_task(p_task_id IN NUMBER);                -- task owner, developer+, or package code
  PROCEDURE cancel_open_tasks(p_ticket_id IN NUMBER, p_task_type_code IN VARCHAR2 DEFAULT NULL);
  FUNCTION open_task_id(p_ticket_id IN NUMBER, p_task_type_code IN VARCHAR2, p_user_id IN NUMBER DEFAULT NULL) RETURN NUMBER;

  -- ----------------------------------------------------------------- testing (spec WU-11)
  -- Create a PENDING test request (assignee, environment, version, criteria all required),
  -- TEST_REQUEST task + TEST_REQUESTED notification. Called by transition to READY_TEST and
  -- usable directly by developer+ for an additional test round. Returns test_result_id.
  FUNCTION request_test(
    p_ticket_id        IN NUMBER,
    p_assignee_user_id IN NUMBER,
    p_environment_id   IN NUMBER,
    p_app_version      IN VARCHAR2,
    p_criteria         IN CLOB,
    p_release_id       IN NUMBER DEFAULT NULL) RETURN NUMBER;

  -- Record PASSED/FAILED by the assigned tester or developer+. Completes the task, audits
  -- TEST_RECORDED, and transitions the ticket READY_TEST -> RESOLVED (passed) or
  -- READY_TEST -> IN_PROGRESS (failed, p_notes required as evidence) in the same transaction.
  PROCEDURE record_test_result(
    p_test_result_id IN NUMBER,
    p_result_code    IN VARCHAR2,
    p_notes          IN CLOB,
    p_row_version    IN NUMBER);

  -- ----------------------------------------------------------------- jobs
  -- RESOLVED tickets older than config AUTO_CLOSE_DAYS -> CLOSED (system transition).
  PROCEDURE auto_close_resolved;
END afh_workflow_pkg;
/
