-- AFH_JOB_WEEKLY_DIGEST: Builds one weekly digest mail per user with pending digest events
-- Created DISABLED; enable from the Administration page or with DBMS_SCHEDULER.enable('AFH_JOB_WEEKLY_DIGEST').
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_scheduler_jobs WHERE job_name = 'AFH_JOB_WEEKLY_DIGEST';
  IF l_cnt = 0 THEN
    DBMS_SCHEDULER.create_job(
      job_name        => 'AFH_JOB_WEEKLY_DIGEST',
      job_type        => 'PLSQL_BLOCK',
      job_action      => q'[BEGIN afh_notification_pkg.send_digests(WEEKLY); END;]',
      repeat_interval => 'FREQ=WEEKLY;BYDAY=MON;BYHOUR=6;BYMINUTE=0',
      enabled         => FALSE,
      auto_drop       => FALSE,
      comments        => 'Builds one weekly digest mail per user with pending digest events');
  END IF;
END;
/
