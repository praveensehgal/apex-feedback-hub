-- Constraints for AFH_SAVED_FILTERS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_SAVED_FILTERS_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_saved_filters ADD CONSTRAINT AFH_SAVED_FILTERS_UK1 UNIQUE (owner_user_id, scope_code, filter_name)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_SAVED_FILTERS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_saved_filters ADD CONSTRAINT AFH_SAVED_FILTERS_FK1 FOREIGN KEY (owner_user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_SAVED_FILTERS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_saved_filters ADD CONSTRAINT AFH_SAVED_FILTERS_FK2 FOREIGN KEY (application_id) REFERENCES afh_applications (application_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_SAVED_FILTERS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_saved_filters ADD CONSTRAINT AFH_SAVED_FILTERS_CK1 CHECK (scope_code IN ('WORKBENCH','ALL_FEEDBACK','MY_WORK'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_SAVED_FILTERS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_saved_filters ADD CONSTRAINT AFH_SAVED_FILTERS_CK2 CHECK (is_shared IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_SAVED_FILTERS_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_saved_filters ADD CONSTRAINT AFH_SAVED_FILTERS_CK3 CHECK (filter_json IS JSON)]';
  END IF;
END;
/
