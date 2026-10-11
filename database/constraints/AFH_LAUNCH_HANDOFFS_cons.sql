-- Constraints for AFH_LAUNCH_HANDOFFS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_LAUNCH_HANDOFFS_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_launch_handoffs ADD CONSTRAINT AFH_LAUNCH_HANDOFFS_UK1 UNIQUE (correlation_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_LAUNCH_HANDOFFS_UK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_launch_handoffs ADD CONSTRAINT AFH_LAUNCH_HANDOFFS_UK2 UNIQUE (nonce)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_LAUNCH_HANDOFFS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_launch_handoffs ADD CONSTRAINT AFH_LAUNCH_HANDOFFS_FK1 FOREIGN KEY (application_id) REFERENCES afh_applications (application_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_LAUNCH_HANDOFFS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_launch_handoffs ADD CONSTRAINT AFH_LAUNCH_HANDOFFS_FK2 FOREIGN KEY (environment_id) REFERENCES afh_environments (environment_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_LAUNCH_HANDOFFS_FK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_launch_handoffs ADD CONSTRAINT AFH_LAUNCH_HANDOFFS_FK3 FOREIGN KEY (ticket_id) REFERENCES afh_tickets (ticket_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_LAUNCH_HANDOFFS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_launch_handoffs ADD CONSTRAINT AFH_LAUNCH_HANDOFFS_CK1 CHECK (expires_at > issued_at)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_LAUNCH_HANDOFFS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_launch_handoffs ADD CONSTRAINT AFH_LAUNCH_HANDOFFS_CK2 CHECK (identity_mode IN ('SHARED_SESSION','SIGNED_ENVELOPE'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_LAUNCH_HANDOFFS_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_launch_handoffs ADD CONSTRAINT AFH_LAUNCH_HANDOFFS_CK3 CHECK (result_code IS NULL OR result_code IN ('ISSUED','VALIDATED','CONSUMED','EXPIRED','REPLAYED','REJECTED'))]';
  END IF;
END;
/
