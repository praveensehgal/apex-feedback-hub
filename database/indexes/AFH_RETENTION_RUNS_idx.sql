-- Indexes for AFH_RETENTION_RUNS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_RETENTION_RUNS_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_RETENTION_RUNS_IX1 ON afh_retention_runs (started_at)';
  END IF;
END;
/
