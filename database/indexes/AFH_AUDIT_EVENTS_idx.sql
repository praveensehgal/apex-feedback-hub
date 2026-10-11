-- Indexes for AFH_AUDIT_EVENTS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_AUDIT_EVENTS_IX1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_AUDIT_EVENTS_IX1 ON afh_audit_events (ticket_id, event_at)';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_AUDIT_EVENTS_IX2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_AUDIT_EVENTS_IX2 ON afh_audit_events (entity_type, entity_id)';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_AUDIT_EVENTS_IX3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_AUDIT_EVENTS_IX3 ON afh_audit_events (actor_user_id)';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_indexes WHERE index_name = 'AFH_AUDIT_EVENTS_IX4';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE INDEX AFH_AUDIT_EVENTS_IX4 ON afh_audit_events (event_at)';
  END IF;
END;
/
