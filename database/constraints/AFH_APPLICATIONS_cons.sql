-- Constraints for AFH_APPLICATIONS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_APPLICATIONS_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_applications ADD CONSTRAINT AFH_APPLICATIONS_UK1 UNIQUE (app_key)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_APPLICATIONS_UK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_applications ADD CONSTRAINT AFH_APPLICATIONS_UK2 UNIQUE (apex_app_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_APPLICATIONS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_applications ADD CONSTRAINT AFH_APPLICATIONS_FK1 FOREIGN KEY (owner_user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_APPLICATIONS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_applications ADD CONSTRAINT AFH_APPLICATIONS_CK1 CHECK (REGEXP_LIKE(app_key, '^[A-Z][A-Z0-9_]{0,29}$'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_APPLICATIONS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_applications ADD CONSTRAINT AFH_APPLICATIONS_CK2 CHECK (identity_mode IN ('SHARED_SESSION','SIGNED_ENVELOPE'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_APPLICATIONS_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_applications ADD CONSTRAINT AFH_APPLICATIONS_CK3 CHECK (is_active IN ('Y','N'))]';
  END IF;
END;
/
