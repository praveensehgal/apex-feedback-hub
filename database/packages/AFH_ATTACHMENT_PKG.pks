CREATE OR REPLACE PACKAGE afh_attachment_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_ATTACHMENT_PKG — file policy, checksums, storage, annotation metadata,
  -- authorized download, and removal. Spec §18, WU-05, DG-06 defaults.
  -- Bytes are returned only by get_for_download / download after authorization.
  -- ---------------------------------------------------------------------------

  c_kind_screenshot  CONSTANT VARCHAR2(30) := 'SCREENSHOT';
  c_kind_annotated   CONSTANT VARCHAR2(30) := 'SCREENSHOT_ANNOTATED';
  c_kind_file        CONSTANT VARCHAR2(30) := 'FILE';
  c_kind_context     CONSTANT VARCHAR2(30) := 'CONTEXT_EXPORT';

  -- ----------------------------------------------------------------- policy (config keys ATTACH_*)
  FUNCTION allowed_extensions RETURN VARCHAR2;        -- comma list, upper case
  FUNCTION max_file_bytes RETURN NUMBER;
  FUNCTION max_ticket_bytes RETURN NUMBER;
  FUNCTION ticket_total_bytes(p_ticket_id IN NUMBER) RETURN NUMBER;   -- non-deleted attachments
  -- Extension (upper, no dot) from a file name; NULL when none.
  FUNCTION extension_of(p_file_name IN VARCHAR2) RETURN VARCHAR2;
  -- Raises AFH-UPL-001 (type) or AFH-UPL-002 (size / ticket total). MIME must be consistent
  -- with the extension for images and PDF; HTML, SVG, scripts, executables are always rejected.
  PROCEDURE validate_file(
    p_file_name IN VARCHAR2,
    p_mime_type IN VARCHAR2,
    p_size      IN NUMBER,
    p_ticket_id IN NUMBER DEFAULT NULL);
  -- Strip path separators and control characters; cap at 255 characters.
  FUNCTION safe_file_name(p_file_name IN VARCHAR2) RETURN VARCHAR2;

  -- ----------------------------------------------------------------- storage
  -- Validates, computes SHA-256, stores, audits ATTACHMENT_ADDED, returns attachment_id.
  -- Uploader = current user. Restricted files require developer+ to add.
  FUNCTION add_attachment(
    p_ticket_id              IN NUMBER,
    p_file_name              IN VARCHAR2,
    p_mime_type              IN VARCHAR2,
    p_content                IN BLOB,
    p_kind_code              IN VARCHAR2 DEFAULT c_kind_file,
    p_comment_id             IN NUMBER   DEFAULT NULL,
    p_test_result_id         IN NUMBER   DEFAULT NULL,
    p_is_restricted          IN VARCHAR2 DEFAULT 'N',
    p_caption                IN VARCHAR2 DEFAULT NULL,
    p_annotation_json        IN CLOB     DEFAULT NULL,
    p_original_attachment_id IN NUMBER   DEFAULT NULL) RETURN NUMBER;

  -- Store an annotated derivative of an existing screenshot: original bytes untouched,
  -- annotation JSON kept with the derivative. Returns the new attachment_id.
  FUNCTION add_annotated_screenshot(
    p_original_attachment_id IN NUMBER,
    p_flattened_png          IN BLOB,
    p_annotation_json        IN CLOB) RETURN NUMBER;

  -- Move every member of an APEX collection (columns: c001 file name, c002 mime type,
  -- c003 kind code, c004 caption, clob001 annotation json, blob001 content) into the
  -- ticket, deleting the collection afterwards. Used by Page 20 after create_ticket.
  -- Returns the number of attachments stored.
  FUNCTION add_from_apex_collection(p_ticket_id IN NUMBER, p_collection_name IN VARCHAR2) RETURN NUMBER;

  -- Soft delete (is_deleted='Y', audit ATTACHMENT_REMOVED). Uploader within the comment
  -- edit window, developer+ for the ticket's application, or admin.
  PROCEDURE remove_attachment(p_attachment_id IN NUMBER);

  -- ----------------------------------------------------------------- authorized download
  FUNCTION can_download(p_attachment_id IN NUMBER) RETURN BOOLEAN;   -- public: any authenticated; restricted: developer+/admin
  -- Authorized read into OUT parameters (raises AFH-AUTH-002; audits ATTACHMENT_DOWNLOADED non-public when restricted).
  PROCEDURE get_for_download(
    p_attachment_id IN  NUMBER,
    o_content       OUT BLOB,
    o_mime_type     OUT VARCHAR2,
    o_file_name     OUT VARCHAR2);
  -- Streams the file with Content-Disposition: attachment (inline only for image/* and
  -- application/pdf) and stops the APEX engine. Call from an APEX page process / AJAX
  -- callback; never from SQL.
  PROCEDURE download(p_attachment_id IN NUMBER, p_inline IN VARCHAR2 DEFAULT 'N');
END afh_attachment_pkg;
/
