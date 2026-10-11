CREATE OR REPLACE PACKAGE afh_ticket_int_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_TICKET_INT_PKG — private helpers for AFH_TICKET_PKG: feedback-type
  -- lookup, type-specific field metadata, field-value JSON parsing and
  -- validation, and intake validation. Not a page-facing API; it performs no
  -- authorization and writes no audit. Pages call AFH_TICKET_PKG only.
  -- Split out so each body stays under the 800-line limit (database-conventions).
  -- ---------------------------------------------------------------------------

  -- Field values keyed by FIELD_CODE (upper-case). Values are raw text as submitted.
  TYPE t_field_map IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(30);

  -- Shorthand: afh_security_pkg.raise_error('AFH-VAL-001', p_message).
  PROCEDURE raise_val(p_message IN VARCHAR2);

  -- ----------------------------------------------------------------- types
  -- feedback_type_id of an ACTIVE type; raises AFH-VAL-001 for unknown/inactive.
  FUNCTION active_type_id(p_type_code IN VARCHAR2) RETURN NUMBER;
  FUNCTION type_code_of(p_feedback_type_id IN NUMBER) RETURN VARCHAR2;

  -- ----------------------------------------------------------------- field values
  -- Parse {"FIELD_CODE":"value",...}; NULL/blank JSON -> empty map. Raises AFH-VAL-001
  -- when the document is not a JSON object. Keys are upper-cased.
  FUNCTION parse_field_values(p_json IN CLOB) RETURN t_field_map;
  -- Validate against the active afh_type_fields for the type: required present and
  -- non-blank, NUMBER numeric, DATE = YYYY-MM-DD, SELECT in the LOV codes, YN in Y/N,
  -- TEXT/TEXTAREA within max_length. Keys not configured for the type are ignored.
  -- Raises AFH-VAL-001 naming the field label.
  PROCEDURE validate_fields(p_feedback_type_id IN NUMBER, p_values IN t_field_map);
  -- MERGE the values for the fields configured on the type (label/data-type snapshot,
  -- display_value). Returns TRUE when at least one stored value changed.
  FUNCTION save_field_values(
    p_ticket_id        IN NUMBER,
    p_feedback_type_id IN NUMBER,
    p_values           IN t_field_map) RETURN BOOLEAN;
  -- Stored values of a ticket as a map (for re-validation on a type change).
  FUNCTION load_field_values(p_ticket_id IN NUMBER) RETURN t_field_map;
  -- Flat JSON object {FIELD_CODE: display_value} for audit facts.
  FUNCTION field_values_facts(p_ticket_id IN NUMBER) RETURN CLOB;
  -- Spec afh_ticket_pkg.type_fields_json.
  FUNCTION type_fields_json(p_type_code IN VARCHAR2) RETURN CLOB;
  -- Label for a code in a 'CODE:Label;CODE:Label' LOV string; NULL when absent.
  FUNCTION lov_label(p_lov_values IN VARCHAR2, p_code IN VARCHAR2) RETURN VARCHAR2;

  -- ----------------------------------------------------------------- intake validation (spec §14.2)
  PROCEDURE validate_title_desc(p_title IN VARCHAR2, p_description IN CLOB);
  -- Application and environment active, environment belongs to the application.
  PROCEDURE validate_source(p_application_id IN NUMBER, p_environment_id IN NUMBER);
  -- NULL allowed; otherwise an active category that is global or owned by the application.
  PROCEDURE validate_category(p_category_id IN NUMBER, p_application_id IN NUMBER);
  -- Active afh_classification_values row for (class_type, code).
  PROCEDURE validate_class_value(p_class_type IN VARCHAR2, p_code IN VARCHAR2);
  -- Active afh_users row; raises AFH-VAL-001 otherwise. NULL passes.
  PROCEDURE validate_user(p_user_id IN NUMBER, p_role_label IN VARCHAR2);
  -- Release belongs to the application and is not COMPLETED/CANCELLED. NULL passes.
  PROCEDURE validate_release(p_release_id IN NUMBER, p_application_id IN NUMBER);

  -- ----------------------------------------------------------------- display and compare helpers (audit facts)
  FUNCTION user_name(p_user_id IN NUMBER) RETURN VARCHAR2;             -- display name or subject; NULL-safe
  FUNCTION release_label(p_release_id IN NUMBER) RETURN VARCHAR2;      -- NULL-safe
  FUNCTION class_label(p_class_type IN VARCHAR2, p_code IN VARCHAR2) RETURN VARCHAR2;   -- falls back to the code
  FUNCTION clob_differs(p_a IN CLOB, p_b IN CLOB) RETURN BOOLEAN;      -- NULL-aware inequality
  FUNCTION snippet(p_clob IN CLOB) RETURN VARCHAR2;                    -- first 500 characters
END afh_ticket_int_pkg;
/

