prompt --application/pages/page_00010
begin
--   Manifest
--     PAGE: 00010
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>68393727750894466
,p_default_application_id=>108
,p_default_id_offset=>0
,p_default_owner=>'AFH'
);
wwv_flow_imp_page.create_page(
 p_id=>10
,p_name=>'Ticket Detail'
,p_alias=>'TICKET'
,p_step_title=>'&P10_TICKET_NO.'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Region selector tabs: turn the trailing "(n)" of a tab label into a count pill. Counts come from',
'   the page items P10_ACTIVITY_COUNT / P10_ATTACHMENT_COUNT / P10_NOTE_COUNT substituted in the region titles. */',
'$(''.apex-rds a'').each(function () {',
'  var $a = $(this), $s = $a.find(''span'').first(), m = $s.text().match(/^(.*?)\s*\((\d+)\)\s*$/);',
'  if (m) { $s.text(m[1]); $s.append('' <span class="afh-rds-count">'' + m[2] + ''</span>''); }',
'});',
'/* AI Recommends: play the analysis steps, then reveal the recommendation. */',
'(function () {',
'  var $ai = $(''.afh-ai''), steps, i = 0, wait;',
'  if (!$ai.length) { return; }',
'  steps = $ai.find(''.afh-ai-run li'');',
'  wait = (window.matchMedia && window.matchMedia(''(prefers-reduced-motion: reduce)'').matches) ? 0 : 900;',
'  function next() {',
'    if (i > 0) { steps.eq(i - 1).removeClass(''is-active'').addClass(''is-done''); }',
'    if (i >= steps.length) { $ai.attr(''data-state'', ''done''); return; }',
'    steps.eq(i).addClass(''is-active''); i += 1; window.setTimeout(next, wait);',
'  }',
'  next();',
'  $ai.on(''click'', ''.afh-ai-copy'', function () {',
'    var text = $(this).closest(''.afh-ai-code'').find(''code'').text();',
'    if (navigator.clipboard) { navigator.clipboard.writeText(text).then(function () { apex.message.showPageSuccess(''Copied to clipboard.''); }); }',
'  });',
'  $ai.on(''click'', ''[data-vote]'', function () {',
'    $ai.find(''[data-vote]'').removeClass(''is-on'').attr(''aria-pressed'', ''false'');',
'    $(this).addClass(''is-on'').attr(''aria-pressed'', ''true'');',
'    apex.message.showPageSuccess(''Thanks for the feedback.'');',
'  });',
'}());'))
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Ticket detail: header, facts, actions, comment composer, cards and the package-rendered timeline. */',
'.afh-head { padding: 2px 0 10px; }',
'.afh-head-top { display: flex; align-items: center; gap: 10px; font-family: var(--afh-mono); font-size: 0.78rem; color: var(--afh-ink-muted); }',
'.afh-no { font-weight: 700; letter-spacing: .04em; color: var(--afh-ink-soft); }',
'.afh-title { font-family: var(--afh-display); font-size: clamp(1.45rem, 2.4vw, 2.05rem); line-height: 1.15; letter-spacing: -.02em; color: var(--afh-ink); margin: 6px 0 8px; }',
'.afh-head .afh-meta { font-family: var(--afh-mono); font-size: 0.72rem; color: var(--afh-ink-muted); }',
'.afh-head .t-Alert { margin: 10px 0 0; }',
'.afh-source { margin-top: 8px; font-size: 0.85rem; }',
'.afh-source a { color: var(--afh-blue); font-weight: 600; text-decoration: none; border-bottom: 1px solid var(--afh-blue-soft); }',
'.afh-source a:hover { border-bottom-color: var(--afh-blue); }',
'.afh-description { font-size: 0.95rem; line-height: 1.55; color: var(--afh-ink); margin-bottom: 6px; }',
'.afh-field { display: grid; grid-template-columns: minmax(140px, 200px) 1fr; gap: 4px 16px; padding: 9px 0; border-top: 1px solid var(--afh-border); }',
'.afh-field-label { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: .05em; color: var(--afh-ink-faint); padding-top: 2px; }',
'.afh-field-value { font-size: 0.9rem; line-height: 1.5; color: var(--afh-ink); }',
'.afh-workflow { display: flex; flex-wrap: wrap; gap: 8px; padding: 2px 0; }',
'#afh-actions .t-Button { margin: 0 6px 6px 0; }',
'#afh-activity .t-Comments-userIcon { background: var(--afh-paper-3); color: var(--afh-ink-muted); }',
'#afh-activity .t-Comments-comment { font-size: 0.9rem; line-height: 1.5; }',
'#afh-activity .t-Comments-info { font-family: var(--afh-mono); font-size: 0.7rem; color: var(--afh-ink-faint); }',
'.t-PageTemplate--rightSideCol .t-Body-actions, .t-PageTemplate--rightSideCol .t-Body-actionsContent { width: 340px; }',
'.t-PageTemplate--rightSideCol .t-Body-actionsToggle { display: none; }',
'.t-PageTemplate--rightSideCol .t-Body-actionsContent { padding-top: 12px; }',
'#afh-actions .t-Region-body { display: flex; flex-wrap: wrap; gap: 6px; }',
'#afh-actions .t-Button { margin: 0; }',
'#P10_COMMENT_BODY { width: 100%; max-width: 1100px; }   /* height is the item''s declarative Height attribute */',
'#afh-activity .afh-eyebrow { display: inline-block; margin-right: 6px; }',
'.afh-detail .t-Region { border: 1px solid var(--afh-border); border-radius: var(--afh-radius-md); box-shadow: var(--afh-shadow); background: var(--afh-paper); }',
'.afh-detail .t-Region-header { background: var(--afh-paper-2); border-bottom: 1px solid var(--afh-border); }',
'.afh-detail .t-Region-title { font-family: var(--afh-display); font-size: 1.02rem; letter-spacing: -.01em; }',
'.afh-detail .afh-head { background: var(--afh-paper); border: 1px solid var(--afh-border); border-left: 4px solid var(--afh-signal); border-radius: var(--afh-radius-md); box-shadow: var(--afh-shadow); padding: 16px 20px 14px; margin-bottom: 14px; }',
'.afh-detail .t-Body-actionsContent .t-Region { box-shadow: none; }',
'.afh-detail #afh-add-comment .t-Form-inputContainer { width: 100%; }',
'.afh-timeline { list-style: none; margin: 0; padding: 4px 0 0 2px; position: relative; }',
'.afh-timeline::before { content: ""; position: absolute; left: 17px; top: 14px; bottom: 14px; width: 2px; background: var(--afh-border); }',
'.afh-tl { position: relative; display: grid; grid-template-columns: 34px 1fr; gap: 12px; padding: 7px 0; }',
'.afh-tl-dot { width: 34px; height: 34px; border-radius: 50%; background: var(--afh-paper-2); border: 1px solid var(--afh-border); display: flex; align-items: center; justify-content: center; font-size: .8rem; color: var(--afh-ink-muted); position: re'
||'lative; z-index: 1; }',
'.afh-tl--comment .afh-tl-dot { background: var(--afh-teal); border-color: var(--afh-teal); color: #fff; font-weight: 700; font-family: var(--afh-display); font-size: .95rem; }',
'.afh-tl--attachment .afh-tl-dot { background: var(--afh-purple-soft); border-color: var(--afh-purple-soft); color: var(--afh-purple); }',
'.afh-tl-main { min-width: 0; padding-top: 6px; }',
'.afh-tl-meta { font-family: var(--afh-mono); font-size: .7rem; color: var(--afh-ink-faint); display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }',
'.afh-tl-meta strong { color: var(--afh-ink-soft); font-weight: 700; }',
'.afh-tl-meta .afh-eyebrow { margin: 0; }',
'.afh-tl-text { font-size: .88rem; color: var(--afh-ink-soft); line-height: 1.5; margin-top: 2px; }',
'.afh-tl--comment .afh-tl-body { margin-top: 8px; background: var(--afh-paper-2); border: 1px solid var(--afh-border); border-radius: var(--afh-radius-sm); padding: 10px 14px; font-size: .93rem; line-height: 1.55; color: var(--afh-ink); }',
'.afh-tl-body p:last-child { margin-bottom: 0; }',
'.afh-tl-body code { font-family: var(--afh-mono); font-size: .85em; background: var(--afh-paper-3); padding: 1px 4px; border-radius: 3px; }',
'.afh-tl-empty { list-style: none; padding: 18px 12px; text-align: center; color: var(--afh-ink-faint); font-size: .85rem; }',
'/* Region selector: display-font tabs, signal underline on the active one, count pill */',
'.apex-rds { margin-bottom: 12px; }',
'.apex-rds .apex-rds-item a { font-family: var(--afh-display); font-size: 1.02rem; font-weight: 600; color: var(--afh-ink-soft); padding: 10px 14px; }',
'.apex-rds .apex-rds-item a:hover { color: var(--afh-ink); }',
'.apex-rds .apex-rds-item.apex-rds-selected a { color: var(--afh-ink); }',
'.afh-rds-count { display: inline-block; min-width: 1.6em; margin-left: 4px; padding: 0 7px; border-radius: 999px; font-family: var(--afh-body); font-size: .72rem; font-weight: 700; line-height: 1.6em; text-align: center; color: var(--afh-paper-0); ba'
||'ckground: var(--afh-ink-soft); vertical-align: 1px; }',
'.apex-rds .apex-rds-item.apex-rds-selected .afh-rds-count { background: var(--afh-signal); }',
'/* AI Recommends (build option AI_PREVIEW): analysis steps, then the recommendation card. */',
'#afh-ai-region .t-Region-header { border-left: 4px solid #5b4bd6; }',
'.afh-ai { --afh-ai: #5b4bd6; }',
'.afh-ai-run { list-style: none; margin: 0; padding: 4px 0; }',
'.afh-ai-run li { position: relative; padding: 6px 0 6px 28px; color: var(--afh-ink-muted); opacity: .35; transition: opacity .3s; }',
'.afh-ai-run li::before { content: ""; position: absolute; left: 4px; top: 9px; width: 12px; height: 12px; border-radius: 50%; border: 2px solid var(--afh-ai); box-sizing: border-box; }',
'.afh-ai-run li.is-active { opacity: 1; }',
'.afh-ai-run li.is-active::before { border-top-color: transparent; animation: afh-ai-spin .8s linear infinite; }',
'.afh-ai-run li.is-done { opacity: 1; }',
'.afh-ai-run li.is-done::before { background: var(--afh-ai); }',
'@keyframes afh-ai-spin { to { transform: rotate(360deg); } }',
'.afh-ai[data-state="thinking"] .afh-ai-result, .afh-ai[data-state="done"] .afh-ai-run { display: none; }',
'.afh-ai-result { animation: afh-ai-in .35s ease-out; }',
'@keyframes afh-ai-in { from { opacity: 0; transform: translateY(4px); } }',
'.afh-ai-top { display: flex; align-items: center; justify-content: space-between; gap: 12px; }',
'.afh-ai-label { font-size: .72rem; font-weight: 700; letter-spacing: .08em; text-transform: uppercase; color: var(--afh-ai); }',
'.afh-ai-conf { position: relative; width: 150px; height: 18px; border: 1px solid var(--afh-border); border-radius: 9px; overflow: hidden; }',
'.afh-ai-conf span { position: absolute; left: 0; top: 0; bottom: 0; background: rgba(91,75,214,.28); }',
'.afh-ai-conf b { position: relative; display: block; text-align: center; font-size: .72rem; line-height: 16px; }',
'.afh-ai-diag { font-size: 1.02rem; line-height: 1.5; margin: 8px 0 14px; }',
'.afh-ai-cols { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }',
'@media (max-width: 900px) { .afh-ai-cols { grid-template-columns: 1fr; } }',
'.afh-ai h4 { margin: 0 0 6px; font-size: .78rem; text-transform: uppercase; letter-spacing: .06em; color: var(--afh-ink-muted); }',
'.afh-ai-ev, .afh-ai-steps { margin: 0; padding-left: 18px; }',
'.afh-ai-ev li, .afh-ai-steps li { margin: 4px 0; }',
'.afh-ai-code { margin-top: 14px; border: 1px solid var(--afh-border); border-radius: var(--afh-radius-md); overflow: hidden; }',
'.afh-ai-code-head { display: flex; justify-content: space-between; align-items: center; padding: 4px 10px; background: var(--afh-paper-2); font-size: .78rem; color: var(--afh-ink-muted); }',
'.afh-ai-code pre { margin: 0; padding: 10px 12px; overflow: auto; font-family: var(--afh-mono); font-size: .8rem; }',
'.afh-ai-foot { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; margin-top: 14px; font-size: .78rem; color: var(--afh-ink-muted); }',
'.afh-ai-vote .t-Button.is-on { background: var(--afh-ai); color: #fff; }',
'@media (prefers-reduced-motion: reduce) { .afh-ai-run li.is-active::before, .afh-ai-result { animation: none; } }'))
,p_step_template=>2526646919027767344
,p_page_css_classes=>'afh-detail'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68608126239417213)
,p_protection_level=>'C'
,p_page_component_map=>'25'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(69004562144804439)
,p_plug_name=>'Region Selector'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--textContent:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>35
,p_location=>null
,p_plug_source_type=>'NATIVE_DISPLAY_SELECTOR'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_region_icons', 'N',
  'include_show_all', 'N',
  'rds_mode', 'STANDARD',
  'remember_selection', 'USER')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70300000000001220)
