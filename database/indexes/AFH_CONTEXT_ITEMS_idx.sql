-- Indexes for AFH_CONTEXT_ITEMS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_CONTEXT_ITEMS_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_CONTEXT_ITEMS_IX1 ON afh_context_items (ticket_context_id)';
  END IF;
END;
/
