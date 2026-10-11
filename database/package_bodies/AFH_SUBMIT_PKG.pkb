CREATE OR REPLACE PACKAGE BODY afh_submit_pkg AS
  c_capture_prefix CONSTANT VARCHAR2(12) := 'AFH_CAPTURE_';
  c_files_prefix   CONSTANT VARCHAR2(10) := 'AFH_FILES_';

  -- APEX stores collection names in UPPER CASE (apex_collection.create_collection uppercases
  -- them) while correlation ids are lower-case hex. Every direct query against APEX_COLLECTIONS
  -- must therefore use the upper-cased name; found 2026-09-06 when submitted tickets carried
  -- context_result_code NONE although UPLOAD_CAPTURE had succeeded.
  FUNCTION capture_coll(p_cid IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN RETURN UPPER(c_capture_prefix || p_cid); END capture_coll;

  FUNCTION files_coll(p_cid IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN RETURN UPPER(c_files_prefix || p_cid); END files_coll;

  FUNCTION context_result(p_cid IN VARCHAR2) RETURN VARCHAR2 IS
    l_rc   VARCHAR2(30 CHAR) := 'NONE';
    l_coll VARCHAR2(60) := capture_coll(p_cid);
  BEGIN
    FOR c IN (SELECT c002 FROM apex_collections WHERE collection_name = l_coll AND c050 = 'HEAD') LOOP
      l_rc := c.c002;
    END LOOP;
    RETURN l_rc;
  END context_result;

  -- ------------------------------------------------------------------ JSON output helpers
  PROCEDURE out_error(p_message IN VARCHAR2) IS
  BEGIN
    apex_json.open_object;
    apex_json.write('ok', FALSE);
    apex_json.write('error', SUBSTR(p_message, 1, 500));
    apex_json.close_object;
  END out_error;

  -- User-safe text for an exception: AFH messages verbatim, anything else generic.
  FUNCTION safe_message RETURN VARCHAR2 IS
    l_code VARCHAR2(12) := afh_security_pkg.error_code_of(SQLERRM);
  BEGIN
    IF l_code IS NOT NULL THEN
      RETURN REGEXP_REPLACE(SQLERRM, '^ORA-\d+: ', '');
    END IF;
    afh_audit_pkg.log_integration_failure(p_event_code => 'CAPTURE', p_safe_detail => 'submit: ' || SUBSTR(SQLERRM, 1, 200));
    RETURN 'AFH-SYS-001: Something went wrong. Your draft is kept; try again or close and reopen Feedback.';
  END safe_message;

  FUNCTION safe_cid(p_cid IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_cid IS NULL OR NOT REGEXP_LIKE(p_cid, '^[0-9a-fA-F]{32}$') THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_ctx_001, 'This feedback launch is invalid. Close and open Feedback again.');
    END IF;
    RETURN LOWER(p_cid);
  END safe_cid;

  -- ------------------------------------------------------------------ data URL
  -- Decodes data:<mime>;base64,<payload> straight from the CLOB. The payload is read in
  -- 32,000-character slices (a multiple of 4, so every slice decodes on its own); it must NOT
  -- be copied into a scalar first - DBMS_LOB.substr returns NULL for any amount over 32,767,
  -- which silently turned every real screenshot and attachment into an empty BLOB
  -- (found 2026-09-06: "AFH-VAL-001: The file is empty" on submit).
  FUNCTION data_url_to_blob(p_data_url IN CLOB, o_mime_type OUT VARCHAR2) RETURN BLOB IS
    l_comma   PLS_INTEGER;
    l_header  VARCHAR2(200 CHAR);
    l_blob    BLOB;
    l_step    PLS_INTEGER := 32000;
    l_total   PLS_INTEGER;
    l_pos     PLS_INTEGER;
    l_piece   VARCHAR2(32000);
    l_raw     RAW(32767);
  BEGIN
    IF p_data_url IS NULL OR DBMS_LOB.substr(p_data_url, 5, 1) <> 'data:' THEN
      RETURN NULL;
    END IF;
    l_comma := DBMS_LOB.instr(p_data_url, ',', 1, 1);
    IF l_comma IS NULL OR l_comma = 0 THEN
      RETURN NULL;
    END IF;
    l_header := DBMS_LOB.substr(p_data_url, LEAST(l_comma - 1, 200), 1);
    o_mime_type := SUBSTR(l_header, 6, INSTR(l_header, ';') - 6);
    DBMS_LOB.createtemporary(l_blob, TRUE, DBMS_LOB.call);
    l_total := DBMS_LOB.getlength(p_data_url);
    l_pos   := l_comma + 1;
    WHILE l_pos <= l_total LOOP
      l_piece := DBMS_LOB.substr(p_data_url, l_step, l_pos);
      l_piece := REPLACE(REPLACE(l_piece, CHR(10)), CHR(13));   -- tolerate wrapped base64
      IF l_piece IS NOT NULL THEN
        l_raw := UTL_ENCODE.base64_decode(UTL_RAW.cast_to_raw(l_piece));
        DBMS_LOB.writeappend(l_blob, UTL_RAW.length(l_raw), l_raw);
      END IF;
      l_pos := l_pos + l_step;
    END LOOP;
    RETURN l_blob;
  END data_url_to_blob;

  -- ------------------------------------------------------------------ item merge
  FUNCTION merge_items(p_browser_items IN CLOB, p_server_items IN CLOB) RETURN CLOB IS
    TYPE t_srv IS RECORD (value VARCHAR2(4000 CHAR), result VARCHAR2(30 CHAR));
    TYPE t_map IS TABLE OF t_srv INDEX BY VARCHAR2(255);
    l_map    t_map;
    l_srv    apex_json.t_values;
    l_brw    apex_json.t_values;
    l_n      PLS_INTEGER;
    l_name   VARCHAR2(255 CHAR);
    l_out    CLOB;
  BEGIN
    IF p_server_items IS NOT NULL THEN
      apex_json.parse(l_srv, p_server_items);
      l_n := apex_json.get_count(p_path => '.', p_values => l_srv);
      FOR i IN 1 .. NVL(l_n, 0) LOOP
        l_name := UPPER(apex_json.get_varchar2(p_path => '[%d].name', p0 => i, p_values => l_srv));
        IF l_name IS NOT NULL THEN
          l_map(l_name).value  := apex_json.get_varchar2(p_path => '[%d].serverValue', p0 => i, p_values => l_srv);
          l_map(l_name).result := NVL(apex_json.get_varchar2(p_path => '[%d].result', p0 => i, p_values => l_srv), 'AVAILABLE');
        END IF;
      END LOOP;
    END IF;
    apex_json.initialize_clob_output;
    apex_json.open_array;
    IF p_browser_items IS NOT NULL THEN
      apex_json.parse(l_brw, p_browser_items);
      l_n := apex_json.get_count(p_path => '.', p_values => l_brw);
      FOR i IN 1 .. NVL(l_n, 0) LOOP
        l_name := apex_json.get_varchar2(p_path => '[%d].name', p0 => i, p_values => l_brw);
        apex_json.open_object;
        apex_json.write('name', l_name);
        apex_json.write('type', apex_json.get_varchar2(p_path => '[%d].type', p0 => i, p_values => l_brw));
        apex_json.write('browserValue', apex_json.get_varchar2(p_path => '[%d].browserValue', p0 => i, p_values => l_brw));
        IF l_map.EXISTS(UPPER(l_name)) THEN
          apex_json.write('serverValue', l_map(UPPER(l_name)).value);
          apex_json.write('serverResult', l_map(UPPER(l_name)).result);
          l_map.DELETE(UPPER(l_name));
        ELSE
          apex_json.write('serverResult', 'UNAVAILABLE');
        END IF;
        apex_json.close_object;
      END LOOP;
    END IF;
    l_name := l_map.FIRST;                       -- server-only items (application items etc.)
    WHILE l_name IS NOT NULL LOOP
      apex_json.open_object;
      apex_json.write('name', l_name);
      apex_json.write('serverValue', l_map(l_name).value);
      apex_json.write('serverResult', l_map(l_name).result);
      apex_json.close_object;
      l_name := l_map.NEXT(l_name);
    END LOOP;
    apex_json.close_array;
    l_out := apex_json.get_clob_output;
    apex_json.free_output;
    apex_json.initialize_output(p_http_header => FALSE);  -- back to HTP: free_output leaves output detached
    RETURN l_out;
  END merge_items;

  -- ------------------------------------------------------------------ launch
  PROCEDURE write_launch(p_l IN afh_launch_pkg.t_launch) IS
    l_assignee NUMBER; l_owner NUMBER; l_rule NUMBER;
    l_routing  VARCHAR2(500 CHAR);
  BEGIN
    IF p_l.result_code = 'VALIDATED' THEN
      BEGIN
        afh_registry_pkg.resolve_route(p_l.application_id, p_l.page_id, NULL, p_l.environment_id, NULL, l_assignee, l_owner, l_rule);
        SELECT 'Goes to ' || NVL((SELECT display_name FROM afh_users WHERE user_id = l_assignee), 'the ' || (SELECT display_name FROM afh_users WHERE user_id = l_owner) || ' queue')
          INTO l_routing FROM dual;
      EXCEPTION WHEN OTHERS THEN l_routing := NULL;
      END;
    END IF;
    apex_json.open_object;
    apex_json.write('ok', p_l.result_code = 'VALIDATED');
    apex_json.write('result_code', p_l.result_code);
    apex_json.write('error_code', p_l.error_code);
    apex_json.write('error_message', p_l.error_message);
    apex_json.write('correlation_id', p_l.correlation_id);
    apex_json.write('application_name', p_l.application_name);
    apex_json.write('app_key', p_l.app_key);
    apex_json.write('env_code', p_l.env_code);
    apex_json.write('env_label', p_l.env_label);
    apex_json.write('page_id', p_l.page_id);
    apex_json.write('page_name', p_l.page_name);
    apex_json.write('routing_text', l_routing);
    apex_json.close_object;
  END write_launch;

  PROCEDURE validate_launch(
    p_cid IN VARCHAR2, p_mode IN VARCHAR2, p_host_app_id IN NUMBER, p_page_id IN NUMBER, p_app_key IN VARCHAR2,
    p_env_code IN VARCHAR2, p_page_name IN VARCHAR2, p_source_url IN VARCHAR2, p_adapter_version IN VARCHAR2, p_token IN VARCHAR2) IS
    l afh_launch_pkg.t_launch;
  BEGIN
    IF UPPER(p_mode) = 'SIGNED' THEN
      l := afh_launch_pkg.validate(p_token => p_token, p_adapter_version => p_adapter_version);
    ELSE
      l := afh_launch_pkg.validate(
             p_correlation_id => safe_cid(p_cid), p_host_session_id => apex_application.g_instance,
             p_apex_app_id => p_host_app_id, p_app_key => p_app_key, p_env_code => p_env_code,
             p_page_id => p_page_id, p_page_name => p_page_name, p_source_url => p_source_url,
             p_adapter_version => p_adapter_version);
    END IF;
    write_launch(l);
  EXCEPTION WHEN OTHERS THEN
    out_error(safe_message);
  END validate_launch;

  -- ------------------------------------------------------------------ capture staging
  -- Collection AFH_CAPTURE_<cid>, one member per part (c050 = part):
  --   HEAD   c001 screenshot result, c002 item result, c003 debug result, c004 adapter version,
  --          c005 screenshot mime, blob001 screenshot PNG
  --   ITEMS  clob001 browser items JSON        SERVER clob001 server items JSON
  --   CLIENT clob001 client facts JSON         SOURCE clob001 source facts JSON
  FUNCTION sub_json(p_values IN apex_json.t_values, p_path IN VARCHAR2) RETURN CLOB IS
    l_out CLOB;
  BEGIN
    IF NOT apex_json.does_exist(p_path => p_path, p_values => p_values) THEN
      RETURN NULL;
    END IF;
    apex_json.initialize_clob_output;
    apex_json.write(p_values, p_path);
    l_out := apex_json.get_clob_output;
    apex_json.free_output;
    apex_json.initialize_output(p_http_header => FALSE);  -- back to HTP: free_output leaves output detached
    RETURN l_out;
  END sub_json;

  PROCEDURE add_part(p_coll IN VARCHAR2, p_part IN VARCHAR2, p_clob IN CLOB) IS
    l_seq NUMBER;
  BEGIN
    l_seq := apex_collection.add_member(p_collection_name => p_coll, p_c050 => p_part, p_clob001 => p_clob);
  END add_part;

  FUNCTION part(p_coll IN VARCHAR2, p_part IN VARCHAR2) RETURN CLOB IS
    l_clob CLOB;
  BEGIN
    SELECT clob001 INTO l_clob FROM apex_collections WHERE collection_name = p_coll AND c050 = p_part;
    RETURN l_clob;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END part;

  PROCEDURE upload_capture(p_cid IN VARCHAR2, p_capture_json IN CLOB) IS
    l_cid   VARCHAR2(32) := safe_cid(p_cid);
    l_l     afh_launch_pkg.t_launch := afh_launch_pkg.get_validated(l_cid);
    l_coll  VARCHAR2(60) := capture_coll(l_cid);
    l_vals  apex_json.t_values;
    l_png   BLOB;
    l_mime  VARCHAR2(100 CHAR);
    l_src   CLOB;
    l_seq   NUMBER;
  BEGIN
    apex_json.parse(l_vals, p_capture_json);
    l_png := data_url_to_blob(apex_json.get_clob(p_path => 'screenshot.dataUrl', p_values => l_vals), l_mime);
    apex_json.initialize_clob_output;
    apex_json.open_object;
    apex_json.write('appKey',    l_l.app_key);
    apex_json.write('apexAppId', l_l.apex_app_id);
    apex_json.write('pageId',    l_l.page_id);
    apex_json.write('pageName',  l_l.page_name);
    apex_json.write('envCode',   l_l.env_code);
    apex_json.write('appVersion', l_l.app_version);
    apex_json.write('sourceUrl', l_l.source_url);
    apex_json.close_object;
    l_src := apex_json.get_clob_output;
    apex_json.free_output;
    apex_json.initialize_output(p_http_header => FALSE);  -- back to HTP: free_output leaves output detached
    apex_collection.create_or_truncate_collection(l_coll);
    l_seq := apex_collection.add_member(
      p_collection_name => l_coll, p_c050 => 'HEAD',
      p_c001 => NVL(apex_json.get_varchar2(p_path => 'screenshot.result', p_values => l_vals), CASE WHEN l_png IS NULL THEN 'FAILED' ELSE 'SUCCESS' END),
      p_c002 => NVL(apex_json.get_varchar2(p_path => 'itemResult', p_values => l_vals), 'FAILED'),
      p_c003 => NVL(apex_json.get_varchar2(p_path => 'debug.result', p_values => l_vals), 'UNAVAILABLE'),
      p_c004 => apex_json.get_varchar2(p_path => 'adapterVersion', p_values => l_vals),
      p_c005 => l_mime,
      p_blob001 => l_png);
    add_part(l_coll, 'ITEMS',  sub_json(l_vals, 'items'));
    add_part(l_coll, 'SERVER', sub_json(l_vals, 'serverItems'));
    add_part(l_coll, 'CLIENT', sub_json(l_vals, 'client'));
    add_part(l_coll, 'SOURCE', l_src);
    apex_json.open_object;
    apex_json.write('ok', TRUE);
    apex_json.write('screenshot', l_png IS NOT NULL);
    apex_json.close_object;
  EXCEPTION WHEN OTHERS THEN
    out_error(safe_message);
  END upload_capture;

  PROCEDURE type_fields(p_type_code IN VARCHAR2) IS
  BEGIN
    htp.p(afh_ticket_pkg.type_fields_json(p_type_code));
  EXCEPTION WHEN OTHERS THEN
    out_error(safe_message);
  END type_fields;

  PROCEDURE dup_candidates(p_cid IN VARCHAR2, p_title IN VARCHAR2, p_type_code IN VARCHAR2, p_description IN CLOB) IS
    l_l afh_launch_pkg.t_launch := afh_launch_pkg.get_validated(safe_cid(p_cid));
  BEGIN
    apex_json.open_array;
    FOR c IN (SELECT * FROM TABLE(afh_search_pkg.duplicate_candidates(
                p_title => p_title, p_description => p_description, p_application_id => l_l.application_id,
                p_page_id => l_l.page_id, p_type_code => p_type_code))) LOOP
      apex_json.open_object;
      apex_json.write('ticket_no', c.ticket_no);
      apex_json.write('title', c.title);
      apex_json.write('status_code', c.status_code);
      apex_json.write('status_label', c.status_label);
      apex_json.write('is_terminal', c.is_terminal);
      apex_json.write('application_name', c.application_name);
      apex_json.write('page_name', c.page_name);
      apex_json.write('score', c.score);
      apex_json.write('explanation', c.explanation);
      apex_json.write('ticket_url', apex_page.get_url(p_page => 10, p_items => 'P10_TICKET_NO', p_values => c.ticket_no));
      apex_json.close_object;
    END LOOP;
    apex_json.close_array;
  EXCEPTION WHEN OTHERS THEN
    apex_json.open_array; apex_json.close_array;   -- AFH-SRCH-001: suggestions are optional
  END dup_candidates;

  -- ------------------------------------------------------------------ files
  -- Collection AFH_FILES_<cid>: c001 file name, c002 mime, c003 kind, c004 caption,
  -- n001 size, clob001 annotation JSON, blob001 content.
  PROCEDURE stage_file(p_cid IN VARCHAR2, p_file_name IN VARCHAR2, p_mime_type IN VARCHAR2, p_size IN NUMBER, p_data_url IN CLOB) IS
    l_cid  VARCHAR2(32) := safe_cid(p_cid);
    l_l    afh_launch_pkg.t_launch := afh_launch_pkg.get_validated(l_cid);
    l_coll VARCHAR2(60) := files_coll(l_cid);
    l_blob BLOB;
    l_mime VARCHAR2(100 CHAR);
    l_name VARCHAR2(255 CHAR) := afh_attachment_pkg.safe_file_name(p_file_name);
    l_seq  NUMBER;
    l_total NUMBER := 0;
  BEGIN
    l_blob := data_url_to_blob(p_data_url, l_mime);
    IF l_blob IS NULL THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_upl_001, 'The file could not be read.');
    END IF;
    afh_attachment_pkg.validate_file(l_name, NVL(p_mime_type, l_mime), DBMS_LOB.getlength(l_blob));
    IF apex_collection.collection_exists(l_coll) THEN
      SELECT NVL(SUM(n001), 0) INTO l_total FROM apex_collections WHERE collection_name = l_coll;
    ELSE
      apex_collection.create_collection(l_coll);
    END IF;
    IF l_total + DBMS_LOB.getlength(l_blob) > afh_attachment_pkg.max_ticket_bytes THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_upl_002, 'The attachments for one ticket cannot exceed '
        || ROUND(afh_attachment_pkg.max_ticket_bytes / 1048576) || ' MB in total.');
    END IF;
    l_seq := apex_collection.add_member(p_collection_name => l_coll, p_c001 => l_name, p_c002 => NVL(p_mime_type, l_mime),
                                        p_c003 => afh_attachment_pkg.c_kind_file, p_n001 => DBMS_LOB.getlength(l_blob), p_blob001 => l_blob);
    apex_json.open_object;
    apex_json.write('ok', TRUE);
    apex_json.write('id', l_seq);
    apex_json.write('name', l_name);
    apex_json.write('size', DBMS_LOB.getlength(l_blob));
    apex_json.close_object;
  EXCEPTION WHEN OTHERS THEN
    out_error(safe_message);
  END stage_file;

  PROCEDURE remove_file(p_cid IN VARCHAR2, p_seq IN NUMBER) IS
    l_cid  VARCHAR2(32) := safe_cid(p_cid);
    l_l    afh_launch_pkg.t_launch := afh_launch_pkg.get_validated(l_cid);
    l_coll VARCHAR2(60) := files_coll(l_cid);
  BEGIN
    IF apex_collection.collection_exists(l_coll) THEN
      apex_collection.delete_member(p_collection_name => l_coll, p_seq => p_seq);
    END IF;
    apex_json.open_object; apex_json.write('ok', TRUE); apex_json.close_object;
  EXCEPTION WHEN OTHERS THEN
    out_error(safe_message);
  END remove_file;

  PROCEDURE annotate(p_cid IN VARCHAR2, p_png_data_url IN CLOB, p_annotation_json IN CLOB) IS
    l_cid  VARCHAR2(32) := safe_cid(p_cid);
    l_l    afh_launch_pkg.t_launch := afh_launch_pkg.get_validated(l_cid);
    l_coll VARCHAR2(60) := files_coll(l_cid);
    l_blob BLOB;
    l_mime VARCHAR2(100 CHAR);
    l_seq  NUMBER;
  BEGIN
    l_blob := data_url_to_blob(p_png_data_url, l_mime);
    IF l_blob IS NULL OR l_mime <> 'image/png' THEN
      afh_security_pkg.raise_error(afh_security_pkg.c_err_upl_001, 'The annotated screenshot must be a PNG image.');
    END IF;
    IF NOT apex_collection.collection_exists(l_coll) THEN
      apex_collection.create_collection(l_coll);
    END IF;
    FOR r IN (SELECT seq_id FROM apex_collections WHERE collection_name = l_coll AND c003 = afh_attachment_pkg.c_kind_annotated) LOOP
      apex_collection.delete_member(l_coll, r.seq_id);   -- one annotated version at a time
    END LOOP;
    l_seq := apex_collection.add_member(p_collection_name => l_coll, p_c001 => 'screenshot-annotated.png', p_c002 => 'image/png',
                                        p_c003 => afh_attachment_pkg.c_kind_annotated, p_n001 => DBMS_LOB.getlength(l_blob),
                                        p_clob001 => p_annotation_json, p_blob001 => l_blob);
    apex_json.open_object; apex_json.write('ok', TRUE); apex_json.write('id', l_seq); apex_json.close_object;
  EXCEPTION WHEN OTHERS THEN
    out_error(safe_message);
  END annotate;

  PROCEDURE annotate_ajax(p_cid IN VARCHAR2, p_png_data_url IN CLOB, p_json_parts IN apex_application_global.vc_arr2) IS
    l_json CLOB;
  BEGIN
    DBMS_LOB.createtemporary(l_json, TRUE, DBMS_LOB.call);
    FOR i IN 1 .. p_json_parts.COUNT LOOP
      IF p_json_parts(i) IS NOT NULL THEN
        DBMS_LOB.writeappend(l_json, LENGTH(p_json_parts(i)), p_json_parts(i));
      END IF;
    END LOOP;
    annotate(p_cid => p_cid, p_png_data_url => p_png_data_url, p_annotation_json => l_json);
  END annotate_ajax;

  -- ------------------------------------------------------------------ submit
  FUNCTION client_meta(p_client IN CLOB) RETURN CLOB IS
    l_v   apex_json.t_values;
    l_out CLOB;
    l_ua  VARCHAR2(500 CHAR);
  BEGIN
    IF p_client IS NULL THEN RETURN NULL; END IF;
    apex_json.parse(l_v, p_client);
    l_ua := apex_json.get_varchar2(p_path => 'userAgent', p_values => l_v);
    apex_json.initialize_clob_output;
    apex_json.open_object;
    apex_json.write('browser',        NVL(apex_json.get_varchar2(p_path => 'browser', p_values => l_v), SUBSTR(l_ua, 1, 100)));
    apex_json.write('browserVersion', apex_json.get_varchar2(p_path => 'browserVersion', p_values => l_v));
    apex_json.write('os',             NVL(apex_json.get_varchar2(p_path => 'os', p_values => l_v), apex_json.get_varchar2(p_path => 'platform', p_values => l_v)));
    apex_json.write('device',         NVL(apex_json.get_varchar2(p_path => 'device', p_values => l_v), 'DESKTOP'));
    apex_json.write('viewport',       apex_json.get_varchar2(p_path => 'viewport', p_values => l_v));
    apex_json.write('locale',         apex_json.get_varchar2(p_path => 'locale', p_values => l_v));
    apex_json.write('timeZone',       apex_json.get_varchar2(p_path => 'timeZone', p_values => l_v));
    apex_json.write('apexVersion',    apex_json.get_varchar2(p_path => 'apexVersion', p_values => l_v));
    apex_json.write('requestMode',    apex_json.get_varchar2(p_path => 'requestMode', p_values => l_v));
    apex_json.close_object;
    l_out := apex_json.get_clob_output;
    apex_json.free_output;
    apex_json.initialize_output(p_http_header => FALSE);  -- back to HTP: free_output leaves output detached
    RETURN l_out;
  END client_meta;

  PROCEDURE store_capture(p_ticket_id IN NUMBER, p_cid IN VARCHAR2, p_l IN afh_launch_pkg.t_launch, p_remove_screenshot IN VARCHAR2) IS
    l_coll   VARCHAR2(60) := capture_coll(p_cid);
    l_files  VARCHAR2(60) := files_coll(p_cid);
    l_srv    CLOB;
    l_srv_rc VARCHAR2(30 CHAR);
    l_items  CLOB;
    l_ctx_id NUMBER;
    l_att_id NUMBER;
    l_item_rc VARCHAR2(30 CHAR);
  BEGIN
    FOR c IN (SELECT * FROM apex_collections WHERE collection_name = l_coll AND c050 = 'HEAD') LOOP
      l_srv := part(l_coll, 'SERVER');
      IF p_l.identity_mode = afh_registry_pkg.c_mode_shared_session AND p_l.host_session_id IS NOT NULL THEN
        l_srv := afh_context_pkg.read_host_session_items(p_l.host_session_id, p_l.apex_app_id, p_l.page_id, l_srv_rc);
      END IF;
      l_items := merge_items(part(l_coll, 'ITEMS'), l_srv);
      l_item_rc := CASE WHEN c.c002 = 'SUCCESS' AND l_srv_rc IN ('FAILED') THEN 'PARTIAL' ELSE c.c002 END;
      l_ctx_id := afh_context_pkg.store_context(
        p_ticket_id => p_ticket_id, p_correlation_id => p_cid, p_contract_version => afh_launch_pkg.c_contract_version,
        p_capture_result_code => afh_context_pkg.overall_result(l_item_rc, c.c001, c.c003),
        p_item_result_code => l_item_rc, p_screenshot_result_code => c.c001, p_debug_result_code => c.c003,
        p_client_meta_json => client_meta(part(l_coll, 'CLIENT')), p_source_meta_json => part(l_coll, 'SOURCE'), p_items_json => l_items,
        p_partial_reason => CASE WHEN l_srv_rc = 'FAILED' THEN 'SERVER_STATE_UNAVAILABLE' END);
      IF c.blob001 IS NOT NULL AND NVL(p_remove_screenshot, 'N') <> 'Y' THEN
        l_att_id := afh_attachment_pkg.add_attachment(
          p_ticket_id => p_ticket_id, p_file_name => 'screenshot.png', p_mime_type => NVL(c.c005, 'image/png'),
          p_content => c.blob001, p_kind_code => afh_attachment_pkg.c_kind_screenshot, p_caption => 'Automatic screenshot');
        FOR a IN (SELECT clob001, blob001 FROM apex_collections
                   WHERE collection_name = l_files AND c003 = afh_attachment_pkg.c_kind_annotated) LOOP
          l_att_id := afh_attachment_pkg.add_annotated_screenshot(l_att_id, a.blob001, a.clob001);
        END LOOP;
      END IF;
    END LOOP;
  END store_capture;

  PROCEDURE store_files(p_ticket_id IN NUMBER, p_cid IN VARCHAR2) IS
    l_coll VARCHAR2(60) := files_coll(p_cid);
    l_id   NUMBER;
  BEGIN
    IF NOT apex_collection.collection_exists(l_coll) THEN RETURN; END IF;
    FOR f IN (SELECT * FROM apex_collections WHERE collection_name = l_coll AND c003 = afh_attachment_pkg.c_kind_file ORDER BY seq_id) LOOP
      l_id := afh_attachment_pkg.add_attachment(
        p_ticket_id => p_ticket_id, p_file_name => f.c001, p_mime_type => f.c002, p_content => f.blob001,
        p_kind_code => afh_attachment_pkg.c_kind_file, p_caption => f.c004);
    END LOOP;
  END store_files;

  PROCEDURE cleanup(p_cid IN VARCHAR2) IS
  BEGIN
    IF apex_collection.collection_exists(capture_coll(p_cid)) THEN apex_collection.delete_collection(capture_coll(p_cid)); END IF;
    IF apex_collection.collection_exists(files_coll(p_cid)) THEN apex_collection.delete_collection(files_coll(p_cid)); END IF;
  END cleanup;

  PROCEDURE write_success(p_ticket_id IN NUMBER) IS
    l_no VARCHAR2(20 CHAR);
  BEGIN
    SELECT ticket_no INTO l_no FROM afh_tickets WHERE ticket_id = p_ticket_id;
    apex_json.open_object;
    apex_json.write('ok', TRUE);
    apex_json.write('ticket_no', l_no);
    apex_json.write('ticket_url', apex_page.get_url(p_page => 10, p_items => 'P10_TICKET_NO', p_values => l_no));
    apex_json.close_object;
  END write_success;

  PROCEDURE submit(p_cid IN VARCHAR2, p_remove_screenshot IN VARCHAR2) IS
    l_cid       VARCHAR2(32) := safe_cid(p_cid);
    l_l         afh_launch_pkg.t_launch;
    l_ticket_id NUMBER;
    l_ctx_rc    VARCHAR2(30 CHAR);
  BEGIN
    l_ticket_id := afh_launch_pkg.ticket_for_correlation(l_cid);
    IF l_ticket_id IS NOT NULL THEN
      write_success(l_ticket_id);                                   -- idempotent retry (spec §22.2)
      RETURN;
    END IF;
    l_l := afh_launch_pkg.get_validated(l_cid);
    l_ctx_rc := context_result(l_cid);
    l_ticket_id := afh_ticket_pkg.create_ticket(
      p_type_code => v('P20_TYPE_CODE'), p_title => v('P20_TITLE'), p_description => v('P20_DESCRIPTION'),
      p_application_id => l_l.application_id, p_environment_id => l_l.environment_id,
      p_page_id => l_l.page_id, p_page_name => l_l.page_name, p_source_url => l_l.source_url, p_app_version => l_l.app_version,
      p_category_id => TO_NUMBER(v('P20_CATEGORY_ID')),
      p_proposed_priority_code => v('P20_PRIORITY_CODE'), p_proposed_severity_code => v('P20_SEVERITY_CODE'), p_proposed_impact_code => v('P20_IMPACT_CODE'),
      p_field_values_json => v('P20_FIELDS_JSON'), p_follow_yn => NVL(v('P20_FOLLOW_YN'), 'Y'),
      p_context_result_code => l_ctx_rc, p_correlation_id => l_cid);
    store_capture(l_ticket_id, l_cid, l_l, p_remove_screenshot);
    store_files(l_ticket_id, l_cid);
    IF v('P20_AFFECTED_TICKET') IS NOT NULL AND afh_ticket_pkg.get_ticket_id(v('P20_AFFECTED_TICKET')) IS NOT NULL THEN
      afh_ticket_pkg.mark_affected(afh_ticket_pkg.get_ticket_id(v('P20_AFFECTED_TICKET')));
    END IF;
    afh_launch_pkg.consume(l_cid, l_ticket_id);
    COMMIT;                                                          -- the page callback owns the transaction
    cleanup(l_cid);
    write_success(l_ticket_id);
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    out_error(safe_message);
  END submit;
END afh_submit_pkg;
/
