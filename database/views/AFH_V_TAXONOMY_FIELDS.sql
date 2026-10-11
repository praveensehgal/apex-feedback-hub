-- AFH_V_TAXONOMY_FIELDS: reusable field definitions with usage counts (Page 64).
CREATE OR REPLACE FORCE VIEW afh_v_taxonomy_fields AS
SELECT fd.field_definition_id, fd.field_code, fd.label, fd.data_type, fd.max_length, fd.help_text, fd.lov_values, fd.is_active,
       (SELECT COUNT(*) FROM afh_type_fields tf WHERE tf.field_definition_id = fd.field_definition_id) AS used_by_types,
       (SELECT LISTAGG(ft.type_code, ', ') WITHIN GROUP (ORDER BY ft.display_seq)
          FROM afh_type_fields tf JOIN afh_feedback_types ft ON ft.feedback_type_id = tf.feedback_type_id
         WHERE tf.field_definition_id = fd.field_definition_id) AS type_codes,
       fd.last_updated_by, fd.last_update_date
  FROM afh_field_definitions fd;
COMMENT ON TABLE afh_v_taxonomy_fields IS 'Field definitions with the types that use them';
