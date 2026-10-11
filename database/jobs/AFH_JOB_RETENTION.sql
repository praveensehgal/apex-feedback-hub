-- AFH_JOB_RETENTION: Retention preview every night; executes archive/purge only when RETENTION_JOB_ARMED = Y
-- Created DISABLED; enable from the Administration page or with DBMS_SCHEDULER.enable('AFH_JOB_RETENTION').
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_scheduler_jobs WHERE job_name = 'AFH_JOB_RETENTION';
  IF l_cnt = 0 THEN
    DBMS_SCHEDULER.create_job(
      job_name        => 'AFH_JOB_RETENTION',
      job_type        => 'PLSQL_BLOCK',
      job_action      => q'[BEGIN afh_retention_pkg.scheduled_run; END;]',
      repeat_interval => 'FREQ=DAILY;BYHOUR=2;BYMINUTE=0',
      enabled         => FALSE,
      auto_drop       => FALSE,
      comments        => 'Retention preview every night; executes archive/purge only when RETENTION_JOB_ARMED = Y');
  END IF;
END;
/
