-- Indexes for AFH_NOTIFICATION_PREFS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_NOTIFICATION_PREFS_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_NOTIFICATION_PREFS_IX1 ON afh_notification_prefs (application_id)';
  END IF;
END;
/
