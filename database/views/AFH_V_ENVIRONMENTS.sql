-- AFH_V_ENVIRONMENTS: environments per application for Page 61/62.
CREATE OR REPLACE FORCE VIEW afh_v_environments AS
SELECT e.environment_id,
       e.application_id,
       a.app_key,
       a.display_name                                                AS application_name,
       e.env_code,
       e.label,
       e.source_identifier,
       e.base_url_pattern,
       e.app_version,
       e.is_active,
       e.display_seq,
       (SELECT COUNT(*) FROM afh_tickets t
         WHERE t.environment_id = e.environment_id
           AND t.is_archived = 'N'
           AND t.status_code NOT IN ('RESOLVED', 'CLOSED', 'DUPLICATE', 'REJECTED', 'CANNOT_REPRODUCE'))
                                                                     AS open_ticket_count,
       e.created_by,
       e.creation_date,
       e.last_updated_by,
       e.last_update_date
  FROM afh_environments e
  JOIN afh_applications a ON a.application_id = e.application_id;

COMMENT ON TABLE afh_v_environments IS 'Source environments with their application key/name and open-ticket count for the registry admin pages.';

