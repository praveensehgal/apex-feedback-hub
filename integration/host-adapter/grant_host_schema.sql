-- Grant a HOST application's parsing schema the right to issue signed launch tokens.
-- Run as the Hub schema owner (AFH). The host schema name is a substitution variable:
--   sql -S -name AFH-AWS @grant_host_schema.sql AFH_HOST
-- or, inside an existing session:  DEFINE host_schema = AFH_HOST  then  @grant_host_schema.sql
--
-- AFH_LAUNCH_PKG is AUTHID DEFINER, so the host never needs privileges on Hub tables.
-- PL/SQL cannot grant a single subprogram: EXECUTE covers the whole package. The host
-- adapter (afh_host_pkg) only calls issue(); validate/consume are Hub page processes.
SET DEFINE ON
SET VERIFY OFF
DEFINE host_schema = &1
GRANT EXECUTE ON afh_launch_pkg TO &host_schema;
SELECT grantee, table_name, privilege
  FROM user_tab_privs_made
 WHERE table_name = 'AFH_LAUNCH_PKG'
   AND grantee = UPPER('&host_schema');
UNDEFINE host_schema
