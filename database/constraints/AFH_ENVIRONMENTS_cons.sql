-- Constraints for AFH_ENVIRONMENTS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ENVIRONMENTS_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_environments ADD CONSTRAINT AFH_ENVIRONMENTS_UK1 UNIQUE (application_id, env_code)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ENVIRONMENTS_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_environments ADD CONSTRAINT AFH_ENVIRONMENTS_FK1 FOREIGN KEY (application_id) REFERENCES afh_applications (application_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ENVIRONMENTS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_environments ADD CONSTRAINT AFH_ENVIRONMENTS_CK1 CHECK (REGEXP_LIKE(env_code, '^[A-Z][A-Z0-9_]{0,29}$'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_ENVIRONMENTS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_environments ADD CONSTRAINT AFH_ENVIRONMENTS_CK2 CHECK (is_active IN ('Y','N'))]';
  END IF;
END;
/
