-- Constraints for AFH_AFFECTED_USERS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_AFFECTED_USERS_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_affected_users ADD CONSTRAINT AFH_AFFECTED_USERS_UK1 UNIQUE (ticket_id, user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_AFFECTED_USERS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_affected_users ADD CONSTRAINT AFH_AFFECTED_USERS_FK1 FOREIGN KEY (ticket_id) REFERENCES afh_tickets (ticket_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_AFFECTED_USERS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_affected_users ADD CONSTRAINT AFH_AFFECTED_USERS_FK2 FOREIGN KEY (user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
