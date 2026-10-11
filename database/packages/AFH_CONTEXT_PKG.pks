CREATE OR REPLACE PACKAGE afh_context_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_CONTEXT_PKG — diagnostic context validation, sanitation, point-in-time
  -- storage, browser/server item comparison, capture results, restricted
  -- retrieval, and host-session server-state reads. Spec §13.3, §18, WU-05.
  -- Contexts and items are append-only; reads of values are authorized per call.
  -- ---------------------------------------------------------------------------

  c_res_success     CONSTANT VARCHAR2(30) := 'SUCCESS';
  c_res_partial     CONSTANT VARCHAR2(30) := 'PARTIAL';
  c_res_unsupported CONSTANT VARCHAR2(30) := 'UNSUPPORTED';
  c_res_failed      CONSTANT VARCHAR2(30) := 'FAILED';
  c_res_denied      CONSTANT VARCHAR2(30) := 'DENIED';

  -- One captured page item as returned to authorized readers
  TYPE t_item IS RECORD (
    context_item_id     NUMBER,
    item_name           VARCHAR2(255 CHAR),
    item_type           VARCHAR2(100 CHAR),
    browser_value       VARCHAR2(4000 CHAR),
    server_value        VARCHAR2(4000 CHAR),
    server_result_code  VARCHAR2(30 CHAR),
    is_changed          VARCHAR2(1 CHAR),
    capture_result_code VARCHAR2(30 CHAR),
    failure_reason      VARCHAR2(500 CHAR),
    exclusion_reason    VARCHAR2(100 CHAR));
  TYPE t_item_tab IS TABLE OF t_item;

  -- ----------------------------------------------------------------- sanitation
  -- TRUE when an item must be excluded (password item types, names matching
  -- afh_audit_pkg.is_sensitive_name, cookie/authorization headers, credentials).
  FUNCTION is_excluded_item(p_item_name IN VARCHAR2, p_item_type IN VARCHAR2) RETURN BOOLEAN;
  -- Redact token-like substrings (JWT-shaped, Bearer ..., long hex/base64 runs next to
  -- key/token/secret words) from free text such as debug output. Never alters other text.
  FUNCTION sanitize_text(p_text IN CLOB) RETURN CLOB;

  -- ----------------------------------------------------------------- server state (DG-04)
  -- Attach to the HOST application's session (same workspace, shared-session mode), read
  -- the page items of p_page_id with v(), and re-attach to the Hub session in both the
  -- normal and WHEN OTHERS paths. Returns a JSON array
  -- [{"name","type","serverValue","result"}], excluded items carry result EXCLUDED and no
  -- value. On any failure returns [] and sets o_result_code FAILED/UNAVAILABLE.
  FUNCTION read_host_session_items(
    p_host_session_id IN  NUMBER,
    p_host_app_id     IN  NUMBER,
    p_page_id         IN  NUMBER,
    o_result_code     OUT VARCHAR2) RETURN CLOB;

  -- ----------------------------------------------------------------- storage
  -- Store one capture for a ticket. p_items_json is a JSON array of
  -- {"name","type","browserValue","serverValue","serverResult"}; items are sanitized,
  -- compared (is_changed), and excluded ones stored with exclusion_reason and no values.
  -- Payloads over config CAPTURE_MAX_PAYLOAD_BYTES are truncated with partial_reason set
  -- and the result downgraded to PARTIAL. Writes audit CONTEXT_CAPTURED (non-public facts)
  -- and an integration CAPTURE event. Returns ticket_context_id.
  FUNCTION store_context(
    p_ticket_id              IN NUMBER,
    p_correlation_id         IN VARCHAR2,
    p_contract_version       IN VARCHAR2,
    p_capture_result_code    IN VARCHAR2,
    p_item_result_code       IN VARCHAR2,
    p_screenshot_result_code IN VARCHAR2,
    p_debug_result_code      IN VARCHAR2,
    p_client_meta_json       IN CLOB,      -- {"browser","browserVersion","os","device","viewport","locale","timeZone","apexVersion","requestMode"}
    p_source_meta_json       IN CLOB,      -- {"appKey","apexAppId","pageId","pageName","envCode","appVersion","sourceUrl"}
    p_items_json             IN CLOB,
    p_debug_payload          IN CLOB     DEFAULT NULL,
    p_partial_reason         IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  -- Overall result for the ticket from the three part results (spec §13.2 / §21 CTX-002).
  FUNCTION overall_result(
    p_item_result_code       IN VARCHAR2,
    p_screenshot_result_code IN VARCHAR2,
    p_debug_result_code      IN VARCHAR2) RETURN VARCHAR2;

  -- ----------------------------------------------------------------- authorized reads (developer for the app / admin)
  -- Each call runs afh_security_pkg.assert_can_view_restricted and writes a non-public
  -- CONTEXT_VIEWED audit event.
  FUNCTION get_items(p_ticket_context_id IN NUMBER) RETURN t_item_tab PIPELINED;
  FUNCTION get_payload(p_ticket_context_id IN NUMBER, p_part IN VARCHAR2) RETURN CLOB;  -- SOURCE_META | CLIENT_META | DEBUG | SANITIZED
  -- Latest context id for a ticket, or NULL.
  FUNCTION latest_context_id(p_ticket_id IN NUMBER) RETURN NUMBER;
  -- Counts for the public summary (no values): total, changed, excluded, failed.
  PROCEDURE item_counts(
    p_ticket_context_id IN  NUMBER,
    o_total             OUT NUMBER,
    o_changed           OUT NUMBER,
    o_excluded          OUT NUMBER,
    o_failed            OUT NUMBER);
END afh_context_pkg;
/
