-- Indexes for AFH_TICKET_CONTEXTS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_TICKET_CONTEXTS_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_TICKET_CONTEXTS_IX1 ON afh_ticket_contexts (ticket_id)';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_TICKET_CONTEXTS_IX2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_TICKET_CONTEXTS_IX2 ON afh_ticket_contexts (correlation_id)';
  END IF;
END;
/
