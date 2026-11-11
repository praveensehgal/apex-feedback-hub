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
-- E-mail addresses are stored lower-case and trimmed (afh_security_pkg.normalize_email).
-- Installs from before Release 1.0.61 may hold mixed-case addresses: normalize them first,
-- once, so the constraint can be added.
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_USERS_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[UPDATE afh_users SET email = SUBSTR(LOWER(TRIM(email)), 1, 320)
                          WHERE email IS NOT NULL
                            AND (TRIM(email) IS NULL OR email <> LOWER(TRIM(email)))]';
    COMMIT;
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_users ADD CONSTRAINT AFH_USERS_CK3 CHECK (email = LOWER(TRIM(email)))]';
  END IF;
END;
/
