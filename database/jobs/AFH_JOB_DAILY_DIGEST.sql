-- AFH_JOB_DAILY_DIGEST: Builds one daily digest mail per user with pending digest events
-- Created DISABLED; enable from the Administration page or with DBMS_SCHEDULER.enable('AFH_JOB_DAILY_DIGEST').
-- An existing job keeps its enabled state and schedule; only a wrong action is corrected
-- (releases up to 1.0.59 passed DAILY unquoted, so every run failed with PLS-00201).
DECLARE
  c_action CONSTANT VARCHAR2(200) := q'[BEGIN afh_notification_pkg.send_digests('DAILY'); END;]';
  l_action user_scheduler_jobs.job_action%TYPE;
BEGIN
  SELECT MAX(job_action) INTO l_action FROM user_scheduler_jobs WHERE job_name = 'AFH_JOB_DAILY_DIGEST';
  IF l_action IS NULL THEN
    DBMS_SCHEDULER.create_job(
      job_name        => 'AFH_JOB_DAILY_DIGEST',
      job_type        => 'PLSQL_BLOCK',
      job_action      => c_action,
      repeat_interval => 'FREQ=DAILY;BYHOUR=6;BYMINUTE=0',
      enabled         => FALSE,
      auto_drop       => FALSE,
      comments        => 'Builds one daily digest mail per user with pending digest events');
  ELSIF l_action <> c_action THEN
    DBMS_SCHEDULER.set_attribute('AFH_JOB_DAILY_DIGEST', 'job_action', c_action);
  END IF;
END;
/
