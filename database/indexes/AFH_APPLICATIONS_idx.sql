-- Indexes for AFH_APPLICATIONS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_APPLICATIONS_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_APPLICATIONS_IX1 ON afh_applications (owner_user_id)';
  END IF;
END;
/
