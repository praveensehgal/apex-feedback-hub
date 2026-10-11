-- Constraints for AFH_USERS
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_USERS_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_users ADD CONSTRAINT AFH_USERS_UK1 UNIQUE (subject_canonical)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_USERS_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_users ADD CONSTRAINT AFH_USERS_CK1 CHECK (is_active IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_USERS_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_users ADD CONSTRAINT AFH_USERS_CK2 CHECK (subject_canonical = UPPER(TRIM(subject_canonical)))]';
  END IF;
END;
/
