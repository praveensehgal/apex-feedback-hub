-- Constraints for AFH_NOTIFICATION_PREFS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATION_PREFS_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notification_prefs ADD CONSTRAINT AFH_NOTIFICATION_PREFS_UK1 UNIQUE (user_id, application_id, event_code)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATION_PREFS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notification_prefs ADD CONSTRAINT AFH_NOTIFICATION_PREFS_FK1 FOREIGN KEY (user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATION_PREFS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notification_prefs ADD CONSTRAINT AFH_NOTIFICATION_PREFS_FK2 FOREIGN KEY (application_id) REFERENCES afh_applications (application_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATION_PREFS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notification_prefs ADD CONSTRAINT AFH_NOTIFICATION_PREFS_CK1 CHECK (preset_code IS NULL OR preset_code IN ('IMMEDIATE','IMPORTANT','DAILY','WEEKLY','IN_APP'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATION_PREFS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notification_prefs ADD CONSTRAINT AFH_NOTIFICATION_PREFS_CK2 CHECK (email_enabled IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATION_PREFS_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notification_prefs ADD CONSTRAINT AFH_NOTIFICATION_PREFS_CK3 CHECK (in_app_enabled IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATION_PREFS_CK4';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notification_prefs ADD CONSTRAINT AFH_NOTIFICATION_PREFS_CK4 CHECK (digest_frequency IS NULL OR digest_frequency IN ('NONE','DAILY','WEEKLY'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_NOTIFICATION_PREFS_CK5';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_notification_prefs ADD CONSTRAINT AFH_NOTIFICATION_PREFS_CK5 CHECK ((event_code IS NULL AND preset_code IS NOT NULL) OR (event_code IS NOT NULL))]';
  END IF;
END;
/
