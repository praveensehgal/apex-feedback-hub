-- Constraints for AFH_FOLLOWERS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_FOLLOWERS_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_followers ADD CONSTRAINT AFH_FOLLOWERS_UK1 UNIQUE (ticket_id, user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_FOLLOWERS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_followers ADD CONSTRAINT AFH_FOLLOWERS_FK1 FOREIGN KEY (ticket_id) REFERENCES afh_tickets (ticket_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_FOLLOWERS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_followers ADD CONSTRAINT AFH_FOLLOWERS_FK2 FOREIGN KEY (user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_FOLLOWERS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_followers ADD CONSTRAINT AFH_FOLLOWERS_CK1 CHECK (follow_source_code IN ('REPORTER','MANUAL','MENTION','ASSIGNMENT','COMMENT','AFFECTED','MERGE','TEST'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_FOLLOWERS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_followers ADD CONSTRAINT AFH_FOLLOWERS_CK2 CHECK (is_muted IN ('Y','N'))]';
  END IF;
END;
/
