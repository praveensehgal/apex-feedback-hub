-- AFH_V_TICKET_DETAIL: one row per ticket with everything Page 10 (Ticket Detail) shows.
-- Exposes no restricted data: no context item values, no internal notes, no attachment
-- bytes; only result codes and counts. title_norm/desc_norm are search internals and omitted.
CREATE OR REPLACE FORCE VIEW afh_v_ticket_detail AS
SELECT t.ticket_id,
       t.ticket_no,
       t.feedback_type_id,
       ft.type_code,
       ft.label                           AS type_label,
       ft.icon_token                      AS type_icon,
       t.title,
       t.description,
       t.reporter_user_id,
       NVL(ru.display_name, ru.subject_display) AS reporter_name,
       ru.email                           AS reporter_email,
       t.application_id,
       a.display_name                     AS application_name,
       a.app_key,
       t.environment_id,
       e.env_code,
       e.label                            AS env_label,
       t.page_id,
       t.page_name,
       t.source_url,
       t.app_version,
       t.category_id,
       c.label                            AS category_label,
       t.proposed_priority_code,
       pp.label                           AS proposed_priority_label,
       t.proposed_severity_code,
       ps.label                           AS proposed_severity_label,
       t.proposed_impact_code,
       pi.label                           AS proposed_impact_label,
       t.priority_code,
       op.label                           AS priority_label,
       op.color_token                     AS priority_color,
       t.severity_code,
       os.label                           AS severity_label,
       os.color_token                     AS severity_color,
       t.impact_code,
       oi.label                           AS impact_label,
       oi.color_token                     AS impact_color,
       t.status_code,
       ws.label                           AS status_label,
       ws.is_terminal,
       ws.color_token                     AS status_color,
       t.assignee_user_id,
       NVL(au.display_name, au.subject_display) AS assignee_name,
       t.owner_user_id,
       NVL(ou.display_name, ou.subject_display) AS owner_name,
       t.release_id,
       r.release_code,
       r.label                            AS release_label,
       t.due_date,
       t.root_cause,
       t.resolution,
       t.context_result_code,
       t.is_archived,
       t.archived_at,
       t.row_version,
       t.last_activity_at,
       t.resolved_at,
       t.closed_at,
       t.submitted_at,
       (SELECT COUNT(*) FROM afh_followers f WHERE f.ticket_id = t.ticket_id)              AS follower_count,
       (SELECT COUNT(*) FROM afh_affected_users x WHERE x.ticket_id = t.ticket_id)         AS affected_count,
       (SELECT COUNT(*) FROM afh_comments cm
         WHERE cm.ticket_id = t.ticket_id AND cm.visibility_code = 'PUBLIC' AND cm.is_archived = 'N') AS comment_count,
       (SELECT COUNT(*) FROM afh_attachments at
         WHERE at.ticket_id = t.ticket_id AND at.is_deleted = 'N' AND at.is_restricted = 'N') AS attachment_count,
       CASE WHEN EXISTS (SELECT 1 FROM afh_attachments at
                          WHERE at.ticket_id = t.ticket_id AND at.is_deleted = 'N' AND at.is_restricted = 'Y')
            THEN 'Y' ELSE 'N' END                                                           AS has_restricted_attachments_yn,
       cx.capture_result_code,
       cx.item_result_code,
       cx.screenshot_result_code,
       cx.debug_result_code,
       cx.captured_at,
       mt.ticket_no                                                                         AS master_ticket_no,
       mt.ticket_id                                                                         AS master_ticket_id,
       (SELECT COUNT(*) FROM afh_ticket_relations dr
         WHERE dr.target_ticket_id = t.ticket_id AND dr.relation_code = 'DUPLICATE_OF' AND dr.is_active = 'Y') AS duplicate_count,
       t.created_by,
       t.creation_date,
       t.last_updated_by,
       t.last_update_date
  FROM afh_tickets t
  JOIN afh_feedback_types       ft ON ft.feedback_type_id = t.feedback_type_id
  JOIN afh_applications         a  ON a.application_id   = t.application_id
  JOIN afh_environments         e  ON e.environment_id   = t.environment_id
  JOIN afh_workflow_statuses    ws ON ws.status_code     = t.status_code
  JOIN afh_users                ru ON ru.user_id         = t.reporter_user_id
  LEFT JOIN afh_users           au ON au.user_id         = t.assignee_user_id
  LEFT JOIN afh_users           ou ON ou.user_id         = t.owner_user_id
  LEFT JOIN afh_categories      c  ON c.category_id      = t.category_id
  LEFT JOIN afh_releases        r  ON r.release_id       = t.release_id
  LEFT JOIN afh_classification_values pp ON pp.class_type = 'PRIORITY' AND pp.value_code = t.proposed_priority_code
  LEFT JOIN afh_classification_values ps ON ps.class_type = 'SEVERITY' AND ps.value_code = t.proposed_severity_code
  LEFT JOIN afh_classification_values pi ON pi.class_type = 'IMPACT'   AND pi.value_code = t.proposed_impact_code
  LEFT JOIN afh_classification_values op ON op.class_type = 'PRIORITY' AND op.value_code = t.priority_code
  LEFT JOIN afh_classification_values os ON os.class_type = 'SEVERITY' AND os.value_code = t.severity_code
  LEFT JOIN afh_classification_values oi ON oi.class_type = 'IMPACT'   AND oi.value_code = t.impact_code
  LEFT JOIN (SELECT tc.ticket_id, tc.capture_result_code, tc.item_result_code, tc.screenshot_result_code,
                    tc.debug_result_code, tc.captured_at,
                    ROW_NUMBER() OVER (PARTITION BY tc.ticket_id ORDER BY tc.captured_at DESC, tc.ticket_context_id DESC) AS rn
               FROM afh_ticket_contexts tc) cx ON cx.ticket_id = t.ticket_id AND cx.rn = 1
  LEFT JOIN (SELECT dr.source_ticket_id, MAX(dr.target_ticket_id) AS target_ticket_id
               FROM afh_ticket_relations dr
              WHERE dr.relation_code = 'DUPLICATE_OF' AND dr.is_active = 'Y'
              GROUP BY dr.source_ticket_id) dup ON dup.source_ticket_id = t.ticket_id
  LEFT JOIN afh_tickets mt ON mt.ticket_id = dup.target_ticket_id;

COMMENT ON TABLE afh_v_ticket_detail IS 'Ticket Detail (Page 10) header: ticket facts, labels, counts, latest capture result codes, and duplicate master. No restricted values.';

