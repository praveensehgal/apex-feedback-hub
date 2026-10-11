CREATE OR REPLACE PACKAGE afh_workflow_int_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_WORKFLOW_INT_PKG — private engine behind afh_workflow_pkg (spec §10).
  -- Exists only to keep AFH_WORKFLOW_PKG.pkb under the 800-line limit. Pages and
  -- other packages call afh_workflow_pkg; nothing here is a public product API.
  -- Every subprogram assumes afh_workflow_pkg has already decided WHAT to do; this
  -- package decides whether the matrix allows it and performs the writes.
  -- No COMMIT. Identity only via afh_security_pkg.
  -- ---------------------------------------------------------------------------

  -- Fact / actor tokens not declared in afh_workflow_pkg (seed 30_workflow.sql uses them)
  c_fact_queue          CONSTANT VARCHAR2(30) := 'QUEUE';             -- assignee given, or ticket already has an assignee or owner
  c_fact_unlink         CONSTANT VARCHAR2(30) := 'UNLINK_DECISION';   -- unlink_duplicate_yn must be 'Y' or 'N'
  c_actor_dev_or_admin  CONSTANT VARCHAR2(30) := 'DEV_OR_ADMIN_ONLY'; -- explicit DEVELOPER grant or admin; ladder ignored

  -- Audit event codes written by the workflow packages
  c_ev_status_changed   CONSTANT VARCHAR2(30) := 'STATUS_CHANGED';
  c_ev_merged           CONSTANT VARCHAR2(30) := 'TICKET_MERGED';
  c_ev_test_requested   CONSTANT VARCHAR2(30) := 'TEST_REQUESTED';
  c_ev_test_recorded    CONSTANT VARCHAR2(30) := 'TEST_RECORDED';
  c_ev_task_created     CONSTANT VARCHAR2(30) := 'TASK_CREATED';
  c_ev_task_completed   CONSTANT VARCHAR2(30) := 'TASK_COMPLETED';
  c_ev_task_cancelled   CONSTANT VARCHAR2(30) := 'TASK_CANCELLED';

  -- Reopen evidence: an attachment the actor uploaded within this many minutes counts as evidence.
  c_evidence_window_min CONSTANT PLS_INTEGER := 10;

  -- One row of afh_workflow_transitions. workflow_transition_id IS NULL means "no such rule".
  TYPE t_rule IS RECORD (
    workflow_transition_id NUMBER,
    from_status_code       VARCHAR2(30 CHAR),
    to_status_code         VARCHAR2(30 CHAR),
    to_label               VARCHAR2(255 CHAR),
    min_role_code          VARCHAR2(30 CHAR),
    alt_actors             VARCHAR2(200 CHAR),
    required_facts         VARCHAR2(200 CHAR),
    reason_required        VARCHAR2(1 CHAR),
    label                  VARCHAR2(255 CHAR),
    display_seq            NUMBER);

  -- TRUE when p_token appears in the comma list p_list (whitespace tolerant).
  FUNCTION has_token(p_list IN VARCHAR2, p_token IN VARCHAR2) RETURN BOOLEAN;

  -- Active rule for (from, to) joined to an active target status; empty record when none.
  FUNCTION find_rule(p_from_status_code IN VARCHAR2, p_to_status_code IN VARCHAR2) RETURN t_rule;
  FUNCTION status_label(p_status_code IN VARCHAR2) RETURN VARCHAR2;

  -- TRUE when the current user may perform p_rule on p_ticket: DEV_OR_ADMIN_ONLY when present,
  -- otherwise meets_min_role(min_role_code) OR any REPORTER / ASSIGNED_TESTER predicate.
  -- SYSTEM never satisfies a user call.
  FUNCTION actor_allowed(p_rule IN t_rule, p_ticket IN afh_tickets%ROWTYPE) RETURN BOOLEAN;

  -- Comma list of required facts not satisfied by the payload or the ticket; NULL when complete.
  FUNCTION missing_facts(
    p_rule    IN t_rule,
    p_ticket  IN afh_tickets%ROWTYPE,
    p_payload IN afh_workflow_pkg.t_payload) RETURN VARCHAR2;

  -- The transition engine. Lock + version check -> rule -> actor (unless p_is_system) ->
  -- facts -> duplicate relation work (to DUPLICATE) -> apply facts -> comment -> status and
  -- timestamps -> tasks -> notifications -> one STATUS_CHANGED audit. Raises AFH-WF-001
  -- before any write on denial.
  PROCEDURE run(
    p_ticket_id      IN NUMBER,
    p_to_status_code IN VARCHAR2,
    p_row_version    IN NUMBER,
    p_payload        IN afh_workflow_pkg.t_payload,
    p_is_system      IN BOOLEAN);

  -- Spec §16 steps 1-5 and 7: validate (distinct, visible, master not itself a duplicate),
  -- replace the active DUPLICATE_OF relation, copy followers (source MERGE) and affected users
  -- to the master without duplicates, audit TICKET_MERGED on both timelines, bump the master.
  -- Called by run() for any transition to DUPLICATE. Does not change the duplicate's status.
  PROCEDURE merge_relations(
    p_duplicate_ticket_id IN NUMBER,
    p_master_ticket_id    IN NUMBER,
    p_reason              IN VARCHAR2);
END afh_workflow_int_pkg;
/
