-- Constraints for AFH_CONTEXT_ITEMS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_CONTEXT_ITEMS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_context_items ADD CONSTRAINT AFH_CONTEXT_ITEMS_FK1 FOREIGN KEY (ticket_context_id) REFERENCES afh_ticket_contexts (ticket_context_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_CONTEXT_ITEMS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_context_items ADD CONSTRAINT AFH_CONTEXT_ITEMS_CK1 CHECK (server_result_code IN ('AVAILABLE','UNAVAILABLE','FAILED','EXCLUDED'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_CONTEXT_ITEMS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_context_items ADD CONSTRAINT AFH_CONTEXT_ITEMS_CK2 CHECK (is_changed IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_CONTEXT_ITEMS_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_context_items ADD CONSTRAINT AFH_CONTEXT_ITEMS_CK3 CHECK (capture_result_code IN ('SUCCESS','EXCLUDED','FAILED'))]';
  END IF;
END;
/
