-- AFH_V_TAXONOMY_TYPES: feedback types with field and ticket counts (Page 64).
CREATE OR REPLACE FORCE VIEW afh_v_taxonomy_types AS
SELECT ft.feedback_type_id, ft.type_code, ft.label, ft.help_text, ft.icon_token, ft.display_seq, ft.is_active,
       (SELECT COUNT(*) FROM afh_type_fields tf WHERE tf.feedback_type_id = ft.feedback_type_id) AS field_count,
       (SELECT COUNT(*) FROM afh_tickets t WHERE t.feedback_type_id = ft.feedback_type_id) AS ticket_count,
       ft.last_updated_by, ft.last_update_date
  FROM afh_feedback_types ft;
COMMENT ON TABLE afh_v_taxonomy_types IS 'Feedback types with field and ticket counts for administration';
