-- AFH_V_ROUTING_RULES: routing rules with resolved labels and a readable criteria summary (Page 62).
CREATE OR REPLACE FORCE VIEW afh_v_routing_rules AS
SELECT r.routing_rule_id,
       r.application_id,
       a.app_key,
       a.display_name                                                AS application_name,
       r.page_id,
       r.category_id,
       c.label                                                       AS category_label,
       r.environment_id,
       e.env_code,
       r.type_code,
       r.assignee_user_id,
       NVL(au.display_name, au.subject_display)                      AS assignee_display_name,
       r.owner_user_id,
       NVL(ou.display_name, ou.subject_display)                      AS owner_display_name,
       r.priority_order,
       r.is_active,
       r.description,
       NVL(LTRIM(
             CASE WHEN r.page_id        IS NOT NULL THEN ' ' || UNISTR('\00B7') || ' Page '     || TO_CHAR(r.page_id) END ||
             CASE WHEN r.category_id    IS NOT NULL THEN ' ' || UNISTR('\00B7') || ' Category ' || c.label           END ||
             CASE WHEN r.environment_id IS NOT NULL THEN ' ' || UNISTR('\00B7') || ' Env '      || e.env_code        END ||
             CASE WHEN r.type_code      IS NOT NULL THEN ' ' || UNISTR('\00B7') || ' Type '     || r.type_code       END,
             ' ' || UNISTR('\00B7')),
           'Any')                                                    AS criteria_text,
       r.created_by,
       r.creation_date,
       r.last_updated_by,
       r.last_update_date
  FROM afh_routing_rules r
  JOIN afh_applications a  ON a.application_id = r.application_id
  LEFT JOIN afh_categories c   ON c.category_id    = r.category_id
  LEFT JOIN afh_environments e ON e.environment_id = r.environment_id
  LEFT JOIN afh_users au       ON au.user_id       = r.assignee_user_id
  LEFT JOIN afh_users ou       ON ou.user_id       = r.owner_user_id;

COMMENT ON TABLE afh_v_routing_rules IS 'Routing rules with application, category, environment and user labels plus criteria_text (e.g. "Page 12 · Category Reports · Env PROD · Type BUG", or "Any") for the Routing admin page (Page 62).';

