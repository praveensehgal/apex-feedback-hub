CREATE OR REPLACE PACKAGE BODY afh_ticket_int_pkg AS
  -- Private helpers for AFH_TICKET_PKG. No authorization, no audit, no COMMIT.

  c_code_pattern CONSTANT VARCHAR2(30) := '^[A-Z][A-Z0-9_]{0,29}$';

  -- Active fields configured for a type, in display order.
  CURSOR c_type_fields(cp_type_id IN NUMBER) IS
    SELECT fd.field_definition_id, fd.field_code, fd.data_type, fd.max_length, fd.lov_values,
           fd.help_text, tf.is_required, tf.display_seq,
           NVL(tf.label_override, fd.label) AS label
      FROM afh_type_fields tf
      JOIN afh_field_definitions fd ON fd.field_definition_id = tf.field_definition_id
     WHERE tf.feedback_type_id = cp_type_id
       AND fd.is_active = 'Y'
     ORDER BY tf.display_seq, fd.field_code;

  PROCEDURE raise_val(p_message IN VARCHAR2) IS
  BEGIN
    afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, p_message);
  END raise_val;

  -- ----------------------------------------------------------------- types
  FUNCTION active_type_id(p_type_code IN VARCHAR2) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    SELECT feedback_type_id INTO l_id
      FROM afh_feedback_types
     WHERE type_code = UPPER(TRIM(p_type_code)) AND is_active = 'Y';
    RETURN l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_val('Choose a feedback type from the list.');
  END active_type_id;

  FUNCTION type_code_of(p_feedback_type_id IN NUMBER) RETURN VARCHAR2 IS
    l_code afh_feedback_types.type_code%TYPE;
  BEGIN
    SELECT type_code INTO l_code FROM afh_feedback_types WHERE feedback_type_id = p_feedback_type_id;
    RETURN l_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END type_code_of;

  -- ----------------------------------------------------------------- LOV helpers
  FUNCTION lov_label(p_lov_values IN VARCHAR2, p_code IN VARCHAR2) RETURN VARCHAR2 IS
    l_entries apex_t_varchar2;
    l_entry   VARCHAR2(4000);
    l_pos     PLS_INTEGER;
  BEGIN
    IF p_lov_values IS NULL OR p_code IS NULL THEN RETURN NULL; END IF;
    l_entries := apex_string.split(p_lov_values, ';');
    FOR i IN 1 .. l_entries.COUNT LOOP
      l_entry := TRIM(l_entries(i));
      l_pos   := INSTR(l_entry, ':');
      IF l_pos > 0 AND SUBSTR(l_entry, 1, l_pos - 1) = p_code THEN
        RETURN SUBSTR(l_entry, l_pos + 1);
      END IF;
    END LOOP;
    RETURN NULL;
  END lov_label;

  PROCEDURE write_lov_json(p_lov_values IN VARCHAR2) IS
    l_entries apex_t_varchar2;
    l_entry   VARCHAR2(4000);
    l_pos     PLS_INTEGER;
  BEGIN
    apex_json.open_array('lov');
    IF p_lov_values IS NOT NULL THEN
      l_entries := apex_string.split(p_lov_values, ';');
      FOR i IN 1 .. l_entries.COUNT LOOP
        l_entry := TRIM(l_entries(i));
        l_pos   := INSTR(l_entry, ':');
        IF l_pos > 0 THEN
          apex_json.open_object;
          apex_json.write('code',  SUBSTR(l_entry, 1, l_pos - 1));
          apex_json.write('label', SUBSTR(l_entry, l_pos + 1));
          apex_json.close_object;
        END IF;
      END LOOP;
    END IF;
    apex_json.close_array;
  END write_lov_json;

  -- ----------------------------------------------------------------- field values
  FUNCTION value_of(p_values IN t_field_map, p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_values.EXISTS(p_code) THEN RETURN p_values(p_code); END IF;
    RETURN NULL;
  END value_of;

  FUNCTION parse_field_values(p_json IN CLOB) RETURN t_field_map IS
    l_map  t_field_map;
    l_vals apex_json.t_values;
    l_keys apex_t_varchar2;
    l_key  VARCHAR2(255);
  BEGIN
    IF p_json IS NULL OR DBMS_LOB.getlength(p_json) = 0
       OR TRIM(DBMS_LOB.substr(p_json, 4000, 1)) IS NULL THEN
      RETURN l_map;
    END IF;
    BEGIN
      apex_json.parse(p_values => l_vals, p_source => p_json, p_strict => TRUE);
      l_keys := apex_json.get_members(p_path => '.', p_values => l_vals);
    EXCEPTION
      WHEN OTHERS THEN
        raise_val('The type-specific details could not be read. Reload the form and try again.');
    END;
    FOR i IN 1 .. l_keys.COUNT LOOP
      l_key := UPPER(TRIM(l_keys(i)));
      IF REGEXP_LIKE(l_key, c_code_pattern) THEN
        l_map(l_key) := apex_json.get_varchar2(p_path => '%s', p0 => l_keys(i), p_values => l_vals);
      END IF;
    END LOOP;
    RETURN l_map;
  EXCEPTION
    WHEN VALUE_ERROR THEN
      raise_val('One of the type-specific details is too long.');
  END parse_field_values;

  PROCEDURE validate_one(
    p_label       IN VARCHAR2,
    p_data_type   IN VARCHAR2,
    p_max_length  IN NUMBER,
    p_lov_values  IN VARCHAR2,
    p_is_required IN VARCHAR2,
    p_value       IN VARCHAR2) IS
    l_num NUMBER;
    l_dt  DATE;
  BEGIN
    IF TRIM(p_value) IS NULL THEN
      IF p_is_required = 'Y' THEN raise_val(p_label || ' is required.'); END IF;
      RETURN;
    END IF;
    CASE p_data_type
      WHEN 'NUMBER' THEN
        BEGIN
          l_num := TO_NUMBER(TRIM(p_value));
        EXCEPTION WHEN OTHERS THEN
          raise_val(p_label || ' must be a number.');
        END;
      WHEN 'DATE' THEN
        IF NOT REGEXP_LIKE(TRIM(p_value), '^\d{4}-\d{2}-\d{2}$') THEN
          raise_val(p_label || ' must be a date in the form YYYY-MM-DD.');
        END IF;
        BEGIN
          l_dt := TO_DATE(TRIM(p_value), 'YYYY-MM-DD');
        EXCEPTION WHEN OTHERS THEN
          raise_val(p_label || ' must be a valid date.');
        END;
      WHEN 'SELECT' THEN
        IF lov_label(p_lov_values, TRIM(p_value)) IS NULL THEN
          raise_val(p_label || ' must be one of the listed options.');
        END IF;
      WHEN 'YN' THEN
        IF UPPER(TRIM(p_value)) NOT IN ('Y', 'N') THEN
          raise_val(p_label || ' must be Yes or No.');
        END IF;
      ELSE
        IF p_max_length IS NOT NULL AND LENGTH(p_value) > p_max_length THEN
          raise_val(p_label || ' must be ' || p_max_length || ' characters or fewer.');
        END IF;
    END CASE;
  END validate_one;

  PROCEDURE validate_fields(p_feedback_type_id IN NUMBER, p_values IN t_field_map) IS
  BEGIN
    FOR r IN c_type_fields(p_feedback_type_id) LOOP
      validate_one(r.label, r.data_type, r.max_length, r.lov_values, r.is_required,
                   value_of(p_values, r.field_code));
    END LOOP;
  END validate_fields;

  FUNCTION display_value_for(p_data_type IN VARCHAR2, p_lov_values IN VARCHAR2, p_value IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_value IS NULL THEN RETURN NULL; END IF;
    IF p_data_type = 'SELECT' THEN
      RETURN NVL(lov_label(p_lov_values, TRIM(p_value)), TRIM(p_value));
    END IF;
    RETURN SUBSTR(p_value, 1, 4000);
  END display_value_for;

  -- TRUE when the stored CLOB differs from the new text (NULL-aware).
  FUNCTION differs(p_old IN CLOB, p_new IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    IF p_old IS NULL AND p_new IS NULL THEN RETURN FALSE; END IF;
    IF p_old IS NULL OR p_new IS NULL THEN RETURN TRUE; END IF;
    RETURN DBMS_LOB.compare(p_old, TO_CLOB(p_new)) <> 0;
  END differs;

  -- Upsert one field; returns TRUE when the stored value changed.
  FUNCTION upsert_one(p_ticket_id IN NUMBER, p_field IN c_type_fields%ROWTYPE, p_new IN VARCHAR2) RETURN BOOLEAN IS
    l_id   NUMBER;
    l_old  CLOB;
    l_val  VARCHAR2(32767) := CASE WHEN TRIM(p_new) IS NULL THEN NULL ELSE p_new END;
    l_disp VARCHAR2(4000)  := display_value_for(p_field.data_type, p_field.lov_values, l_val);
  BEGIN
    BEGIN
      SELECT ticket_field_value_id, field_value INTO l_id, l_old
        FROM afh_ticket_field_values
       WHERE ticket_id = p_ticket_id AND field_definition_id = p_field.field_definition_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_id := NULL;
    END;
    IF l_id IS NULL THEN
      IF l_val IS NULL THEN RETURN FALSE; END IF;
      INSERT INTO afh_ticket_field_values (ticket_id, field_definition_id, field_value, display_value, label_snapshot, data_type_snapshot)
      VALUES (p_ticket_id, p_field.field_definition_id, l_val, l_disp, p_field.label, p_field.data_type);
      RETURN TRUE;
    END IF;
    IF NOT differs(l_old, l_val) THEN RETURN FALSE; END IF;
    UPDATE afh_ticket_field_values
       SET field_value = l_val,
           display_value = l_disp,
           label_snapshot = p_field.label,
           data_type_snapshot = p_field.data_type
     WHERE ticket_field_value_id = l_id;
    RETURN TRUE;
  END upsert_one;

  FUNCTION save_field_values(
    p_ticket_id        IN NUMBER,
    p_feedback_type_id IN NUMBER,
    p_values           IN t_field_map) RETURN BOOLEAN IS
    l_changed BOOLEAN := FALSE;
  BEGIN
    FOR r IN c_type_fields(p_feedback_type_id) LOOP
      IF upsert_one(p_ticket_id, r, value_of(p_values, r.field_code)) THEN
        l_changed := TRUE;
      END IF;
    END LOOP;
    RETURN l_changed;
  END save_field_values;

  FUNCTION load_field_values(p_ticket_id IN NUMBER) RETURN t_field_map IS
    l_map t_field_map;
  BEGIN
    FOR r IN (SELECT fd.field_code, v.field_value
                FROM afh_ticket_field_values v
                JOIN afh_field_definitions fd ON fd.field_definition_id = v.field_definition_id
               WHERE v.ticket_id = p_ticket_id) LOOP
      l_map(r.field_code) := DBMS_LOB.substr(r.field_value, 32000, 1);
    END LOOP;
    RETURN l_map;
  END load_field_values;

  FUNCTION field_values_facts(p_ticket_id IN NUMBER) RETURN CLOB IS
    l_names  apex_t_varchar2 := apex_t_varchar2();
    l_values apex_t_varchar2 := apex_t_varchar2();
  BEGIN
    FOR r IN (SELECT fd.field_code, v.display_value
                FROM afh_ticket_field_values v
                JOIN afh_field_definitions fd ON fd.field_definition_id = v.field_definition_id
               WHERE v.ticket_id = p_ticket_id
               ORDER BY fd.field_code) LOOP
      apex_string.push(l_names,  r.field_code);
      apex_string.push(l_values, SUBSTR(r.display_value, 1, 500));
    END LOOP;
    RETURN afh_audit_pkg.json_obj(l_names, l_values);
  END field_values_facts;

  FUNCTION type_fields_json(p_type_code IN VARCHAR2) RETURN CLOB IS
    l_type_id NUMBER := active_type_id(p_type_code);
    l_out     CLOB;
  BEGIN
    apex_json.initialize_clob_output;
    apex_json.open_array;
    FOR r IN c_type_fields(l_type_id) LOOP
      apex_json.open_object;
      apex_json.write('code',      r.field_code);
      apex_json.write('label',     r.label);
      apex_json.write('dataType',  r.data_type);
      apex_json.write('required',  r.is_required = 'Y');
      apex_json.write('maxLength', r.max_length, p_write_null => TRUE);
      apex_json.write('helpText',  r.help_text,  p_write_null => TRUE);
      write_lov_json(r.lov_values);
      apex_json.close_object;
    END LOOP;
    apex_json.close_array;
    l_out := apex_json.get_clob_output;
    apex_json.free_output;
    apex_json.initialize_output(p_http_header => FALSE);  -- back to HTP: free_output leaves output detached
    RETURN l_out;
  END type_fields_json;

  -- ----------------------------------------------------------------- intake validation
  PROCEDURE validate_title_desc(p_title IN VARCHAR2, p_description IN CLOB) IS
    l_len NUMBER;
  BEGIN
    IF LENGTH(TRIM(p_title)) IS NULL OR LENGTH(TRIM(p_title)) NOT BETWEEN 6 AND 120 THEN
      raise_val('Title must be between 6 and 120 characters.');
    END IF;
    l_len := NVL(DBMS_LOB.getlength(p_description), 0);
    IF l_len NOT BETWEEN 10 AND 32000 THEN
      raise_val('Description must be between 10 and 32,000 characters.');
    END IF;
  END validate_title_desc;

  PROCEDURE validate_source(p_application_id IN NUMBER, p_environment_id IN NUMBER) IS
    l_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO l_cnt FROM afh_applications
     WHERE application_id = p_application_id AND is_active = 'Y';
    IF l_cnt = 0 THEN raise_val('The source application is not registered or is inactive.'); END IF;
    SELECT COUNT(*) INTO l_cnt FROM afh_environments
     WHERE environment_id = p_environment_id AND application_id = p_application_id AND is_active = 'Y';
    IF l_cnt = 0 THEN raise_val('The source environment is not registered for this application.'); END IF;
  END validate_source;

  PROCEDURE validate_category(p_category_id IN NUMBER, p_application_id IN NUMBER) IS
    l_cnt PLS_INTEGER;
  BEGIN
    IF p_category_id IS NULL THEN RETURN; END IF;
    SELECT COUNT(*) INTO l_cnt FROM afh_categories
     WHERE category_id = p_category_id AND is_active = 'Y'
       AND (application_id IS NULL OR application_id = p_application_id);
    IF l_cnt = 0 THEN raise_val('Choose a category from the list.'); END IF;
  END validate_category;

  PROCEDURE validate_class_value(p_class_type IN VARCHAR2, p_code IN VARCHAR2) IS
    l_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO l_cnt FROM afh_classification_values
     WHERE class_type = p_class_type AND value_code = p_code AND is_active = 'Y';
    IF l_cnt = 0 THEN
      raise_val('Choose a ' || LOWER(p_class_type) || ' from the list.');
    END IF;
  END validate_class_value;

  PROCEDURE validate_user(p_user_id IN NUMBER, p_role_label IN VARCHAR2) IS
    l_cnt PLS_INTEGER;
  BEGIN
    IF p_user_id IS NULL THEN RETURN; END IF;
    SELECT COUNT(*) INTO l_cnt FROM afh_users WHERE user_id = p_user_id AND is_active = 'Y';
    IF l_cnt = 0 THEN raise_val('Choose an active user as the ' || p_role_label || '.'); END IF;
  END validate_user;

  PROCEDURE validate_release(p_release_id IN NUMBER, p_application_id IN NUMBER) IS
    l_app   NUMBER;
    l_state afh_releases.state_code%TYPE;
  BEGIN
    IF p_release_id IS NULL THEN RETURN; END IF;
    BEGIN
      SELECT application_id, state_code INTO l_app, l_state FROM afh_releases WHERE release_id = p_release_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      raise_val('Choose a release from the list.');
    END;
    IF l_app <> p_application_id THEN
      raise_val('The release belongs to a different application.');
    END IF;
    IF l_state IN ('COMPLETED', 'CANCELLED') THEN
      raise_val('The release is already ' || LOWER(l_state) || '. Choose an open release.');
    END IF;
  END validate_release;

  -- ----------------------------------------------------------------- display and compare helpers
  FUNCTION user_name(p_user_id IN NUMBER) RETURN VARCHAR2 IS
    l_name VARCHAR2(255);
  BEGIN
    IF p_user_id IS NULL THEN RETURN NULL; END IF;
    SELECT NVL(display_name, subject_display) INTO l_name FROM afh_users WHERE user_id = p_user_id;
    RETURN l_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END user_name;

  FUNCTION release_label(p_release_id IN NUMBER) RETURN VARCHAR2 IS
    l_label VARCHAR2(255);
  BEGIN
    IF p_release_id IS NULL THEN RETURN NULL; END IF;
    SELECT label INTO l_label FROM afh_releases WHERE release_id = p_release_id;
    RETURN l_label;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END release_label;

  FUNCTION class_label(p_class_type IN VARCHAR2, p_code IN VARCHAR2) RETURN VARCHAR2 IS
    l_label VARCHAR2(255);
  BEGIN
    SELECT label INTO l_label FROM afh_classification_values
     WHERE class_type = p_class_type AND value_code = p_code;
    RETURN l_label;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN p_code;
  END class_label;

  FUNCTION clob_differs(p_a IN CLOB, p_b IN CLOB) RETURN BOOLEAN IS
  BEGIN
    IF p_a IS NULL AND p_b IS NULL THEN RETURN FALSE; END IF;
    IF p_a IS NULL OR p_b IS NULL THEN RETURN TRUE; END IF;
    RETURN DBMS_LOB.compare(p_a, p_b) <> 0;
  END clob_differs;

  FUNCTION snippet(p_clob IN CLOB) RETURN VARCHAR2 IS
  BEGIN
    IF p_clob IS NULL THEN RETURN NULL; END IF;
    RETURN DBMS_LOB.substr(p_clob, 500, 1);
  END snippet;
END afh_ticket_int_pkg;
/

