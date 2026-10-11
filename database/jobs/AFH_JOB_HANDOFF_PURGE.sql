-- AFH_JOB_HANDOFF_PURGE: Deletes launch handoff rows older than 24 hours
-- Created DISABLED; enable from the Administration page or with DBMS_SCHEDULER.enable('AFH_JOB_HANDOFF_PURGE').
DECLARE
  l_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_scheduler_jobs WHERE job_name = 'AFH_JOB_HANDOFF_PURGE';
  IF l_cnt = 0 THEN
    DBMS_SCHEDULER.create_job(
      job_name        => 'AFH_JOB_HANDOFF_PURGE',
      job_type        => 'PLSQL_BLOCK',
      job_action      => q'[DECLARE l_n NUMBER; BEGIN l_n := afh_launch_pkg.purge_expired; COMMIT; END;]',
      repeat_interval => 'FREQ=HOURLY',
      enabled         => FALSE,
      auto_drop       => FALSE,
      comments        => 'Deletes launch handoff rows older than 24 hours');
  END IF;
END;
/
