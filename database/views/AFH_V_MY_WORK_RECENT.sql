-- AFH_V_MY_WORK_RECENT: "Recently viewed" and "Recently changed" tickets for the
-- current user (Page 1 My Work). VIEWED rows come from afh_ticket_views; CHANGED rows
-- are tickets the user reports, follows, or is assigned to with activity in the last
-- 14 days. Per-user: afh_security_pkg.current_user_id. Archived tickets are excluded.
CREATE OR REPLACE FORCE VIEW afh_v_my_work_recent AS
WITH me AS (
  SELECT afh_security_pkg.current_user_id AS user_id FROM dual
), mine AS (
  SELECT t.ticket_id, t.last_activity_at
    FROM afh_tickets t, me
   WHERE t.is_archived = 'N'
     AND t.last_activity_at >= SYSTIMESTAMP - INTERVAL '14' DAY
     AND (t.reporter_user_id = me.user_id
          OR t.assignee_user_id = me.user_id
          OR EXISTS (SELECT 1 FROM afh_followers f WHERE f.ticket_id = t.ticket_id AND f.user_id = me.user_id))
), picks AS (
  SELECT v.ticket_id, 'VIEWED' AS source, v.last_viewed_at AS at_time
    FROM afh_ticket_views v, me
   WHERE v.user_id = me.user_id
  UNION ALL
  SELECT m.ticket_id, 'CHANGED', m.last_activity_at
    FROM mine m
)
SELECT p.ticket_id,
       t.ticket_no,
       t.title,
       t.status_code,
       COALESCE(s.label, INITCAP(REPLACE(t.status_code, '_', ' '))) AS status_label,
       t.priority_code,
       t.application_id,
       a.display_name                                               AS application_name,
       p.source,
       p.at_time
  FROM picks p
  JOIN afh_tickets t       ON t.ticket_id = p.ticket_id
  JOIN afh_applications a  ON a.application_id = t.application_id
  LEFT JOIN afh_workflow_statuses s ON s.status_code = t.status_code
 WHERE t.is_archived = 'N';

COMMENT ON TABLE afh_v_my_work_recent IS 'Recently viewed (source VIEWED, from afh_ticket_views) and recently changed (source CHANGED, last 14 days on tickets the user reports/follows/owns) tickets for the current user; feeds My Work.';
