-- Indexes for AFH_COMMENTS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_COMMENTS_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_COMMENTS_IX1 ON afh_comments (ticket_id, posted_at)';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_COMMENTS_IX2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_COMMENTS_IX2 ON afh_comments (author_user_id)';
  END IF;
END;
/
