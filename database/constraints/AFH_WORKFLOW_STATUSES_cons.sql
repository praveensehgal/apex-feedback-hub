-- Constraints for AFH_WORKFLOW_STATUSES
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_WORKFLOW_STATUSES_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_workflow_statuses ADD CONSTRAINT AFH_WORKFLOW_STATUSES_UK1 UNIQUE (status_code)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_WORKFLOW_STATUSES_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_workflow_statuses ADD CONSTRAINT AFH_WORKFLOW_STATUSES_CK1 CHECK (REGEXP_LIKE(status_code, '^[A-Z][A-Z0-9_]{0,29}$'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_WORKFLOW_STATUSES_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_workflow_statuses ADD CONSTRAINT AFH_WORKFLOW_STATUSES_CK2 CHECK (is_terminal IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_WORKFLOW_STATUSES_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_workflow_statuses ADD CONSTRAINT AFH_WORKFLOW_STATUSES_CK3 CHECK (is_active IN ('Y','N'))]';
  END IF;
END;
/
