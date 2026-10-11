-- AFH_V_TICKET_RELATIONS: every relation readable from either side (Page 10).
CREATE OR REPLACE FORCE VIEW afh_v_ticket_relations AS
SELECT r.ticket_relation_id,
       r.source_ticket_id AS ticket_id,
       r.target_ticket_id AS related_ticket_id,
       'OUT' AS direction,
       r.relation_code,
       CASE r.relation_code WHEN 'DUPLICATE_OF' THEN 'Duplicate of' WHEN 'RELATED' THEN 'Related to' WHEN 'DEPENDS_ON' THEN 'Depends on' WHEN 'BLOCKS' THEN 'Blocks' END AS relation_label,
       t.ticket_no AS related_ticket_no, t.title AS related_title, s.label AS related_status_label, t.status_code AS related_status_code,
       r.reason, r.is_active, r.creation_date
  FROM afh_ticket_relations r
  JOIN afh_tickets t ON t.ticket_id = r.target_ticket_id
  JOIN afh_workflow_statuses s ON s.status_code = t.status_code
UNION ALL
SELECT r.ticket_relation_id,
       r.target_ticket_id,
       r.source_ticket_id,
       'IN',
       r.relation_code,
       CASE r.relation_code WHEN 'DUPLICATE_OF' THEN 'Has duplicate' WHEN 'RELATED' THEN 'Related to' WHEN 'DEPENDS_ON' THEN 'Blocked by' WHEN 'BLOCKS' THEN 'Depends on' END,
       t.ticket_no, t.title, s.label, t.status_code,
       r.reason, r.is_active, r.creation_date
  FROM afh_ticket_relations r
  JOIN afh_tickets t ON t.ticket_id = r.source_ticket_id
  JOIN afh_workflow_statuses s ON s.status_code = t.status_code;
COMMENT ON TABLE afh_v_ticket_relations IS 'Ticket relations from both sides with a readable label per direction';
