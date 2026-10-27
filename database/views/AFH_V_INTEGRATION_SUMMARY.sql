-- AFH_V_INTEGRATION_SUMMARY: per-application adapter and handoff health (Pages 60, 67).
CREATE OR REPLACE FORCE VIEW afh_v_integration_summary AS
SELECT a.application_id, a.app_key, a.display_name AS application_name, a.identity_mode,
       a.adapter_version, NVL(a.min_adapter_version, afh_security_pkg.config_value('MIN_ADAPTER_VERSION')) AS min_adapter_version,
       afh_registry_int_pkg.is_adapter_supported_yn(a.application_id, a.adapter_version) AS adapter_supported_yn,
       (SELECT MAX(ie.event_at) FROM afh_integration_events ie WHERE ie.application_id = a.application_id AND ie.event_code = 'LAUNCH') AS last_launch_at,
       (SELECT COUNT(*) FROM afh_integration_events ie WHERE ie.application_id = a.application_id AND ie.event_code = 'LAUNCH' AND ie.event_at >= SYSTIMESTAMP - 7) AS launches_7d,
       (SELECT COUNT(*) FROM afh_integration_events ie WHERE ie.application_id = a.application_id AND ie.event_code = 'LAUNCH' AND ie.result_code IN ('FAILED', 'REJECTED', 'MISMATCH') AND ie.event_at >= SYSTIMESTAMP - 7) AS failures_7d,
       (SELECT COUNT(*) FROM afh_integration_events ie WHERE ie.application_id = a.application_id AND ie.event_code = 'CAPTURE' AND ie.result_code = 'PARTIAL' AND ie.event_at >= SYSTIMESTAMP - 7) AS partial_captures_7d,
       (SELECT COUNT(*) FROM afh_integration_events ie WHERE ie.application_id = a.application_id AND ie.event_code = 'MAIL' AND ie.result_code = 'FAILED' AND ie.event_at >= SYSTIMESTAMP - 7) AS mail_failures_7d,
       (SELECT COUNT(*) FROM afh_launch_handoffs h WHERE h.application_id = a.application_id AND h.issued_at >= SYSTIMESTAMP - 7) AS handoffs_7d,
       (SELECT COUNT(*) FROM afh_launch_handoffs h WHERE h.application_id = a.application_id AND h.result_code = 'CONSUMED' AND h.issued_at >= SYSTIMESTAMP - 7) AS tickets_from_handoffs_7d
  FROM afh_applications a
 WHERE a.is_active = 'Y';
COMMENT ON TABLE afh_v_integration_summary IS 'Adapter version, launch and failure counts per application for Integration Health';
