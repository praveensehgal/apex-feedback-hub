-- AFH_V_INTEGRATION_HEALTH: handoff, capture and mail events of the last 30 days (Page 67).
CREATE OR REPLACE FORCE VIEW afh_v_integration_health AS
SELECT ie.integration_event_id, ie.event_at, ie.event_code, ie.result_code,
       CASE ie.result_code WHEN 'OK' THEN 'success' WHEN 'PARTIAL' THEN 'warning' ELSE 'danger' END AS severity,
       ie.application_id, NVL(a.display_name, ie.app_key) AS application_name, ie.app_key,
       ie.environment_id, e.env_code, ie.correlation_id, ie.adapter_version, ie.safe_detail
  FROM afh_integration_events ie
  LEFT JOIN afh_applications a ON a.application_id = ie.application_id
  LEFT JOIN afh_environments e ON e.environment_id = ie.environment_id
 WHERE ie.event_at >= SYSTIMESTAMP - 30;
COMMENT ON TABLE afh_v_integration_health IS 'Integration events of the last 30 days with application labels and a severity token';
