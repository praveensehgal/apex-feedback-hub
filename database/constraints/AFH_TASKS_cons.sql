-- Constraints for AFH_TASKS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TASKS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_tasks ADD CONSTRAINT AFH_TASKS_FK1 FOREIGN KEY (user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TASKS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_tasks ADD CONSTRAINT AFH_TASKS_FK2 FOREIGN KEY (ticket_id) REFERENCES afh_tickets (ticket_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TASKS_FK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_tasks ADD CONSTRAINT AFH_TASKS_FK3 FOREIGN KEY (completed_by_user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TASKS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_tasks ADD CONSTRAINT AFH_TASKS_CK1 CHECK (task_type_code IN ('ASSIGNMENT','INFO_REQUEST','TEST_REQUEST','REVIEW'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TASKS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_tasks ADD CONSTRAINT AFH_TASKS_CK2 CHECK (state_code IN ('OPEN','DONE','CANCELLED'))]';
  END IF;
END;
/
