CREATE OR REPLACE PACKAGE afh_submit_pkg AUTHID DEFINER AS
  -- ---------------------------------------------------------------------------
  -- AFH_SUBMIT_PKG — the server side of Page 20 (Submit Feedback). One entry
  -- point per AJAX callback named in docs/architecture/browser-integration.md §5.
  -- Design amendment: keeps the capture staging, item merging and the atomic
  -- creation transaction (spec §14.3) in a package instead of page processes.
  -- Staged data lives in APEX collections AFH_CAPTURE_<cid> and AFH_FILES_<cid>
  -- (session-scoped, never on disk); every call re-validates the handoff through
  -- afh_launch_pkg.get_validated so a correlation id alone grants nothing.
  -- Each procedure writes its JSON response with APEX_JSON (htp output) and
  -- never raises to the browser: errors become {"ok":false,"error":"<safe text>"}.
  -- ---------------------------------------------------------------------------

  -- VALIDATE_LAUNCH: x01 cid, x02 mode (SHARED|SIGNED), x03 host apex app id, x04 page id,
  -- x05 app key, x06 env code, x07 page name, x08 url, x09 adapter version; P20_TOKEN for signed.
  -- Writes the t_launch facts (result_code, error_code, error_message, application_name,
  -- env_label, env_code, page_id, page_name, app_key, correlation_id, routing_text).
  PROCEDURE validate_launch(
    p_cid             IN VARCHAR2,
    p_mode            IN VARCHAR2,
    p_host_app_id     IN NUMBER,
    p_page_id         IN NUMBER,
    p_app_key         IN VARCHAR2,
    p_env_code        IN VARCHAR2,
    p_page_name       IN VARCHAR2,
    p_source_url      IN VARCHAR2,
    p_adapter_version IN VARCHAR2,
    p_token           IN VARCHAR2);

  -- UPLOAD_CAPTURE: x01 cid, p_clob_01 the adapter capture JSON (contract §4).
  -- Stores parts in AFH_CAPTURE_<cid>; screenshot data URL decoded to blob001.
  -- Item-capture result recorded by upload_capture for this correlation id ('NONE' when
  -- nothing was uploaded). Reads the session collection under its upper-cased name.
  FUNCTION context_result(p_cid IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE upload_capture(p_cid IN VARCHAR2, p_capture_json IN CLOB);

  -- TYPE_FIELDS: x01 type code -> afh_ticket_pkg.type_fields_json
  PROCEDURE type_fields(p_type_code IN VARCHAR2);

  -- DUP_CANDIDATES: x01 title, x02 type code, p_clob_01 description; uses the validated
  -- launch's application and page. Writes a JSON array of candidates.
  PROCEDURE dup_candidates(p_cid IN VARCHAR2, p_title IN VARCHAR2, p_type_code IN VARCHAR2, p_description IN CLOB);

  -- STAGE_FILE: x01 cid, x02 file name, x03 mime, x04 size, p_clob_01 data URL.
  -- Validates policy (afh_attachment_pkg.validate_file), stores in AFH_FILES_<cid>.
  -- Writes {"ok":true,"id":<seq>} or {"ok":false,"error":...}.
  PROCEDURE stage_file(p_cid IN VARCHAR2, p_file_name IN VARCHAR2, p_mime_type IN VARCHAR2, p_size IN NUMBER, p_data_url IN CLOB);

  -- REMOVE_FILE: x01 cid, x02 id (collection seq)
  PROCEDURE remove_file(p_cid IN VARCHAR2, p_seq IN NUMBER);

  -- ANNOTATE: x01 cid, p_clob_01 flattened PNG data URL, f01 the annotation JSON in slices.
  -- APEX AJAX carries exactly one CLOB (p_clob_01); the page process therefore hands the f01
  -- array to annotate_ajax, which joins it and calls annotate. Stores as SCREENSHOT_ANNOTATED
  -- in AFH_FILES_<cid> (the original stays in AFH_CAPTURE_<cid>).
  PROCEDURE annotate(p_cid IN VARCHAR2, p_png_data_url IN CLOB, p_annotation_json IN CLOB);
  PROCEDURE annotate_ajax(p_cid IN VARCHAR2, p_png_data_url IN CLOB, p_json_parts IN apex_application_global.vc_arr2);

  -- SUBMIT: x01 cid, x02 remove-screenshot Y/N, page items P20_* (read from session state).
  -- One transaction: get_validated -> create_ticket -> store_context (items merged from
  -- browser + server snapshot; shared mode reads server values itself) -> attachments
  -- (screenshot, annotated derivative, staged files) -> mark affected ticket -> consume.
  -- Idempotent on cid. Writes {"ok":true,"ticket_no":...,"ticket_url":...}. Commits.
  PROCEDURE submit(p_cid IN VARCHAR2, p_remove_screenshot IN VARCHAR2);

  -- Merge the adapter's browser items with a server snapshot into the store_context
  -- shape [{"name","type","browserValue","serverValue","serverResult"}]. Public for tests.
  FUNCTION merge_items(p_browser_items IN CLOB, p_server_items IN CLOB) RETURN CLOB;

  -- Decode a data: URL (base64) to a BLOB; NULL when not a data URL. Public for tests.
  FUNCTION data_url_to_blob(p_data_url IN CLOB, o_mime_type OUT VARCHAR2) RETURN BLOB;
END afh_submit_pkg;
/
