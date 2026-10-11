-- AFH_V_RETENTION_RUNS: archive and deletion executions with labels (Page 66).
CREATE OR REPLACE FORCE VIEW afh_v_retention_runs AS
SELECT retention_run_id, policy_code,
       CASE policy_code WHEN 'ARCHIVE_CLOSED' THEN 'Archive closed tickets' WHEN 'PURGE_ATTACHMENTS' THEN 'Purge attachment bytes' WHEN 'DELETE_TICKETS' THEN 'Delete (anonymize) tickets' ELSE policy_code END AS policy_label,
       mode_code, started_at, completed_at, actor_subject, ticket_count, attachment_count, bytes_affected,
       ROUND(bytes_affected / 1048576, 1) AS mb_affected, result_code, error_detail, detail_json
  FROM afh_retention_runs;
COMMENT ON TABLE afh_v_retention_runs IS 'Retention preview and execution runs';
