-- Indexes for AFH_TEST_RESULTS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_TEST_RESULTS_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_TEST_RESULTS_IX1 ON afh_test_results (ticket_id)';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_TEST_RESULTS_IX2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_TEST_RESULTS_IX2 ON afh_test_results (assignee_user_id, result_code)';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_TEST_RESULTS_IX3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_TEST_RESULTS_IX3 ON afh_test_results (environment_id)';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_TEST_RESULTS_IX4';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_TEST_RESULTS_IX4 ON afh_test_results (requested_by_user_id)';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_TEST_RESULTS_IX5';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_TEST_RESULTS_IX5 ON afh_test_results (completed_by_user_id)';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_TEST_RESULTS_IX6';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_TEST_RESULTS_IX6 ON afh_test_results (release_id)';
  END IF;
END;
/
