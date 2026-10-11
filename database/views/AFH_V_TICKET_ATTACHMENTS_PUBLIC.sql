-- AFH_V_TICKET_ATTACHMENTS_PUBLIC: non-deleted, non-restricted attachment metadata for ticket pages.
-- Never exposes bytes; downloads go through afh_attachment_pkg.download.
CREATE OR REPLACE FORCE VIEW afh_v_ticket_attachments_public AS
SELECT a.attachment_id,
       a.ticket_id,
       a.comment_id,
       a.test_result_id,
       a.kind_code,
       a.file_name,
       a.mime_type,
       a.file_size,
       a.sha256_hex,
       NVL(u.display_name, u.subject_display)                         AS uploaded_by,
       a.uploaded_by_user_id,
       a.uploaded_at,
       a.caption,
       CASE WHEN a.mime_type LIKE 'image/%' THEN 'Y' ELSE 'N' END     AS is_image_yn,
       a.original_attachment_id,
       CASE WHEN a.annotation_json IS NOT NULL THEN 'Y' ELSE 'N' END AS has_annotation_yn
  FROM afh_attachments a
  LEFT JOIN afh_users u ON u.user_id = a.uploaded_by_user_id
 WHERE a.is_deleted    = 'N'
   AND a.is_restricted = 'N';

COMMENT ON TABLE afh_v_ticket_attachments_public IS 'Public (non-restricted, non-deleted) attachment metadata per ticket; no bytes';

