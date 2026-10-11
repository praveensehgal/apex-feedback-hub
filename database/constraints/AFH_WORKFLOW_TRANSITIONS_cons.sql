-- Constraints for AFH_WORKFLOW_TRANSITIONS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_WORKFLOW_TRANSITIONS_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_workflow_transitions ADD CONSTRAINT AFH_WORKFLOW_TRANSITIONS_UK1 UNIQUE (from_status_code, to_status_code)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_WORKFLOW_TRANSITIONS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_workflow_transitions ADD CONSTRAINT AFH_WORKFLOW_TRANSITIONS_FK1 FOREIGN KEY (from_status_code) REFERENCES afh_workflow_statuses (status_code)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_WORKFLOW_TRANSITIONS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_workflow_transitions ADD CONSTRAINT AFH_WORKFLOW_TRANSITIONS_FK2 FOREIGN KEY (to_status_code) REFERENCES afh_workflow_statuses (status_code)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_WORKFLOW_TRANSITIONS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_workflow_transitions ADD CONSTRAINT AFH_WORKFLOW_TRANSITIONS_CK1 CHECK (min_role_code IS NULL OR min_role_code IN ('USER','TESTER','DEVELOPER','APP_OWNER','AFH_ADMIN'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_WORKFLOW_TRANSITIONS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_workflow_transitions ADD CONSTRAINT AFH_WORKFLOW_TRANSITIONS_CK2 CHECK (reason_required IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_WORKFLOW_TRANSITIONS_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_workflow_transitions ADD CONSTRAINT AFH_WORKFLOW_TRANSITIONS_CK3 CHECK (is_active IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_WORKFLOW_TRANSITIONS_CK4';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_workflow_transitions ADD CONSTRAINT AFH_WORKFLOW_TRANSITIONS_CK4 CHECK (from_status_code <> to_status_code)]';
  END IF;
END;
/
