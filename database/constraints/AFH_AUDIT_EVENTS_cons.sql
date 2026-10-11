-- Constraints for AFH_AUDIT_EVENTS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_AUDIT_EVENTS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_audit_events ADD CONSTRAINT AFH_AUDIT_EVENTS_FK1 FOREIGN KEY (ticket_id) REFERENCES afh_tickets (ticket_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_AUDIT_EVENTS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_audit_events ADD CONSTRAINT AFH_AUDIT_EVENTS_FK2 FOREIGN KEY (actor_user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_AUDIT_EVENTS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_audit_events ADD CONSTRAINT AFH_AUDIT_EVENTS_CK1 CHECK (REGEXP_LIKE(event_code, '^[A-Z][A-Z0-9_]{0,29}$'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_AUDIT_EVENTS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_audit_events ADD CONSTRAINT AFH_AUDIT_EVENTS_CK2 CHECK (is_public IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_AUDIT_EVENTS_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_audit_events ADD CONSTRAINT AFH_AUDIT_EVENTS_CK3 CHECK (before_facts IS NULL OR before_facts IS JSON)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_AUDIT_EVENTS_CK4';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_audit_events ADD CONSTRAINT AFH_AUDIT_EVENTS_CK4 CHECK (after_facts IS NULL OR after_facts IS JSON)]';
  END IF;
END;
/
