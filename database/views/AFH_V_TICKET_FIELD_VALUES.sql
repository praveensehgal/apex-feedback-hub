-- AFH_V_TICKET_FIELD_VALUES: type-specific values with the label shown at submission (Page 10).
CREATE OR REPLACE FORCE VIEW afh_v_ticket_field_values AS
SELECT v.ticket_field_value_id,
       v.ticket_id,
       f.field_code,
       v.label_snapshot,
       v.data_type_snapshot,
       v.display_value,
       v.field_value,
       NVL(tf.display_seq, 999) AS display_seq
  FROM afh_ticket_field_values v
  JOIN afh_field_definitions f ON f.field_definition_id = v.field_definition_id
  JOIN afh_tickets t ON t.ticket_id = v.ticket_id
  LEFT JOIN afh_type_fields tf ON tf.field_definition_id = v.field_definition_id AND tf.feedback_type_id = t.feedback_type_id;
COMMENT ON TABLE afh_v_ticket_field_values IS 'Type-specific field values per ticket with the label snapshot taken at submission';
