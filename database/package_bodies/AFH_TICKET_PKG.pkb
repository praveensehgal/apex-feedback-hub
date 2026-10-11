CREATE OR REPLACE PACKAGE BODY afh_ticket_pkg AS
  -- ---------------------------------------------------------------------------
  -- Ticket core. Field metadata, JSON and intake validation live in
  -- afh_ticket_int_pkg. No COMMIT anywhere; the page process commits.
  -- ---------------------------------------------------------------------------

  e_row_locked  EXCEPTION;  PRAGMA EXCEPTION_INIT(e_row_locked, -54);
  e_no_body     EXCEPTION;  PRAGMA EXCEPTION_INIT(e_no_body, -4067);   -- package body does not exist
  e_no_unit     EXCEPTION;  PRAGMA EXCEPTION_INIT(e_no_unit, -6508);   -- program unit not found

  -- Status a ticket is born with (spec §10.1). Literal on purpose: afh_workflow_pkg's
  -- spec constants would force that package to be instantiated here.
  c_status_new     CONSTANT VARCHAR2(30) := 'NEW';
  c_src_reporter   CONSTANT VARCHAR2(30) := 'REPORTER';
  c_src_assignment CONSTANT VARCHAR2(30) := 'ASSIGNMENT';
  c_src_affected   CONSTANT VARCHAR2(30) := 'AFFECTED';
  c_rel_duplicate  CONSTANT VARCHAR2(30) := 'DUPLICATE_OF';
  c_rel_related    CONSTANT VARCHAR2(30) := 'RELATED';
  c_rel_depends    CONSTANT VARCHAR2(30) := 'DEPENDS_ON';
  c_rel_blocks     CONSTANT VARCHAR2(30) := 'BLOCKS';

  -- ----------------------------------------------------------------- private helpers
  PROCEDURE raise_val(p_message IN VARCHAR2) IS
  BEGIN
    afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, p_message);
  END raise_val;

  PROCEDURE raise_auth(p_message IN VARCHAR2) IS
  BEGIN
    afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002, p_message);
  END raise_auth;

  FUNCTION get_row(p_ticket_id IN NUMBER) RETURN afh_tickets%ROWTYPE IS
    l_row afh_tickets%ROWTYPE;
  BEGIN
    SELECT * INTO l_row FROM afh_tickets WHERE ticket_id = p_ticket_id;
    RETURN l_row;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_val('The ticket could not be found.');
  END get_row;

  FUNCTION jo(p_names IN apex_t_varchar2, p_values IN apex_t_varchar2) RETURN CLOB IS
  BEGIN
    RETURN afh_audit_pkg.json_obj(p_names, p_values);
  END jo;

  PROCEDURE audit(
    p_ticket_id  IN NUMBER,
    p_event_code IN VARCHAR2,
    p_before     IN CLOB     DEFAULT NULL,
    p_after      IN CLOB     DEFAULT NULL,
    p_summary    IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_ticket,
      p_entity_id    => p_ticket_id,
      p_event_code   => p_event_code,
      p_ticket_id    => p_ticket_id,
      p_before_facts => p_before,
      p_after_facts  => p_after,
      p_summary      => p_summary);
  END audit;

  -- last_activity_at only: relation/affected changes are not edits of the ticket row,
  -- so they must not invalidate another user's open form (row_version untouched).
  PROCEDURE touch_activity(p_ticket_id IN NUMBER) IS
  BEGIN
    UPDATE afh_tickets SET last_activity_at = SYSTIMESTAMP WHERE ticket_id = p_ticket_id;
  END touch_activity;

  -- ----------------------------------------------------------------- lookups
  FUNCTION format_ticket_no(p_seq IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF p_seq IS NULL THEN RETURN NULL; END IF;
    RETURN 'FB-' || CASE WHEN p_seq < 10000 THEN LPAD(TRUNC(p_seq), 4, '0') ELSE TO_CHAR(TRUNC(p_seq)) END;
  END format_ticket_no;

  FUNCTION get_ticket_id(p_ticket_no IN VARCHAR2) RETURN NUMBER IS
    l_txt VARCHAR2(100) := UPPER(REGEXP_REPLACE(p_ticket_no, '[^[:alnum:]]', ''));
    l_id  NUMBER;
  BEGIN
    IF l_txt LIKE 'FB%' THEN l_txt := SUBSTR(l_txt, 3); END IF;
    IF l_txt IS NULL OR NOT REGEXP_LIKE(l_txt, '^[0-9]{1,18}$') THEN RETURN NULL; END IF;
    SELECT ticket_id INTO l_id FROM afh_tickets WHERE ticket_no = format_ticket_no(TO_NUMBER(l_txt));
    RETURN l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END get_ticket_id;

  FUNCTION application_id_of(p_ticket_id IN NUMBER) RETURN NUMBER IS
    l_val NUMBER;
  BEGIN
    SELECT application_id INTO l_val FROM afh_tickets WHERE ticket_id = p_ticket_id;
    RETURN l_val;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END application_id_of;

  FUNCTION status_code_of(p_ticket_id IN NUMBER) RETURN VARCHAR2 IS
    l_val afh_tickets.status_code%TYPE;
  BEGIN
    SELECT status_code INTO l_val FROM afh_tickets WHERE ticket_id = p_ticket_id;
    RETURN l_val;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END status_code_of;

  FUNCTION row_version_of(p_ticket_id IN NUMBER) RETURN NUMBER IS
    l_val NUMBER;
  BEGIN
    SELECT row_version INTO l_val FROM afh_tickets WHERE ticket_id = p_ticket_id;
    RETURN l_val;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END row_version_of;

  -- ----------------------------------------------------------------- locking
  PROCEDURE lock_ticket(p_ticket_id IN NUMBER, p_row_version IN NUMBER) IS
    l_ver NUMBER;
  BEGIN
    BEGIN
      SELECT row_version INTO l_ver FROM afh_tickets WHERE ticket_id = p_ticket_id FOR UPDATE NOWAIT;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_val('The ticket could not be found.');
      WHEN e_row_locked THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_lock_001,
          'This ticket is being updated by another user. Wait a moment and try again.');
    END;
    IF p_row_version IS NULL OR l_ver <> p_row_version THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_lock_001,
        'This ticket was changed by another user. Reload to see the current values.');
    END IF;
  END lock_ticket;

  PROCEDURE bump_version(p_ticket_id IN NUMBER) IS
  BEGIN
    UPDATE afh_tickets
       SET row_version = row_version + 1, last_activity_at = SYSTIMESTAMP
     WHERE ticket_id = p_ticket_id;
  END bump_version;

  -- ----------------------------------------------------------------- creation
  -- Ticket already created for the correlation ID (idempotent retry). Tolerates a
  -- missing afh_launch_pkg body during staged installs; any other error propagates.
  FUNCTION existing_for_correlation(p_correlation_id IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF p_correlation_id IS NULL THEN RETURN NULL; END IF;
    RETURN afh_launch_pkg.ticket_for_correlation(p_correlation_id);
  EXCEPTION
    WHEN e_no_body OR e_no_unit THEN RETURN NULL;
  END existing_for_correlation;

  PROCEDURE validate_intake(
    p_title IN VARCHAR2, p_description IN CLOB, p_application_id IN NUMBER, p_environment_id IN NUMBER,
    p_category_id IN NUMBER, p_priority IN VARCHAR2, p_severity IN VARCHAR2, p_impact IN VARCHAR2,
    p_follow_yn IN VARCHAR2, p_context_result_code IN VARCHAR2) IS
  BEGIN
    afh_ticket_int_pkg.validate_title_desc(p_title, p_description);
    afh_ticket_int_pkg.validate_source(p_application_id, p_environment_id);
    afh_ticket_int_pkg.validate_category(p_category_id, p_application_id);
    afh_ticket_int_pkg.validate_class_value('PRIORITY', p_priority);
    afh_ticket_int_pkg.validate_class_value('SEVERITY', p_severity);
    afh_ticket_int_pkg.validate_class_value('IMPACT',   p_impact);
    IF NVL(p_follow_yn, 'Y') NOT IN ('Y', 'N') THEN
      raise_val('Follow must be Yes or No.');
    END IF;
    IF p_context_result_code NOT IN ('SUCCESS', 'PARTIAL', 'UNSUPPORTED', 'FAILED', 'NONE') THEN
      raise_val('The diagnostic capture result is missing. Capture again and retry.');
    END IF;
  END validate_intake;

  FUNCTION build_row(
    p_type_id IN NUMBER, p_title IN VARCHAR2, p_description IN CLOB,
    p_application_id IN NUMBER, p_environment_id IN NUMBER, p_page_id IN NUMBER, p_page_name IN VARCHAR2,
    p_source_url IN VARCHAR2, p_app_version IN VARCHAR2, p_category_id IN NUMBER,
    p_priority IN VARCHAR2, p_severity IN VARCHAR2, p_impact IN VARCHAR2,
    p_context_result_code IN VARCHAR2, p_owner_user_id IN NUMBER, p_assignee_user_id IN NUMBER)
    RETURN afh_tickets%ROWTYPE IS
    l afh_tickets%ROWTYPE;
  BEGIN
    l.ticket_no               := format_ticket_no(afh_ticket_no_seq.NEXTVAL);
    l.feedback_type_id        := p_type_id;
    l.title                   := TRIM(p_title);
    l.description             := p_description;
    l.title_norm              := afh_search_pkg.normalize_text(TRIM(p_title));
    l.desc_norm               := afh_search_pkg.normalize_description(p_description);
    l.reporter_user_id        := afh_security_pkg.current_user_id;
    l.application_id          := p_application_id;
    l.environment_id          := p_environment_id;
    l.page_id                 := p_page_id;
    l.page_name               := SUBSTR(p_page_name, 1, 255);
    l.source_url              := SUBSTR(p_source_url, 1, 2000);
    l.app_version             := SUBSTR(p_app_version, 1, 50);
    l.category_id             := p_category_id;
    l.proposed_priority_code  := p_priority;
    l.proposed_severity_code  := p_severity;
    l.proposed_impact_code    := p_impact;
    l.priority_code           := p_priority;       -- official = proposed at creation
    l.severity_code           := p_severity;
    l.impact_code             := p_impact;
    l.status_code             := c_status_new;
    l.owner_user_id           := p_owner_user_id;
    l.assignee_user_id        := p_assignee_user_id;
    l.context_result_code     := p_context_result_code;
    l.is_archived             := 'N';
    l.row_version             := 1;
    l.submitted_at            := SYSTIMESTAMP;
    l.last_activity_at        := l.submitted_at;
    RETURN l;
  END build_row;

  PROCEDURE after_create(p_row IN afh_tickets%ROWTYPE, p_follow_yn IN VARCHAR2, p_routing_rule_id IN NUMBER) IS
    l_task_id NUMBER;
  BEGIN
    IF NVL(p_follow_yn, 'Y') = 'Y' THEN
      afh_notification_pkg.follow(p_row.ticket_id, p_row.reporter_user_id, c_src_reporter);
    END IF;
    IF p_row.assignee_user_id IS NOT NULL THEN
      l_task_id := afh_workflow_pkg.create_task(
        p_user_id => p_row.assignee_user_id, p_ticket_id => p_row.ticket_id,
        p_task_type_code => afh_workflow_pkg.c_task_assignment,
        p_summary => 'Assigned on creation: ' || p_row.ticket_no);
      afh_notification_pkg.follow(p_row.ticket_id, p_row.assignee_user_id, c_src_assignment);
    END IF;
    audit(p_row.ticket_id, c_ev_created, NULL,
      jo(apex_t_varchar2('ticket_no', 'type_code', 'title', 'application_id', 'environment_id', 'page_id', 'page_name',
                         'proposed_priority', 'proposed_severity', 'proposed_impact', 'owner', 'assignee',
                         'routing_rule_id', 'context_result'),
         apex_t_varchar2(p_row.ticket_no, afh_ticket_int_pkg.type_code_of(p_row.feedback_type_id), p_row.title,
                         p_row.application_id, p_row.environment_id, p_row.page_id, p_row.page_name,
                         p_row.proposed_priority_code, p_row.proposed_severity_code, p_row.proposed_impact_code,
                         afh_ticket_int_pkg.user_name(p_row.owner_user_id), afh_ticket_int_pkg.user_name(p_row.assignee_user_id),
                         p_routing_rule_id, p_row.context_result_code)),
      'Ticket ' || p_row.ticket_no || ' created');
    afh_notification_pkg.raise_event(
      p_event_code => afh_notification_pkg.c_ev_new_ticket, p_ticket_id => p_row.ticket_id,
      p_target_user_id => p_row.owner_user_id, p_summary => 'New ticket ' || p_row.ticket_no);
    IF p_row.assignee_user_id IS NOT NULL THEN
      afh_notification_pkg.raise_event(
        p_event_code => afh_notification_pkg.c_ev_assignment, p_ticket_id => p_row.ticket_id,
        p_target_user_id => p_row.assignee_user_id, p_task_id => l_task_id, p_summary => 'Assigned to you');
    END IF;
  END after_create;

  FUNCTION create_ticket(
    p_type_code               IN VARCHAR2,
    p_title                   IN VARCHAR2,
    p_description             IN CLOB,
    p_application_id          IN NUMBER,
    p_environment_id          IN NUMBER,
    p_page_id                 IN NUMBER,
    p_page_name               IN VARCHAR2,
    p_source_url              IN VARCHAR2,
    p_app_version             IN VARCHAR2,
    p_category_id             IN NUMBER,
    p_proposed_priority_code  IN VARCHAR2,
    p_proposed_severity_code  IN VARCHAR2,
    p_proposed_impact_code    IN VARCHAR2,
    p_field_values_json       IN CLOB     DEFAULT NULL,
    p_follow_yn               IN VARCHAR2 DEFAULT 'Y',
    p_context_result_code     IN VARCHAR2 DEFAULT 'NONE',
    p_correlation_id          IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_existing NUMBER;
    l_type_id  NUMBER;
    l_fields   afh_ticket_int_pkg.t_field_map;
    l_owner    NUMBER;
    l_assignee NUMBER;
    l_rule     NUMBER;
    l_row      afh_tickets%ROWTYPE;
    l_saved    BOOLEAN;
  BEGIN
    afh_security_pkg.assert_authenticated;
    l_existing := existing_for_correlation(p_correlation_id);
    IF l_existing IS NOT NULL THEN RETURN l_existing; END IF;
    validate_intake(p_title, p_description, p_application_id, p_environment_id, p_category_id,
                    UPPER(p_proposed_priority_code), UPPER(p_proposed_severity_code), UPPER(p_proposed_impact_code),
                    p_follow_yn, p_context_result_code);
    l_type_id := afh_ticket_int_pkg.active_type_id(p_type_code);
    l_fields  := afh_ticket_int_pkg.parse_field_values(p_field_values_json);
    afh_ticket_int_pkg.validate_fields(l_type_id, l_fields);
    afh_registry_pkg.resolve_route(
      p_application_id => p_application_id, p_page_id => p_page_id, p_category_id => p_category_id,
      p_environment_id => p_environment_id, p_type_code => UPPER(TRIM(p_type_code)),
      o_assignee_user_id => l_assignee, o_owner_user_id => l_owner, o_routing_rule_id => l_rule);
    l_row := build_row(l_type_id, p_title, p_description, p_application_id, p_environment_id, p_page_id, p_page_name,
                       p_source_url, p_app_version, p_category_id,
                       UPPER(p_proposed_priority_code), UPPER(p_proposed_severity_code), UPPER(p_proposed_impact_code),
                       p_context_result_code, l_owner, l_assignee);
    INSERT INTO afh_tickets VALUES l_row;
    SELECT ticket_id INTO l_row.ticket_id FROM afh_tickets WHERE ticket_no = l_row.ticket_no;
    l_saved := afh_ticket_int_pkg.save_field_values(l_row.ticket_id, l_type_id, l_fields);
    after_create(l_row, p_follow_yn, l_rule);
    RETURN l_row.ticket_id;
  END create_ticket;

  -- ----------------------------------------------------------------- details
  PROCEDURE assert_can_edit_details(p_ticket_id IN NUMBER) IS
  BEGIN
    IF afh_security_pkg.can_classify(p_ticket_id) THEN RETURN; END IF;
    IF afh_security_pkg.is_reporter(p_ticket_id) AND status_code_of(p_ticket_id) = c_status_new THEN RETURN; END IF;
    raise_auth('You can only edit the details of your own ticket while it is new.');
  END assert_can_edit_details;

  FUNCTION details_facts(p_title IN VARCHAR2, p_description IN CLOB, p_category_id IN NUMBER) RETURN CLOB IS
    l_cat VARCHAR2(255);
  BEGIN
    IF p_category_id IS NOT NULL THEN
      SELECT MAX(label) INTO l_cat FROM afh_categories WHERE category_id = p_category_id;
    END IF;
    RETURN jo(apex_t_varchar2('title', 'description_length', 'category'),
              apex_t_varchar2(p_title, NVL(DBMS_LOB.getlength(p_description), 0), l_cat));
  END details_facts;

  -- Title/description/category; returns TRUE when something changed (audit written).
  FUNCTION apply_details(p_row IN afh_tickets%ROWTYPE, p_title IN VARCHAR2, p_description IN CLOB, p_category_id IN NUMBER)
    RETURN BOOLEAN IS
    l_title afh_tickets.title%TYPE := TRIM(p_title);
  BEGIN
    afh_ticket_int_pkg.validate_title_desc(p_title, p_description);
    afh_ticket_int_pkg.validate_category(p_category_id, p_row.application_id);
    IF l_title = p_row.title AND NOT afh_ticket_int_pkg.clob_differs(p_description, p_row.description)
       AND NVL(p_category_id, -1) = NVL(p_row.category_id, -1) THEN
      RETURN FALSE;
    END IF;
    UPDATE afh_tickets
       SET title       = l_title,
           description = p_description,
           title_norm  = afh_search_pkg.normalize_text(l_title),
           desc_norm   = afh_search_pkg.normalize_description(p_description),
           category_id = p_category_id
     WHERE ticket_id = p_row.ticket_id;
    audit(p_row.ticket_id, c_ev_details,
          details_facts(p_row.title, p_row.description, p_row.category_id),
          details_facts(l_title, p_description, p_category_id),
          'Details updated');
    RETURN TRUE;
  END apply_details;

  -- Type-specific values; returns TRUE when a stored value changed (audit written).
  FUNCTION apply_fields(p_row IN afh_tickets%ROWTYPE, p_field_values_json IN CLOB) RETURN BOOLEAN IS
    l_fields afh_ticket_int_pkg.t_field_map;
    l_before CLOB;
  BEGIN
    l_fields := afh_ticket_int_pkg.parse_field_values(p_field_values_json);
    afh_ticket_int_pkg.validate_fields(p_row.feedback_type_id, l_fields);
    l_before := afh_ticket_int_pkg.field_values_facts(p_row.ticket_id);
    IF NOT afh_ticket_int_pkg.save_field_values(p_row.ticket_id, p_row.feedback_type_id, l_fields) THEN
      RETURN FALSE;
    END IF;
    audit(p_row.ticket_id, c_ev_fields, l_before,
          afh_ticket_int_pkg.field_values_facts(p_row.ticket_id), 'Type-specific details updated');
    RETURN TRUE;
  END apply_fields;

  PROCEDURE update_details(
    p_ticket_id          IN NUMBER,
    p_row_version        IN NUMBER,
    p_title              IN VARCHAR2,
    p_description        IN CLOB,
    p_category_id        IN NUMBER,
    p_field_values_json  IN CLOB DEFAULT NULL) IS
    l_row     afh_tickets%ROWTYPE;
    l_changed BOOLEAN := FALSE;
  BEGIN
    assert_can_edit_details(p_ticket_id);
    lock_ticket(p_ticket_id, p_row_version);
    l_row := get_row(p_ticket_id);
    IF apply_details(l_row, p_title, p_description, p_category_id) THEN l_changed := TRUE; END IF;
    IF p_field_values_json IS NOT NULL AND apply_fields(l_row, p_field_values_json) THEN l_changed := TRUE; END IF;
    IF l_changed THEN bump_version(p_ticket_id); END IF;
  END update_details;

  -- ----------------------------------------------------------------- classification
  FUNCTION class_facts(p_priority IN VARCHAR2, p_severity IN VARCHAR2, p_impact IN VARCHAR2, p_type_id IN NUMBER) RETURN CLOB IS
  BEGIN
    RETURN jo(apex_t_varchar2('priority', 'severity', 'impact', 'type_code'),
              apex_t_varchar2(p_priority, p_severity, p_impact, afh_ticket_int_pkg.type_code_of(p_type_id)));
  END class_facts;

  PROCEDURE set_classification(
    p_ticket_id     IN NUMBER,
    p_row_version   IN NUMBER,
    p_priority_code IN VARCHAR2,
    p_severity_code IN VARCHAR2,
    p_impact_code   IN VARCHAR2,
    p_type_code     IN VARCHAR2 DEFAULT NULL) IS
    l_row     afh_tickets%ROWTYPE;
    l_pri     afh_tickets.priority_code%TYPE := UPPER(TRIM(p_priority_code));
    l_sev     afh_tickets.severity_code%TYPE := UPPER(TRIM(p_severity_code));
    l_imp     afh_tickets.impact_code%TYPE   := UPPER(TRIM(p_impact_code));
    l_type_id NUMBER;
  BEGIN
    afh_security_pkg.assert_can_classify(p_ticket_id);
    lock_ticket(p_ticket_id, p_row_version);
    l_row := get_row(p_ticket_id);
    afh_ticket_int_pkg.validate_class_value('PRIORITY', l_pri);
    afh_ticket_int_pkg.validate_class_value('SEVERITY', l_sev);
    afh_ticket_int_pkg.validate_class_value('IMPACT',   l_imp);
    l_type_id := l_row.feedback_type_id;
    IF p_type_code IS NOT NULL THEN
      l_type_id := afh_ticket_int_pkg.active_type_id(p_type_code);
      IF l_type_id <> l_row.feedback_type_id THEN
        -- the stored values must satisfy the new type's required fields
        afh_ticket_int_pkg.validate_fields(l_type_id, afh_ticket_int_pkg.load_field_values(p_ticket_id));
      END IF;
    END IF;
    IF l_pri = l_row.priority_code AND l_sev = l_row.severity_code AND l_imp = l_row.impact_code
       AND l_type_id = l_row.feedback_type_id THEN
      RETURN;
    END IF;
    UPDATE afh_tickets
       SET priority_code = l_pri, severity_code = l_sev, impact_code = l_imp, feedback_type_id = l_type_id
     WHERE ticket_id = p_ticket_id;
    audit(p_ticket_id, c_ev_classified,
          class_facts(l_row.priority_code, l_row.severity_code, l_row.impact_code, l_row.feedback_type_id),
          class_facts(l_pri, l_sev, l_imp, l_type_id), 'Classification changed');
    IF l_pri <> l_row.priority_code THEN
      afh_notification_pkg.raise_event(
        p_event_code => afh_notification_pkg.c_ev_priority, p_ticket_id => p_ticket_id,
        p_summary => 'Priority changed to ' || afh_ticket_int_pkg.class_label('PRIORITY', l_pri));
    END IF;
    bump_version(p_ticket_id);
  END set_classification;

  -- ----------------------------------------------------------------- assignment
  FUNCTION assign_facts(p_assignee_user_id IN NUMBER, p_due_date IN TIMESTAMP WITH LOCAL TIME ZONE) RETURN CLOB IS
  BEGIN
    RETURN jo(apex_t_varchar2('assignee', 'assignee_user_id', 'due_date'),
              apex_t_varchar2(afh_ticket_int_pkg.user_name(p_assignee_user_id), p_assignee_user_id,
                              TO_CHAR(p_due_date, 'YYYY-MM-DD HH24:MI')));
  END assign_facts;

  PROCEDURE assign(
    p_ticket_id        IN NUMBER,
    p_row_version      IN NUMBER,
    p_assignee_user_id IN NUMBER,
    p_due_date         IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL) IS
    l_row      afh_tickets%ROWTYPE;
    l_changed  BOOLEAN;
    l_due      afh_tickets.due_date%TYPE;
    l_task_id  NUMBER;
  BEGIN
    afh_security_pkg.assert_can_assign(p_ticket_id);
    lock_ticket(p_ticket_id, p_row_version);
    l_row := get_row(p_ticket_id);
    afh_ticket_int_pkg.validate_user(p_assignee_user_id, 'assignee');
    l_due     := NVL(p_due_date, l_row.due_date);
    l_changed := NVL(p_assignee_user_id, -1) <> NVL(l_row.assignee_user_id, -1);
    IF NOT l_changed AND (l_due IS NULL AND l_row.due_date IS NULL OR l_due = l_row.due_date) THEN
      RETURN;
    END IF;
    IF l_changed THEN
      afh_workflow_pkg.cancel_open_tasks(p_ticket_id, afh_workflow_pkg.c_task_assignment);
    END IF;
    UPDATE afh_tickets SET assignee_user_id = p_assignee_user_id, due_date = l_due WHERE ticket_id = p_ticket_id;
    IF l_changed AND p_assignee_user_id IS NOT NULL THEN
      l_task_id := afh_workflow_pkg.create_task(
        p_user_id => p_assignee_user_id, p_ticket_id => p_ticket_id,
        p_task_type_code => afh_workflow_pkg.c_task_assignment,
        p_summary => 'Assigned: ' || l_row.ticket_no, p_due_date => l_due);
      afh_notification_pkg.follow_required(p_ticket_id, p_assignee_user_id, c_src_assignment);
    END IF;
    audit(p_ticket_id, c_ev_assigned, assign_facts(l_row.assignee_user_id, l_row.due_date),
          assign_facts(p_assignee_user_id, l_due),
          CASE WHEN p_assignee_user_id IS NULL THEN 'Unassigned' ELSE 'Assigned to ' || afh_ticket_int_pkg.user_name(p_assignee_user_id) END);
    IF l_changed AND p_assignee_user_id IS NOT NULL THEN
      afh_notification_pkg.raise_event(
        p_event_code => afh_notification_pkg.c_ev_assignment, p_ticket_id => p_ticket_id,
        p_target_user_id => p_assignee_user_id, p_task_id => l_task_id, p_summary => 'Assigned to you');
    END IF;
    bump_version(p_ticket_id);
  END assign;

  PROCEDURE set_owner(p_ticket_id IN NUMBER, p_row_version IN NUMBER, p_owner_user_id IN NUMBER) IS
    l_row afh_tickets%ROWTYPE;
  BEGIN
    afh_security_pkg.assert_can_assign(p_ticket_id);
    lock_ticket(p_ticket_id, p_row_version);
    l_row := get_row(p_ticket_id);
    IF p_owner_user_id IS NULL THEN raise_val('Choose an owner for the ticket.'); END IF;
    afh_ticket_int_pkg.validate_user(p_owner_user_id, 'owner');
    IF p_owner_user_id = l_row.owner_user_id THEN RETURN; END IF;
    UPDATE afh_tickets SET owner_user_id = p_owner_user_id WHERE ticket_id = p_ticket_id;
    audit(p_ticket_id, c_ev_owner,
          jo(apex_t_varchar2('owner', 'owner_user_id'), apex_t_varchar2(afh_ticket_int_pkg.user_name(l_row.owner_user_id), l_row.owner_user_id)),
          jo(apex_t_varchar2('owner', 'owner_user_id'), apex_t_varchar2(afh_ticket_int_pkg.user_name(p_owner_user_id), p_owner_user_id)),
          'Owner changed to ' || afh_ticket_int_pkg.user_name(p_owner_user_id));
    bump_version(p_ticket_id);
  END set_owner;

  PROCEDURE set_release(p_ticket_id IN NUMBER, p_row_version IN NUMBER, p_release_id IN NUMBER) IS
    l_row afh_tickets%ROWTYPE;
  BEGIN
    afh_security_pkg.assert_can_assign(p_ticket_id);
    lock_ticket(p_ticket_id, p_row_version);
    l_row := get_row(p_ticket_id);
    afh_ticket_int_pkg.validate_release(p_release_id, l_row.application_id);
    IF NVL(p_release_id, -1) = NVL(l_row.release_id, -1) THEN RETURN; END IF;
    UPDATE afh_tickets SET release_id = p_release_id WHERE ticket_id = p_ticket_id;
    audit(p_ticket_id, c_ev_release,
          jo(apex_t_varchar2('release', 'release_id'), apex_t_varchar2(afh_ticket_int_pkg.release_label(l_row.release_id), l_row.release_id)),
          jo(apex_t_varchar2('release', 'release_id'), apex_t_varchar2(afh_ticket_int_pkg.release_label(p_release_id), p_release_id)),
          CASE WHEN p_release_id IS NULL THEN 'Target release cleared' ELSE 'Target release: ' || afh_ticket_int_pkg.release_label(p_release_id) END);
    afh_notification_pkg.raise_event(
      p_event_code => afh_notification_pkg.c_ev_release, p_ticket_id => p_ticket_id,
      p_summary => CASE WHEN p_release_id IS NULL THEN 'Target release cleared' ELSE 'Target release: ' || afh_ticket_int_pkg.release_label(p_release_id) END);
    bump_version(p_ticket_id);
  END set_release;

  PROCEDURE set_due_date(p_ticket_id IN NUMBER, p_row_version IN NUMBER, p_due_date IN TIMESTAMP WITH LOCAL TIME ZONE) IS
    l_row afh_tickets%ROWTYPE;
  BEGIN
    afh_security_pkg.assert_can_assign(p_ticket_id);
    lock_ticket(p_ticket_id, p_row_version);
    l_row := get_row(p_ticket_id);
    IF (p_due_date IS NULL AND l_row.due_date IS NULL) OR p_due_date = l_row.due_date THEN RETURN; END IF;
    UPDATE afh_tickets SET due_date = p_due_date WHERE ticket_id = p_ticket_id;
    audit(p_ticket_id, c_ev_due,
          jo(apex_t_varchar2('due_date'), apex_t_varchar2(TO_CHAR(l_row.due_date, 'YYYY-MM-DD HH24:MI'))),
          jo(apex_t_varchar2('due_date'), apex_t_varchar2(TO_CHAR(p_due_date, 'YYYY-MM-DD HH24:MI'))),
          CASE WHEN p_due_date IS NULL THEN 'Due date cleared' ELSE 'Due ' || TO_CHAR(p_due_date, 'YYYY-MM-DD') END);
    bump_version(p_ticket_id);
  END set_due_date;

  PROCEDURE set_resolution(
    p_ticket_id   IN NUMBER,
    p_row_version IN NUMBER,
    p_root_cause  IN CLOB,
    p_resolution  IN CLOB) IS
    l_row afh_tickets%ROWTYPE;
  BEGIN
    afh_security_pkg.assert_can_classify(p_ticket_id);
    lock_ticket(p_ticket_id, p_row_version);
    l_row := get_row(p_ticket_id);
    IF NOT afh_ticket_int_pkg.clob_differs(p_root_cause, l_row.root_cause) AND NOT afh_ticket_int_pkg.clob_differs(p_resolution, l_row.resolution) THEN
      RETURN;
    END IF;
    UPDATE afh_tickets SET root_cause = p_root_cause, resolution = p_resolution WHERE ticket_id = p_ticket_id;
    audit(p_ticket_id, c_ev_resolution,
          jo(apex_t_varchar2('root_cause', 'resolution'), apex_t_varchar2(afh_ticket_int_pkg.snippet(l_row.root_cause), afh_ticket_int_pkg.snippet(l_row.resolution))),
          jo(apex_t_varchar2('root_cause', 'resolution'), apex_t_varchar2(afh_ticket_int_pkg.snippet(p_root_cause), afh_ticket_int_pkg.snippet(p_resolution))),
          'Root cause and resolution updated');
    bump_version(p_ticket_id);
  END set_resolution;

  -- ----------------------------------------------------------------- relations
  -- RELATED: reporter of the source ticket or developer+ on its application.
  -- DEPENDS_ON / BLOCKS: developer+ on the source ticket's application.
  PROCEDURE assert_can_relate(p_source_ticket_id IN NUMBER, p_relation_code IN VARCHAR2) IS
  BEGIN
    IF afh_security_pkg.meets_min_role(afh_security_pkg.c_role_developer, application_id_of(p_source_ticket_id)) THEN
      RETURN;
    END IF;
    IF p_relation_code = c_rel_related AND afh_security_pkg.is_reporter(p_source_ticket_id) THEN
      RETURN;
    END IF;
    raise_auth('You do not have permission to link these tickets.');
  END assert_can_relate;

  -- Same link (or its mirror image) already active: RELATED is symmetric,
  -- a DEPENDS_ON b is the same fact as b BLOCKS a.
  FUNCTION relation_exists(p_source IN NUMBER, p_target IN NUMBER, p_code IN VARCHAR2) RETURN BOOLEAN IS
    l_cnt    PLS_INTEGER;
    l_mirror VARCHAR2(30) := CASE p_code WHEN c_rel_depends THEN c_rel_blocks WHEN c_rel_blocks THEN c_rel_depends ELSE p_code END;
  BEGIN
    SELECT COUNT(*) INTO l_cnt
      FROM afh_ticket_relations
     WHERE is_active = 'Y'
       AND ((source_ticket_id = p_source AND target_ticket_id = p_target AND relation_code = p_code)
         OR (source_ticket_id = p_target AND target_ticket_id = p_source AND relation_code = l_mirror));
    RETURN l_cnt > 0;
  END relation_exists;

  FUNCTION dependency_path_exists(p_from IN NUMBER, p_to IN NUMBER) RETURN BOOLEAN IS
    l_cnt PLS_INTEGER;
  BEGIN
    -- Directed "depends on" edges: DEPENDS_ON a->b is a->b; BLOCKS a->b means b depends on a.
    SELECT COUNT(*) INTO l_cnt
      FROM (SELECT CASE WHEN relation_code = c_rel_blocks THEN target_ticket_id ELSE source_ticket_id END AS from_id,
                   CASE WHEN relation_code = c_rel_blocks THEN source_ticket_id ELSE target_ticket_id END AS to_id
              FROM afh_ticket_relations
             WHERE is_active = 'Y' AND relation_code IN (c_rel_depends, c_rel_blocks)) e
     WHERE e.to_id = p_to
     START WITH e.from_id = p_from
     CONNECT BY NOCYCLE PRIOR e.to_id = e.from_id;
    RETURN l_cnt > 0;
  END dependency_path_exists;

  FUNCTION duplicate_path_exists(p_from IN NUMBER, p_to IN NUMBER) RETURN BOOLEAN IS
    l_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO l_cnt
      FROM (SELECT source_ticket_id, target_ticket_id FROM afh_ticket_relations
             WHERE is_active = 'Y' AND relation_code = c_rel_duplicate) r
     WHERE r.target_ticket_id = p_to
     START WITH r.source_ticket_id = p_from
     CONNECT BY NOCYCLE PRIOR r.target_ticket_id = r.source_ticket_id;
    RETURN l_cnt > 0;
  END duplicate_path_exists;

  FUNCTION would_create_cycle(p_source_ticket_id IN NUMBER, p_target_ticket_id IN NUMBER, p_relation_code IN VARCHAR2) RETURN BOOLEAN IS
    l_code VARCHAR2(30) := UPPER(TRIM(p_relation_code));
  BEGIN
    IF p_source_ticket_id = p_target_ticket_id THEN RETURN TRUE; END IF;
    CASE l_code
      WHEN c_rel_related   THEN RETURN FALSE;
      WHEN c_rel_duplicate THEN RETURN duplicate_path_exists(p_target_ticket_id, p_source_ticket_id);
      WHEN c_rel_depends   THEN RETURN dependency_path_exists(p_target_ticket_id, p_source_ticket_id);
      WHEN c_rel_blocks    THEN RETURN dependency_path_exists(p_source_ticket_id, p_target_ticket_id);
      ELSE RETURN FALSE;
    END CASE;
  END would_create_cycle;

  PROCEDURE audit_relation(p_ticket_id IN NUMBER, p_other_id IN NUMBER, p_code IN VARCHAR2, p_direction IN VARCHAR2,
                           p_action IN VARCHAR2, p_reason IN VARCHAR2) IS
    l_other afh_tickets%ROWTYPE := get_row(p_other_id);
  BEGIN
    audit(p_ticket_id, c_ev_relation, NULL,
          jo(apex_t_varchar2('action', 'relation_code', 'direction', 'related_ticket_no', 'related_ticket_id', 'reason'),
             apex_t_varchar2(p_action, p_code, p_direction, l_other.ticket_no, p_other_id, p_reason)),
          INITCAP(p_action) || ' ' || LOWER(REPLACE(p_code, '_', ' ')) || ' link with ' || l_other.ticket_no);
    touch_activity(p_ticket_id);
  END audit_relation;

  FUNCTION add_relation(
    p_source_ticket_id IN NUMBER,
    p_target_ticket_id IN NUMBER,
    p_relation_code    IN VARCHAR2,
    p_reason           IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_code VARCHAR2(30) := UPPER(TRIM(p_relation_code));
    l_src  afh_tickets%ROWTYPE;
    l_tgt  afh_tickets%ROWTYPE;
    l_id   NUMBER;
  BEGIN
    afh_security_pkg.assert_authenticated;
    IF l_code = c_rel_duplicate THEN
      raise_val('Duplicate links are created through the merge action.');
    ELSIF l_code NOT IN (c_rel_related, c_rel_depends, c_rel_blocks) THEN
      raise_val('Choose a link type: Related, Depends on, or Blocks.');
    END IF;
    IF p_source_ticket_id = p_target_ticket_id THEN raise_val('A ticket cannot be linked to itself.'); END IF;
    l_src := get_row(p_source_ticket_id);
    l_tgt := get_row(p_target_ticket_id);
    assert_can_relate(p_source_ticket_id, l_code);
    IF relation_exists(p_source_ticket_id, p_target_ticket_id, l_code) THEN
      raise_val('These tickets are already linked this way.');
    END IF;
    IF would_create_cycle(p_source_ticket_id, p_target_ticket_id, l_code) THEN
      raise_val('This link would create a circular dependency between tickets.');
    END IF;
    INSERT INTO afh_ticket_relations (source_ticket_id, target_ticket_id, relation_code, reason, is_active)
    VALUES (p_source_ticket_id, p_target_ticket_id, l_code, SUBSTR(p_reason, 1, 1000), 'Y')
    RETURNING ticket_relation_id INTO l_id;
    audit_relation(l_src.ticket_id, l_tgt.ticket_id, l_code, 'OUT', 'ADDED', p_reason);
    audit_relation(l_tgt.ticket_id, l_src.ticket_id, l_code, 'IN',  'ADDED', p_reason);
    RETURN l_id;
  END add_relation;

  PROCEDURE remove_relation(p_ticket_relation_id IN NUMBER) IS
    l_rel afh_ticket_relations%ROWTYPE;
  BEGIN
    afh_security_pkg.assert_authenticated;
    BEGIN
      SELECT * INTO l_rel FROM afh_ticket_relations WHERE ticket_relation_id = p_ticket_relation_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      raise_val('The link could not be found.');
    END;
    IF l_rel.relation_code = c_rel_duplicate THEN
      raise_val('Duplicate links are managed through the merge and reopen actions.');
    END IF;
    assert_can_relate(l_rel.source_ticket_id, l_rel.relation_code);
    IF l_rel.is_active = 'N' THEN RETURN; END IF;
    UPDATE afh_ticket_relations SET is_active = 'N', deactivated_at = SYSTIMESTAMP
     WHERE ticket_relation_id = p_ticket_relation_id;
    audit_relation(l_rel.source_ticket_id, l_rel.target_ticket_id, l_rel.relation_code, 'OUT', 'REMOVED', NULL);
    audit_relation(l_rel.target_ticket_id, l_rel.source_ticket_id, l_rel.relation_code, 'IN',  'REMOVED', NULL);
  END remove_relation;

  -- ----------------------------------------------------------------- affected users
  FUNCTION affected_count(p_ticket_id IN NUMBER) RETURN NUMBER IS
    l_cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_cnt FROM afh_affected_users WHERE ticket_id = p_ticket_id;
    RETURN l_cnt;
  END affected_count;

  FUNCTION is_assignee(p_ticket_id IN NUMBER) RETURN BOOLEAN IS
    l_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO l_cnt FROM afh_tickets
     WHERE ticket_id = p_ticket_id AND assignee_user_id = afh_security_pkg.current_user_id;
    RETURN l_cnt > 0;
  END is_assignee;

  FUNCTION is_affected(p_ticket_id IN NUMBER) RETURN BOOLEAN IS
    l_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO l_cnt FROM afh_affected_users
     WHERE ticket_id = p_ticket_id AND user_id = afh_security_pkg.current_user_id;
    RETURN l_cnt > 0;
  END is_affected;

  PROCEDURE mark_affected(p_ticket_id IN NUMBER, p_comment_text IN VARCHAR2 DEFAULT NULL) IS
    l_user_id NUMBER;
    l_row     afh_tickets%ROWTYPE;
  BEGIN
    afh_security_pkg.assert_authenticated;
    l_user_id := afh_security_pkg.current_user_id;
    l_row     := get_row(p_ticket_id);
    IF is_affected(p_ticket_id) THEN RETURN; END IF;   -- idempotent: one row per user
    BEGIN
      INSERT INTO afh_affected_users (ticket_id, user_id, comment_text)
      VALUES (p_ticket_id, l_user_id, SUBSTR(p_comment_text, 1, 1000));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
      RETURN;                                           -- lost a race with the same user: still one row
    END;
    afh_notification_pkg.follow(p_ticket_id, l_user_id, c_src_affected);
    audit(p_ticket_id, c_ev_affected, NULL,
          jo(apex_t_varchar2('action', 'user', 'affected_count'),
             apex_t_varchar2('MARKED', afh_ticket_int_pkg.user_name(l_user_id), affected_count(p_ticket_id))),
          afh_ticket_int_pkg.user_name(l_user_id) || ' is also affected');
    touch_activity(p_ticket_id);
  END mark_affected;

  PROCEDURE unmark_affected(p_ticket_id IN NUMBER) IS
    l_user_id NUMBER;
  BEGIN
    afh_security_pkg.assert_authenticated;
    l_user_id := afh_security_pkg.current_user_id;
    DELETE FROM afh_affected_users WHERE ticket_id = p_ticket_id AND user_id = l_user_id;
    IF SQL%ROWCOUNT = 0 THEN RETURN; END IF;
    audit(p_ticket_id, c_ev_affected, NULL,
          jo(apex_t_varchar2('action', 'user', 'affected_count'),
             apex_t_varchar2('UNMARKED', afh_ticket_int_pkg.user_name(l_user_id), affected_count(p_ticket_id))),
          afh_ticket_int_pkg.user_name(l_user_id) || ' is no longer marked as affected');
    touch_activity(p_ticket_id);
  END unmark_affected;

  -- ----------------------------------------------------------------- archive and views
  PROCEDURE set_archived(p_ticket_id IN NUMBER, p_is_archived IN VARCHAR2) IS
    l_flag VARCHAR2(1) := UPPER(TRIM(p_is_archived));
    l_row  afh_tickets%ROWTYPE;
  BEGIN
    afh_security_pkg.assert_admin;
    IF l_flag NOT IN ('Y', 'N') THEN raise_val('Archive flag must be Y or N.'); END IF;
    l_row := get_row(p_ticket_id);
    IF l_row.is_archived = l_flag THEN RETURN; END IF;
    UPDATE afh_tickets
       SET is_archived = l_flag,
           archived_at = CASE WHEN l_flag = 'Y' THEN SYSTIMESTAMP ELSE NULL END
     WHERE ticket_id = p_ticket_id;
    audit(p_ticket_id, c_ev_archived,
          jo(apex_t_varchar2('is_archived'), apex_t_varchar2(l_row.is_archived)),
          jo(apex_t_varchar2('is_archived'), apex_t_varchar2(l_flag)),
          CASE WHEN l_flag = 'Y' THEN 'Ticket archived' ELSE 'Ticket restored from archive' END);
    bump_version(p_ticket_id);
  END set_archived;

  PROCEDURE record_view(p_ticket_id IN NUMBER) IS
    l_user_id NUMBER := afh_security_pkg.current_user_id;
  BEGIN
    IF l_user_id IS NULL OR p_ticket_id IS NULL THEN RETURN; END IF;
    MERGE INTO afh_ticket_views v
    USING (SELECT l_user_id AS user_id, p_ticket_id AS ticket_id FROM dual) s
       ON (v.user_id = s.user_id AND v.ticket_id = s.ticket_id)
     WHEN MATCHED THEN UPDATE SET v.last_viewed_at = SYSTIMESTAMP, v.view_count = v.view_count + 1
     WHEN NOT MATCHED THEN INSERT (user_id, ticket_id, last_viewed_at, view_count)
          VALUES (s.user_id, s.ticket_id, SYSTIMESTAMP, 1);
  END record_view;

  -- ----------------------------------------------------------------- metadata helpers
  PROCEDURE validate_field_values(p_type_code IN VARCHAR2, p_field_values_json IN CLOB) IS
    l_type_id NUMBER := afh_ticket_int_pkg.active_type_id(p_type_code);
  BEGIN
    afh_ticket_int_pkg.validate_fields(l_type_id, afh_ticket_int_pkg.parse_field_values(p_field_values_json));
  END validate_field_values;

  FUNCTION type_fields_json(p_type_code IN VARCHAR2) RETURN CLOB IS
  BEGIN
    RETURN afh_ticket_int_pkg.type_fields_json(p_type_code);
  END type_fields_json;
END afh_ticket_pkg;
/

