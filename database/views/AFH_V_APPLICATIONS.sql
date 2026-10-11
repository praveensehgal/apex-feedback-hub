-- AFH_V_APPLICATIONS: registry list for Page 61. Never selects shared_secret.
CREATE OR REPLACE FORCE VIEW afh_v_applications AS
SELECT a.application_id,
       a.app_key,
       a.apex_app_id,
       a.display_name,
       a.owner_user_id,
       NVL(o.display_name, o.subject_display)                        AS owner_display_name,
       a.identity_mode,
       a.adapter_version,
       a.min_adapter_version,
       a.is_active,
       a.description,
       (SELECT COUNT(*) FROM afh_environments e
         WHERE e.application_id = a.application_id)                  AS environment_count,
       (SELECT COUNT(*) FROM afh_tickets t
         WHERE t.application_id = a.application_id
           AND t.is_archived = 'N'
           AND t.status_code NOT IN ('RESOLVED', 'CLOSED', 'DUPLICATE', 'REJECTED', 'CANNOT_REPRODUCE'))
                                                                     AS open_ticket_count,
       (SELECT MAX(t.last_activity_at) FROM afh_tickets t
         WHERE t.application_id = a.application_id)                  AS last_ticket_at,
       afh_registry_int_pkg.is_adapter_supported_yn(a.application_id, a.adapter_version)
                                                                     AS adapter_supported_yn,
       a.created_by,
       a.creation_date,
       a.last_updated_by,
       a.last_update_date
  FROM afh_applications a
  LEFT JOIN afh_users o ON o.user_id = a.owner_user_id;

COMMENT ON TABLE afh_v_applications IS 'Registered applications with owner, counts and adapter support for the Applications admin page (Page 61). Exposes no shared secret.';

