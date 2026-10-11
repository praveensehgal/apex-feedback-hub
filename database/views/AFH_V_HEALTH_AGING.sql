-- AFH_V_HEALTH_AGING: open tickets per application and age bucket (Page 3).
CREATE OR REPLACE FORCE VIEW afh_v_health_aging AS
SELECT q.application_id, q.application_name, q.age_bucket, q.age_bucket_seq,
       COUNT(*) AS open_count,
       SUM(CASE WHEN q.is_overdue_yn = 'Y' THEN 1 ELSE 0 END) AS overdue_count
  FROM afh_v_ticket_queue q
 GROUP BY q.application_id, q.application_name, q.age_bucket, q.age_bucket_seq;
COMMENT ON TABLE afh_v_health_aging IS 'Open ticket counts by application and aging bucket';
