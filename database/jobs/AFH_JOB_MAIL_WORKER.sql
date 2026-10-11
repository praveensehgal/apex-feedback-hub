-- AFH_JOB_MAIL_WORKER: Sends queued e-mail notifications; no-op while MAIL_ENABLED = N
-- Created DISABLED; enable from the Administration page or with DBMS_SCHEDULER.enable('AFH_JOB_MAIL_WORKER').
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_scheduler_jobs WHERE job_name = 'AFH_JOB_MAIL_WORKER';
  IF l_cnt = 0 THEN
    DBMS_SCHEDULER.create_job(
      job_name        => 'AFH_JOB_MAIL_WORKER',
      job_type        => 'PLSQL_BLOCK',
      job_action      => q'[BEGIN afh_notification_pkg.process_mail_queue; END;]',
      repeat_interval => 'FREQ=MINUTELY;INTERVAL=2',
      enabled         => FALSE,
      auto_drop       => FALSE,
      comments        => 'Sends queued e-mail notifications; no-op while MAIL_ENABLED = N');
  END IF;
END;
/
