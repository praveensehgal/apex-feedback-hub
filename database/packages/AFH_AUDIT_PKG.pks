CREATE OR REPLACE PACKAGE afh_audit_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_AUDIT_PKG — immutable event creation, safe before/after facts,
  -- correlation IDs, integration-health events. Spec §12, §20.
  -- No authorization of its own: callers are package APIs that already checked.
  -- ---------------------------------------------------------------------------

  -- Entity type codes used in afh_audit_events.entity_type
  c_entity_ticket        CONSTANT VARCHAR2(30) := 'TICKET';
  c_entity_comment       CONSTANT VARCHAR2(30) := 'COMMENT';
  c_entity_attachment    CONSTANT VARCHAR2(30) := 'ATTACHMENT';
  c_entity_context       CONSTANT VARCHAR2(30) := 'CONTEXT';
  c_entity_test          CONSTANT VARCHAR2(30) := 'TEST_RESULT';
  c_entity_release       CONSTANT VARCHAR2(30) := 'RELEASE';
  c_entity_application   CONSTANT VARCHAR2(30) := 'APPLICATION';
  c_entity_environment   CONSTANT VARCHAR2(30) := 'ENVIRONMENT';
  c_entity_routing_rule  CONSTANT VARCHAR2(30) := 'ROUTING_RULE';
  c_entity_user          CONSTANT VARCHAR2(30) := 'USER';
  c_entity_user_role     CONSTANT VARCHAR2(30) := 'USER_ROLE';
  c_entity_config        CONSTANT VARCHAR2(30) := 'CONFIG';
  c_entity_taxonomy      CONSTANT VARCHAR2(30) := 'TAXONOMY';
  c_entity_workflow      CONSTANT VARCHAR2(30) := 'WORKFLOW';
  c_entity_template      CONSTANT VARCHAR2(30) := 'TEMPLATE';
  c_entity_notification  CONSTANT VARCHAR2(30) := 'NOTIFICATION';
  c_entity_retention     CONSTANT VARCHAR2(30) := 'RETENTION_RUN';
  c_entity_launch        CONSTANT VARCHAR2(30) := 'LAUNCH';

  -- New correlation ID: 32 hex characters, safe to log and to place in a URL.
  FUNCTION new_correlation_id RETURN VARCHAR2;

  -- Build a flat JSON object from parallel name/value lists. Values are JSON-escaped.
  -- Names matching is_sensitive_name are stored as "[redacted]". NULL value -> JSON null.
  FUNCTION json_obj(p_names IN apex_t_varchar2, p_values IN apex_t_varchar2) RETURN CLOB;

  -- TRUE when a fact/item name looks like a credential (password, token, cookie, secret,
  -- authorization, session id, api key, ...). Shared with afh_context_pkg.
  FUNCTION is_sensitive_name(p_name IN VARCHAR2) RETURN BOOLEAN;

  -- Write one immutable audit event in the caller's transaction. Actor resolved from
  -- afh_security_pkg.current_subject / current_user_id. p_is_public = 'N' hides the row
  -- from the public ticket timeline (internal notes, restricted reads, config changes).
  PROCEDURE log_event(
    p_entity_type    IN VARCHAR2,
    p_entity_id      IN NUMBER,
    p_event_code     IN VARCHAR2,
    p_ticket_id      IN NUMBER   DEFAULT NULL,
    p_before_facts   IN CLOB     DEFAULT NULL,
    p_after_facts    IN CLOB     DEFAULT NULL,
    p_summary        IN VARCHAR2 DEFAULT NULL,
    p_is_public      IN VARCHAR2 DEFAULT 'Y',
    p_correlation_id IN VARCHAR2 DEFAULT NULL);

  -- Integration-health event (launch, capture, mail, adapter init, version). Runs in the
  -- caller's transaction. p_safe_detail must never contain payloads, tokens, or subjects
  -- other than the canonical subject.
  PROCEDURE log_integration_event(
    p_event_code      IN VARCHAR2,
    p_result_code     IN VARCHAR2,
    p_app_key         IN VARCHAR2 DEFAULT NULL,
    p_application_id  IN NUMBER   DEFAULT NULL,
    p_environment_id  IN NUMBER   DEFAULT NULL,
    p_correlation_id  IN VARCHAR2 DEFAULT NULL,
    p_adapter_version IN VARCHAR2 DEFAULT NULL,
    p_safe_detail     IN VARCHAR2 DEFAULT NULL);

  -- The ONE documented autonomous-transaction routine (spec §7.2): records a failed
  -- handoff/capture even when the caller's transaction rolls back.
  PROCEDURE log_integration_failure(
    p_event_code      IN VARCHAR2,
    p_app_key         IN VARCHAR2 DEFAULT NULL,
    p_application_id  IN NUMBER   DEFAULT NULL,
    p_environment_id  IN NUMBER   DEFAULT NULL,
    p_correlation_id  IN VARCHAR2 DEFAULT NULL,
    p_adapter_version IN VARCHAR2 DEFAULT NULL,
    p_safe_detail     IN VARCHAR2 DEFAULT NULL);

  -- The SECOND documented autonomous-transaction routine (spec §7.2 amendment, see
  -- docs/superpowers/specs/2026-08-22-afh-build-design.md §4): records a denied
  -- restricted read (spec §21 AFH-AUTH-002 "audit denied restricted access") so the
  -- row survives the RAISE_APPLICATION_ERROR rollback that follows. Never carries
  -- payloads; when the ticket row is not yet committed (test fixtures) the event is
  -- written without the ticket FK.
  PROCEDURE log_denial(
    p_entity_type IN VARCHAR2,
    p_entity_id   IN NUMBER,
    p_ticket_id   IN NUMBER,
    p_summary     IN VARCHAR2);

  -- Current session correlation ID (set by afh_launch_pkg.validate or by a page process);
  -- NULL when none. Used by log_event when p_correlation_id is NULL.
  PROCEDURE set_correlation_id(p_correlation_id IN VARCHAR2);
  FUNCTION  get_correlation_id RETURN VARCHAR2;
END afh_audit_pkg;
/
