-- Indexes for AFH_COMMENT_REVISIONS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_COMMENT_REVISIONS_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_COMMENT_REVISIONS_IX1 ON afh_comment_revisions (edited_by_user_id)';
  END IF;
END;
/
