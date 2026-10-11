CREATE OR REPLACE PACKAGE BODY afh_registry_int_pkg AS
  -- ---------------------------------------------------------------------------
  -- AFH_REGISTRY_INT_PKG body — shared helpers, routing rules, releases.
  -- Private to AFH_REGISTRY_PKG; see that spec for the contract of each routine.
  -- ---------------------------------------------------------------------------

  c_evt_rule_added       CONSTANT VARCHAR2(30) := 'ROUTING_RULE_ADDED';
  c_evt_rule_updated     CONSTANT VARCHAR2(30) := 'ROUTING_RULE_UPDATED';
  c_evt_rule_activated   CONSTANT VARCHAR2(30) := 'ROUTING_RULE_ACTIVATED';
  c_evt_rule_deactivated CONSTANT VARCHAR2(30) := 'ROUTING_RULE_DEACTIVATED';
  c_evt_rule_deleted     CONSTANT VARCHAR2(30) := 'ROUTING_RULE_DELETED';
  c_evt_release_added    CONSTANT VARCHAR2(30) := 'RELEASE_ADDED';
  c_evt_release_updated  CONSTANT VARCHAR2(30) := 'RELEASE_UPDATED';
  c_evt_release_complete CONSTANT VARCHAR2(30) := 'RELEASE_COMPLETED';
  c_state_completed      CONSTANT VARCHAR2(30) := 'COMPLETED';
  c_state_planned        CONSTANT VARCHAR2(30) := 'PLANNED';

  -- ================================================================= validation helpers
  PROCEDURE raise_val(p_message IN VARCHAR2) IS
  BEGIN
    afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, p_message);
  END raise_val;

  PROCEDURE assert_not_null(p_value IN VARCHAR2, p_label IN VARCHAR2) IS
  BEGIN
    IF TRIM(p_value) IS NULL THEN
      raise_val(p_label || ' is required.');
    END IF;
  END assert_not_null;

  PROCEDURE assert_yn(p_value IN VARCHAR2, p_label IN VARCHAR2) IS
  BEGIN
    IF p_value IS NULL OR p_value NOT IN ('Y', 'N') THEN
      raise_val(p_label || ' must be Y or N.');
    END IF;
  END assert_yn;

  PROCEDURE assert_code(p_value IN VARCHAR2, p_label IN VARCHAR2) IS
  BEGIN
    IF p_value IS NULL OR NOT REGEXP_LIKE(p_value, '^[A-Z][A-Z0-9_]{0,29}$') THEN
      raise_val(p_label || ' must start with a letter and contain only A-Z, 0-9 and _ (max 30).');
    END IF;
  END assert_code;

  PROCEDURE assert_user_exists(p_user_id IN NUMBER, p_label IN VARCHAR2) IS
    l_cnt PLS_INTEGER;
  BEGIN
    IF p_user_id IS NULL THEN
      RETURN;
    END IF;
    SELECT COUNT(*) INTO l_cnt FROM afh_users WHERE user_id = p_user_id;
    IF l_cnt = 0 THEN
      raise_val(p_label || ' user was not found.');
    END IF;
  END assert_user_exists;

  FUNCTION yn(p_bool IN BOOLEAN) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_bool THEN 'Y' ELSE 'N' END;
  END yn;

  FUNCTION yn_facts(p_is_active IN VARCHAR2) RETURN CLOB IS
  BEGIN
    RETURN afh_audit_pkg.json_obj(apex_t_varchar2('is_active'), apex_t_varchar2(p_is_active));
  END yn_facts;

  -- ================================================================= row fetchers
  FUNCTION app_row(p_application_id IN NUMBER, p_for_update IN VARCHAR2) RETURN afh_applications%ROWTYPE IS
    l_row afh_applications%ROWTYPE;
  BEGIN
    IF p_for_update = 'Y' THEN
      SELECT * INTO l_row FROM afh_applications WHERE application_id = p_application_id FOR UPDATE;
    ELSE
      SELECT * INTO l_row FROM afh_applications WHERE application_id = p_application_id;
    END IF;
    RETURN l_row;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_val('Application was not found.');
  END app_row;

  FUNCTION env_row(p_environment_id IN NUMBER, p_for_update IN VARCHAR2) RETURN afh_environments%ROWTYPE IS
    l_row afh_environments%ROWTYPE;
  BEGIN
    IF p_for_update = 'Y' THEN
      SELECT * INTO l_row FROM afh_environments WHERE environment_id = p_environment_id FOR UPDATE;
    ELSE
      SELECT * INTO l_row FROM afh_environments WHERE environment_id = p_environment_id;
    END IF;
    RETURN l_row;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_val('Environment was not found.');
  END env_row;

  FUNCTION rule_row(p_routing_rule_id IN NUMBER, p_for_update IN VARCHAR2) RETURN afh_routing_rules%ROWTYPE IS
    l_row afh_routing_rules%ROWTYPE;
  BEGIN
    IF p_for_update = 'Y' THEN
      SELECT * INTO l_row FROM afh_routing_rules WHERE routing_rule_id = p_routing_rule_id FOR UPDATE;
    ELSE
      SELECT * INTO l_row FROM afh_routing_rules WHERE routing_rule_id = p_routing_rule_id;
    END IF;
    RETURN l_row;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_val('Routing rule was not found.');
  END rule_row;

  FUNCTION release_row(p_release_id IN NUMBER, p_for_update IN VARCHAR2) RETURN afh_releases%ROWTYPE IS
    l_row afh_releases%ROWTYPE;
  BEGIN
    IF p_for_update = 'Y' THEN
      SELECT * INTO l_row FROM afh_releases WHERE release_id = p_release_id FOR UPDATE;
    ELSE
      SELECT * INTO l_row FROM afh_releases WHERE release_id = p_release_id;
    END IF;
    RETURN l_row;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_val('Release was not found.');
  END release_row;

  FUNCTION is_adapter_supported_yn(p_application_id IN NUMBER, p_adapter_version IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN yn(afh_registry_pkg.is_adapter_supported(p_application_id, p_adapter_version));
  END is_adapter_supported_yn;

  -- ================================================================= routing helpers
  FUNCTION rule_facts(p_row IN afh_routing_rules%ROWTYPE) RETURN CLOB IS
  BEGIN
    RETURN afh_audit_pkg.json_obj(
      apex_t_varchar2('application_id', 'page_id', 'category_id', 'environment_id', 'type_code',
                      'assignee_user_id', 'owner_user_id', 'priority_order', 'is_active', 'description'),
      apex_t_varchar2(TO_CHAR(p_row.application_id), TO_CHAR(p_row.page_id), TO_CHAR(p_row.category_id),
                      TO_CHAR(p_row.environment_id), p_row.type_code, TO_CHAR(p_row.assignee_user_id),
                      TO_CHAR(p_row.owner_user_id), TO_CHAR(p_row.priority_order), p_row.is_active,
                      p_row.description));
  END rule_facts;

  PROCEDURE audit_rule(p_routing_rule_id IN NUMBER, p_event_code IN VARCHAR2,
                       p_before IN CLOB, p_after IN CLOB, p_summary IN VARCHAR2) IS
  BEGIN
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_routing_rule,
      p_entity_id    => p_routing_rule_id,
      p_event_code   => p_event_code,
      p_before_facts => p_before,
      p_after_facts  => p_after,
      p_summary      => p_summary);
  END audit_rule;

  -- Criteria and targets of a rule must belong to the rule's application.
  PROCEDURE validate_rule(
    p_application_id   IN NUMBER,
    p_category_id      IN NUMBER,
    p_environment_id   IN NUMBER,
    p_type_code        IN VARCHAR2,
    p_assignee_user_id IN NUMBER,
    p_owner_user_id    IN NUMBER,
    p_priority_order   IN NUMBER) IS
    l_cnt PLS_INTEGER;
  BEGIN
    IF p_assignee_user_id IS NULL AND p_owner_user_id IS NULL THEN
      raise_val('A routing rule needs an assignee or an owner.');
    END IF;
    IF p_priority_order IS NULL OR p_priority_order < 0 THEN
      raise_val('Priority order must be zero or a positive number.');
    END IF;
    assert_user_exists(p_assignee_user_id, 'Assignee');
    assert_user_exists(p_owner_user_id, 'Owner');
    IF p_environment_id IS NOT NULL THEN
      SELECT COUNT(*) INTO l_cnt FROM afh_environments
       WHERE environment_id = p_environment_id AND application_id = p_application_id;
      IF l_cnt = 0 THEN
        raise_val('Environment does not belong to this application.');
      END IF;
    END IF;
    IF p_category_id IS NOT NULL THEN
      SELECT COUNT(*) INTO l_cnt FROM afh_categories
       WHERE category_id = p_category_id
         AND (application_id IS NULL OR application_id = p_application_id);
      IF l_cnt = 0 THEN
        raise_val('Category does not belong to this application.');
      END IF;
    END IF;
    IF p_type_code IS NOT NULL THEN
      SELECT COUNT(*) INTO l_cnt FROM afh_feedback_types WHERE type_code = p_type_code;
      IF l_cnt = 0 THEN
        raise_val('Feedback type ' || p_type_code || ' does not exist.');
      END IF;
    END IF;
  END validate_rule;

  -- ================================================================= routing API
  FUNCTION add_routing_rule(
    p_application_id   IN NUMBER,
    p_page_id          IN NUMBER,
    p_category_id      IN NUMBER,
    p_environment_id   IN NUMBER,
    p_type_code        IN VARCHAR2,
    p_assignee_user_id IN NUMBER,
    p_owner_user_id    IN NUMBER,
    p_priority_order   IN NUMBER,
    p_description      IN VARCHAR2) RETURN NUMBER IS
    l_type afh_routing_rules.type_code%TYPE := UPPER(TRIM(p_type_code));
    l_app  afh_applications%ROWTYPE;
    l_row  afh_routing_rules%ROWTYPE;
    l_id   NUMBER;
  BEGIN
    afh_security_pkg.assert_can_manage_routing(p_application_id);
    l_app := app_row(p_application_id);
    validate_rule(p_application_id, p_category_id, p_environment_id, l_type,
                  p_assignee_user_id, p_owner_user_id, NVL(p_priority_order, 100));
    INSERT INTO afh_routing_rules (application_id, page_id, category_id, environment_id, type_code,
                                   assignee_user_id, owner_user_id, priority_order, is_active, description)
    VALUES (p_application_id, p_page_id, p_category_id, p_environment_id, l_type,
            p_assignee_user_id, p_owner_user_id, NVL(p_priority_order, 100), 'Y', TRIM(p_description))
    RETURNING routing_rule_id INTO l_id;
    l_row := rule_row(l_id, 'N');
    audit_rule(l_id, c_evt_rule_added, NULL, rule_facts(l_row),
               'Routing rule added for ' || l_app.app_key);
    RETURN l_id;
  END add_routing_rule;

  PROCEDURE update_routing_rule(
    p_routing_rule_id  IN NUMBER,
    p_page_id          IN NUMBER,
    p_category_id      IN NUMBER,
    p_environment_id   IN NUMBER,
    p_type_code        IN VARCHAR2,
    p_assignee_user_id IN NUMBER,
    p_owner_user_id    IN NUMBER,
    p_priority_order   IN NUMBER,
    p_description      IN VARCHAR2) IS
    l_type afh_routing_rules.type_code%TYPE := UPPER(TRIM(p_type_code));
    l_old  afh_routing_rules%ROWTYPE;
    l_new  afh_routing_rules%ROWTYPE;
  BEGIN
    l_old := rule_row(p_routing_rule_id, 'Y');
    afh_security_pkg.assert_can_manage_routing(l_old.application_id);
    validate_rule(l_old.application_id, p_category_id, p_environment_id, l_type,
                  p_assignee_user_id, p_owner_user_id, p_priority_order);
    UPDATE afh_routing_rules
       SET page_id          = p_page_id,
           category_id      = p_category_id,
           environment_id   = p_environment_id,
           type_code        = l_type,
           assignee_user_id = p_assignee_user_id,
           owner_user_id    = p_owner_user_id,
           priority_order   = p_priority_order,
           description      = TRIM(p_description)
     WHERE routing_rule_id = p_routing_rule_id;
    l_new := rule_row(p_routing_rule_id, 'N');
    audit_rule(p_routing_rule_id, c_evt_rule_updated, rule_facts(l_old), rule_facts(l_new),
               'Routing rule ' || p_routing_rule_id || ' updated');
  END update_routing_rule;

  PROCEDURE set_routing_rule_active(p_routing_rule_id IN NUMBER, p_is_active IN VARCHAR2) IS
    l_old  afh_routing_rules%ROWTYPE;
    l_flag VARCHAR2(1) := UPPER(TRIM(p_is_active));
  BEGIN
    l_old := rule_row(p_routing_rule_id, 'Y');
    afh_security_pkg.assert_can_manage_routing(l_old.application_id);
    assert_yn(l_flag, 'Active flag');
    IF l_old.is_active = l_flag THEN
      RETURN;
    END IF;
    UPDATE afh_routing_rules SET is_active = l_flag WHERE routing_rule_id = p_routing_rule_id;
    audit_rule(p_routing_rule_id,
               CASE l_flag WHEN 'Y' THEN c_evt_rule_activated ELSE c_evt_rule_deactivated END,
               yn_facts(l_old.is_active), yn_facts(l_flag),
               'Routing rule ' || p_routing_rule_id || CASE l_flag WHEN 'Y' THEN ' activated' ELSE ' deactivated' END);
  END set_routing_rule_active;

  PROCEDURE delete_routing_rule(p_routing_rule_id IN NUMBER) IS
    l_old afh_routing_rules%ROWTYPE;
  BEGIN
    l_old := rule_row(p_routing_rule_id, 'Y');
    afh_security_pkg.assert_can_manage_routing(l_old.application_id);
    DELETE FROM afh_routing_rules WHERE routing_rule_id = p_routing_rule_id;
    audit_rule(p_routing_rule_id, c_evt_rule_deleted, rule_facts(l_old), NULL,
               'Routing rule ' || p_routing_rule_id || ' deleted');
  END delete_routing_rule;

  -- Owner of last resort: the user behind config FALLBACK_OWNER_SUBJECT (created on
  -- first use so a configured queue subject never has to log in first). NULL when the
  -- key is not configured.
  FUNCTION fallback_owner_user_id RETURN NUMBER IS
    l_subject afh_users.subject_canonical%TYPE;
    l_id      NUMBER;
  BEGIN
    l_subject := afh_security_pkg.canonical_subject(afh_security_pkg.config_value('FALLBACK_OWNER_SUBJECT'));
    IF l_subject IS NULL THEN
      RETURN NULL;
    END IF;
    BEGIN
      SELECT user_id INTO l_id FROM afh_users WHERE subject_canonical = l_subject;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_id := afh_security_pkg.ensure_user(l_subject, 'Feedback Queue');
    END;
    RETURN l_id;
  END fallback_owner_user_id;

  PROCEDURE resolve_route(
    p_application_id   IN  NUMBER,
    p_page_id          IN  NUMBER,
    p_category_id      IN  NUMBER,
    p_environment_id   IN  NUMBER,
    p_type_code        IN  VARCHAR2,
    o_assignee_user_id OUT NUMBER,
    o_owner_user_id    OUT NUMBER,
    o_routing_rule_id  OUT NUMBER) IS
    l_type afh_routing_rules.type_code%TYPE := UPPER(TRIM(p_type_code));
  BEGIN
    o_assignee_user_id := NULL;
    o_owner_user_id    := NULL;
    o_routing_rule_id  := NULL;
    BEGIN
      SELECT r.routing_rule_id, r.assignee_user_id, r.owner_user_id
        INTO o_routing_rule_id, o_assignee_user_id, o_owner_user_id
        FROM afh_routing_rules r
       WHERE r.application_id = p_application_id
         AND r.is_active = 'Y'
         AND (r.page_id        IS NULL OR r.page_id        = p_page_id)
         AND (r.category_id    IS NULL OR r.category_id    = p_category_id)
         AND (r.environment_id IS NULL OR r.environment_id = p_environment_id)
         AND (r.type_code      IS NULL OR r.type_code      = l_type)
       ORDER BY r.priority_order, r.routing_rule_id
       FETCH FIRST 1 ROW ONLY;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;
    IF o_owner_user_id IS NULL THEN
      SELECT MAX(owner_user_id) INTO o_owner_user_id
        FROM afh_applications WHERE application_id = p_application_id;
    END IF;
    IF o_owner_user_id IS NULL THEN
      o_owner_user_id := fallback_owner_user_id;
    END IF;
    IF o_owner_user_id IS NULL THEN
      raise_val('No owner could be resolved for this application; configure an application owner or the fallback queue.');
    END IF;
  END resolve_route;

  -- ================================================================= release helpers
  FUNCTION release_facts(p_row IN afh_releases%ROWTYPE) RETURN CLOB IS
  BEGIN
    RETURN afh_audit_pkg.json_obj(
      apex_t_varchar2('application_id', 'release_code', 'label', 'target_date', 'completed_date', 'state_code', 'notes'),
      apex_t_varchar2(TO_CHAR(p_row.application_id), p_row.release_code, p_row.label,
                      TO_CHAR(p_row.target_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
                      TO_CHAR(p_row.completed_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
                      p_row.state_code, p_row.notes));
  END release_facts;

  PROCEDURE audit_release(p_release_id IN NUMBER, p_event_code IN VARCHAR2,
                          p_before IN CLOB, p_after IN CLOB, p_summary IN VARCHAR2) IS
  BEGIN
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_release,
      p_entity_id    => p_release_id,
      p_event_code   => p_event_code,
      p_before_facts => p_before,
      p_after_facts  => p_after,
      p_summary      => p_summary);
  END audit_release;

  PROCEDURE assert_release_state(p_state_code IN VARCHAR2) IS
  BEGIN
    IF p_state_code IS NULL OR p_state_code NOT IN ('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') THEN
      raise_val('Release state must be PLANNED, IN_PROGRESS, COMPLETED or CANCELLED.');
    END IF;
  END assert_release_state;

  -- ================================================================= release API
  FUNCTION add_release(
    p_application_id IN NUMBER,
    p_release_code   IN VARCHAR2,
    p_label          IN VARCHAR2,
    p_target_date    IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_notes          IN VARCHAR2) RETURN NUMBER IS
    l_code afh_releases.release_code%TYPE := UPPER(TRIM(p_release_code));
    l_app  afh_applications%ROWTYPE;
    l_row  afh_releases%ROWTYPE;
    l_id   NUMBER;
  BEGIN
    afh_security_pkg.assert_can_manage_releases(p_application_id);
    l_app := app_row(p_application_id);
    assert_code(l_code, 'Release code');
    assert_not_null(p_label, 'Label');
    BEGIN
      INSERT INTO afh_releases (application_id, release_code, label, target_date, state_code, notes)
      VALUES (p_application_id, l_code, TRIM(p_label), p_target_date, c_state_planned, p_notes)
      RETURNING release_id INTO l_id;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        raise_val('Release code ' || l_code || ' already exists for this application.');
    END;
    l_row := release_row(l_id, 'N');
    audit_release(l_id, c_evt_release_added, NULL, release_facts(l_row),
                  'Release ' || l_code || ' added to ' || l_app.app_key);
    RETURN l_id;
  END add_release;

  PROCEDURE update_release(
    p_release_id   IN NUMBER,
    p_label        IN VARCHAR2,
    p_target_date  IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_state_code   IN VARCHAR2,
    p_notes        IN VARCHAR2) IS
    l_state afh_releases.state_code%TYPE := UPPER(TRIM(p_state_code));
    l_old   afh_releases%ROWTYPE;
    l_new   afh_releases%ROWTYPE;
  BEGIN
    l_old := release_row(p_release_id, 'Y');
    afh_security_pkg.assert_can_manage_releases(l_old.application_id);
    assert_not_null(p_label, 'Label');
    assert_release_state(l_state);
    IF l_state = c_state_completed AND l_old.state_code <> c_state_completed THEN
      raise_val('Use Complete Release to mark a release as completed.');
    END IF;
    UPDATE afh_releases
       SET label          = TRIM(p_label),
           target_date    = p_target_date,
           state_code     = l_state,
           notes          = p_notes,
           completed_date = CASE WHEN l_state = c_state_completed THEN completed_date END
     WHERE release_id = p_release_id;
    l_new := release_row(p_release_id, 'N');
    audit_release(p_release_id, c_evt_release_updated, release_facts(l_old), release_facts(l_new),
                  'Release ' || l_old.release_code || ' updated');
  END update_release;

  -- Single definition of "unresolved": any status outside c_closed_status_list.
  FUNCTION unresolved_ticket_count(p_release_id IN NUMBER) RETURN NUMBER IS
    l_cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_cnt
      FROM afh_tickets t
     WHERE t.release_id = p_release_id
       AND t.status_code NOT IN ('RESOLVED', 'CLOSED', 'DUPLICATE', 'REJECTED', 'CANNOT_REPRODUCE');
    RETURN l_cnt;
  END unresolved_ticket_count;

  PROCEDURE complete_release(p_release_id IN NUMBER, p_force IN VARCHAR2) IS
    l_old    afh_releases%ROWTYPE;
    l_new    afh_releases%ROWTYPE;
    l_cnt    NUMBER;
    l_forced VARCHAR2(1) := CASE WHEN UPPER(TRIM(p_force)) = 'Y' THEN 'Y' ELSE 'N' END;
  BEGIN
    l_old := release_row(p_release_id, 'Y');
    afh_security_pkg.assert_can_manage_releases(l_old.application_id);
    IF l_old.state_code = c_state_completed THEN
      raise_val('Release ' || l_old.release_code || ' is already completed.');
    END IF;
    l_cnt := unresolved_ticket_count(p_release_id);
    IF l_cnt > 0 AND l_forced = 'N' THEN
      raise_val('Release ' || l_old.release_code || ' has ' || l_cnt ||
                ' unresolved ticket(s); resolve or move them, or force completion.');
    END IF;
    UPDATE afh_releases
       SET state_code = c_state_completed, completed_date = SYSTIMESTAMP
     WHERE release_id = p_release_id;
    l_new := release_row(p_release_id, 'N');
    audit_release(p_release_id, c_evt_release_complete, release_facts(l_old),
                  afh_audit_pkg.json_obj(
                    apex_t_varchar2('state_code', 'completed_date', 'unresolved_count', 'forced'),
                    apex_t_varchar2(l_new.state_code, TO_CHAR(l_new.completed_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
                                    TO_CHAR(l_cnt), l_forced)),
                  'Release ' || l_old.release_code || ' completed' ||
                  CASE WHEN l_forced = 'Y' AND l_cnt > 0 THEN ' (forced with ' || l_cnt || ' unresolved)' END);
  END complete_release;
END afh_registry_int_pkg;
/
