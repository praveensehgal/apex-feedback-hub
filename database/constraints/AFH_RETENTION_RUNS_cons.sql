-- Constraints for AFH_RETENTION_RUNS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_RETENTION_RUNS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_retention_runs ADD CONSTRAINT AFH_RETENTION_RUNS_CK1 CHECK (mode_code IN ('PREVIEW','EXECUTE'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_RETENTION_RUNS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_retention_runs ADD CONSTRAINT AFH_RETENTION_RUNS_CK2 CHECK (result_code IS NULL OR result_code IN ('OK','FAILED','PARTIAL'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_RETENTION_RUNS_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_retention_runs ADD CONSTRAINT AFH_RETENTION_RUNS_CK3 CHECK (detail_json IS NULL OR detail_json IS JSON)]';
  END IF;
END;
/
