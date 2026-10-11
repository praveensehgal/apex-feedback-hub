-- Constraints for AFH_TEST_RESULTS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TEST_RESULTS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_test_results ADD CONSTRAINT AFH_TEST_RESULTS_FK1 FOREIGN KEY (ticket_id) REFERENCES afh_tickets (ticket_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TEST_RESULTS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_test_results ADD CONSTRAINT AFH_TEST_RESULTS_FK2 FOREIGN KEY (assignee_user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TEST_RESULTS_FK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_test_results ADD CONSTRAINT AFH_TEST_RESULTS_FK3 FOREIGN KEY (environment_id) REFERENCES afh_environments (environment_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TEST_RESULTS_FK4';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_test_results ADD CONSTRAINT AFH_TEST_RESULTS_FK4 FOREIGN KEY (requested_by_user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TEST_RESULTS_FK5';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_test_results ADD CONSTRAINT AFH_TEST_RESULTS_FK5 FOREIGN KEY (completed_by_user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TEST_RESULTS_FK6';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_test_results ADD CONSTRAINT AFH_TEST_RESULTS_FK6 FOREIGN KEY (release_id) REFERENCES afh_releases (release_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TEST_RESULTS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_test_results ADD CONSTRAINT AFH_TEST_RESULTS_CK1 CHECK (result_code IN ('PENDING','PASSED','FAILED','CANCELLED'))]';
  END IF;
END;
/