,p_plug_name=>'Add a comment'
,p_region_name=>'afh-add-comment'
,p_parent_plug_id=>wwv_flow_imp.id(69004562144804439)
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>55
,p_include_in_reg_disp_sel_yn=>'Y'
,p_plug_display_point=>'SUB_REGIONS'
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70300000000001290)
,p_plug_name=>'Activity (&P10_ACTIVITY_COUNT.)'
,p_region_name=>'afh-activity'
,p_parent_plug_id=>wwv_flow_imp.id(69004562144804439)
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--textContent:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>45
,p_include_in_reg_disp_sel_yn=>'Y'
,p_plug_display_point=>'SUB_REGIONS'
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN afh_ui_pkg.render_timeline(:P10_TICKET_ID, :APP_ID, :APP_SESSION);',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70300000000001380)
,p_name=>'Attachments (&P10_ATTACHMENT_COUNT.)'
,p_region_name=>'afh-attachments'
,p_parent_plug_id=>wwv_flow_imp.id(69004562144804439)
,p_template=>4072358936313175081
,p_display_sequence=>65
,p_include_in_reg_disp_sel_yn=>'Y'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--altRowsDefault:t-Report--rowHighlight'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT a.attachment_id,',
'       a.file_name,',
'       a.caption,',
'       a.kind_code,',
'       CASE a.kind_code WHEN ''SCREENSHOT'' THEN ''Screenshot'' WHEN ''SCREENSHOT_ANNOTATED'' THEN ''Annotated screenshot'' WHEN ''CONTEXT_EXPORT'' THEN ''Context export'' ELSE ''File'' END AS kind_label,',
'       a.mime_type,',
'       a.is_image_yn,',
'       CASE WHEN a.file_size >= 1048576 THEN ROUND(a.file_size / 1048576, 1) || '' MB'' ELSE ROUND(a.file_size / 1024) || '' KB'' END AS file_size_text,',
'       a.uploaded_by,',
'       a.uploaded_at,',
'       apex_util.prepare_url(''f?p='' || :APP_ID || '':10:'' || :APP_SESSION || '':APPLICATION_PROCESS=DOWNLOAD:NO::'') || ''&x01='' || a.attachment_id AS download_url,',
'       CASE WHEN a.mime_type LIKE ''image/%'' OR a.mime_type = ''application/pdf'' THEN ''<a href="'' || apex_util.prepare_url(''f?p='' || :APP_ID || '':10:'' || :APP_SESSION || '':APPLICATION_PROCESS=VIEW_ATTACHMENT:NO::'') || ''&x01='' || a.attachment_id || ''" t'
||'arget="_blank" rel="noopener" class="t-Button t-Button--noUI t-Button--icon" title="Open in a new tab" aria-label="Open in a new tab"><span class="t-Icon fa fa-eye" aria-hidden="true"></span></a>'' END AS view_html',
'  FROM afh_v_ticket_attachments_public a',
' WHERE a.ticket_id = :P10_TICKET_ID',
' ORDER BY a.uploaded_at DESC'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(69003398009804427)
,p_query_column_id=>1
,p_column_alias=>'ATTACHMENT_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(69003454785804428)
,p_query_column_id=>2
,p_column_alias=>'FILE_NAME'
,p_column_display_sequence=>20
,p_column_heading=>'File Name'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(69003595728804429)
,p_query_column_id=>3
,p_column_alias=>'CAPTION'
,p_column_display_sequence=>30
,p_column_heading=>'Caption'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(69003612135804430)
,p_query_column_id=>4
,p_column_alias=>'KIND_CODE'
,p_column_display_sequence=>40
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(69003744011804431)
,p_query_column_id=>5
,p_column_alias=>'KIND_LABEL'
,p_column_display_sequence=>50
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(69003889017804432)
,p_query_column_id=>6
,p_column_alias=>'MIME_TYPE'
,p_column_display_sequence=>60
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(69003952710804433)
,p_query_column_id=>7
,p_column_alias=>'IS_IMAGE_YN'
,p_column_display_sequence=>70
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(69004083993804434)
,p_query_column_id=>8
,p_column_alias=>'FILE_SIZE_TEXT'
,p_column_display_sequence=>80
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(69004124519804435)
,p_query_column_id=>9
,p_column_alias=>'UPLOADED_BY'
,p_column_display_sequence=>90
,p_column_heading=>'Uploaded By'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(69004272899804436)
,p_query_column_id=>10
,p_column_alias=>'UPLOADED_AT'
,p_column_display_sequence=>100
,p_column_heading=>'Uploaded At'
,p_column_format=>'DD-MON-YYYY HH:MIPM'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(69004343328804437)
,p_query_column_id=>11
,p_column_alias=>'DOWNLOAD_URL'
,p_column_display_sequence=>110
,p_column_heading=>'Download'
,p_column_html_expression=>'<a href="#DOWNLOAD_URL#" class="t-Button t-Button--noUI t-Button--icon" title="Download #FILE_NAME#" aria-label="Download #FILE_NAME#"><span class="t-Icon fa fa-download" aria-hidden="true"></span></a>'
,p_column_alignment=>'CENTER'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000099020)
,p_query_column_id=>12
,p_column_alias=>'VIEW_HTML'
,p_column_display_sequence=>105
,p_column_heading=>'Open'
,p_column_alignment=>'CENTER'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70300000000001520)
,p_plug_name=>'Add attachment'
,p_region_name=>'afh-add-attachment'
,p_parent_plug_id=>wwv_flow_imp.id(70300000000001380)
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_plug_new_grid_row=>false
,p_plug_display_point=>'SUB_REGIONS'
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70300000000001570)
,p_name=>'Internal notes (&P10_NOTE_COUNT.)'
,p_region_name=>'afh-notes'
,p_parent_plug_id=>wwv_flow_imp.id(69004562144804439)
,p_template=>4072358936313175081
,p_display_sequence=>75
,p_include_in_reg_disp_sel_yn=>'Y'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--scrollBody'
,p_component_template_options=>'[object Object]:[object Object]:[object Object]'
,p_display_point=>'SUB_REGIONS'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT comment_id, user_name, comment_date, body_html AS comment_text,',
'       CASE WHEN edit_count > 0 THEN ''<span class="t-Comments-date">edited</span>'' END AS attribute_1,',
'       ''<span class="fa fa-lock" aria-hidden="true"></span>'' AS user_icon, posted_at,',
'       NULL AS actions, NULL AS attribute_2, NULL AS attribute_3, NULL AS attribute_4',
'  FROM (SELECT n.*, TO_CHAR(posted_at, ''DD Mon YYYY HH24:MI'') AS comment_date, author_name AS user_name',
'          FROM TABLE(afh_comment_pkg.get_internal_notes(:P10_TICKET_ID)) n)',
' ORDER BY posted_at'))
,p_required_role=>wwv_flow_imp.id(68798617960373404)
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2613168815517880001
,p_query_num_rows=>200
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No internal notes.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001580)
,p_query_column_id=>1
,p_column_alias=>'COMMENT_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001590)
,p_query_column_id=>2
,p_column_alias=>'USER_NAME'
,p_column_display_sequence=>20
,p_column_heading=>'User'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001600)
,p_query_column_id=>3
,p_column_alias=>'COMMENT_DATE'
,p_column_display_sequence=>30
,p_column_heading=>'When'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001610)
,p_query_column_id=>4
,p_column_alias=>'COMMENT_TEXT'
,p_column_display_sequence=>40
,p_column_heading=>'Note'
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001620)
,p_query_column_id=>5
,p_column_alias=>'ATTRIBUTE_1'
,p_column_display_sequence=>50
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001630)
,p_query_column_id=>6
,p_column_alias=>'USER_ICON'
,p_column_display_sequence=>60
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001640)
,p_query_column_id=>7
,p_column_alias=>'POSTED_AT'
,p_column_display_sequence=>70
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000009010)
,p_query_column_id=>8
,p_column_alias=>'ACTIONS'
,p_column_display_sequence=>80
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000009020)
,p_query_column_id=>9
,p_column_alias=>'ATTRIBUTE_2'
,p_column_display_sequence=>90
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000009030)
,p_query_column_id=>10
,p_column_alias=>'ATTRIBUTE_3'
,p_column_display_sequence=>100
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000009040)
,p_query_column_id=>11
,p_column_alias=>'ATTRIBUTE_4'
,p_column_display_sequence=>110
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70300000000001010)
,p_plug_name=>'Header'
,p_region_name=>'afh-head'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_out CLOB;',
'  r afh_v_ticket_detail%ROWTYPE;',
'BEGIN',
'  SELECT * INTO r FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID;',
'  l_out := l_out || (''<div class="afh-head">'');',
'  l_out := l_out || (''<div class="afh-head-top"><span class="afh-no">'' || apex_escape.html(r.ticket_no) || ''</span>''',
'        || ''<span class="t-Badge afh-status afh-status--'' || apex_escape.html(r.status_color) || ''">'' || apex_escape.html(r.status_label) || ''</span>''',
'        || CASE WHEN r.is_archived = ''Y'' THEN ''<span class="t-Badge">Archived</span>'' END || ''</div>'');',
'  l_out := l_out || (''<h1 class="afh-title">'' || apex_escape.html(r.title) || ''</h1>'');',
'  l_out := l_out || (''<div class="afh-meta"><span class="fa '' || apex_escape.html(r.type_icon) || ''"></span> '' || apex_escape.html(r.type_label)',
unistr('        || '' \00B7 '' || apex_escape.html(r.application_name) || '' \00B7 '' || apex_escape.html(r.env_label)'),
unistr('        || '' \00B7 Page '' || apex_escape.html(r.page_id || '' '' || r.page_name)'),
unistr('        || '' \00B7 v'' || apex_escape.html(r.app_version)'),
unistr('        || '' \00B7 Reported by '' || apex_escape.html(r.reporter_name) || '' '' || TO_CHAR(r.submitted_at, ''DD Mon YYYY HH24:MI'') || ''</div>'');'),
'  IF r.master_ticket_no IS NOT NULL THEN',
'    l_out := l_out || (''<div class="t-Alert t-Alert--warning t-Alert--horizontal" role="status"><div class="t-Alert-body">This ticket was merged into ''',
'          || ''<a href="'' || apex_util.prepare_url(''f?p='' || :APP_ID || '':10:'' || :APP_SESSION || ''::NO::P10_TICKET_NO:'' || r.master_ticket_no) || ''">''',
'          || apex_escape.html(r.master_ticket_no) || ''</a>. Comments and evidence stay here for reference.</div></div>'');',
'  END IF;',
'  IF r.source_url IS NOT NULL THEN',
'    l_out := l_out || (''<div class="afh-source"><a href="'' || apex_escape.html_attribute(r.source_url) || ''" target="_blank" rel="noopener noreferrer">Open the page this was reported from</a></div>'');',
'  END IF;',
'  l_out := l_out || (''</div>'');',
'  RETURN l_out;',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70300000000001020)
,p_plug_name=>'Report'
,p_region_name=>'afh-report'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_out CLOB;',
'  l_desc CLOB;',
'BEGIN',
'  SELECT description INTO l_desc FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID;',
'  l_out := l_out || (''<div class="afh-description">'' || REPLACE(apex_escape.html(DBMS_LOB.substr(l_desc, 32000, 1)), CHR(10), ''<br>'') || ''</div>'');',
'  FOR f IN (SELECT label_snapshot, display_value FROM afh_v_ticket_field_values WHERE ticket_id = :P10_TICKET_ID ORDER BY display_seq) LOOP',
'    l_out := l_out || (''<div class="afh-field"><div class="afh-field-label">'' || apex_escape.html(f.label_snapshot) || ''</div>''',
'          || ''<div class="afh-field-value">'' || REPLACE(apex_escape.html(f.display_value), CHR(10), ''<br>'') || ''</div></div>'');',
'  END LOOP;',
'  RETURN l_out;',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70300000000001030)
,p_name=>'Facts'
,p_region_name=>'afh-facts'
,p_template=>4072358936313175081
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-AVPList--variableLabelLarge:t-AVPList--leftAligned'
,p_display_point=>'REGION_POSITION_03'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ''Priority'' AS attribute, priority_label || CASE WHEN priority_code <> proposed_priority_code THEN '' (proposed '' || proposed_priority_label || '')'' END AS value, 1 AS seq FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID',
'UNION ALL SELECT ''Severity'', severity_label || CASE WHEN severity_code <> proposed_severity_code THEN '' (proposed '' || proposed_severity_label || '')'' END, 2 FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID',
'UNION ALL SELECT ''Impact'', impact_label || CASE WHEN impact_code <> proposed_impact_code THEN '' (proposed '' || proposed_impact_label || '')'' END, 3 FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID',
'UNION ALL SELECT ''Category'', NVL(category_label, ''-''), 4 FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID',
'UNION ALL SELECT ''Assignee'', NVL(assignee_name, ''Unassigned''), 5 FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID',
'UNION ALL SELECT ''Queue owner'', NVL(owner_name, ''-''), 6 FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID',
'UNION ALL SELECT ''Target release'', NVL(release_label, ''-''), 7 FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID',
'UNION ALL SELECT ''Due'', NVL(TO_CHAR(due_date, ''DD Mon YYYY''), ''-''), 8 FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID',
'UNION ALL SELECT ''Followers'', TO_CHAR(follower_count), 9 FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID',
'UNION ALL SELECT ''Affected users'', TO_CHAR(affected_count), 10 FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID',
'UNION ALL SELECT ''Last activity'', TO_CHAR(last_activity_at, ''DD Mon YYYY HH24:MI''), 11 FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID',
'ORDER BY seq'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2100515124465797522
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001040)
,p_query_column_id=>1
,p_column_alias=>'ATTRIBUTE'
,p_column_display_sequence=>10
,p_column_heading=>'Attribute'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001050)
,p_query_column_id=>2
,p_column_alias=>'VALUE'
,p_column_display_sequence=>20
,p_column_heading=>'Value'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001060)
,p_query_column_id=>3
,p_column_alias=>'SEQ'
,p_column_display_sequence=>30
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70300000000001140)
,p_plug_name=>'Actions'
,p_region_name=>'afh-actions'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_03'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70300000000001650)
,p_name=>'Capture summary'
,p_region_name=>'afh-capture'
,p_template=>4072358936313175081
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#:t-AVPList--variableLabelLarge:t-AVPList--leftAligned'
,p_display_point=>'REGION_POSITION_03'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ''Captured'' AS attribute, TO_CHAR(captured_at, ''DD Mon YYYY HH24:MI:SS'') AS value, 1 AS seq FROM afh_v_ticket_context_summary WHERE ticket_id = :P10_TICKET_ID AND is_latest_yn = ''Y''',
'UNION ALL SELECT ''Result'', capture_result_code || '' (items '' || item_result_code || '', screenshot '' || screenshot_result_code || '', debug '' || debug_result_code || '')'', 2 FROM afh_v_ticket_context_summary WHERE ticket_id = :P10_TICKET_ID AND is_lates'
||'t_yn = ''Y''',
unistr('UNION ALL SELECT ''Items'', item_total || '' captured \00B7 '' || item_changed || '' changed \00B7 '' || item_excluded || '' excluded \00B7 '' || item_failed || '' failed'', 3 FROM afh_v_ticket_context_summary WHERE ticket_id = :P10_TICKET_ID AND is_latest_yn = ''Y'''),
unistr('UNION ALL SELECT ''Browser'', browser_name || '' '' || browser_version || '' \00B7 '' || os_name || '' \00B7 '' || device_type || '' \00B7 '' || viewport, 4 FROM afh_v_ticket_context_summary WHERE ticket_id = :P10_TICKET_ID AND is_latest_yn = ''Y'''),
unistr('UNION ALL SELECT ''Locale'', locale || '' \00B7 '' || time_zone || '' \00B7 APEX '' || apex_version, 5 FROM afh_v_ticket_context_summary WHERE ticket_id = :P10_TICKET_ID AND is_latest_yn = ''Y'''),
'UNION ALL SELECT ''Partial reason'', partial_reason, 6 FROM afh_v_ticket_context_summary WHERE ticket_id = :P10_TICKET_ID AND is_latest_yn = ''Y'' AND partial_reason IS NOT NULL',
'ORDER BY seq'))
,p_required_role=>wwv_flow_imp.id(68798617960373404)
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2100515124465797522
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No diagnostic context was captured for this ticket.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001660)
,p_query_column_id=>1
,p_column_alias=>'ATTRIBUTE'
,p_column_display_sequence=>10
,p_column_heading=>'Attribute'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001670)
,p_query_column_id=>2
,p_column_alias=>'VALUE'
,p_column_display_sequence=>20
,p_column_heading=>'Value'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001680)
,p_query_column_id=>3
,p_column_alias=>'SEQ'
,p_column_display_sequence=>30
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70300000000001690)
,p_plug_name=>'Diagnostic context'
,p_region_name=>'afh-context'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2664334895415463485
,p_plug_display_sequence=>85
,p_plug_new_grid_row=>false
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT i.item_name, i.item_type, i.browser_value, i.server_value, i.server_result_code, i.is_changed, i.capture_result_code, i.failure_reason, i.exclusion_reason',
'  FROM TABLE(afh_context_pkg.get_items(afh_context_pkg.latest_context_id(:P10_TICKET_ID))) i',
' ORDER BY i.context_item_id'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_no_data_found=>'No diagnostic context was captured for this ticket.'
,p_plug_required_role=>wwv_flow_imp.id(68798617960373404)
,p_prn_content_disposition=>'ATTACHMENT'
,p_prn_units=>'INCHES'
,p_prn_paper_size=>'LETTER'
,p_prn_width=>11
,p_prn_height=>8.5
,p_prn_orientation=>'HORIZONTAL'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(70300000000001700)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV'
,p_enable_mail_download=>'N'
,p_owner=>'AFH'
,p_internal_uid=>70300000000001700
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70300000000001710)
,p_db_column_name=>'ITEM_NAME'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'Item Name'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70300000000001720)
,p_db_column_name=>'ITEM_TYPE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'Item Type'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70300000000001730)
,p_db_column_name=>'BROWSER_VALUE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Browser Value'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70300000000001740)
,p_db_column_name=>'SERVER_VALUE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'Server Value'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70300000000001750)
,p_db_column_name=>'SERVER_RESULT_CODE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Server Result Code'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70300000000001760)
,p_db_column_name=>'IS_CHANGED'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Is Changed'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70300000000001770)
,p_db_column_name=>'CAPTURE_RESULT_CODE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Capture Result Code'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70300000000001780)
,p_db_column_name=>'FAILURE_REASON'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'Failure Reason'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70300000000001790)
,p_db_column_name=>'EXCLUSION_REASON'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'Exclusion Reason'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(70300000000001800)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'703001'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ITEM_NAME:ITEM_TYPE:BROWSER_VALUE:SERVER_VALUE:SERVER_RESULT_CODE:IS_CHANGED:CAPTURE_RESULT_CODE:FAILURE_REASON:EXCLUSION_REASON'
);
wwv_flow_imp_page.create_worksheet_condition(
 p_id=>wwv_flow_imp.id(70300000000001810)
,p_report_id=>wwv_flow_imp.id(70300000000001800)
,p_name=>'Changed'
,p_condition_type=>'HIGHLIGHT'
,p_allow_delete=>'N'
,p_column_name=>'IS_CHANGED'
,p_operator=>'='
,p_expr=>'Y'
,p_condition_sql=>' (case when ("IS_CHANGED" = #APXWS_EXPR#) then #APXWS_HL_ID# end) '
,p_condition_display=>'#APXWS_COL_NAME# = ''Y'' '
,p_enabled=>'Y'
,p_highlight_sequence=>10
,p_row_bg_color=>'#fff7e6'
);
wwv_flow_imp_page.create_worksheet_condition(
 p_id=>wwv_flow_imp.id(70300000000001820)
,p_report_id=>wwv_flow_imp.id(70300000000001800)
,p_name=>'Excluded'
,p_condition_type=>'HIGHLIGHT'
,p_allow_delete=>'N'
,p_column_name=>'CAPTURE_RESULT_CODE'
,p_operator=>'='
,p_expr=>'EXCLUDED'
,p_condition_sql=>' (case when ("CAPTURE_RESULT_CODE" = #APXWS_EXPR#) then #APXWS_HL_ID# end) '
,p_condition_display=>'#APXWS_COL_NAME# = ''EXCLUDED'' '
,p_enabled=>'Y'
,p_highlight_sequence=>20
,p_row_bg_color=>'#f3f4f6'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70300000000001840)
,p_plug_name=>'Triage'
,p_region_name=>'afh-triage'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_plug_new_grid_row=>false
,p_location=>null
,p_plug_required_role=>wwv_flow_imp.id(68798936619375152)
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70300000000001950)
,p_plug_name=>'Change status'
,p_region_name=>'afh-workflow'
,p_parent_plug_id=>wwv_flow_imp.id(70300000000001840)
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--noPadding:t-Region--noBorder'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_point=>'SUB_REGIONS'
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_out CLOB;',
'BEGIN',
'  l_out := l_out || (''<div class="afh-workflow">'');',
'  FOR t IN (SELECT * FROM TABLE(afh_workflow_pkg.allowed_transitions(:P10_TICKET_ID)) ORDER BY display_seq) LOOP',
'    l_out := l_out || (''<a class="t-Button t-Button--hot" href="''',
'          || apex_util.prepare_url(''f?p='' || :APP_ID || '':100:'' || :APP_SESSION || ''::NO::P100_TICKET_ID,P100_TO_STATUS:'' || :P10_TICKET_ID || '','' || t.to_status_code)',
'          || ''" role="button">'' || apex_escape.html(t.label) || ''</a> '');',
'  END LOOP;',
'  l_out := l_out || (''</div>'');',
'  RETURN l_out;',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
,p_plug_required_role=>wwv_flow_imp.id(68608126239417213)
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70300000000001960)
,p_name=>'Testing'
,p_region_name=>'afh-testing'
,p_template=>4072358936313175081
,p_display_sequence=>105
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT test_result_id, requested_at, requested_by_display_name, assignee_display_name, environment_label, app_version, result_label, result_code,',
'       completed_at, completed_by_display_name, DBMS_LOB.substr(acceptance_criteria, 500, 1) AS criteria, DBMS_LOB.substr(notes, 500, 1) AS notes,',
'       CASE WHEN result_code = ''PENDING'' THEN ''Record result'' END AS record_link',
'  FROM afh_v_ticket_tests',
' WHERE ticket_id = :P10_TICKET_ID',
' ORDER BY requested_at DESC'))
,p_required_role=>wwv_flow_imp.id(68608126239417213)
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No tests requested.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001970)
,p_query_column_id=>1
,p_column_alias=>'TEST_RESULT_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001980)
,p_query_column_id=>2
,p_column_alias=>'REQUESTED_AT'
,p_column_display_sequence=>20
,p_column_heading=>'Requested'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000001990)
,p_query_column_id=>3
,p_column_alias=>'REQUESTED_BY_DISPLAY_NAME'
,p_column_display_sequence=>30
,p_column_heading=>'Requested by'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002000)
,p_query_column_id=>4
,p_column_alias=>'ASSIGNEE_DISPLAY_NAME'
,p_column_display_sequence=>40
,p_column_heading=>'Tester'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002010)
,p_query_column_id=>5
,p_column_alias=>'ENVIRONMENT_LABEL'
,p_column_display_sequence=>50
,p_column_heading=>'Environment'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002020)
,p_query_column_id=>6
,p_column_alias=>'APP_VERSION'
,p_column_display_sequence=>60
,p_column_heading=>'Version'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002030)
,p_query_column_id=>7
,p_column_alias=>'RESULT_LABEL'
,p_column_display_sequence=>70
,p_column_heading=>'Result'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002040)
,p_query_column_id=>8
,p_column_alias=>'RESULT_CODE'
,p_column_display_sequence=>80
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002050)
,p_query_column_id=>9
,p_column_alias=>'COMPLETED_AT'
,p_column_display_sequence=>90
,p_column_heading=>'Completed'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002060)
,p_query_column_id=>10
,p_column_alias=>'COMPLETED_BY_DISPLAY_NAME'
,p_column_display_sequence=>100
,p_column_heading=>'Completed by'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002070)
,p_query_column_id=>11
,p_column_alias=>'CRITERIA'
,p_column_display_sequence=>110
,p_column_heading=>'Acceptance criteria'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002080)
,p_query_column_id=>12
,p_column_alias=>'NOTES'
,p_column_display_sequence=>120
,p_column_heading=>'Notes'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002090)
,p_query_column_id=>13
,p_column_alias=>'RECORD_LINK'
,p_column_display_sequence=>130
,p_column_link=>'f?p=&APP_ID.:101:&SESSION.::&DEBUG.:101:P101_TEST_RESULT_ID:#TEST_RESULT_ID#'
,p_column_linktext=>'#RECORD_LINK#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70300000000002100)
,p_name=>'Relations'
,p_region_name=>'afh-relations'
,p_template=>4072358936313175081
,p_display_sequence=>115
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT relation_label, related_ticket_no, related_title, related_status_label, reason, is_active,',
'       apex_util.prepare_url(''f?p='' || :APP_ID || '':10:'' || :APP_SESSION || ''::NO::P10_TICKET_NO:'' || related_ticket_no) AS open_url',
'  FROM afh_v_ticket_relations',
' WHERE ticket_id = :P10_TICKET_ID AND is_active = ''Y''',
' ORDER BY relation_code, related_ticket_no'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No related tickets.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002110)
,p_query_column_id=>1
,p_column_alias=>'RELATION_LABEL'
,p_column_display_sequence=>10
,p_column_heading=>'Relation'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002120)
,p_query_column_id=>2
,p_column_alias=>'RELATED_TICKET_NO'
,p_column_display_sequence=>20
,p_column_heading=>'Ticket'
,p_column_link=>'&OPEN_URL.'
,p_column_linktext=>'#RELATED_TICKET_NO#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002130)
,p_query_column_id=>3
,p_column_alias=>'RELATED_TITLE'
,p_column_display_sequence=>30
,p_column_heading=>'Title'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002140)
,p_query_column_id=>4
,p_column_alias=>'RELATED_STATUS_LABEL'
,p_column_display_sequence=>40
,p_column_heading=>'Status'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002150)
,p_query_column_id=>5
,p_column_alias=>'REASON'
,p_column_display_sequence=>50
,p_column_heading=>'Reason'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002160)
,p_query_column_id=>6
,p_column_alias=>'IS_ACTIVE'
,p_column_display_sequence=>60
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70300000000002170)
,p_query_column_id=>7
,p_column_alias=>'OPEN_URL'
,p_column_display_sequence=>70
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70300000000099010)
,p_plug_name=>'Assigned to you'
,p_region_name=>'afh-assigned-note'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>15
,p_plug_display_point=>'REGION_POSITION_03'
,p_plug_source=>'<p class="afh-assigned-note"><span class="fa fa-bell" aria-hidden="true"></span> This ticket is assigned to you, so you always follow it and its notifications cannot be muted.</p>'
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'afh_ticket_pkg.is_assignee(:P10_TICKET_ID)'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(72000000000000110)
,p_plug_name=>'AI Recommends'
,p_region_name=>'afh-ai-region'
,p_region_template_options=>'#DEFAULT#:js-useLocalStorage:is-collapsed:t-Region--scrollBody'
,p_plug_template=>2664334895415463485
,p_plug_display_sequence=>30
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  -- AI Recommends (demo, build option AI_PREVIEW): a rule-based stand-in for the planned AI',
'  -- assistant. Reads the ticket, its captured context and the host page from the APEX dictionary.',
'  l_out      CLOB;',
'  l_no       VARCHAR2(30);',
'  l_type     VARCHAR2(30);',
'  l_title    VARCHAR2(4000);',
'  l_text     VARCHAR2(4000);',
'  l_app      VARCHAR2(255);',
'  l_app_id   NUMBER;',
'  l_apex_id  NUMBER;',
'  l_page     NUMBER;',
'  l_pname    VARCHAR2(255);',
'  l_mode     VARCHAR2(10);',
'  l_focus    VARCHAR2(255);',
'  l_bval     VARCHAR2(4000);',
'  l_sval     VARCHAR2(4000);',
'  l_changed  PLS_INTEGER := 0;',
'  l_excl     VARCHAR2(255);',
'  l_items    PLS_INTEGER := 0;',
'  l_procs    PLS_INTEGER := 0;',
'  l_vals     PLS_INTEGER := 0;',
'  l_regs     PLS_INTEGER := 0;',
'  l_proc     VARCHAR2(255);',
'  l_psrc     VARCHAR2(4000);',
'  l_avg      NUMBER;',
'  l_views    PLS_INTEGER := 0;',
'  l_conf     PLS_INTEGER;',
'  l_diag     VARCHAR2(4000);',
'  l_ev       VARCHAR2(32767);',
'  l_steps    VARCHAR2(32767);',
'  l_code     VARCHAR2(32767);',
'  l_code_t   VARCHAR2(200);',
'  l_sql      VARCHAR2(32767);',
'  l_api      VARCHAR2(128);',
'  l_parms    VARCHAR2(4000);',
'  l_key      VARCHAR2(255);',
'  l_nparm    PLS_INTEGER := 0;',
'  FUNCTION h(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN apex_escape.html(p); END;',
'  FUNCTION cut(p VARCHAR2, n PLS_INTEGER DEFAULT 40) RETURN VARCHAR2 IS',
unistr('  BEGIN RETURN CASE WHEN p IS NULL THEN ''(empty)'' WHEN LENGTH(p) > n THEN SUBSTR(p, 1, n) || ''\2026'' ELSE p END; END;'),
'  FUNCTION li(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN ''<li>'' || p || ''</li>''; END;',
'  FUNCTION code_block(p_label VARCHAR2, p_code VARCHAR2) RETURN VARCHAR2 IS',
'  BEGIN',
'    RETURN ''<div class="afh-ai-code"><div class="afh-ai-code-head"><span>'' || h(p_label) || ''</span>''',
'        || ''<button type="button" class="t-Button t-Button--small t-Button--noUI afh-ai-copy">Copy</button></div>''',
'        || ''<pre><code>'' || h(p_code) || ''</code></pre></div>'';',
'  END;',
'BEGIN',
'  SELECT ticket_no, type_code, title, SUBSTR(DBMS_LOB.substr(description, 2000, 1), 1, 2000), application_name, application_id, page_id, page_name',
'    INTO l_no, l_type, l_title, l_text, l_app, l_app_id, l_page, l_pname',
'    FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID;',
'',
'  BEGIN SELECT apex_app_id INTO l_apex_id FROM afh_applications WHERE application_id = l_app_id;',
'  EXCEPTION WHEN NO_DATA_FOUND THEN l_apex_id := NULL; END;',
'',
'  -- Captured context: changed fields and excluded credentials (the package enforces authorization).',
'  BEGIN',
'    FOR i IN (SELECT item_name, browser_value, server_value, is_changed, exclusion_reason',
'                FROM TABLE(afh_context_pkg.get_items(afh_context_pkg.latest_context_id(:P10_TICKET_ID)))',
'               ORDER BY CASE WHEN item_name LIKE ''%AMOUNT%'' OR item_name LIKE ''%DATE%'' THEN 0 ELSE 1 END, context_item_id) LOOP',
'      IF i.exclusion_reason IS NOT NULL THEN l_excl := NVL(l_excl, i.item_name);',
'      ELSIF i.is_changed = ''Y'' THEN',
'        l_changed := l_changed + 1;',
'        IF l_focus IS NULL THEN l_focus := i.item_name; l_bval := i.browser_value; l_sval := i.server_value; END IF;',
'      END IF;',
'    END LOOP;',
'  EXCEPTION WHEN OTHERS THEN NULL;',
'  END;',
'',
'  -- The reported page, read from the APEX dictionary.',
'  IF l_apex_id IS NOT NULL AND l_page IS NOT NULL THEN',
'    BEGIN',
'      SELECT COUNT(*) INTO l_items FROM apex_application_page_items WHERE application_id = l_apex_id AND page_id = l_page;',
'      SELECT COUNT(*) INTO l_vals FROM apex_application_page_val WHERE application_id = l_apex_id AND page_id = l_page;',
'      SELECT COUNT(*) INTO l_regs FROM apex_application_page_regions WHERE application_id = l_apex_id AND page_id = l_page;',
'      SELECT COUNT(*), MAX(process_name), MAX(DBMS_LOB.substr(process_source, 4000, 1))',
'        INTO l_procs, l_proc, l_psrc',
'        FROM apex_application_page_proc WHERE application_id = l_apex_id AND page_id = l_page;',
'      SELECT ROUND(AVG(elapsed_time), 3), COUNT(*) INTO l_avg, l_views',
'        FROM apex_workspace_activity_log WHERE application_id = l_apex_id AND page_id = l_page AND view_date > SYSDATE - 30;',
'    EXCEPTION WHEN OTHERS THEN NULL;',
'    END;',
'  END IF;',
'',
'  l_mode := CASE',
'              WHEN l_type = ''PERFORMANCE'' OR LOWER(l_title || '' '' || l_text) LIKE ''%slow%'' THEN ''PERF''',
'              WHEN l_type IN (''BUG'', ''DATA'') OR l_changed > 0 THEN ''BUG''',
'              ELSE ''CHANGE'' END;',
'',
'  l_ev := li(''Report: <b>'' || h(cut(l_title, 80)) || ''</b>'');',
'  IF l_page IS NOT NULL THEN',
'    l_ev := l_ev || li(''Code: '' || h(l_app) || '' page '' || l_page || '' <i>'' || h(l_pname) || ''</i> &mdash; ''',
'          || l_items || '' items, '' || l_regs || '' regions, '' || l_procs || '' process'' || CASE WHEN l_procs = 1 THEN '''' ELSE ''es'' END',
'          || '', '' || l_vals || '' validation'' || CASE WHEN l_vals = 1 THEN '''' ELSE ''s'' END);',
'  END IF;',
'  IF l_focus IS NOT NULL THEN',
'    l_ev := l_ev || li(''Session state: '' || l_changed || '' field'' || CASE WHEN l_changed = 1 THEN '''' ELSE ''s'' END',
'          || '' changed but not saved; <code>'' || h(l_focus) || ''</code> was <code>'' || h(cut(l_bval)) || ''</code> in the browser, <code>''',
'          || h(cut(l_sval)) || ''</code> on the server'');',
'  END IF;',
'  IF l_views > 0 THEN',
'    l_ev := l_ev || li(''Database: page '' || l_page || '' averaged '' || TO_CHAR(l_avg, ''FM990.000'') || '' s server time over '' || l_views || '' views (30 days)'');',
'  END IF;',
'  IF l_excl IS NOT NULL THEN',
'    l_ev := l_ev || li(''Skipped: <code>'' || h(l_excl) || ''</code> was excluded at capture and was not read'');',
'  END IF;',
'',
'  IF l_mode = ''PERF'' THEN',
'    l_conf := 74;',
'    l_diag := ''Server time on page '' || l_page || '' is low'' || CASE WHEN l_views > 0 THEN '' ('' || TO_CHAR(l_avg, ''FM990.000'') || '' s average)'' END',
'           || '', so the delay is most likely in the browser: region rendering, an unindexed lookup behind a list of values, or a synchronous call on page load.'';',
'    l_steps := li(''Run the page with debug at LEVEL9 and sort the debug log by elapsed time to find the slowest step.'')',
'            || li(''Check each list of values on the page for a full table scan and add an index on its lookup column.'')',
'            || li(''Set long-running regions to <b>Lazy Loading</b> so the page paints before they finish.'')',
'            || li(''Re-test and compare the elapsed time with the baseline below.'');',
'    l_code_t := ''Find the slowest pages (last 7 days)'';',
'    l_code := ''SELECT page_id, page_name,'' || CHR(10) || ''       ROUND(AVG(elapsed_time), 3) AS avg_s,'' || CHR(10)',
'           || ''       ROUND(MAX(elapsed_time), 3) AS max_s, COUNT(*) AS views'' || CHR(10)',
'           || ''  FROM apex_workspace_activity_log'' || CHR(10)',
'           || '' WHERE application_id = '' || NVL(TO_CHAR(l_apex_id), '':APP_ID'') || CHR(10)',
'           || ''   AND view_date > SYSDATE - 7'' || CHR(10)',
'           || '' GROUP BY page_id, page_name'' || CHR(10) || '' ORDER BY avg_s DESC;'';',
'  ELSIF l_mode = ''BUG'' THEN',
'    l_conf := LEAST(92, 72 + 6 * LEAST(l_changed, 3));',
'    IF l_psrc IS NOT NULL AND UPPER(TRIM(l_psrc)) IN (''NULL;'', ''BEGIN NULL; END;'') THEN',
'      l_diag := ''The <b>'' || h(l_proc) || ''</b> process on page '' || l_page || '' is an empty block (<code>NULL;</code>). ''',
'             || ''Submitted values reach session state but are never written to a table, so the user''''s changes are lost on save.'';',
'    ELSE',
'      l_diag := ''Page '' || l_page || '' accepts ''',
'             || CASE WHEN l_focus IS NOT NULL THEN ''<code>'' || h(l_focus) || ''</code>'' ELSE ''the submitted values'' END',
'             || '' without a server-side validation, so a bad value fails silently in the <b>'' || h(NVL(l_proc, ''save'')) || ''</b> process.'';',
'    END IF;',
'    l_steps := li(''Replace the body of <b>'' || h(NVL(l_proc, ''the save process'')) || ''</b> with a call to the table API shown below.'')',
'            || li(''Add a server-side validation on <code>'' || h(NVL(l_focus, ''the changed item'')) || ''</code> so a bad value is reported inline.'')',
'            || li(''Re-run the reporter''''s steps with the captured values and confirm the row is updated.'')',
'            || li(''Record a test result on this ticket and link the fix to the next release.'');',
'    l_code_t := ''Page '' || l_page || '' &rarr; Processing &rarr; '' || NVL(l_proc, ''Save'');',
'    -- Build the table-API call from the reported page''s own items.',
'    l_api := LOWER(REGEXP_REPLACE(TRIM(NVL(l_pname, ''page_'' || l_page)), ''[^A-Za-z0-9]+'', ''_''));',
'    BEGIN',
'      FOR it IN (SELECT item_name, display_as FROM apex_application_page_items',
'                  WHERE application_id = l_apex_id AND page_id = l_page',
'                    AND display_as NOT IN (''Display Only'', ''Password'')',
'                  ORDER BY CASE WHEN display_as = ''Hidden'' THEN 0 ELSE 1 END, display_sequence) LOOP',
'        EXIT WHEN l_nparm >= 6;',
'        l_nparm := l_nparm + 1;',
'        IF l_key IS NULL AND it.display_as = ''Hidden'' THEN l_key := it.item_name; END IF;',
'        l_parms := l_parms || CASE WHEN l_nparm > 1 THEN '','' || CHR(10) END',
'                || ''    p_'' || RPAD(LOWER(REGEXP_REPLACE(it.item_name, ''^P[0-9]+_'', '''')), 16) || '' => :'' || it.item_name;',
'      END LOOP;',
'    EXCEPTION WHEN OTHERS THEN NULL;',
'    END;',
'    IF l_parms IS NOT NULL THEN',
'      l_code := ''BEGIN'' || CHR(10) || ''  '' || l_api || ''_api.save('' || CHR(10) || l_parms || '');'' || CHR(10) || ''END;'';',
'      l_sql := ''SELECT *'' || CHR(10) || ''  FROM '' || l_api || CHR(10)',
'            || CASE WHEN l_key IS NOT NULL',
'                    THEN '' WHERE '' || LOWER(REGEXP_REPLACE(l_key, ''^P[0-9]+_'', '''')) || '' = :'' || l_key || '';''',
'                    ELSE '' ORDER BY last_update_date DESC FETCH FIRST 5 ROWS ONLY;'' END;',
'    END IF;',
'  ELSE',
'    l_conf := 66;',
'    l_diag := ''This is a change request for '' || h(NVL(l_app, ''the application''))',
'           || CASE WHEN l_page IS NOT NULL THEN '' page '' || l_page END',
'           || ''. The page already has the items and processing it needs, so this can be built as a declarative change with no schema work.'';',
'    l_steps := li(''Confirm the expected behaviour with the reporter in a comment on this ticket.'')',
'            || li(''Add the change on page '' || NVL(TO_CHAR(l_page), ''n'') || '' declaratively; no new tables are needed.'')',
'            || li(''Add a test case for the new behaviour and link the ticket to the next release.'');',
'  END IF;',
'',
'  l_out := ''<div class="afh-ai" data-state="thinking">''',
'        || ''<ol class="afh-ai-run" aria-live="polite">''',
'        || ''<li>Reading the report and '' || CASE WHEN l_focus IS NOT NULL THEN ''the captured session state'' ELSE ''its context'' END || ''</li>''',
'        || ''<li>Inspecting '' || h(NVL(l_app, ''the application'')) || CASE WHEN l_page IS NOT NULL THEN '' page '' || l_page END || '' in the APEX dictionary</li>''',
'        || ''<li>Querying the database for activity and related data</li>''',
'        || ''</ol>''',
'        || ''<div class="afh-ai-result">''',
'        || ''<div class="afh-ai-top"><div class="afh-ai-label">Likely cause</div>''',
'        || ''<div class="afh-ai-conf" title="Confidence"><span style="width:'' || l_conf || ''%"></span><b>'' || l_conf || ''%</b></div></div>''',
'        || ''<p class="afh-ai-diag">'' || l_diag || ''</p>''',
'        || ''<div class="afh-ai-cols"><div><h4>What I looked at</h4><ul class="afh-ai-ev">'' || l_ev || ''</ul></div>''',
'        || ''<div><h4>Recommended fix</h4><ol class="afh-ai-steps">'' || l_steps || ''</ol></div></div>'';',
'  IF l_code IS NOT NULL THEN l_out := l_out || code_block(REPLACE(REPLACE(l_code_t, ''&rarr;'', ''>''), ''&mdash;'', ''-''), l_code); END IF;',
'  IF l_sql IS NOT NULL THEN l_out := l_out || code_block(''Verify the fix'', l_sql); END IF;',
'  l_out := l_out',
'        || ''<div class="afh-ai-foot"><span>Analysed '' || h(l_no) || '' &middot; '' || TO_CHAR(SYSDATE, ''DD-MON-YYYY HH24:MI'') || ''</span>''',
'        || ''<span class="afh-ai-vote"><button type="button" class="t-Button t-Button--small" data-vote="up">Helpful</button>''',
'        || ''<button type="button" class="t-Button t-Button--small" data-vote="down">Not helpful</button></span></div>''',
'        || ''</div></div>'';',
'  RETURN l_out;',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
,p_plug_required_role=>wwv_flow_imp.id(68798617960373404)
,p_required_patch=>wwv_flow_imp.id(72000000000000010)
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70300000000001150)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70300000000001140)
,p_button_name=>'FOLLOW'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Follow'
,p_button_condition=>'RETURN NOT afh_notification_pkg.is_following(:P10_TICKET_ID);'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-bell'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70300000000002180)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70300000000002100)
,p_button_name=>'LINK_TICKET'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Link ticket'
,p_button_redirect_url=>'f?p=&APP_ID.:100:&SESSION.::&DEBUG.:100:P100_TICKET_ID,P100_TO_STATUS:&P10_TICKET_ID.,RELATION'
,p_icon_css_classes=>'fa-link'
,p_grid_new_row=>'Y'
,p_security_scheme=>wwv_flow_imp.id(68798936619375152)
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70300000000001160)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(70300000000001140)
,p_button_name=>'UNFOLLOW'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Unfollow'
,p_button_condition=>'RETURN afh_notification_pkg.is_following(:P10_TICKET_ID) AND NOT afh_ticket_pkg.is_assignee(:P10_TICKET_ID);'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-bell-slash'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70300000000001170)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(70300000000001140)
,p_button_name=>'MUTE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Mute'
,p_button_condition=>'RETURN afh_notification_pkg.is_following(:P10_TICKET_ID) AND NOT afh_notification_pkg.is_muted(:P10_TICKET_ID) AND NOT afh_ticket_pkg.is_assignee(:P10_TICKET_ID);'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-volume-off'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70300000000001250)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(70300000000001220)
,p_button_name=>'POST_COMMENT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft:t-Button--stretch'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Post'
,p_icon_css_classes=>'fa-comment'
,p_grid_new_row=>'N'
,p_grid_new_column=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70300000000001180)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(70300000000001140)
,p_button_name=>'UNMUTE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Unmute'
,p_button_condition=>'RETURN afh_notification_pkg.is_muted(:P10_TICKET_ID) AND NOT afh_ticket_pkg.is_assignee(:P10_TICKET_ID);'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-volume-up'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70300000000001190)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(70300000000001140)
,p_button_name=>'AFFECTED'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'This affects me too'
,p_button_condition=>'RETURN NOT afh_security_pkg.meets_min_role(''DEVELOPER'', afh_ticket_pkg.application_id_of(:P10_TICKET_ID)) AND NOT afh_ticket_pkg.is_affected(:P10_TICKET_ID);'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-user-plus'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70300000000001550)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(70300000000001520)
,p_button_name=>'UPLOAD'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft:t-Button--stretch'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Upload'
,p_icon_css_classes=>'fa-upload'
,p_grid_new_row=>'N'
,p_grid_new_column=>'N'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70300000000001200)
,p_button_sequence=>60
,p_button_plug_id=>wwv_flow_imp.id(70300000000001140)
,p_button_name=>'UNAFFECTED'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Remove me from affected'
,p_button_condition=>'RETURN NOT afh_security_pkg.meets_min_role(''DEVELOPER'', afh_ticket_pkg.application_id_of(:P10_TICKET_ID)) AND afh_ticket_pkg.is_affected(:P10_TICKET_ID);'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-user-times'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70300000000001930)
,p_button_sequence=>90
,p_button_plug_id=>wwv_flow_imp.id(70300000000001840)
,p_button_name=>'SAVE_TRIAGE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft:t-Button--stretch'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save triage'
,p_icon_css_classes=>'fa-save'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001070)
,p_name=>'P10_TICKET_NO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70300000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001080)
,p_name=>'P10_TICKET_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70300000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'I'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001090)
,p_name=>'P10_ROW_VERSION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(70300000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'I'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001100)
,p_name=>'P10_STATUS_CODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(70300000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'I'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001110)
,p_name=>'P10_ACTION_MSG'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(70300000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'I'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001230)
,p_name=>'P10_COMMENT_BODY'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70300000000001220)
,p_prompt=>'Comment'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cMaxlength=>32000
,p_cHeight=>3
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs'
,p_is_persistent=>'N'
,p_help_text=>'Plain text. *emphasis*, **strong**, `code`, - lists, [link](https://...) and @mentions are rendered.'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001240)
,p_name=>'P10_COMMENT_VISIBILITY'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70300000000001220)
,p_item_default=>'PUBLIC'
,p_prompt=>'Visibility'
,p_display_as=>'NATIVE_RADIOGROUP'
,p_lov=>'STATIC2:Public;PUBLIC,Internal note;INTERNAL'
,p_field_template=>2318601014859922299
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_security_scheme=>wwv_flow_imp.id(68798617960373404)
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '2',
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001530)
,p_name=>'P10_FILE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70300000000001520)
,p_prompt=>'File'
,p_display_as=>'NATIVE_FILE'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'allow_multiple_files', 'N',
  'display_as', 'DROPZONE_INLINE',
  'max_file_size', '25000',
  'purge_file_at', 'REQUEST',
  'storage_type', 'APEX_APPLICATION_TEMP_FILES')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001540)
