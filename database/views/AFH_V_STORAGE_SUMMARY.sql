-- AFH_V_STORAGE_SUMMARY: attachment storage per kind (Page 66).
CREATE OR REPLACE FORCE VIEW afh_v_storage_summary AS
SELECT kind_code, file_count, total_bytes, restricted_count, oldest_at,
       ROUND(total_bytes / 1048576, 1) AS total_mb
  FROM TABLE(afh_retention_pkg.storage_summary);
COMMENT ON TABLE afh_v_storage_summary IS 'Attachment counts and bytes by kind';
