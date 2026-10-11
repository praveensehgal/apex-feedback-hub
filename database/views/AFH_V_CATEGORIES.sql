-- AFH_V_CATEGORIES: global and per-application categories with parent and application labels.
CREATE OR REPLACE FORCE VIEW afh_v_categories AS
SELECT c.category_id, c.application_id, a.display_name AS application_name, NVL(a.display_name, 'Global') AS scope,
       c.category_code, c.label, c.parent_category_id, p.label AS parent_label, c.display_seq, c.is_active,
       (SELECT COUNT(*) FROM afh_tickets t WHERE t.category_id = c.category_id) AS ticket_count,
       c.last_updated_by, c.last_update_date
  FROM afh_categories c
  LEFT JOIN afh_applications a ON a.application_id = c.application_id
  LEFT JOIN afh_categories p ON p.category_id = c.parent_category_id;
COMMENT ON TABLE afh_v_categories IS 'Categories with scope, parent label and ticket count';
