-- Indexes for AFH_AFFECTED_USERS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_AFFECTED_USERS_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_AFFECTED_USERS_IX1 ON afh_affected_users (user_id)';
  END IF;
END;
/
