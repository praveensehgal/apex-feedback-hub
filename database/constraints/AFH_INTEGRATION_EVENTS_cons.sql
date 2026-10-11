-- Constraints for AFH_INTEGRATION_EVENTS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_INTEGRATION_EVENTS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_integration_events ADD CONSTRAINT AFH_INTEGRATION_EVENTS_FK1 FOREIGN KEY (application_id) REFERENCES afh_applications (application_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_INTEGRATION_EVENTS_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_integration_events ADD CONSTRAINT AFH_INTEGRATION_EVENTS_FK2 FOREIGN KEY (environment_id) REFERENCES afh_environments (environment_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_INTEGRATION_EVENTS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_integration_events ADD CONSTRAINT AFH_INTEGRATION_EVENTS_CK1 CHECK (event_code IN ('LAUNCH','CAPTURE','MAIL','ADAPTER_INIT','VERSION'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_INTEGRATION_EVENTS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_integration_events ADD CONSTRAINT AFH_INTEGRATION_EVENTS_CK2 CHECK (result_code IN ('OK','PARTIAL','FAILED','REJECTED','MISMATCH'))]';
  END IF;
END;
/
