-- AFH_V_RELEASES: releases with ticket counts for Page 40.
CREATE OR REPLACE FORCE VIEW afh_v_releases AS
SELECT r.release_id,
       r.application_id,
       a.app_key,
       a.display_name                                                AS application_name,
       r.release_code,
       r.label,
       r.target_date,
       r.completed_date,
       r.state_code,
       r.notes,
       (SELECT COUNT(*) FROM afh_tickets t
         WHERE t.release_id = r.release_id)                          AS ticket_count,
       afh_registry_pkg.unresolved_ticket_count(r.release_id)       AS unresolved_count,
       (SELECT COUNT(*) FROM afh_tickets t
         WHERE t.release_id = r.release_id
           AND t.status_code IN ('RESOLVED', 'CLOSED', 'DUPLICATE', 'REJECTED', 'CANNOT_REPRODUCE'))
                                                                     AS resolved_count,
       r.created_by,
       r.creation_date,
       r.last_updated_by,
       r.last_update_date
  FROM afh_releases r
  JOIN afh_applications a ON a.application_id = r.application_id;

COMMENT ON TABLE afh_v_releases IS 'Releases per application with total, unresolved and resolved ticket counts for the Releases page (Page 40).';

