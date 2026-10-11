-- Constraints for AFH_NOTIFICATIONS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATIONS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notifications ADD CONSTRAINT AFH_NOTIFICATIONS_FK1 FOREIGN KEY (recipient_user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATIONS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notifications ADD CONSTRAINT AFH_NOTIFICATIONS_FK2 FOREIGN KEY (ticket_id) REFERENCES afh_tickets (ticket_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATIONS_FK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notifications ADD CONSTRAINT AFH_NOTIFICATIONS_FK3 FOREIGN KEY (actor_user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATIONS_FK4';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notifications ADD CONSTRAINT AFH_NOTIFICATIONS_FK4 FOREIGN KEY (task_id) REFERENCES afh_tasks (task_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATIONS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notifications ADD CONSTRAINT AFH_NOTIFICATIONS_CK1 CHECK (channel_code IN ('IN_APP','EMAIL','DIGEST'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATIONS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notifications ADD CONSTRAINT AFH_NOTIFICATIONS_CK2 CHECK (state_code IN ('NEW','READ','QUEUED','SENT','FAILED','SKIPPED_DISABLED','DIGESTED','CANCELLED'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATIONS_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notifications ADD CONSTRAINT AFH_NOTIFICATIONS_CK3 CHECK (digest_frequency IS NULL OR digest_frequency IN ('DAILY','WEEKLY'))]';
  END IF;
END;
/
