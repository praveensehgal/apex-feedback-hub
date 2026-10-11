CREATE OR REPLACE PACKAGE afh_registry_int_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_REGISTRY_INT_PKG — private helper package for AFH_REGISTRY_PKG.
  -- Exists only to keep each body under the 800-line limit: it holds the shared
  -- validation/row helpers and the routing-rule and release implementations.
  -- It is NOT a public API. APEX pages and other packages call AFH_REGISTRY_PKG,
  -- whose spec documents the contract for every subprogram repeated here.
  -- Install after AFH_REGISTRY_PKG.pks and before the views.
  -- ---------------------------------------------------------------------------

  -- Statuses that count as "not unresolved" for releases and open-ticket counts.
  -- Views repeat this list literally (SQL cannot bind a PL/SQL collection on 19c).
  c_closed_status_list CONSTANT VARCHAR2(100) := 'RESOLVED,CLOSED,DUPLICATE,REJECTED,CANNOT_REPRODUCE';

  -- ----------------------------------------------------------------- validation helpers
  PROCEDURE assert_not_null(p_value IN VARCHAR2, p_label IN VARCHAR2);          -- AFH-VAL-001
  PROCEDURE assert_yn(p_value IN VARCHAR2, p_label IN VARCHAR2);                -- 'Y'/'N' only
  PROCEDURE assert_code(p_value IN VARCHAR2, p_label IN VARCHAR2);              -- ^[A-Z][A-Z0-9_]{0,29}$
  PROCEDURE assert_user_exists(p_user_id IN NUMBER, p_label IN VARCHAR2);      -- NULL passes
  FUNCTION  yn(p_bool IN BOOLEAN) RETURN VARCHAR2;
  FUNCTION  yn_facts(p_is_active IN VARCHAR2) RETURN CLOB;                      -- {"is_active": ...}

  -- Row fetchers. Raise AFH-VAL-001 ('... not found') when the id is unknown.
  -- p_for_update = 'Y' locks the row for the caller's transaction.
  FUNCTION app_row(p_application_id IN NUMBER, p_for_update IN VARCHAR2 DEFAULT 'N') RETURN afh_applications%ROWTYPE;
  FUNCTION env_row(p_environment_id IN NUMBER, p_for_update IN VARCHAR2 DEFAULT 'N') RETURN afh_environments%ROWTYPE;

  -- SQL-callable wrapper: 19c cannot call a BOOLEAN function from SQL, so views use this.
  FUNCTION is_adapter_supported_yn(p_application_id IN NUMBER, p_adapter_version IN VARCHAR2) RETURN VARCHAR2;

  -- ----------------------------------------------------------------- routing (contract: afh_registry_pkg)
  FUNCTION add_routing_rule(
    p_application_id   IN NUMBER,
    p_page_id          IN NUMBER,
    p_category_id      IN NUMBER,
    p_environment_id   IN NUMBER,
    p_type_code        IN VARCHAR2,
    p_assignee_user_id IN NUMBER,
    p_owner_user_id    IN NUMBER,
    p_priority_order   IN NUMBER,
    p_description      IN VARCHAR2) RETURN NUMBER;

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

  PROCEDURE resolve_route(
    p_application_id   IN  NUMBER,
    p_page_id          IN  NUMBER,
    p_category_id      IN  NUMBER,
    p_environment_id   IN  NUMBER,
    p_type_code        IN  VARCHAR2,
    o_assignee_user_id OUT NUMBER,
    o_owner_user_id    OUT NUMBER,
    o_routing_rule_id  OUT NUMBER);

  -- ----------------------------------------------------------------- releases (contract: afh_registry_pkg)
  FUNCTION add_release(
    p_application_id IN NUMBER,
    p_release_code   IN VARCHAR2,
    p_label          IN VARCHAR2,
    p_target_date    IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_notes          IN VARCHAR2) RETURN NUMBER;

  PROCEDURE update_release(
    p_release_id   IN NUMBER,
    p_label        IN VARCHAR2,
    p_target_date  IN TIMESTAMP WITH LOCAL TIME ZONE,
    p_state_code   IN VARCHAR2,
    p_notes        IN VARCHAR2);

  FUNCTION  unresolved_ticket_count(p_release_id IN NUMBER) RETURN NUMBER;
  PROCEDURE complete_release(p_release_id IN NUMBER, p_force IN VARCHAR2);
END afh_registry_int_pkg;
/
