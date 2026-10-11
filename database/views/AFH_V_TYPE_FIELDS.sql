-- AFH_V_TYPE_FIELDS: fields per type with the effective label (Pages 20, 64).
CREATE OR REPLACE FORCE VIEW afh_v_type_fields AS
SELECT tf.type_field_id, tf.feedback_type_id, ft.type_code, ft.label AS type_label,
       tf.field_definition_id, fd.field_code, fd.label AS field_label, tf.label_override,
       NVL(tf.label_override, fd.label) AS effective_label,
       fd.data_type, fd.max_length, fd.help_text, fd.lov_values, tf.is_required, tf.display_seq,
       CASE WHEN ft.is_active = 'Y' AND fd.is_active = 'Y' THEN 'Y' ELSE 'N' END AS is_active
  FROM afh_type_fields tf
  JOIN afh_feedback_types ft ON ft.feedback_type_id = tf.feedback_type_id
  JOIN afh_field_definitions fd ON fd.field_definition_id = tf.field_definition_id;
COMMENT ON TABLE afh_v_type_fields IS 'Fields shown for each feedback type, with label override resolved';
