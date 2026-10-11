CREATE OR REPLACE PACKAGE BODY afh_taxonomy_pkg AS
  c_code_rx CONSTANT VARCHAR2(30) := '^[A-Z][A-Z0-9_]{0,29}$';

  -- ------------------------------------------------------------------ helpers
  PROCEDURE check_code(p_code IN VARCHAR2, p_what IN VARCHAR2) IS
  BEGIN
    IF p_code IS NULL OR NOT REGEXP_LIKE(p_code, c_code_rx) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001,
        p_what || ' code must be uppercase letters, digits and underscores, starting with a letter.');
    END IF;
  END check_code;

  PROCEDURE check_yn(p_value IN VARCHAR2, p_what IN VARCHAR2) IS
  BEGIN
    IF p_value NOT IN ('Y', 'N') THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, p_what || ' must be Y or N.');
    END IF;
  END check_yn;

  PROCEDURE check_label(p_label IN VARCHAR2) IS
  BEGIN
    IF TRIM(p_label) IS NULL OR LENGTH(p_label) > 255 THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'A label of 1 to 255 characters is required.');
    END IF;
  END check_label;

  PROCEDURE audit(p_entity IN VARCHAR2, p_event IN VARCHAR2, p_id IN NUMBER, p_summary IN VARCHAR2,
                  p_names IN apex_t_varchar2, p_values IN apex_t_varchar2) IS
  BEGIN
    afh_audit_pkg.log_event(
      p_entity_type => p_entity,
      p_entity_id   => p_id,
      p_event_code  => p_event,
      p_after_facts => afh_audit_pkg.json_obj(p_names, p_values),
      p_summary     => p_summary,
      p_is_public   => 'N');
  END audit;

  -- ------------------------------------------------------------------ types
  PROCEDURE save_type(
    p_feedback_type_id IN NUMBER, p_type_code IN VARCHAR2, p_label IN VARCHAR2, p_help_text IN VARCHAR2,
    p_icon_token IN VARCHAR2, p_display_seq IN NUMBER, p_is_active IN VARCHAR2) IS
    l_id NUMBER := p_feedback_type_id;
  BEGIN
    afh_security_pkg.assert_admin;
    check_label(p_label); check_yn(p_is_active, 'Active');
    IF l_id IS NULL THEN
      check_code(p_type_code, 'Type');
      INSERT INTO afh_feedback_types (type_code, label, help_text, icon_token, display_seq, is_active)
      VALUES (p_type_code, p_label, p_help_text, p_icon_token, NVL(p_display_seq, 10), p_is_active)
      RETURNING feedback_type_id INTO l_id;
    ELSE
      UPDATE afh_feedback_types
         SET label = p_label, help_text = p_help_text, icon_token = p_icon_token,
             display_seq = NVL(p_display_seq, display_seq), is_active = p_is_active
       WHERE feedback_type_id = l_id;
    END IF;
    audit(afh_audit_pkg.c_entity_taxonomy, 'TAXONOMY_CHANGED', l_id, 'Feedback type ' || p_type_code || ' saved',
          apex_t_varchar2('object', 'code', 'label', 'is_active'), apex_t_varchar2('TYPE', p_type_code, p_label, p_is_active));
  END save_type;

  -- ------------------------------------------------------------------ fields
  PROCEDURE save_field(
    p_field_definition_id IN NUMBER, p_field_code IN VARCHAR2, p_label IN VARCHAR2, p_data_type IN VARCHAR2,
    p_max_length IN NUMBER, p_help_text IN VARCHAR2, p_lov_values IN VARCHAR2, p_is_active IN VARCHAR2) IS
    l_id NUMBER := p_field_definition_id;
  BEGIN
    afh_security_pkg.assert_admin;
    check_label(p_label); check_yn(p_is_active, 'Active');
    IF p_data_type NOT IN ('TEXT', 'TEXTAREA', 'NUMBER', 'DATE', 'SELECT', 'YN') THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown field data type.');
    END IF;
    IF p_data_type = 'SELECT' AND TRIM(p_lov_values) IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'A select-list field needs its values (CODE:Label;CODE:Label).');
    END IF;
    IF l_id IS NULL THEN
      check_code(p_field_code, 'Field');
      INSERT INTO afh_field_definitions (field_code, label, data_type, max_length, help_text, lov_values, is_active)
      VALUES (p_field_code, p_label, p_data_type, p_max_length, p_help_text, p_lov_values, p_is_active)
      RETURNING field_definition_id INTO l_id;
    ELSE
      UPDATE afh_field_definitions
         SET label = p_label, data_type = p_data_type, max_length = p_max_length, help_text = p_help_text,
             lov_values = p_lov_values, is_active = p_is_active
       WHERE field_definition_id = l_id;
    END IF;
    audit(afh_audit_pkg.c_entity_taxonomy, 'TAXONOMY_CHANGED', l_id, 'Field ' || p_field_code || ' saved',
          apex_t_varchar2('object', 'code', 'label', 'data_type', 'is_active'), apex_t_varchar2('FIELD', p_field_code, p_label, p_data_type, p_is_active));
  END save_field;

  -- ------------------------------------------------------------------ type fields
  PROCEDURE save_type_field(
    p_type_field_id IN NUMBER, p_type_code IN VARCHAR2, p_field_code IN VARCHAR2,
    p_is_required IN VARCHAR2, p_display_seq IN NUMBER, p_label_override IN VARCHAR2) IS
    l_id    NUMBER := p_type_field_id;
    l_type  NUMBER;
    l_field NUMBER;
  BEGIN
    afh_security_pkg.assert_admin;
    check_yn(p_is_required, 'Required');
    IF l_id IS NULL THEN
      BEGIN
        SELECT feedback_type_id INTO l_type FROM afh_feedback_types WHERE type_code = p_type_code;
        SELECT field_definition_id INTO l_field FROM afh_field_definitions WHERE field_code = p_field_code;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown type or field code.');
      END;
      INSERT INTO afh_type_fields (feedback_type_id, field_definition_id, is_required, display_seq, label_override)
      VALUES (l_type, l_field, p_is_required, NVL(p_display_seq, 10), p_label_override)
      RETURNING type_field_id INTO l_id;
    ELSE
      UPDATE afh_type_fields
         SET is_required = p_is_required, display_seq = NVL(p_display_seq, display_seq), label_override = p_label_override
       WHERE type_field_id = l_id;
    END IF;
    audit(afh_audit_pkg.c_entity_taxonomy, 'TAXONOMY_CHANGED', l_id, 'Type field ' || p_type_code || '.' || p_field_code || ' saved',
          apex_t_varchar2('object', 'type', 'field', 'is_required'), apex_t_varchar2('TYPE_FIELD', p_type_code, p_field_code, p_is_required));
  END save_type_field;

  PROCEDURE remove_type_field(p_type_field_id IN NUMBER) IS
  BEGIN
    afh_security_pkg.assert_admin;
    DELETE FROM afh_type_fields WHERE type_field_id = p_type_field_id;
    audit(afh_audit_pkg.c_entity_taxonomy, 'TAXONOMY_CHANGED', p_type_field_id, 'Type field mapping removed',
          apex_t_varchar2('object', 'action'), apex_t_varchar2('TYPE_FIELD', 'REMOVED'));
  END remove_type_field;

  -- ------------------------------------------------------------------ categories
  PROCEDURE save_category(
    p_category_id IN NUMBER, p_application_id IN NUMBER, p_category_code IN VARCHAR2, p_label IN VARCHAR2,
    p_parent_category_id IN NUMBER, p_display_seq IN NUMBER, p_is_active IN VARCHAR2) IS
    l_id NUMBER := p_category_id;
  BEGIN
    afh_security_pkg.assert_admin;
    check_label(p_label); check_yn(p_is_active, 'Active');
    IF p_parent_category_id IS NOT NULL AND p_parent_category_id = l_id THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'A category cannot be its own parent.');
    END IF;
    IF l_id IS NULL THEN
      check_code(p_category_code, 'Category');
      INSERT INTO afh_categories (application_id, category_code, label, parent_category_id, display_seq, is_active)
      VALUES (p_application_id, p_category_code, p_label, p_parent_category_id, NVL(p_display_seq, 10), p_is_active)
      RETURNING category_id INTO l_id;
    ELSE
      UPDATE afh_categories
         SET label = p_label, parent_category_id = p_parent_category_id,
             display_seq = NVL(p_display_seq, display_seq), is_active = p_is_active
       WHERE category_id = l_id;
    END IF;
    audit(afh_audit_pkg.c_entity_taxonomy, 'TAXONOMY_CHANGED', l_id, 'Category ' || p_category_code || ' saved',
          apex_t_varchar2('object', 'code', 'label', 'is_active'), apex_t_varchar2('CATEGORY', p_category_code, p_label, p_is_active));
  END save_category;

  -- ------------------------------------------------------------------ classification values
  PROCEDURE save_classification_value(
    p_classification_value_id IN NUMBER, p_class_type IN VARCHAR2, p_value_code IN VARCHAR2, p_label IN VARCHAR2,
    p_display_seq IN NUMBER, p_is_active IN VARCHAR2, p_is_default IN VARCHAR2, p_color_token IN VARCHAR2) IS
    l_id   NUMBER := p_classification_value_id;
    l_type VARCHAR2(30 CHAR) := p_class_type;
  BEGIN
    afh_security_pkg.assert_admin;
    check_label(p_label); check_yn(p_is_active, 'Active'); check_yn(p_is_default, 'Default');
    IF l_id IS NULL THEN
      check_code(p_value_code, 'Value');
      IF l_type NOT IN ('PRIORITY', 'SEVERITY', 'IMPACT') THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown classification type.');
      END IF;
      INSERT INTO afh_classification_values (class_type, value_code, label, display_seq, is_active, is_default, color_token)
      VALUES (l_type, p_value_code, p_label, NVL(p_display_seq, 10), p_is_active, p_is_default, p_color_token)
      RETURNING classification_value_id INTO l_id;
    ELSE
      SELECT class_type INTO l_type FROM afh_classification_values WHERE classification_value_id = l_id;
      UPDATE afh_classification_values
         SET label = p_label, display_seq = NVL(p_display_seq, display_seq), is_active = p_is_active,
             is_default = p_is_default, color_token = p_color_token
       WHERE classification_value_id = l_id;
    END IF;
    IF p_is_default = 'Y' THEN
      UPDATE afh_classification_values SET is_default = 'N'
       WHERE class_type = l_type AND classification_value_id <> l_id AND is_default = 'Y';
    END IF;
    audit(afh_audit_pkg.c_entity_taxonomy, 'TAXONOMY_CHANGED', l_id, 'Classification ' || l_type || '.' || p_value_code || ' saved',
          apex_t_varchar2('object', 'class_type', 'code', 'label', 'is_default'), apex_t_varchar2('CLASSIFICATION', l_type, p_value_code, p_label, p_is_default));
  END save_classification_value;

  -- ------------------------------------------------------------------ workflow
  PROCEDURE save_status(
    p_workflow_status_id IN NUMBER, p_label IN VARCHAR2, p_display_seq IN NUMBER,
    p_color_token IN VARCHAR2, p_description IN VARCHAR2, p_is_active IN VARCHAR2) IS
    l_code VARCHAR2(30 CHAR);
  BEGIN
    afh_security_pkg.assert_admin;
    check_label(p_label); check_yn(p_is_active, 'Active');
    UPDATE afh_workflow_statuses
       SET label = p_label, display_seq = NVL(p_display_seq, display_seq), color_token = p_color_token,
           description = p_description, is_active = p_is_active
     WHERE workflow_status_id = p_workflow_status_id
     RETURNING status_code INTO l_code;
    IF SQL%ROWCOUNT = 0 THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown status.');
    END IF;
    audit(afh_audit_pkg.c_entity_workflow, 'WORKFLOW_CHANGED', p_workflow_status_id, 'Status ' || l_code || ' saved',
          apex_t_varchar2('object', 'code', 'label', 'is_active'), apex_t_varchar2('STATUS', l_code, p_label, p_is_active));
  END save_status;

  PROCEDURE save_transition(
    p_workflow_transition_id IN NUMBER, p_label IN VARCHAR2, p_reason_required IN VARCHAR2,
    p_is_active IN VARCHAR2, p_display_seq IN NUMBER, p_description IN VARCHAR2) IS
    l_from VARCHAR2(30 CHAR);
    l_to   VARCHAR2(30 CHAR);
  BEGIN
    afh_security_pkg.assert_admin;
    check_yn(p_reason_required, 'Reason required'); check_yn(p_is_active, 'Active');
    UPDATE afh_workflow_transitions
       SET label = p_label, reason_required = p_reason_required, is_active = p_is_active,
           display_seq = NVL(p_display_seq, display_seq), description = p_description
     WHERE workflow_transition_id = p_workflow_transition_id
     RETURNING from_status_code, to_status_code INTO l_from, l_to;
    IF SQL%ROWCOUNT = 0 THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown transition.');
    END IF;
    audit(afh_audit_pkg.c_entity_workflow, 'WORKFLOW_CHANGED', p_workflow_transition_id, 'Transition ' || l_from || ' -> ' || l_to || ' saved',
          apex_t_varchar2('object', 'from', 'to', 'label', 'is_active', 'reason_required'),
          apex_t_varchar2('TRANSITION', l_from, l_to, p_label, p_is_active, p_reason_required));
  END save_transition;
END afh_taxonomy_pkg;
/
