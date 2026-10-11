CREATE OR REPLACE PACKAGE afh_registry_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_REGISTRY_PKG — registered applications, environments, adapter
  -- versions, ownership, routing rules, and releases. Spec §12, WU-03, WU-11.
  -- Authorization: application/environment/user-facing registration = AFH_ADMIN;
  -- routing rules and releases = app owner of that application or AFH_ADMIN.
  -- Every mutation writes one audit event (entity APPLICATION/ENVIRONMENT/
  -- ROUTING_RULE/RELEASE).
  -- ---------------------------------------------------------------------------

  c_mode_shared_session  CONSTANT VARCHAR2(30) := 'SHARED_SESSION';
  c_mode_signed_envelope CONSTANT VARCHAR2(30) := 'SIGNED_ENVELOPE';

  -- ----------------------------------------------------------------- applications (admin)
  -- Creates the application with a fresh shared secret. Returns application_id.
  -- o_secret_b64url is the ONLY time the secret is exposed; the page shows it once.
  FUNCTION register_application(
    p_app_key         IN  VARCHAR2,
    p_apex_app_id     IN  NUMBER,
    p_display_name    IN  VARCHAR2,
    p_owner_user_id   IN  NUMBER,
    p_identity_mode   IN  VARCHAR2 DEFAULT c_mode_shared_session,
    p_description     IN  VARCHAR2 DEFAULT NULL,
    o_secret_b64url   OUT VARCHAR2) RETURN NUMBER;

  PROCEDURE update_application(
    p_application_id  IN NUMBER,
    p_display_name    IN VARCHAR2,
    p_owner_user_id   IN NUMBER,
    p_identity_mode   IN VARCHAR2,
    p_description     IN VARCHAR2,
    p_min_adapter_version IN VARCHAR2 DEFAULT NULL);

  PROCEDURE set_application_active(p_application_id IN NUMBER, p_is_active IN VARCHAR2);

  -- Replace the shared secret; returns the new secret (base64url) for one-time display.
  FUNCTION rotate_secret(p_application_id IN NUMBER) RETURN VARCHAR2;

  -- Record the adapter version last seen from a host (called by afh_launch_pkg).
  PROCEDURE record_adapter_version(p_application_id IN NUMBER, p_adapter_version IN VARCHAR2);

  -- Lookups (no authorization; return NULL when not found or inactive unless p_include_inactive='Y')
  FUNCTION find_application_id(p_app_key IN VARCHAR2, p_include_inactive IN VARCHAR2 DEFAULT 'N') RETURN NUMBER;
  FUNCTION find_application_id_by_apex(p_apex_app_id IN NUMBER, p_include_inactive IN VARCHAR2 DEFAULT 'N') RETURN NUMBER;
  FUNCTION application_name(p_application_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION identity_mode(p_application_id IN NUMBER) RETURN VARCHAR2;

  -- ----------------------------------------------------------------- environments (admin)
  FUNCTION add_environment(
    p_application_id    IN NUMBER,
    p_env_code          IN VARCHAR2,
    p_label             IN VARCHAR2,
    p_source_identifier IN VARCHAR2 DEFAULT NULL,
    p_base_url_pattern  IN VARCHAR2 DEFAULT NULL,
    p_app_version       IN VARCHAR2 DEFAULT NULL,
    p_display_seq       IN NUMBER   DEFAULT 10) RETURN NUMBER;

  PROCEDURE update_environment(
    p_environment_id    IN NUMBER,
    p_label             IN VARCHAR2,
    p_source_identifier IN VARCHAR2,
    p_base_url_pattern  IN VARCHAR2,
    p_app_version       IN VARCHAR2,
    p_display_seq       IN NUMBER);

  PROCEDURE set_environment_active(p_environment_id IN NUMBER, p_is_active IN VARCHAR2);

  FUNCTION find_environment_id(p_application_id IN NUMBER, p_env_code IN VARCHAR2, p_include_inactive IN VARCHAR2 DEFAULT 'N') RETURN NUMBER;

  -- Source-URL policy (spec §13.2 / §13.4 step 5): TRUE when p_url matches the
  -- environment's base_url_pattern (LIKE pattern; NULL pattern = any https/http URL
  -- with no credentials, no javascript:/data: scheme).
  FUNCTION source_url_allowed(p_environment_id IN NUMBER, p_url IN VARCHAR2) RETURN BOOLEAN;
  -- Strip query credentials/fragments; returns NULL for disallowed schemes.
  FUNCTION sanitize_url(p_url IN VARCHAR2) RETURN VARCHAR2;

  -- ----------------------------------------------------------------- adapter versions
  -- Semantic-version compare: -1, 0, 1. Non-numeric parts compare as 0.
  FUNCTION version_compare(p_a IN VARCHAR2, p_b IN VARCHAR2) RETURN PLS_INTEGER;
  -- TRUE when p_adapter_version >= application's min_adapter_version (falls back to
  -- config MIN_ADAPTER_VERSION).
  FUNCTION is_adapter_supported(p_application_id IN NUMBER, p_adapter_version IN VARCHAR2) RETURN BOOLEAN;

  -- ----------------------------------------------------------------- routing (app owner / admin)
  FUNCTION add_routing_rule(
    p_application_id   IN NUMBER,
    p_page_id          IN NUMBER   DEFAULT NULL,
    p_category_id      IN NUMBER   DEFAULT NULL,
    p_environment_id   IN NUMBER   DEFAULT NULL,
    p_type_code        IN VARCHAR2 DEFAULT NULL,
    p_assignee_user_id IN NUMBER   DEFAULT NULL,
    p_owner_user_id    IN NUMBER   DEFAULT NULL,
    p_priority_order   IN NUMBER   DEFAULT 100,
    p_description      IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  PROCEDURE update_routing_rule(
    p_routing_rule_id  IN NUMBER,
    p_page_id          IN NUMBER,
    p_category_id      IN NUMBER,
    p_environment_id   IN NUMBER,
    p_type_code        IN VARCHAR2,
    p_assignee_user_id IN NUMBER,
    p_owner_user_id    IN NUMBER,
    p_priority_order   IN NUMBER,
    p_description      IN VARCHAR2);

  PROCEDURE set_routing_rule_active(p_routing_rule_id IN NUMBER, p_is_active IN VARCHAR2);
  PROCEDURE delete_routing_rule(p_routing_rule_id IN NUMBER);

  -- Deterministic resolution (spec WU-03): lowest priority_order among active rules whose
  -- non-null criteria all match; ties broken by routing_rule_id. o_owner_user_id falls
  -- back to the application owner, then config FALLBACK_OWNER_SUBJECT's user. Raises
  -- AFH-VAL-001 when no owner can be resolved at all (ticket creation must roll back).
  PROCEDURE resolve_route(
    p_application_id   IN  NUMBER,
    p_page_id          IN  NUMBER,
    p_category_id      IN  NUMBER,
    p_environment_id   IN  NUMBER,
    p_type_code        IN  VARCHAR2,
    o_assignee_user_id OUT NUMBER,
    o_owner_user_id    OUT NUMBER,
    o_routing_rule_id  OUT NUMBER);

  -- ----------------------------------------------------------------- releases (app owner / admin)
  FUNCTION add_release(
    p_application_id IN NUMBER,
    p_release_code   IN VARCHAR2,
    p_label          IN VARCHAR2,
    p_target_date    IN TIMESTAMP WITH LOCAL TIME ZONE DEFAULT NULL,
    p_notes          IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  PROCEDURE update_release(
    p_release_id   IN NUMBER,
    p_label        IN VARCHAR2,
    p_target_date  IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_state_code   IN VARCHAR2,
    p_notes        IN VARCHAR2);

  -- Count of included tickets not in RESOLVED/CLOSED; the page must show this before
  -- calling complete_release (spec WU-11 exit criteria).
  FUNCTION unresolved_ticket_count(p_release_id IN NUMBER) RETURN NUMBER;
  -- Marks COMPLETED with completed_date = now. p_force = 'N' raises AFH-VAL-001 when
  -- unresolved tickets remain.
  PROCEDURE complete_release(p_release_id IN NUMBER, p_force IN VARCHAR2 DEFAULT 'N');
END afh_registry_pkg;
/
