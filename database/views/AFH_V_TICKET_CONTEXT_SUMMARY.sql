-- AFH_V_TICKET_CONTEXT_SUMMARY: one row per diagnostic capture with result codes, client facts
-- and item counts. No item values, no payloads — those come from afh_context_pkg after authorization.
CREATE OR REPLACE FORCE VIEW afh_v_ticket_context_summary AS
SELECT c.ticket_id,
       c.ticket_context_id,
       c.captured_at,
       c.correlation_id,
       c.contract_version,
       c.capture_result_code,
       c.item_result_code,
       c.screenshot_result_code,
       c.debug_result_code,
       c.browser_name,
       c.browser_version,
       c.os_name,
       c.device_type,
       c.viewport,
       c.locale,
       c.time_zone,
       c.apex_version,
       c.request_mode,
       NVL(i.item_total, 0)    AS item_total,
       NVL(i.item_changed, 0)  AS item_changed,
       NVL(i.item_excluded, 0) AS item_excluded,
       NVL(i.item_failed, 0)   AS item_failed,
       c.partial_reason,
       CASE WHEN c.ticket_context_id = MAX(c.ticket_context_id) KEEP (DENSE_RANK LAST ORDER BY c.captured_at, c.ticket_context_id)
                                       OVER (PARTITION BY c.ticket_id)
            THEN 'Y' ELSE 'N' END AS is_latest_yn
  FROM afh_ticket_contexts c
  LEFT JOIN (SELECT ticket_context_id,
                    COUNT(*)                                                       AS item_total,
                    COUNT(CASE WHEN is_changed = 'Y' THEN 1 END)                   AS item_changed,
                    COUNT(CASE WHEN capture_result_code = 'EXCLUDED' THEN 1 END)   AS item_excluded,
                    COUNT(CASE WHEN capture_result_code = 'FAILED' THEN 1 END)     AS item_failed
               FROM afh_context_items
              GROUP BY ticket_context_id) i
    ON i.ticket_context_id = c.ticket_context_id;

COMMENT ON TABLE afh_v_ticket_context_summary IS 'Per-capture result codes, client facts and item counts; no values or payloads';