,p_name=>'P10_FILE_CAPTION'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(70300000000001520)
,p_prompt=>'Caption'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>60
,p_cMaxlength=>400
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001850)
,p_name=>'P10_PRIORITY_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70300000000001840)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Priority'
,p_source=>'SELECT priority_code FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, value_code r FROM afh_v_classification_values WHERE class_type = ''PRIORITY'' AND is_active = ''Y'' ORDER BY display_seq'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001860)
,p_name=>'P10_SEVERITY_CODE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70300000000001840)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Severity'
,p_source=>'SELECT severity_code FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, value_code r FROM afh_v_classification_values WHERE class_type = ''SEVERITY'' AND is_active = ''Y'' ORDER BY display_seq'
,p_begin_on_new_line=>'N'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001870)
,p_name=>'P10_IMPACT_CODE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(70300000000001840)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Impact'
,p_source=>'SELECT impact_code FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, value_code r FROM afh_v_classification_values WHERE class_type = ''IMPACT'' AND is_active = ''Y'' ORDER BY display_seq'
,p_begin_on_new_line=>'N'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001880)
,p_name=>'P10_ASSIGNEE_USER_ID'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(70300000000001840)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Assignee'
,p_source=>'SELECT assignee_user_id FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT display_name d, user_id r FROM afh_v_users WHERE is_active = ''Y'' ORDER BY 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Unassigned'
,p_begin_on_new_line=>'N'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001890)
,p_name=>'P10_RELEASE_ID'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(70300000000001840)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Target release'
,p_source=>'SELECT release_id FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, release_id r FROM afh_v_releases WHERE application_id = (SELECT application_id FROM afh_tickets WHERE ticket_id = :P10_TICKET_ID) AND state_code IN (''PLANNED'',''IN_PROGRESS'') ORDER BY target_date'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'None'
,p_begin_on_new_line=>'N'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001900)
,p_name=>'P10_DUE_DATE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(70300000000001840)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Due'
,p_source=>'SELECT CAST(due_date AS DATE) FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_begin_on_new_line=>'N'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001910)
,p_name=>'P10_ROOT_CAUSE'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(70300000000001840)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Root cause'
,p_source=>'SELECT root_cause FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cHeight=>3
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000001920)
,p_name=>'P10_RESOLUTION'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(70300000000001840)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Resolution'
,p_source=>'SELECT resolution FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cHeight=>3
,p_begin_on_new_line=>'N'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000009910)
,p_name=>'P10_ACTIVITY_COUNT'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>51
,p_item_plug_id=>wwv_flow_imp.id(70300000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000009920)
,p_name=>'P10_ATTACHMENT_COUNT'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>52
,p_item_plug_id=>wwv_flow_imp.id(70300000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000009930)
,p_name=>'P10_NOTE_COUNT'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>53
,p_item_plug_id=>wwv_flow_imp.id(70300000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_computation(
 p_id=>wwv_flow_imp.id(70300000000009940)
,p_computation_sequence=>10
,p_computation_item=>'P10_ACTIVITY_COUNT'
,p_computation_point=>'BEFORE_HEADER'
,p_computation_type=>'QUERY'
,p_computation=>'SELECT COUNT(*) FROM afh_v_ticket_timeline WHERE ticket_id = COALESCE(TO_NUMBER(:P10_TICKET_ID), (SELECT k.ticket_id FROM afh_tickets k WHERE k.ticket_no = :P10_TICKET_NO))'
);
wwv_flow_imp_page.create_page_computation(
 p_id=>wwv_flow_imp.id(70300000000009950)
,p_computation_sequence=>20
,p_computation_item=>'P10_ATTACHMENT_COUNT'
,p_computation_point=>'BEFORE_HEADER'
,p_computation_type=>'QUERY'
,p_computation=>'SELECT COUNT(*) FROM afh_v_ticket_attachments_public WHERE ticket_id = COALESCE(TO_NUMBER(:P10_TICKET_ID), (SELECT k.ticket_id FROM afh_tickets k WHERE k.ticket_no = :P10_TICKET_NO))'
);
wwv_flow_imp_page.create_page_computation(
 p_id=>wwv_flow_imp.id(70300000000009960)
,p_computation_sequence=>30
,p_computation_item=>'P10_NOTE_COUNT'
,p_computation_point=>'BEFORE_HEADER'
,p_computation_type=>'QUERY'
,p_computation=>'SELECT COUNT(*) FROM afh_comments WHERE ticket_id = COALESCE(TO_NUMBER(:P10_TICKET_ID), (SELECT k.ticket_id FROM afh_tickets k WHERE k.ticket_no = :P10_TICKET_NO)) AND visibility_code = ''INTERNAL'' AND is_archived = ''N'''
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(70300000000002230)
,p_validation_name=>'File chosen'
,p_validation_sequence=>5
,p_validation=>'P10_FILE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'Choose a file first.'
,p_when_button_pressed=>wwv_flow_imp.id(70300000000001550)
,p_associated_item=>wwv_flow_imp.id(70300000000001530)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(70300000000001260)
,p_validation_name=>'Comment required'
,p_validation_sequence=>10
,p_validation=>'P10_COMMENT_BODY'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'Enter a comment.'
,p_when_button_pressed=>wwv_flow_imp.id(70300000000001250)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(70300000000002190)
,p_name=>'Refresh after workflow dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(70300000000001950)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(70300000000002200)
,p_event_id=>wwv_flow_imp.id(70300000000002190)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_SUBMIT_PAGE'
,p_attribute_01=>'DIALOG_CLOSED'
,p_attribute_02=>'N'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(70300000000002210)
,p_name=>'Refresh after test dialog'
,p_event_sequence=>20
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(70300000000001960)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(70300000000002220)
,p_event_id=>wwv_flow_imp.id(70300000000002210)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_SUBMIT_PAGE'
,p_attribute_01=>'DIALOG_CLOSED'
,p_attribute_02=>'N'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70300000000001210)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'User action'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  CASE :REQUEST',
'    WHEN ''FOLLOW''     THEN afh_notification_pkg.follow(:P10_TICKET_ID);            :P10_ACTION_MSG := ''You now follow this ticket.'';',
'    WHEN ''UNFOLLOW''   THEN afh_notification_pkg.unfollow(:P10_TICKET_ID);          :P10_ACTION_MSG := ''You no longer follow this ticket.'';',
'    WHEN ''MUTE''       THEN afh_notification_pkg.set_mute(:P10_TICKET_ID, ''Y'');     :P10_ACTION_MSG := ''Notifications for this ticket are muted.'';',
'    WHEN ''UNMUTE''     THEN afh_notification_pkg.set_mute(:P10_TICKET_ID, ''N'');     :P10_ACTION_MSG := ''Notifications for this ticket are on.'';',
'    WHEN ''AFFECTED''   THEN afh_ticket_pkg.mark_affected(:P10_TICKET_ID);           :P10_ACTION_MSG := ''Recorded that this affects you too.'';',
'    WHEN ''UNAFFECTED'' THEN afh_ticket_pkg.unmark_affected(:P10_TICKET_ID);         :P10_ACTION_MSG := ''Removed you from the affected users.'';',
'  END CASE;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'RETURN :REQUEST IN (''FOLLOW'',''UNFOLLOW'',''MUTE'',''UNMUTE'',''AFFECTED'',''UNAFFECTED'');'
,p_process_when_type=>'FUNCTION_BODY'
,p_process_when2=>'PLSQL'
,p_process_success_message=>'&P10_ACTION_MSG.'
,p_internal_uid=>70300000000001210
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70300000000001270)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Post comment'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_id NUMBER;',
'BEGIN',
'  l_id := afh_comment_pkg.add_comment(',
'            p_ticket_id       => :P10_TICKET_ID,',
'            p_body            => :P10_COMMENT_BODY,',
'            p_visibility_code => NVL(:P10_COMMENT_VISIBILITY, ''PUBLIC''));',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(70300000000001250)
,p_process_success_message=>'Comment posted.'
,p_internal_uid=>70300000000001270
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70300000000001280)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_SESSION_STATE'
,p_process_name=>'Clear comment'
,p_attribute_01=>'CLEAR_CACHE_FOR_ITEMS'
,p_attribute_03=>'P10_COMMENT_BODY'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(70300000000001250)
,p_internal_uid=>70300000000001280
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70300000000001560)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Upload attachment'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_id NUMBER;',
'BEGIN',
'  FOR f IN (SELECT filename, mime_type, blob_content FROM apex_application_temp_files WHERE name = :P10_FILE) LOOP',
'    l_id := afh_attachment_pkg.add_attachment(',
'              p_ticket_id => :P10_TICKET_ID,',
'              p_file_name => f.filename,',
'              p_mime_type => f.mime_type,',
'              p_content   => f.blob_content,',
'              p_kind_code => afh_attachment_pkg.c_kind_file,',
'              p_caption   => :P10_FILE_CAPTION);',
'  END LOOP;',
'  :P10_FILE := NULL;',
'  :P10_FILE_CAPTION := NULL;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(70300000000001550)
,p_process_success_message=>'Attachment added.'
,p_internal_uid=>70300000000001560
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70300000000001940)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save triage'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  r  afh_v_ticket_detail%ROWTYPE;',
'  PROCEDURE refresh IS BEGIN :P10_ROW_VERSION := afh_ticket_pkg.row_version_of(:P10_TICKET_ID); END;',
'BEGIN',
'  SELECT * INTO r FROM afh_v_ticket_detail WHERE ticket_id = :P10_TICKET_ID;',
'  IF :P10_PRIORITY_CODE <> r.priority_code OR :P10_SEVERITY_CODE <> r.severity_code OR :P10_IMPACT_CODE <> r.impact_code THEN',
'    afh_ticket_pkg.set_classification(:P10_TICKET_ID, :P10_ROW_VERSION, :P10_PRIORITY_CODE, :P10_SEVERITY_CODE, :P10_IMPACT_CODE);',
'    refresh;',
'  END IF;',
'  IF NVL(:P10_ASSIGNEE_USER_ID, -1) <> NVL(r.assignee_user_id, -1) THEN',
'    afh_ticket_pkg.assign(:P10_TICKET_ID, :P10_ROW_VERSION, :P10_ASSIGNEE_USER_ID, :P10_DUE_DATE);',
'    refresh;',
'  ELSIF NVL(:P10_DUE_DATE, DATE ''1900-01-01'') <> NVL(CAST(r.due_date AS DATE), DATE ''1900-01-01'') THEN',
'    afh_ticket_pkg.set_due_date(:P10_TICKET_ID, :P10_ROW_VERSION, :P10_DUE_DATE);',
'    refresh;',
'  END IF;',
'  IF NVL(:P10_RELEASE_ID, -1) <> NVL(r.release_id, -1) THEN',
'    afh_ticket_pkg.set_release(:P10_TICKET_ID, :P10_ROW_VERSION, :P10_RELEASE_ID);',
'    refresh;',
'  END IF;',
'  IF NVL(DBMS_LOB.compare(NVL(:P10_ROOT_CAUSE, EMPTY_CLOB()), NVL(r.root_cause, EMPTY_CLOB())), -1) <> 0',
'     OR NVL(DBMS_LOB.compare(NVL(:P10_RESOLUTION, EMPTY_CLOB()), NVL(r.resolution, EMPTY_CLOB())), -1) <> 0 THEN',
'    afh_ticket_pkg.set_resolution(:P10_TICKET_ID, :P10_ROW_VERSION, :P10_ROOT_CAUSE, :P10_RESOLUTION);',
'    refresh;',
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(70300000000001930)
,p_process_success_message=>'Triage saved.'
,p_internal_uid=>70300000000001940
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70300000000001120)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Resolve ticket'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  IF :P10_TICKET_NO IS NULL AND :P10_TICKET_ID IS NOT NULL THEN',
'    SELECT ticket_no INTO :P10_TICKET_NO FROM afh_tickets WHERE ticket_id = :P10_TICKET_ID;',
'  END IF;',
'  :P10_TICKET_ID := afh_search_pkg.resolve_for_navigation(:P10_TICKET_NO, p_follow_master => ''N'');',
'  SELECT ticket_no, status_code, row_version',
'    INTO :P10_TICKET_NO, :P10_STATUS_CODE, :P10_ROW_VERSION',
'    FROM afh_tickets WHERE ticket_id = :P10_TICKET_ID;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_process_error_message=>'That ticket does not exist.'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>70300000000001120
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70300000000001130)
,p_process_sequence=>20
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Record view'
,p_process_sql_clob=>'afh_ticket_pkg.record_view(:P10_TICKET_ID);'
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>70300000000001130
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70300000000001830)
,p_process_sequence=>30
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Audit context view'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_meta CLOB;',
'BEGIN',
'  l_meta := afh_context_pkg.get_payload(afh_context_pkg.latest_context_id(:P10_TICKET_ID), ''CLIENT_META'');',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'RETURN afh_context_pkg.latest_context_id(:P10_TICKET_ID) IS NOT NULL;'
,p_process_when_type=>'FUNCTION_BODY'
,p_process_when2=>'PLSQL'
,p_security_scheme=>wwv_flow_imp.id(68798617960373404)
,p_internal_uid=>70300000000001830
);
wwv_flow_imp.component_end;
end;
/
