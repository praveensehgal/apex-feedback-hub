-- Saved filters visible to the current user: their own plus filters shared by others.
-- Per-user view: filtered on afh_security_pkg.current_user_id.
CREATE OR REPLACE FORCE VIEW afh_v_saved_filters AS
SELECT sf.saved_filter_id,
       sf.owner_user_id,
       NVL(u.display_name, u.subject_display)  AS owner_display_name,
       sf.scope_code,
       sf.filter_name,
       sf.filter_json,
       sf.is_shared,
       sf.application_id,
       CASE WHEN sf.owner_user_id = afh_security_pkg.current_user_id THEN 'Y' ELSE 'N' END AS is_mine_yn
  FROM afh_saved_filters sf
  LEFT JOIN afh_users u ON u.user_id = sf.owner_user_id
 WHERE sf.owner_user_id = afh_security_pkg.current_user_id
    OR sf.is_shared = 'Y';

COMMENT ON TABLE afh_v_saved_filters IS 'Saved filters for the current user: own filters plus shared ones (Pages 2 and 30).';

