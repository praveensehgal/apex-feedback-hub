-- Constraints for AFH_TICKET_RELATIONS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TICKET_RELATIONS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_ticket_relations ADD CONSTRAINT AFH_TICKET_RELATIONS_FK1 FOREIGN KEY (source_ticket_id) REFERENCES afh_tickets (ticket_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TICKET_RELATIONS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_ticket_relations ADD CONSTRAINT AFH_TICKET_RELATIONS_FK2 FOREIGN KEY (target_ticket_id) REFERENCES afh_tickets (ticket_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TICKET_RELATIONS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_ticket_relations ADD CONSTRAINT AFH_TICKET_RELATIONS_CK1 CHECK (relation_code IN ('DUPLICATE_OF','RELATED','DEPENDS_ON','BLOCKS'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TICKET_RELATIONS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_ticket_relations ADD CONSTRAINT AFH_TICKET_RELATIONS_CK2 CHECK (is_active IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TICKET_RELATIONS_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_ticket_relations ADD CONSTRAINT AFH_TICKET_RELATIONS_CK3 CHECK (source_ticket_id <> target_ticket_id)]';
  END IF;
END;
/
