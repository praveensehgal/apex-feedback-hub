-- Constraints for AFH_TICKET_FIELD_VALUES
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TICKET_FIELD_VALUES_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_ticket_field_values ADD CONSTRAINT AFH_TICKET_FIELD_VALUES_UK1 UNIQUE (ticket_id, field_definition_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TICKET_FIELD_VALUES_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_ticket_field_values ADD CONSTRAINT AFH_TICKET_FIELD_VALUES_FK1 FOREIGN KEY (ticket_id) REFERENCES afh_tickets (ticket_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_TICKET_FIELD_VALUES_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_ticket_field_values ADD CONSTRAINT AFH_TICKET_FIELD_VALUES_FK2 FOREIGN KEY (field_definition_id) REFERENCES afh_field_definitions (field_definition_id)]';
  END IF;
END;
/
