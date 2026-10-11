-- One row per ticket for All Feedback / search (Page 2). Public facts only: no context,
-- no internal notes, no attachment bytes. Archived tickets are included with is_archived
-- so the page can apply the retention policy; duplicates carry their master ticket number.
-- Filter with bind variables from the page, e.g.
--   WHERE ticket_id IN (SELECT ticket_id FROM TABLE(afh_search_pkg.search_tickets(:P2_SEARCH)))
CREATE OR REPLACE FORCE VIEW afh_v_ticket_search AS
SELECT t.ticket_id,
       t.ticket_no,
       t.title,
       ft.type_code,
       ft.label                                   AS type_label,
       ft.icon_token                              AS type_icon,
       t.application_id,
       a.display_name                             AS application_name,
       e.env_code,
       e.label                                    AS env_label,
       t.page_id,
       t.page_name,
       cat.label                                  AS category_label,
       t.status_code,
       NVL(st.label, t.status_code)               AS status_label,
       NVL(st.is_terminal, 'N')                   AS status_is_terminal,
       st.color_token                             AS status_color,
       t.priority_code,
       NVL(pr.label, t.priority_code)             AS priority_label,
       t.severity_code,
       NVL(sv.label, t.severity_code)             AS severity_label,
       t.impact_code,
       NVL(im.label, t.impact_code)               AS impact_label,
       t.reporter_user_id,
       NVL(ru.display_name, ru.subject_display)   AS reporter_display_name,
       t.assignee_user_id,
       NVL(au.display_name, au.subject_display)   AS assignee_display_name,
       t.release_id,
       rel.label                                  AS release_label,
       t.submitted_at,
       t.last_activity_at,
       t.is_archived,
       (SELECT MIN(m.ticket_no)
          FROM afh_ticket_relations r
          JOIN afh_tickets m ON m.ticket_id = r.target_ticket_id
         WHERE r.source_ticket_id = t.ticket_id
           AND r.relation_code = 'DUPLICATE_OF' AND r.is_active = 'Y') AS master_ticket_no,
       (SELECT COUNT(*) FROM afh_followers f WHERE f.ticket_id = t.ticket_id)        AS follower_count,
       (SELECT COUNT(*) FROM afh_affected_users x WHERE x.ticket_id = t.ticket_id)   AS affected_count,
       (SELECT COUNT(*) FROM afh_comments c
         WHERE c.ticket_id = t.ticket_id AND c.visibility_code = 'PUBLIC' AND c.is_archived = 'N') AS comment_count,
       (SELECT COUNT(*) FROM afh_attachments at
         WHERE at.ticket_id = t.ticket_id AND at.is_deleted = 'N' AND at.is_restricted = 'N') AS attachment_count,
       CAST(DBMS_LOB.substr(t.description, 300, 1) AS VARCHAR2(300 CHAR)) AS description_excerpt
  FROM afh_tickets t
  LEFT JOIN afh_feedback_types ft ON ft.feedback_type_id = t.feedback_type_id
  LEFT JOIN afh_applications a    ON a.application_id = t.application_id
  LEFT JOIN afh_environments e    ON e.environment_id = t.environment_id
  LEFT JOIN afh_categories cat    ON cat.category_id = t.category_id
  LEFT JOIN afh_workflow_statuses st ON st.status_code = t.status_code
  LEFT JOIN afh_classification_values pr ON pr.class_type = 'PRIORITY' AND pr.value_code = t.priority_code
  LEFT JOIN afh_classification_values sv ON sv.class_type = 'SEVERITY' AND sv.value_code = t.severity_code
  LEFT JOIN afh_classification_values im ON im.class_type = 'IMPACT'   AND im.value_code = t.impact_code
  LEFT JOIN afh_users ru          ON ru.user_id = t.reporter_user_id
  LEFT JOIN afh_users au          ON au.user_id = t.assignee_user_id
  LEFT JOIN afh_releases rel      ON rel.release_id = t.release_id;

COMMENT ON TABLE afh_v_ticket_search IS 'One row per ticket with public display facts, counts and master ticket number for All Feedback / search (Page 2).';

