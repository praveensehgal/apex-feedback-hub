-- AFH_V_CONFIG_SUMMARY: installation settings for Page 60. Secret values are masked.
CREATE OR REPLACE FORCE VIEW afh_v_config_summary AS
SELECT c.config_id,
       c.config_key,
       CASE WHEN c.is_secret = 'Y' AND c.config_value IS NOT NULL THEN '********' ELSE c.config_value END AS display_value,
       c.data_type,
       c.description,
       c.is_secret,
       c.is_editable,
       c.last_updated_by,
       c.last_update_date
  FROM afh_install_config c;
COMMENT ON TABLE afh_v_config_summary IS 'Installation configuration keys with masked secret values for the administration page';
