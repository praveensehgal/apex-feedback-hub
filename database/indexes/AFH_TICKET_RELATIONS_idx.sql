-- Indexes for AFH_TICKET_RELATIONS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_TICKET_RELATIONS_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_TICKET_RELATIONS_IX1 ON afh_ticket_relations (source_ticket_id, relation_code, is_active)';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_TICKET_RELATIONS_IX2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_TICKET_RELATIONS_IX2 ON afh_ticket_relations (target_ticket_id)';
  END IF;
END;
/
