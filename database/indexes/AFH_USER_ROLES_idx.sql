-- Indexes for AFH_USER_ROLES
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_USER_ROLES_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_USER_ROLES_IX1 ON afh_user_roles (application_id)';
  END IF;
END;
/
