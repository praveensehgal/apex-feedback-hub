CREATE OR REPLACE PACKAGE afh_launch_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_LAUNCH_PKG — trusted launch handoff: envelope issue (signed mode),
  -- validation in the spec §13.4 order, nonce/expiry, idempotent retry, and
  -- handoff bookkeeping. Spec §13, DG-01, DG-02, WU-06.
  -- EXECUTE on this package is granted to host schemas for issue() only via the
  -- AFH_HOST_PKG wrapper; everything else is called by Hub page processes.
  -- ---------------------------------------------------------------------------

  c_contract_version CONSTANT VARCHAR2(10) := '1.0';

  -- Everything a validated launch tells Page 20
  TYPE t_launch IS RECORD (
    correlation_id     VARCHAR2(64 CHAR),
    application_id     NUMBER,
    app_key            VARCHAR2(30 CHAR),
    application_name   VARCHAR2(255 CHAR),
    apex_app_id        NUMBER,
    environment_id     NUMBER,
    env_code           VARCHAR2(30 CHAR),
    env_label          VARCHAR2(255 CHAR),
    app_version        VARCHAR2(50 CHAR),
    identity_mode      VARCHAR2(30 CHAR),
    subject_canonical  VARCHAR2(255 CHAR),
    user_id            NUMBER,
    page_id            NUMBER,
    page_name          VARCHAR2(255 CHAR),
    source_url         VARCHAR2(2000 CHAR),
    host_session_id    NUMBER,              -- shared-session mode only
    result_code        VARCHAR2(30 CHAR),   -- VALIDATED | REJECTED
    error_code         VARCHAR2(12 CHAR),   -- AFH-CTX-001 / 003, AFH-AUTH-001 ... when REJECTED
    error_message      VARCHAR2(500 CHAR));

  -- ----------------------------------------------------------------- signed-envelope mode (host schema calls via AFH_HOST_PKG)
  -- Issue a one-time token for p_subject (the HOST's authenticated APP_USER, supplied by
  -- trusted host PL/SQL, never by the browser). Token = b64url(json) || '.' || b64url(hmac).
  -- JSON: {"v","cid","nonce","iat","exp","sub","app","apexApp","page","pageName","env","url"}.
  -- Writes the afh_launch_handoffs row (ISSUED). exp = iat + config HANDOFF_TTL_SECONDS (<=120).
  FUNCTION issue(
    p_app_key     IN VARCHAR2,
    p_subject     IN VARCHAR2,
    p_env_code    IN VARCHAR2,
    p_apex_app_id IN NUMBER,
    p_page_id     IN NUMBER,
    p_page_name   IN VARCHAR2,
    p_source_url  IN VARCHAR2) RETURN VARCHAR2;

  -- ----------------------------------------------------------------- validation (Page 20 load)
  -- Validates in spec §13.4 order 1-5 and returns a t_launch. Never raises for a bad
  -- launch: result_code = REJECTED with error_code/message, integration LAUNCH event
  -- written (autonomous on rejection), so the page can show the safe message.
  --   Signed mode: p_token present -> signature, contract, expiry, nonce unused, registry,
  --                URL policy. Subject = signed subject; user row ensured.
  --   Shared mode: p_token NULL -> p_host_session_id must equal the current APEX session
  --                (same workspace), APEX_SESSION state for p_apex_app_id must belong to the
  --                same APP_USER, registry + env + URL policy. Subject = current APP_USER.
  --                A handoff row is created with correlation p_correlation_id (or a new one).
  -- Marks the handoff VALIDATED and sets afh_audit_pkg.set_correlation_id.
  FUNCTION validate(
    p_token           IN VARCHAR2 DEFAULT NULL,
    p_correlation_id  IN VARCHAR2 DEFAULT NULL,
    p_host_session_id IN NUMBER   DEFAULT NULL,
    p_apex_app_id     IN NUMBER   DEFAULT NULL,
    p_app_key         IN VARCHAR2 DEFAULT NULL,
    p_env_code        IN VARCHAR2 DEFAULT NULL,
    p_page_id         IN NUMBER   DEFAULT NULL,
    p_page_name       IN VARCHAR2 DEFAULT NULL,
    p_source_url      IN VARCHAR2 DEFAULT NULL,
    p_adapter_version IN VARCHAR2 DEFAULT NULL) RETURN t_launch;

  -- Re-read a VALIDATED, unconsumed, unexpired handoff for the current user (Page 20 steps
  -- 2-3 and submit). Raises AFH-CTX-001 when it is missing, expired, consumed by another
  -- ticket, or belongs to another subject.
  FUNCTION get_validated(p_correlation_id IN VARCHAR2) RETURN t_launch;

  -- Mark the handoff CONSUMED by p_ticket_id and write the integration LAUNCH OK event.
  -- Same transaction as ticket creation.
  PROCEDURE consume(p_correlation_id IN VARCHAR2, p_ticket_id IN NUMBER);

  -- Ticket already created for this correlation ID (idempotent retry), or NULL.
  FUNCTION ticket_for_correlation(p_correlation_id IN VARCHAR2) RETURN NUMBER;

  -- Delete handoff rows older than 24 hours (job). Returns rows removed.
  FUNCTION purge_expired RETURN NUMBER;
END afh_launch_pkg;
/
