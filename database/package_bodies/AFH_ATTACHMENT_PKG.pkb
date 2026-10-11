CREATE OR REPLACE PACKAGE BODY afh_attachment_pkg AS
  -- ---------------------------------------------------------------------------
  -- AFH_ATTACHMENT_PKG body. Spec §18, WU-05, DG-06 defaults.
  -- Bytes leave the database only through get_for_download / download.
  -- ---------------------------------------------------------------------------

  -- DG-06 defaults, used when the ATTACH_* configuration keys are absent
  c_default_ext         CONSTANT VARCHAR2(200) := 'PNG,JPG,JPEG,PDF,TXT,CSV,XLSX,DOCX';
  c_default_file_bytes  CONSTANT NUMBER        := 26214400;    -- 25 MB
  c_default_tkt_bytes   CONSTANT NUMBER        := 104857600;   -- 100 MB
  c_default_edit_window CONSTANT NUMBER        := 15;          -- minutes, COMMENT_EDIT_WINDOW_MIN fallback
  -- Never accepted regardless of configuration (spec §18: HTML, SVG, scripts, executables,
  -- macro-enabled office documents, archives)
  c_blocked_ext  CONSTANT VARCHAR2(400) :=
    ',HTML,HTM,SVG,JS,MJS,EXE,BAT,CMD,SH,PS1,VBS,JAR,MSI,DLL,COM,SCR,PHP,ZIP,RAR,7Z,DOCM,XLSM,PPTM,';
  c_blocked_mime CONSTANT VARCHAR2(400) :=
    ',TEXT/HTML,APPLICATION/XHTML+XML,IMAGE/SVG+XML,APPLICATION/JAVASCRIPT,TEXT/JAVASCRIPT,'
    || 'APPLICATION/X-MSDOWNLOAD,APPLICATION/ZIP,APPLICATION/X-RAR-COMPRESSED,';

  c_evt_added      CONSTANT VARCHAR2(30) := 'ATTACHMENT_ADDED';
  c_evt_removed    CONSTANT VARCHAR2(30) := 'ATTACHMENT_REMOVED';
  c_evt_downloaded CONSTANT VARCHAR2(30) := 'ATTACHMENT_DOWNLOADED';

  -- =========================================================================== lookups
  FUNCTION att_row(p_attachment_id IN NUMBER) RETURN afh_attachments%ROWTYPE IS
    l_row afh_attachments%ROWTYPE;
  BEGIN
    SELECT * INTO l_row FROM afh_attachments WHERE attachment_id = p_attachment_id;
    RETURN l_row;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Attachment not found.');
    RETURN l_row;
  END att_row;

  FUNCTION ticket_app(p_ticket_id IN NUMBER) RETURN NUMBER IS
    l_app NUMBER;
  BEGIN
    SELECT application_id INTO l_app FROM afh_tickets WHERE ticket_id = p_ticket_id;
    RETURN l_app;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Ticket not found.');
    RETURN NULL;
  END ticket_app;

  FUNCTION fmt_mb(p_bytes IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN RTRIM(RTRIM(TO_CHAR(ROUND(p_bytes / 1048576, 1), 'FM9999990.9'), '0'), '.') || ' MB';
  END fmt_mb;

  FUNCTION is_json(p_text IN CLOB) RETURN BOOLEAN IS
    l_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO l_cnt FROM dual WHERE p_text IS JSON;
    RETURN l_cnt = 1;
  END is_json;

  -- =========================================================================== policy
  FUNCTION allowed_extensions RETURN VARCHAR2 IS
    l_list VARCHAR2(4000) := UPPER(REPLACE(afh_security_pkg.config_value('ATTACH_ALLOWED_EXT'), ' ', ''));
  BEGIN
    RETURN NVL(TRIM(BOTH ',' FROM l_list), c_default_ext);
  END allowed_extensions;

  FUNCTION max_file_bytes RETURN NUMBER IS
  BEGIN
    RETURN afh_security_pkg.config_number('ATTACH_MAX_FILE_BYTES', c_default_file_bytes);
  END max_file_bytes;

  FUNCTION max_ticket_bytes RETURN NUMBER IS
  BEGIN
    RETURN afh_security_pkg.config_number('ATTACH_MAX_TICKET_BYTES', c_default_tkt_bytes);
  END max_ticket_bytes;

  FUNCTION ticket_total_bytes(p_ticket_id IN NUMBER) RETURN NUMBER IS
    l_total NUMBER;
  BEGIN
    SELECT NVL(SUM(file_size), 0) INTO l_total
      FROM afh_attachments
     WHERE ticket_id = p_ticket_id AND is_deleted = 'N';
    RETURN l_total;
  END ticket_total_bytes;

  FUNCTION extension_of(p_file_name IN VARCHAR2) RETURN VARCHAR2 IS
    l_dot PLS_INTEGER := INSTR(p_file_name, '.', -1);
  BEGIN
    IF l_dot = 0 OR l_dot = LENGTH(p_file_name) THEN
      RETURN NULL;
    END IF;
    RETURN UPPER(TRIM(SUBSTR(p_file_name, l_dot + 1)));
  END extension_of;

  FUNCTION expected_mime(p_ext IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_ext
             WHEN 'PNG'  THEN 'image/png'
             WHEN 'JPG'  THEN 'image/jpeg'
             WHEN 'JPEG' THEN 'image/jpeg'
             WHEN 'PDF'  THEN 'application/pdf'
           END;
  END expected_mime;

  PROCEDURE check_type(p_file_name IN VARCHAR2, p_mime_type IN VARCHAR2) IS
    l_ext      VARCHAR2(255) := extension_of(p_file_name);
    l_allowed  VARCHAR2(4000) := allowed_extensions;
    l_mime     VARCHAR2(255) := LOWER(TRIM(p_mime_type));
    l_expected VARCHAR2(100);
  BEGIN
    IF l_ext IS NULL
       OR INSTR(c_blocked_ext, ',' || l_ext || ',') > 0
       OR INSTR(',' || l_allowed || ',', ',' || l_ext || ',') = 0 THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_upl_001,
        'Files of type .' || LOWER(NVL(l_ext, '(none)')) || ' are not permitted. Allowed: '
        || LOWER(REPLACE(l_allowed, ',', ', ')) || '.');
    END IF;
    IF INSTR(c_blocked_mime, ',' || UPPER(l_mime) || ',') > 0 THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_upl_001,
        'Files of content type ' || l_mime || ' are not permitted.');
    END IF;
    l_expected := expected_mime(l_ext);
    IF l_expected IS NOT NULL
       AND NOT (l_mime = l_expected OR (l_expected = 'image/jpeg' AND l_mime = 'image/pjpeg')) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_upl_001,
        'The file content type does not match its .' || LOWER(l_ext) || ' extension.');
    END IF;
  END check_type;

  PROCEDURE check_size(p_size IN NUMBER, p_ticket_id IN NUMBER) IS
    l_max NUMBER := max_file_bytes;
    l_tkt NUMBER := max_ticket_bytes;
  BEGIN
    IF p_size IS NULL OR p_size < 0 THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'File size is required.');
    END IF;
    IF p_size > l_max THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_upl_002,
        'The file exceeds the maximum size of ' || fmt_mb(l_max) || ' per file.');
    END IF;
    IF p_ticket_id IS NOT NULL AND ticket_total_bytes(p_ticket_id) + p_size > l_tkt THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_upl_002,
        'This ticket has reached its attachment limit of ' || fmt_mb(l_tkt) || '.');
    END IF;
  END check_size;

  PROCEDURE validate_file(
    p_file_name IN VARCHAR2,
    p_mime_type IN VARCHAR2,
    p_size      IN NUMBER,
    p_ticket_id IN NUMBER DEFAULT NULL) IS
  BEGIN
    check_type(p_file_name, p_mime_type);
    check_size(p_size, p_ticket_id);
  END validate_file;

  -- Magic-number check for the types the browser may render inline.
  PROCEDURE check_content(p_ext IN VARCHAR2, p_content IN BLOB) IS
    l_magic VARCHAR2(16);
    l_ok    BOOLEAN := TRUE;
  BEGIN
    IF p_ext NOT IN ('PNG','JPG','JPEG','PDF') THEN
      RETURN;
    END IF;
    l_magic := RAWTOHEX(DBMS_LOB.substr(p_content, 4, 1));
    IF p_ext = 'PNG' THEN
      l_ok := l_magic = '89504E47';
    ELSIF p_ext IN ('JPG','JPEG') THEN
      l_ok := SUBSTR(l_magic, 1, 6) = 'FFD8FF';
    ELSIF p_ext = 'PDF' THEN
      l_ok := l_magic = '25504446';
    END IF;
    IF NOT l_ok THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_upl_001, 'The file content does not match its type.');
    END IF;
  END check_content;

  FUNCTION safe_file_name(p_file_name IN VARCHAR2) RETURN VARCHAR2 IS
    l_name VARCHAR2(4000);
  BEGIN
    l_name := REGEXP_REPLACE(p_file_name, '[[:cntrl:]]', '');
    l_name := RTRIM(l_name, '/\');
    l_name := REGEXP_SUBSTR(l_name, '[^/\\]+$');      -- base name only: no path components
    l_name := TRIM(l_name);
    IF l_name IS NULL THEN
      l_name := 'file';
    END IF;
    RETURN SUBSTR(l_name, 1, 255);
  END safe_file_name;

  -- =========================================================================== storage: checks
  FUNCTION check_ticket_access(p_ticket_id IN NUMBER) RETURN NUMBER IS
    l_app NUMBER := ticket_app(p_ticket_id);
  BEGIN
    IF NOT afh_security_pkg.can_view_ticket(p_ticket_id) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002,
        'You are not permitted to add files to this ticket.');
    END IF;
    RETURN l_app;
  END check_ticket_access;

  PROCEDURE check_links(p_ticket_id IN NUMBER, p_comment_id IN NUMBER,
                        p_test_result_id IN NUMBER, p_original_attachment_id IN NUMBER) IS
    l_cnt PLS_INTEGER;
  BEGIN
    IF p_comment_id IS NOT NULL THEN
      SELECT COUNT(*) INTO l_cnt FROM afh_comments WHERE comment_id = p_comment_id AND ticket_id = p_ticket_id;
      IF l_cnt = 0 THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The comment does not belong to this ticket.');
      END IF;
    END IF;
    IF p_test_result_id IS NOT NULL THEN
      SELECT COUNT(*) INTO l_cnt FROM afh_test_results
       WHERE test_result_id = p_test_result_id AND ticket_id = p_ticket_id;
      IF l_cnt = 0 THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The test request does not belong to this ticket.');
      END IF;
    END IF;
    IF p_original_attachment_id IS NOT NULL THEN
      SELECT COUNT(*) INTO l_cnt FROM afh_attachments
       WHERE attachment_id = p_original_attachment_id AND ticket_id = p_ticket_id;
      IF l_cnt = 0 THEN
        afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The original screenshot does not belong to this ticket.');
      END IF;
    END IF;
  END check_links;

  PROCEDURE check_add_inputs(p_app IN NUMBER, p_kind_code IN VARCHAR2, p_is_restricted IN VARCHAR2,
                             p_annotation_json IN CLOB) IS
  BEGIN
    IF p_kind_code NOT IN (c_kind_screenshot, c_kind_annotated, c_kind_file, c_kind_context) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Unknown attachment kind.');
    END IF;
    IF NVL(p_is_restricted, 'N') NOT IN ('Y','N') THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Restricted flag must be Y or N.');
    END IF;
    IF p_is_restricted = 'Y'
       AND NOT (afh_security_pkg.is_developer(p_app) OR afh_security_pkg.is_admin) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002,
        'Only developers and administrators may add restricted files.');
    END IF;
    IF p_annotation_json IS NOT NULL AND NOT is_json(p_annotation_json) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Annotation data is not valid JSON.');
    END IF;
  END check_add_inputs;

  PROCEDURE audit_added(p_row IN afh_attachments%ROWTYPE) IS
  BEGIN
    afh_audit_pkg.log_event(
      p_entity_type => afh_audit_pkg.c_entity_attachment,
      p_entity_id   => p_row.attachment_id,
      p_event_code  => c_evt_added,
      p_ticket_id   => p_row.ticket_id,
      p_after_facts => afh_audit_pkg.json_obj(
        apex_t_varchar2('fileName','fileSize','kind','mimeType','sha256Hex','isRestricted',
                        'commentId','testResultId','originalAttachmentId'),
        apex_t_varchar2(p_row.file_name, p_row.file_size, p_row.kind_code, p_row.mime_type, p_row.sha256_hex,
                        p_row.is_restricted, p_row.comment_id, p_row.test_result_id, p_row.original_attachment_id)),
      p_summary     => 'Attachment added: ' || p_row.file_name,
      p_is_public   => CASE WHEN p_row.is_restricted = 'Y' THEN 'N' ELSE 'Y' END);
  END audit_added;

  -- =========================================================================== storage: public
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
    p_original_attachment_id IN NUMBER   DEFAULT NULL) RETURN NUMBER IS
    l_row afh_attachments%ROWTYPE;
    l_app NUMBER;
  BEGIN
    afh_security_pkg.assert_authenticated;
    l_app := check_ticket_access(p_ticket_id);
    check_add_inputs(l_app, p_kind_code, p_is_restricted, p_annotation_json);
    check_links(p_ticket_id, p_comment_id, p_test_result_id, p_original_attachment_id);
    l_row.file_name := safe_file_name(p_file_name);
    l_row.mime_type := SUBSTR(LOWER(TRIM(p_mime_type)), 1, 255);
    l_row.file_size := NVL(DBMS_LOB.getlength(p_content), 0);
    IF l_row.file_size = 0 THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'The file is empty.');
    END IF;
    validate_file(l_row.file_name, l_row.mime_type, l_row.file_size, p_ticket_id);
    check_content(extension_of(l_row.file_name), p_content);
    l_row.ticket_id              := p_ticket_id;
    l_row.comment_id             := p_comment_id;
    l_row.test_result_id         := p_test_result_id;
    l_row.kind_code              := p_kind_code;
    l_row.content                := p_content;
    l_row.sha256_hex             := afh_security_pkg.sha256_hex(p_content);
    l_row.uploaded_by_user_id    := afh_security_pkg.current_user_id;
    l_row.uploaded_at            := SYSTIMESTAMP;
    l_row.is_restricted          := NVL(p_is_restricted, 'N');
    l_row.annotation_json        := p_annotation_json;
    l_row.original_attachment_id := p_original_attachment_id;
    l_row.is_deleted             := 'N';
    l_row.caption                := SUBSTR(p_caption, 1, 500);
    INSERT INTO afh_attachments VALUES l_row RETURNING attachment_id INTO l_row.attachment_id;
    audit_added(l_row);
    RETURN l_row.attachment_id;
  END add_attachment;

  FUNCTION add_annotated_screenshot(
    p_original_attachment_id IN NUMBER,
    p_flattened_png          IN BLOB,
    p_annotation_json        IN CLOB) RETURN NUMBER IS
    l_orig afh_attachments%ROWTYPE := att_row(p_original_attachment_id);
    l_name VARCHAR2(255);
  BEGIN
    IF l_orig.is_deleted = 'Y' OR l_orig.kind_code <> c_kind_screenshot THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Annotations can only be added to a screenshot.');
    END IF;
    IF NOT can_download(p_original_attachment_id) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002,
        'You are not permitted to annotate this screenshot.');
    END IF;
    IF p_annotation_json IS NULL OR DBMS_LOB.getlength(p_annotation_json) = 0 THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'Annotation data is required.');
    END IF;
    l_name := SUBSTR(REGEXP_REPLACE(l_orig.file_name, '\.[^.]*$', ''), 1, 240) || '_annotated.png';
    RETURN add_attachment(
      p_ticket_id              => l_orig.ticket_id,
      p_file_name              => l_name,
      p_mime_type              => 'image/png',
      p_content                => p_flattened_png,
      p_kind_code              => c_kind_annotated,
      p_test_result_id         => l_orig.test_result_id,
      p_is_restricted          => l_orig.is_restricted,
      p_caption                => l_orig.caption,
      p_annotation_json        => p_annotation_json,
      p_original_attachment_id => p_original_attachment_id);
  END add_annotated_screenshot;

  -- Without an APEX session there is no collection to read; treat "unreachable" as absent.
  FUNCTION collection_reachable(p_collection_name IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN apex_collection.collection_exists(p_collection_name => p_collection_name);
  EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
  END collection_reachable;

  FUNCTION add_from_apex_collection(p_ticket_id IN NUMBER, p_collection_name IN VARCHAR2) RETURN NUMBER IS
    l_count PLS_INTEGER := 0;
    l_id    NUMBER;
    l_annot CLOB;
  BEGIN
    IF p_collection_name IS NULL OR NOT collection_reachable(p_collection_name) THEN
      RETURN 0;
    END IF;
    FOR r IN (SELECT c001, c002, c003, c004, clob001, blob001
                FROM apex_collections
               WHERE collection_name = UPPER(p_collection_name)
               ORDER BY seq_id) LOOP
      l_annot := CASE WHEN r.clob001 IS NOT NULL AND DBMS_LOB.getlength(r.clob001) > 0 THEN r.clob001 END;
      l_id := add_attachment(
        p_ticket_id       => p_ticket_id,
        p_file_name       => r.c001,
        p_mime_type       => r.c002,
        p_content         => r.blob001,
        p_kind_code       => NVL(r.c003, c_kind_file),
        p_caption         => r.c004,
        p_annotation_json => l_annot);
      l_count := l_count + 1;
    END LOOP;
    apex_collection.delete_collection(p_collection_name => p_collection_name);
    RETURN l_count;
  END add_from_apex_collection;

  -- =========================================================================== removal
  FUNCTION can_remove(p_row IN afh_attachments%ROWTYPE, p_app IN NUMBER) RETURN BOOLEAN IS
    l_window NUMBER := afh_security_pkg.config_number('COMMENT_EDIT_WINDOW_MIN', c_default_edit_window);
  BEGIN
    IF afh_security_pkg.is_admin OR afh_security_pkg.is_developer(p_app) THEN
      RETURN TRUE;
    END IF;
    RETURN p_row.uploaded_by_user_id = afh_security_pkg.current_user_id
       AND p_row.uploaded_at + NUMTODSINTERVAL(l_window, 'MINUTE') >= SYSTIMESTAMP;
  END can_remove;

  PROCEDURE remove_attachment(p_attachment_id IN NUMBER) IS
    l_row afh_attachments%ROWTYPE;
    l_app NUMBER;
  BEGIN
    afh_security_pkg.assert_authenticated;
    l_row := att_row(p_attachment_id);
    IF l_row.is_deleted = 'Y' THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_val_001, 'This file has already been removed.');
    END IF;
    l_app := ticket_app(l_row.ticket_id);
    IF NOT can_remove(l_row, l_app) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002, 'You are not permitted to remove this file.');
    END IF;
    UPDATE afh_attachments
       SET is_deleted = 'Y', deleted_at = SYSTIMESTAMP
     WHERE attachment_id = p_attachment_id AND is_deleted = 'N';
    afh_audit_pkg.log_event(
      p_entity_type  => afh_audit_pkg.c_entity_attachment,
      p_entity_id    => p_attachment_id,
      p_event_code   => c_evt_removed,
      p_ticket_id    => l_row.ticket_id,
      p_before_facts => afh_audit_pkg.json_obj(apex_t_varchar2('isDeleted'), apex_t_varchar2('N')),
      p_after_facts  => afh_audit_pkg.json_obj(
        apex_t_varchar2('isDeleted','fileName','fileSize','kind','isRestricted'),
        apex_t_varchar2('Y', l_row.file_name, l_row.file_size, l_row.kind_code, l_row.is_restricted)),
      p_summary      => 'Attachment removed: ' || l_row.file_name,
      p_is_public    => CASE WHEN l_row.is_restricted = 'Y' THEN 'N' ELSE 'Y' END);
  END remove_attachment;

  -- =========================================================================== authorized download
  FUNCTION can_download(p_attachment_id IN NUMBER) RETURN BOOLEAN IS
    l_row afh_attachments%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO l_row FROM afh_attachments WHERE attachment_id = p_attachment_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
    END;
    IF l_row.is_deleted = 'Y' OR NOT afh_security_pkg.can_view_ticket(l_row.ticket_id) THEN
      RETURN FALSE;
    END IF;
    IF l_row.is_restricted = 'Y' THEN
      RETURN afh_security_pkg.can_view_restricted(l_row.ticket_id);
    END IF;
    RETURN TRUE;
  END can_download;

  PROCEDURE get_for_download(
    p_attachment_id IN  NUMBER,
    o_content       OUT BLOB,
    o_mime_type     OUT VARCHAR2,
    o_file_name     OUT VARCHAR2) IS
    l_row afh_attachments%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO l_row FROM afh_attachments WHERE attachment_id = p_attachment_id AND is_deleted = 'N';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002, 'You are not permitted to download this file.');
    END;
    IF NOT afh_security_pkg.can_view_ticket(l_row.ticket_id) THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_auth_002, 'You are not permitted to download this file.');
    END IF;
    IF l_row.is_restricted = 'Y' THEN
      afh_security_pkg.assert_can_view_restricted(l_row.ticket_id);   -- audits a denial
      afh_audit_pkg.log_event(
        p_entity_type => afh_audit_pkg.c_entity_attachment,
        p_entity_id   => l_row.attachment_id,
        p_event_code  => c_evt_downloaded,
        p_ticket_id   => l_row.ticket_id,
        p_after_facts => afh_audit_pkg.json_obj(apex_t_varchar2('fileName','fileSize','kind'),
                                                apex_t_varchar2(l_row.file_name, l_row.file_size, l_row.kind_code)),
        p_summary     => 'Restricted attachment downloaded: ' || l_row.file_name,
        p_is_public   => 'N');
    END IF;
    o_content   := l_row.content;
    o_mime_type := l_row.mime_type;
    o_file_name := l_row.file_name;
  END get_for_download;

  PROCEDURE download(p_attachment_id IN NUMBER, p_inline IN VARCHAR2 DEFAULT 'N') IS
    l_content BLOB;
    l_mime    VARCHAR2(255);
    l_name    VARCHAR2(255);
    l_disp    VARCHAR2(20);
  BEGIN
    get_for_download(p_attachment_id, l_content, l_mime, l_name);
    l_disp := CASE WHEN p_inline = 'Y' AND (l_mime LIKE 'image/%' OR l_mime = 'application/pdf')
                   THEN 'inline' ELSE 'attachment' END;
    owa_util.mime_header(l_mime, FALSE);
    htp.p('Content-Length: ' || DBMS_LOB.getlength(l_content));
    htp.p('Content-Disposition: ' || l_disp || '; filename="' || REPLACE(l_name, '"', '') || '"');
    htp.p('X-Content-Type-Options: nosniff');
    owa_util.http_header_close;
    wpg_docload.download_file(l_content);
    apex_application.stop_apex_engine;
  END download;
END afh_attachment_pkg;
/
