-- Pre-flight checks. Any failure aborts the install before the first object is created.
DECLARE
  l_db_version    VARCHAR2(30);
  l_apex_version  VARCHAR2(30);
  l_installed_ver VARCHAR2(30);
  l_cnt           PLS_INTEGER;
  l_crypto        PLS_INTEGER;
BEGIN
  -- Database 19c or later
  SELECT version INTO l_db_version FROM product_component_version WHERE product LIKE 'Oracle%Database%' AND ROWNUM = 1;
  IF TO_NUMBER(REGEXP_SUBSTR(l_db_version, '^\d+')) < 19 THEN
    RAISE_APPLICATION_ERROR(-20901, 'AFH-INS-001: Oracle Database 19c or later is required, found ' || l_db_version);
  END IF;

  -- APEX 24.2 or later
  BEGIN
    EXECUTE IMMEDIATE 'SELECT version_no FROM apex_release' INTO l_apex_version;
  EXCEPTION WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20902, 'AFH-INS-002: Oracle APEX is not installed or not visible to this schema');
  END;
  IF TO_NUMBER(REGEXP_SUBSTR(l_apex_version, '^\d+')) * 100 + TO_NUMBER(REGEXP_SUBSTR(l_apex_version, '^\d+\.(\d+)', 1, 1, NULL, 1)) < 2402 THEN
    RAISE_APPLICATION_ERROR(-20903, 'AFH-INS-003: Oracle APEX 24.2 or later is required, found ' || l_apex_version);
  END IF;

  -- DBMS_CRYPTO execute privilege (needed by the signed-envelope identity path)
  SELECT COUNT(*) INTO l_crypto FROM all_tab_privs
   WHERE table_name = 'DBMS_CRYPTO' AND privilege = 'EXECUTE' AND grantee IN (USER, 'PUBLIC');
  IF l_crypto = 0 THEN
    RAISE_APPLICATION_ERROR(-20904, 'AFH-INS-004: GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ' || USER || ' is required');
  END IF;

  -- Same-version re-run is allowed; a different installed version must go through upgrades/
  SELECT COUNT(*) INTO l_cnt FROM user_tables WHERE table_name = 'AFH_INSTALL_CONFIG';
  IF l_cnt = 1 THEN
    BEGIN
      EXECUTE IMMEDIATE q'[SELECT config_value FROM afh_install_config WHERE config_key = 'PRODUCT_VERSION']' INTO l_installed_ver;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_installed_ver := NULL;   -- tables exist but seed never ran: treat as a fresh install
    END;
    IF l_installed_ver IS NOT NULL AND l_installed_ver <> '&afh_product_version' THEN
      RAISE_APPLICATION_ERROR(-20905, 'AFH-INS-005: version ' || l_installed_ver || ' is installed; run database/upgrades to reach &afh_product_version');
    END IF;
  END IF;

  DBMS_OUTPUT.put_line('prereq ok: database ' || l_db_version || ', apex ' || l_apex_version || ', schema ' || USER);
END;
/
