-- AFH_V_WORKFLOW_TRANSITIONS: the transition matrix with labels and readable actors (Page 64).
CREATE OR REPLACE FORCE VIEW afh_v_workflow_transitions AS
SELECT tr.workflow_transition_id, tr.from_status_code, f.label AS from_label, tr.to_status_code, t.label AS to_label,
       tr.label, tr.min_role_code, tr.alt_actors,
       CASE tr.min_role_code WHEN 'USER' THEN 'Any user' WHEN 'TESTER' THEN 'Tester and above' WHEN 'DEVELOPER' THEN 'Developer, app owner, admin'
            WHEN 'APP_OWNER' THEN 'App owner, admin' WHEN 'AFH_ADMIN' THEN 'Administrator' ELSE 'System' END
         || CASE WHEN tr.alt_actors IS NOT NULL THEN ' + ' || REPLACE(REPLACE(REPLACE(REPLACE(tr.alt_actors, 'REPORTER', 'reporter'), 'ASSIGNED_TESTER', 'assigned tester'), 'SYSTEM', 'system'), 'DEV_OR_ADMIN_ONLY', '(developer or admin only, not app owner)') END AS actors_text,
       tr.required_facts, tr.reason_required, tr.is_active, tr.display_seq, tr.description, f.display_seq AS from_seq, t.display_seq AS to_seq,
       tr.last_updated_by, tr.last_update_date
  FROM afh_workflow_transitions tr
  JOIN afh_workflow_statuses f ON f.status_code = tr.from_status_code
  JOIN afh_workflow_statuses t ON t.status_code = tr.to_status_code;
COMMENT ON TABLE afh_v_workflow_transitions IS 'Transition matrix with status labels and a readable actor description';
