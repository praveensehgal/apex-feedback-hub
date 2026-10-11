-- AFH_HOST_PKG — the host-schema half of the APEX Feedback Hub launch adapter.
-- Installed in the HOST application's parsing schema (not in the Hub schema).
-- Prerequisite, run as the Hub schema owner: integration/host-adapter/grant_host_schema.sql
-- Install:  sql -S -name <HOST-CONN> @afh_host_pkg.pks  then  @afh_host_pkg.pkb
-- The body references the Hub schema through the substitution variable hub_schema
-- (DEFINE at the top of the .pkb, default AFH).
CREATE OR REPLACE PACKAGE afh_host_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- Everything here runs inside the HOST application's own APEX session. The
  -- authenticated subject is read from trusted session state
  -- (SYS_CONTEXT('APEX$SESSION','APP_USER')) and is never a parameter: the
  -- browser cannot choose who it is. Spec §13, design §4.1 (DG-01 signed path).
  -- ---------------------------------------------------------------------------

  c_adapter_version  CONSTANT VARCHAR2(20) := '1.0.0';
  c_mode_shared      CONSTANT VARCHAR2(30) := 'SHARED_SESSION';
  c_mode_signed      CONSTANT VARCHAR2(30) := 'SIGNED_ENVELOPE';
  c_hub_launch_page  CONSTANT NUMBER       := 20;

  -- Signed-envelope mode. Issues a one-time launch token for the current APP_USER by
  -- calling <hub>.afh_launch_pkg.issue. apexApp is apex_application.g_flow_id.
  -- Raises AFH-AUTH-001 when there is no authenticated APP_USER; AFH-VAL-001 from the
  -- Hub when the application/environment is not registered for signed launches.
  FUNCTION get_launch_token(
    p_app_key    IN VARCHAR2,
    p_env_code   IN VARCHAR2,
    p_page_id    IN NUMBER,
    p_page_name  IN VARCHAR2,
    p_source_url IN VARCHAR2) RETURN VARCHAR2;

  -- Relative URL for apex.navigation.dialog():
  --   SIGNED_ENVELOPE : f?p=<hub>:20:<session|0>::NO::P20_TOKEN:<token>
  --   SHARED_SESSION  : f?p=<hub>:20:<session>::NO::P20_CORR,P20_HOST_APP,P20_HOST_PAGE:<corr>,<app>,<page>
  -- p_session_id defaults to 0 (signed) or the current APEX session (shared). The Hub
  -- page items P20_TOKEN / P20_CORR / P20_HOST_APP / P20_HOST_PAGE must be Unrestricted
  -- (no checksum) for URL-set values to survive (HANDOFF §7, DG-02).
  FUNCTION hub_dialog_url(
    p_hub_app_id     IN NUMBER,
    p_mode           IN VARCHAR2 DEFAULT c_mode_signed,
    p_token          IN VARCHAR2 DEFAULT NULL,
    p_correlation_id IN VARCHAR2 DEFAULT NULL,
    p_session_id     IN NUMBER   DEFAULT NULL) RETURN VARCHAR2;

  -- Server-side item snapshot for signed (cross-workspace) mode, produced by an AJAX
  -- callback on the host Global Page and posted to the Hub by the adapter JS.
  -- JSON array of {"name","type","serverValue","result"} for the page items of
  -- p_page_id in the current application plus the application items. Items whose name
  -- or display type looks like a credential are emitted with result "EXCLUDED" and no
  -- serverValue (spec §13.3). Values are capped at 4000 characters. Any failure returns
  -- '[]' so a host page never breaks because of feedback capture.
  FUNCTION server_items_json(p_page_id IN NUMBER) RETURN CLOB;
END afh_host_pkg;
/
