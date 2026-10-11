-- =============================================================================
-- APEX Feedback Hub — uninstall (DESTRUCTIVE)
-- Run as the product schema (AFH). Removes every AFH_ object owned by this schema.
-- It does NOT remove the APEX application, the workspace, or the schema itself,
-- and it does NOT run from install.sql.
--
-- Required:  DEFINE afh_confirm_uninstall = 'YES'
-- Optional:  DEFINE afh_keep_data = 'YES'   -> drops packages/views/jobs only, keeps tables
--
-- Retained after a full uninstall: nothing in this schema. Back up first:
--   expdp ... schemas=AFH   (tables, BLOB attachments, audit history)
--   APEX application export (apex/application/)
-- =============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED
SET VERIFY OFF
WHENEVER SQLERROR EXIT FAILURE

DECLARE
  l_confirm VARCHAR2(10) := '&afh_confirm_uninstall';
  l_keep    VARCHAR2(10) := NVL('&afh_keep_data', 'NO');
  PROCEDURE drop_all(p_type IN VARCHAR2, p_like IN VARCHAR2, p_suffix IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    FOR r IN (SELECT object_name FROM user_objects
               WHERE object_type = p_type AND object_name LIKE p_like ESCAPE '\'
               ORDER BY object_name) LOOP
      BEGIN
        EXECUTE IMMEDIATE 'DROP ' || p_type || ' ' || r.object_name || ' ' || p_suffix;
        DBMS_OUTPUT.put_line('dropped ' || p_type || ' ' || r.object_name);
      EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('FAILED  ' || p_type || ' ' || r.object_name || ': ' || SQLERRM);
      END;
    END LOOP;
  END;
BEGIN
  IF l_confirm <> 'YES' THEN
    RAISE_APPLICATION_ERROR(-20910, 'AFH-INS-010: set DEFINE afh_confirm_uninstall = ''YES'' to uninstall');
  END IF;
  IF USER NOT LIKE 'AFH%' THEN
    RAISE_APPLICATION_ERROR(-20911, 'AFH-INS-011: run the uninstall as the product schema, not ' || USER);
  END IF;

  -- 1. scheduler jobs
  FOR r IN (SELECT job_name FROM user_scheduler_jobs WHERE job_name LIKE 'AFH\_JOB\_%' ESCAPE '\') LOOP
    DBMS_SCHEDULER.drop_job(r.job_name, force => TRUE);
    DBMS_OUTPUT.put_line('dropped JOB ' || r.job_name);
  END LOOP;
  -- 2. code and views
  drop_all('PACKAGE', 'AFH\_%');
  drop_all('VIEW',    'AFH\_V\_%');
  IF l_keep = 'YES' THEN
    DBMS_OUTPUT.put_line('afh_keep_data = YES: tables, triggers, sequences retained');
    RETURN;
  END IF;
  -- 3. data (destructive)
  drop_all('TABLE',    'AFH\_%', 'CASCADE CONSTRAINTS PURGE');
  drop_all('SEQUENCE', 'AFH\_%');
  DBMS_OUTPUT.put_line('uninstall complete');
END;
/
SELECT object_type, COUNT(*) AS remaining FROM user_objects WHERE object_name LIKE 'AFH%' GROUP BY object_type;
