-- Constraints for AFH_TYPE_FIELDS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TYPE_FIELDS_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_type_fields ADD CONSTRAINT AFH_TYPE_FIELDS_UK1 UNIQUE (feedback_type_id, field_definition_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TYPE_FIELDS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_type_fields ADD CONSTRAINT AFH_TYPE_FIELDS_FK1 FOREIGN KEY (feedback_type_id) REFERENCES afh_feedback_types (feedback_type_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TYPE_FIELDS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_type_fields ADD CONSTRAINT AFH_TYPE_FIELDS_FK2 FOREIGN KEY (field_definition_id) REFERENCES afh_field_definitions (field_definition_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TYPE_FIELDS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_type_fields ADD CONSTRAINT AFH_TYPE_FIELDS_CK1 CHECK (is_required IN ('Y','N'))]';
  END IF;
END;
/
