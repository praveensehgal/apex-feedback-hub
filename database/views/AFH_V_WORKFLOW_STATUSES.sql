-- AFH_V_WORKFLOW_STATUSES: statuses with live ticket counts (Pages 30, 64).
CREATE OR REPLACE FORCE VIEW afh_v_workflow_statuses AS
SELECT s.workflow_status_id, s.status_code, s.label, s.display_seq, s.is_terminal, s.is_active, s.color_token, s.description,
       (SELECT COUNT(*) FROM afh_tickets t WHERE t.status_code = s.status_code AND t.is_archived = 'N') AS ticket_count,
       s.last_updated_by, s.last_update_date
  FROM afh_workflow_statuses s;
COMMENT ON TABLE afh_v_workflow_statuses IS 'Workflow statuses with non-archived ticket counts';
