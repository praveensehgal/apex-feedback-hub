-- AFH_JOB_AUTO_CLOSE: Closes RESOLVED tickets older than AUTO_CLOSE_DAYS
-- Created DISABLED; enable from the Administration page or with DBMS_SCHEDULER.enable('AFH_JOB_AUTO_CLOSE').
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_scheduler_jobs WHERE job_name = 'AFH_JOB_AUTO_CLOSE';
  IF l_cnt = 0 THEN
    DBMS_SCHEDULER.create_job(
      job_name        => 'AFH_JOB_AUTO_CLOSE',
      job_type        => 'PLSQL_BLOCK',
      job_action      => q'[BEGIN afh_workflow_pkg.auto_close_resolved; COMMIT; END;]',
      repeat_interval => 'FREQ=DAILY;BYHOUR=1;BYMINUTE=0',
      enabled         => FALSE,
      auto_drop       => FALSE,
      comments        => 'Closes RESOLVED tickets older than AUTO_CLOSE_DAYS');
  END IF;
END;
/
