-- AFH_V_CLASSIFICATION_VALUES: priority, severity and impact choices (Pages 10, 20, 64).
CREATE OR REPLACE FORCE VIEW afh_v_classification_values AS
SELECT classification_value_id, class_type, value_code, label, display_seq, is_active, is_default, color_token, last_updated_by, last_update_date
  FROM afh_classification_values;
COMMENT ON TABLE afh_v_classification_values IS 'Classification choices by class type';
