-- Indexes for AFH_SAVED_FILTERS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_SAVED_FILTERS_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_SAVED_FILTERS_IX1 ON afh_saved_filters (application_id)';
  END IF;
END;
/
