-- Constraints for AFH_FEEDBACK_TYPES
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_FEEDBACK_TYPES_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_feedback_types ADD CONSTRAINT AFH_FEEDBACK_TYPES_UK1 UNIQUE (type_code)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_FEEDBACK_TYPES_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_feedback_types ADD CONSTRAINT AFH_FEEDBACK_TYPES_CK1 CHECK (REGEXP_LIKE(type_code, '^[A-Z][A-Z0-9_]{0,29}$'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_FEEDBACK_TYPES_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_feedback_types ADD CONSTRAINT AFH_FEEDBACK_TYPES_CK2 CHECK (is_active IN ('Y','N'))]';
  END IF;
END;
/
