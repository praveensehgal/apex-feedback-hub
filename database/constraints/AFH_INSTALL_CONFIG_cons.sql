-- Constraints for AFH_INSTALL_CONFIG
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_INSTALL_CONFIG_UK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_install_config ADD CONSTRAINT AFH_INSTALL_CONFIG_UK1 UNIQUE (config_key)]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_INSTALL_CONFIG_CK1';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_install_config ADD CONSTRAINT AFH_INSTALL_CONFIG_CK1 CHECK (REGEXP_LIKE(config_key, '^[A-Z][A-Z0-9_]{0,29}$'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_INSTALL_CONFIG_CK2';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_install_config ADD CONSTRAINT AFH_INSTALL_CONFIG_CK2 CHECK (data_type IN ('TEXT','NUMBER','YN','URL','COLOR','LENGTH','FONT','LIST'))]';
  END IF;
END;
/
-- Decision 007 admitted LENGTH and FONT. An installation created before that decision
-- already holds CK2 without them, so the guarded block above will not fire; replace it
-- in place when the installed definition is the older one. SEARCH_CONDITION_VC is 12.2+
-- and therefore available on the 19c compatibility floor.
DECLARE
  l_cond user_constraints.search_condition_vc%TYPE;
BEGIN
  SELECT search_condition_vc INTO l_cond
    FROM user_constraints WHERE constraint_name = 'AFH_INSTALL_CONFIG_CK2';
  IF INSTR(UPPER(l_cond), '''FONT''') = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_install_config DROP CONSTRAINT AFH_INSTALL_CONFIG_CK2]';
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_install_config ADD CONSTRAINT AFH_INSTALL_CONFIG_CK2 CHECK (data_type IN ('TEXT','NUMBER','YN','URL','COLOR','LENGTH','FONT','LIST'))]';
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;   -- fresh install: the guarded block above already created it
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_INSTALL_CONFIG_CK3';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_install_config ADD CONSTRAINT AFH_INSTALL_CONFIG_CK3 CHECK (is_secret IN ('Y','N'))]';
  END IF;
END;
/
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_constraints WHERE constraint_name = 'AFH_INSTALL_CONFIG_CK4';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE afh_install_config ADD CONSTRAINT AFH_INSTALL_CONFIG_CK4 CHECK (is_editable IN ('Y','N'))]';
  END IF;
END;
/
