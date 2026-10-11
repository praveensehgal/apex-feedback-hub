-- AFH_V_TICKET_ATTACHMENTS_ALL: every attachment row (restricted and removed included) for
-- developer pages protected by an authorization scheme. Metadata only; never bytes.
CREATE OR REPLACE FORCE VIEW afh_v_ticket_attachments_all AS
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
       CASE WHEN a.annotation_json IS NOT NULL THEN 'Y' ELSE 'N' END AS has_annotation_yn,
       a.is_restricted,
       a.is_deleted,
       a.deleted_at
  FROM afh_attachments a
  LEFT JOIN afh_users u ON u.user_id = a.uploaded_by_user_id;

COMMENT ON TABLE afh_v_ticket_attachments_all IS 'All attachment metadata including restricted and removed rows, for developer pages; no bytes';

