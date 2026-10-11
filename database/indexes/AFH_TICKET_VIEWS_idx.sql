-- Indexes for AFH_TICKET_VIEWS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_TICKET_VIEWS_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_TICKET_VIEWS_IX1 ON afh_ticket_views (ticket_id)';
  END IF;
END;
/
