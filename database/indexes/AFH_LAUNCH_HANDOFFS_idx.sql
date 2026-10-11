-- Indexes for AFH_LAUNCH_HANDOFFS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_LAUNCH_HANDOFFS_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_LAUNCH_HANDOFFS_IX1 ON afh_launch_handoffs (issued_at)';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_LAUNCH_HANDOFFS_IX2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_LAUNCH_HANDOFFS_IX2 ON afh_launch_handoffs (environment_id)';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_LAUNCH_HANDOFFS_IX3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_LAUNCH_HANDOFFS_IX3 ON afh_launch_handoffs (ticket_id)';
  END IF;
END;
/
