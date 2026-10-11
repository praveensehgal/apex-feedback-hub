CREATE OR REPLACE PACKAGE afh_taxonomy_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_TAXONOMY_PKG — administration of feedback types, fields, type-field
  -- mapping, categories, classification values, status labels and transition
  -- switches (Page 64). Design amendment: spec §12 has no owner for taxonomy
  -- maintenance, and the architecture rule forbids DML in pages.
  -- Every procedure: assert_admin, validate, upsert, audit TAXONOMY_CHANGED or
  -- WORKFLOW_CHANGED (entity TAXONOMY / WORKFLOW, is_public 'N').
  -- Stable codes are immutable once a row exists; deactivation replaces deletion
  -- except for type-field mappings, which are configuration.
  -- ---------------------------------------------------------------------------
  PROCEDURE save_type(
    p_feedback_type_id IN NUMBER,
    p_type_code        IN VARCHAR2,
    p_label            IN VARCHAR2,
    p_help_text        IN VARCHAR2,
    p_icon_token       IN VARCHAR2,
    p_display_seq      IN NUMBER,
    p_is_active        IN VARCHAR2);

  PROCEDURE save_field(
    p_field_definition_id IN NUMBER,
    p_field_code          IN VARCHAR2,
    p_label               IN VARCHAR2,
    p_data_type           IN VARCHAR2,
    p_max_length          IN NUMBER,
    p_help_text           IN VARCHAR2,
    p_lov_values          IN VARCHAR2,
    p_is_active           IN VARCHAR2);

  PROCEDURE save_type_field(
    p_type_field_id  IN NUMBER,
    p_type_code      IN VARCHAR2,
    p_field_code     IN VARCHAR2,
    p_is_required    IN VARCHAR2,
    p_display_seq    IN NUMBER,
    p_label_override IN VARCHAR2);
  PROCEDURE remove_type_field(p_type_field_id IN NUMBER);

  PROCEDURE save_category(
    p_category_id        IN NUMBER,
    p_application_id     IN NUMBER,
    p_category_code      IN VARCHAR2,
    p_label              IN VARCHAR2,
    p_parent_category_id IN NUMBER,
    p_display_seq        IN NUMBER,
    p_is_active          IN VARCHAR2);

  -- Exactly one default per class type: setting p_is_default = 'Y' clears the others.
  PROCEDURE save_classification_value(
    p_classification_value_id IN NUMBER,
    p_class_type              IN VARCHAR2,
    p_value_code              IN VARCHAR2,
    p_label                   IN VARCHAR2,
    p_display_seq             IN NUMBER,
    p_is_active               IN VARCHAR2,
    p_is_default              IN VARCHAR2,
    p_color_token             IN VARCHAR2);

  -- Status codes and the terminal flag are never changed here (spec §10.1).
  PROCEDURE save_status(
    p_workflow_status_id IN NUMBER,
    p_label              IN VARCHAR2,
    p_display_seq        IN NUMBER,
    p_color_token        IN VARCHAR2,
    p_description        IN VARCHAR2,
    p_is_active          IN VARCHAR2);

  -- From/to/actors/required facts are product rules (spec §10.2); only these are editable.
  PROCEDURE save_transition(
    p_workflow_transition_id IN NUMBER,
    p_label                  IN VARCHAR2,
    p_reason_required        IN VARCHAR2,
    p_is_active              IN VARCHAR2,
    p_display_seq            IN NUMBER,
    p_description            IN VARCHAR2);
END afh_taxonomy_pkg;
/
