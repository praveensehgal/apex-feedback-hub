-- Constraints for AFH_USER_ROLES
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_USER_ROLES_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_user_roles ADD CONSTRAINT AFH_USER_ROLES_UK1 UNIQUE (user_id, role_code, application_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_USER_ROLES_FK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_user_roles ADD CONSTRAINT AFH_USER_ROLES_FK1 FOREIGN KEY (user_id) REFERENCES afh_users (user_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_USER_ROLES_FK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_user_roles ADD CONSTRAINT AFH_USER_ROLES_FK2 FOREIGN KEY (application_id) REFERENCES afh_applications (application_id)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_USER_ROLES_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_user_roles ADD CONSTRAINT AFH_USER_ROLES_CK1 CHECK (role_code IN ('USER','TESTER','DEVELOPER','APP_OWNER','AFH_ADMIN'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_USER_ROLES_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_user_roles ADD CONSTRAINT AFH_USER_ROLES_CK2 CHECK (expiration_date IS NULL OR effective_date IS NULL OR expiration_date > effective_date)]';
  END IF;
END;
/
