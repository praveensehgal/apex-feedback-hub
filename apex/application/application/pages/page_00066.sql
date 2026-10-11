prompt --application/pages/page_00066
begin
--   Manifest
--     PAGE: 00066
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
 p_id=>66
,p_name=>'Attachments and Retention'
,p_alias=>'RETENTION'
,p_step_title=>'Attachments and Retention'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'document.addEventListener(''click'', function (e) {',
'  var a = e.target.closest(''.afh-ret-preview''); if (!a) { return; }',
'  e.preventDefault();',
'  apex.server.process(''PREVIEW_POLICY'', { x01: a.dataset.policy }, { dataType: ''json'' })',
'    .then(function (r) {',
'      if (!r.ok) { apex.message.alert(r.message); return; }',
'      $s(''P66_LAST_RUN_ID'', r.run_id);',
'      [''afh-last-run'', ''afh-runs'', ''afh-policies''].forEach(function (id) { apex.region(id).refresh(); });',
'      apex.message.showPageSuccess(''Preview complete.'');',
'    })',
'    .catch(function () { apex.message.alert(''The preview failed. Check the run history.''); });',
'});'))
,p_step_template=>4072355960268175073
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68797704657367743)
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71400000000001010)
,p_plug_name=>'Policy'
,p_region_name=>'afh-policy'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71400000000001130)
,p_name=>'Storage'
,p_region_name=>'afh-storage'
,p_template=>4072358936313175081
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT kind_code,',
'       file_count,',
'       total_mb,',
'       total_bytes,',
'       restricted_count,',
'       oldest_at',
'  FROM afh_v_storage_summary',
' ORDER BY kind_code'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No attachments stored.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001140)
,p_query_column_id=>1
,p_column_alias=>'KIND_CODE'
,p_column_display_sequence=>10
,p_column_heading=>'Kind'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001150)
,p_query_column_id=>2
,p_column_alias=>'FILE_COUNT'
,p_column_display_sequence=>20
,p_column_heading=>'Files'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001160)
,p_query_column_id=>3
,p_column_alias=>'TOTAL_MB'
,p_column_display_sequence=>30
,p_column_heading=>'MB'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001170)
,p_query_column_id=>4
,p_column_alias=>'TOTAL_BYTES'
,p_column_display_sequence=>40
,p_column_heading=>'Bytes'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001180)
,p_query_column_id=>5
,p_column_alias=>'RESTRICTED_COUNT'
,p_column_display_sequence=>50
,p_column_heading=>'Restricted'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001190)
,p_query_column_id=>6
,p_column_alias=>'OLDEST_AT'
,p_column_display_sequence=>60
,p_column_heading=>'Oldest'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71400000000001200)
,p_plug_name=>'Hidden'
,p_region_name=>'afh-hidden'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>25
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71400000000001230)
,p_name=>'Retention'
,p_region_name=>'afh-policies'
,p_template=>4072358936313175081
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT p.policy_code,',
'       p.policy_label,',
'       p.description,',
'       p.confirm_word,',
'       (SELECT MAX(r.started_at) FROM afh_v_retention_runs r',
'         WHERE r.policy_code = p.policy_code AND r.mode_code = ''PREVIEW'') AS last_preview_at,',
'       (SELECT MAX(r.started_at) FROM afh_v_retention_runs r',
'         WHERE r.policy_code = p.policy_code AND r.mode_code = ''EXECUTE'') AS last_execute_at,',
'       ''Preview'' AS preview_action,',
'       ''Execute'' AS execute_action',
'  FROM (SELECT ''ARCHIVE_CLOSED''    AS policy_code,',
'               ''Archive closed tickets'' AS policy_label,',
'               ''Terminal tickets closed longer than ARCHIVE_AFTER_DAYS are marked archived; identity, search and audit are kept'' AS description,',
'               ''ARCHIVE'' AS confirm_word,',
'               1 AS seq',
'          FROM dual',
'        UNION ALL',
'        SELECT ''PURGE_ATTACHMENTS'',',
'               ''Purge attachment bytes'',',
'               ''Attachment content on archived tickets older than DEFAULT_RETENTION_DAYS is removed; the attachment row stays'',',
'               ''DELETE'',',
'               2',
'          FROM dual',
'        UNION ALL',
'        SELECT ''DELETE_TICKETS'',',
'               ''Delete (anonymize) tickets'',',
'               ''Archived tickets older than DEFAULT_RETENTION_DAYS are hard-deleted with a surviving audit record'',',
'               ''DELETE'',',
'               3',
'          FROM dual) p',
' ORDER BY p.seq'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>10
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001240)
,p_query_column_id=>1
,p_column_alias=>'POLICY_CODE'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001250)
,p_query_column_id=>2
,p_column_alias=>'POLICY_LABEL'
,p_column_display_sequence=>20
,p_column_heading=>'Policy'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001260)
,p_query_column_id=>3
,p_column_alias=>'DESCRIPTION'
,p_column_display_sequence=>30
,p_column_heading=>'What it does'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001270)
,p_query_column_id=>4
,p_column_alias=>'CONFIRM_WORD'
,p_column_display_sequence=>40
,p_column_heading=>'Confirmation word'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001280)
,p_query_column_id=>5
,p_column_alias=>'LAST_PREVIEW_AT'
,p_column_display_sequence=>50
,p_column_heading=>'Last preview'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001290)
,p_query_column_id=>6
,p_column_alias=>'LAST_EXECUTE_AT'
,p_column_display_sequence=>60
,p_column_heading=>'Last execute'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001300)
,p_query_column_id=>7
,p_column_alias=>'PREVIEW_ACTION'
,p_column_display_sequence=>70
,p_column_html_expression=>'<a href="#" class="t-Button t-Button--small afh-ret-preview" data-policy="#POLICY_CODE#">#PREVIEW_ACTION#</a>'
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001310)
,p_query_column_id=>8
,p_column_alias=>'EXECUTE_ACTION'
,p_column_display_sequence=>80
,p_column_link=>'f?p=&APP_ID.:660:&SESSION.::&DEBUG.:660:P660_POLICY_CODE:#POLICY_CODE#'
,p_column_linktext=>'#EXECUTE_ACTION#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71400000000001320)
,p_name=>'Last preview'
,p_region_name=>'afh-last-run'
,p_template=>4072358936313175081
,p_display_sequence=>40
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT retention_run_id,',
'       policy_label,',
'       mode_code,',
'       started_at,',
'       completed_at,',
'       actor_subject,',
'       ticket_count,',
'       attachment_count,',
'       mb_affected,',
'       result_code,',
'       error_detail,',
'       DBMS_LOB.SUBSTR(detail_json, 4000, 1) AS detail_preview',
'  FROM afh_v_retention_runs',
' WHERE retention_run_id = :P66_LAST_RUN_ID'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P66_LAST_RUN_ID'
,p_lazy_loading=>false
,p_query_row_template=>2100515439059797523
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'Run a preview to see the counts and bytes a policy would touch.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001330)
,p_query_column_id=>1
,p_column_alias=>'RETENTION_RUN_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001340)
,p_query_column_id=>2
,p_column_alias=>'POLICY_LABEL'
,p_column_display_sequence=>20
,p_column_heading=>'Policy'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001350)
,p_query_column_id=>3
,p_column_alias=>'MODE_CODE'
,p_column_display_sequence=>30
,p_column_heading=>'Mode'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001360)
,p_query_column_id=>4
,p_column_alias=>'STARTED_AT'
,p_column_display_sequence=>40
,p_column_heading=>'Started'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001370)
,p_query_column_id=>5
,p_column_alias=>'COMPLETED_AT'
,p_column_display_sequence=>50
,p_column_heading=>'Completed'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001380)
,p_query_column_id=>6
,p_column_alias=>'ACTOR_SUBJECT'
,p_column_display_sequence=>60
,p_column_heading=>'By'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001390)
,p_query_column_id=>7
,p_column_alias=>'TICKET_COUNT'
,p_column_display_sequence=>70
,p_column_heading=>'Tickets'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001400)
,p_query_column_id=>8
,p_column_alias=>'ATTACHMENT_COUNT'
,p_column_display_sequence=>80
,p_column_heading=>'Attachments'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001410)
,p_query_column_id=>9
,p_column_alias=>'MB_AFFECTED'
,p_column_display_sequence=>90
,p_column_heading=>'MB'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001420)
,p_query_column_id=>10
,p_column_alias=>'RESULT_CODE'
,p_column_display_sequence=>100
,p_column_heading=>'Result'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001430)
,p_query_column_id=>11
,p_column_alias=>'ERROR_DETAIL'
,p_column_display_sequence=>110
,p_column_heading=>'Error'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001440)
,p_query_column_id=>12
,p_column_alias=>'DETAIL_PREVIEW'
,p_column_display_sequence=>120
,p_column_heading=>'First 100 ticket numbers'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71400000000001450)
,p_name=>'Run history'
,p_region_name=>'afh-runs'
,p_template=>2664334895415463485
,p_display_sequence=>50
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT retention_run_id,',
'       policy_code,',
'       policy_label,',
'       mode_code,',
'       started_at,',
'       completed_at,',
'       actor_subject,',
'       ticket_count,',
'       attachment_count,',
'       mb_affected,',
'       bytes_affected,',
'       result_code,',
'       error_detail',
'  FROM afh_v_retention_runs',
' ORDER BY started_at DESC'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>50
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No runs yet.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001460)
,p_query_column_id=>1
,p_column_alias=>'RETENTION_RUN_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001470)
,p_query_column_id=>2
,p_column_alias=>'POLICY_CODE'
,p_column_display_sequence=>20
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001480)
,p_query_column_id=>3
,p_column_alias=>'POLICY_LABEL'
,p_column_display_sequence=>30
,p_column_heading=>'Policy'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001490)
,p_query_column_id=>4
,p_column_alias=>'MODE_CODE'
,p_column_display_sequence=>40
,p_column_heading=>'Mode'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001500)
,p_query_column_id=>5
,p_column_alias=>'STARTED_AT'
,p_column_display_sequence=>50
,p_column_heading=>'Started'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001510)
,p_query_column_id=>6
,p_column_alias=>'COMPLETED_AT'
,p_column_display_sequence=>60
,p_column_heading=>'Completed'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001520)
,p_query_column_id=>7
,p_column_alias=>'ACTOR_SUBJECT'
,p_column_display_sequence=>70
,p_column_heading=>'By'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001530)
,p_query_column_id=>8
,p_column_alias=>'TICKET_COUNT'
,p_column_display_sequence=>80
,p_column_heading=>'Tickets'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001540)
,p_query_column_id=>9
,p_column_alias=>'ATTACHMENT_COUNT'
,p_column_display_sequence=>90
,p_column_heading=>'Attachments'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001550)
,p_query_column_id=>10
,p_column_alias=>'MB_AFFECTED'
,p_column_display_sequence=>100
,p_column_heading=>'MB'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001560)
,p_query_column_id=>11
,p_column_alias=>'BYTES_AFFECTED'
,p_column_display_sequence=>110
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001570)
,p_query_column_id=>12
,p_column_alias=>'RESULT_CODE'
,p_column_display_sequence=>120
,p_column_heading=>'Result'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000001580)
,p_query_column_id=>13
,p_column_alias=>'ERROR_DETAIL'
,p_column_display_sequence=>130
,p_column_heading=>'Error'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71400000000001650)
,p_plug_name=>'Archive a ticket'
,p_region_name=>'afh-archive'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>60
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71400000000001080)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71400000000001010)
,p_button_name=>'SAVE_POLICY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft:t-Button--stretch'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save policy'
,p_icon_css_classes=>'fa-save'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71400000000001680)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71400000000001650)
,p_button_name=>'ARCHIVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Archive'
,p_icon_css_classes=>'fa-archive'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71400000000001690)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(71400000000001650)
,p_button_name=>'UNARCHIVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Unarchive'
,p_icon_css_classes=>'fa-undo'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71400000000001020)
,p_name=>'P66_ATTACH_ALLOWED_EXT'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(71400000000001010)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Allowed extensions'
,p_source=>'RETURN afh_security_pkg.config_value(''ATTACH_ALLOWED_EXT'');'
,p_source_type=>'FUNCTION_BODY'
,p_source_language=>'PLSQL'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>60
,p_cMaxlength=>500
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_help_text=>'Comma-separated, e.g. PNG,JPG,PDF'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71400000000001030)
,p_name=>'P66_ATTACH_MAX_FILE_BYTES'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(71400000000001010)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Largest file (bytes)'
,p_source=>'RETURN afh_security_pkg.config_value(''ATTACH_MAX_FILE_BYTES'');'
,p_source_type=>'FUNCTION_BODY'
,p_source_language=>'PLSQL'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>14
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'virtual_keyboard', 'TEXT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71400000000001040)
,p_name=>'P66_ATTACH_MAX_TICKET_BYTES'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(71400000000001010)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Largest total per ticket (bytes)'
,p_source=>'RETURN afh_security_pkg.config_value(''ATTACH_MAX_TICKET_BYTES'');'
,p_source_type=>'FUNCTION_BODY'
,p_source_language=>'PLSQL'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>14
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'virtual_keyboard', 'TEXT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71400000000001050)
,p_name=>'P66_DEFAULT_RETENTION_DAYS'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(71400000000001010)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Retention days'
,p_source=>'RETURN afh_security_pkg.config_value(''DEFAULT_RETENTION_DAYS'');'
,p_source_type=>'FUNCTION_BODY'
,p_source_language=>'PLSQL'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>8
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'virtual_keyboard', 'TEXT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71400000000001060)
,p_name=>'P66_ARCHIVE_AFTER_DAYS'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(71400000000001010)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Archive after days'
,p_source=>'RETURN afh_security_pkg.config_value(''ARCHIVE_AFTER_DAYS'');'
,p_source_type=>'FUNCTION_BODY'
,p_source_language=>'PLSQL'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>8
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'virtual_keyboard', 'TEXT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71400000000001070)
,p_name=>'P66_RETENTION_JOB_ARMED'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(71400000000001010)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Retention job armed'
,p_source=>'RETURN afh_security_pkg.config_value(''RETENTION_JOB_ARMED'');'
,p_source_type=>'FUNCTION_BODY'
,p_source_language=>'PLSQL'
,p_display_as=>'NATIVE_YES_NO'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_help_text=>'When off, the scheduled job only previews.'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'off_label', 'No',
  'off_value', 'N',
  'on_label', 'Yes',
  'on_value', 'Y',
  'use_defaults', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71400000000001210)
,p_name=>'P66_POLICY_CODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(71400000000001200)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71400000000001220)
,p_name=>'P66_LAST_RUN_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(71400000000001200)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71400000000001660)
,p_name=>'P66_TICKET_NO'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(71400000000001650)
,p_prompt=>'Ticket number'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>20
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_help_text=>'FB-0042 or 42'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71400000000001670)
,p_name=>'P66_ARCHIVE_REASON'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(71400000000001650)
,p_prompt=>'Reason'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>60
,p_cMaxlength=>500
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(71400000000001090)
,p_validation_name=>'Extension list format'
,p_validation_sequence=>10
,p_validation=>'REGEXP_LIKE(UPPER(REPLACE(:P66_ATTACH_ALLOWED_EXT, '' '', '''')), ''^[A-Z0-9]+(,[A-Z0-9]+)*$'')'
,p_validation2=>'PLSQL'
,p_validation_type=>'EXPRESSION'
,p_error_message=>'Extensions: letters and digits separated by commas.'
,p_when_button_pressed=>wwv_flow_imp.id(71400000000001080)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(71400000000001100)
,p_validation_name=>'Ticket total not below file size'
,p_validation_sequence=>20
,p_validation=>'TO_NUMBER(:P66_ATTACH_MAX_TICKET_BYTES) >= TO_NUMBER(:P66_ATTACH_MAX_FILE_BYTES)'
,p_validation2=>'PLSQL'
,p_validation_type=>'EXPRESSION'
,p_error_message=>'The per-ticket total must be at least the single-file limit.'
,p_when_button_pressed=>wwv_flow_imp.id(71400000000001080)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(71400000000001110)
,p_validation_name=>'Retention not below archive delay'
,p_validation_sequence=>30
,p_validation=>'TO_NUMBER(:P66_DEFAULT_RETENTION_DAYS) >= TO_NUMBER(:P66_ARCHIVE_AFTER_DAYS)'
,p_validation2=>'PLSQL'
,p_validation_type=>'EXPRESSION'
,p_error_message=>'Retention days must be at least the archive delay.'
,p_when_button_pressed=>wwv_flow_imp.id(71400000000001080)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71400000000001600)
,p_name=>'Refresh after execute'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(71400000000001230)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71400000000001610)
,p_event_id=>wwv_flow_imp.id(71400000000001600)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71400000000001320)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71400000000001620)
,p_event_id=>wwv_flow_imp.id(71400000000001600)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71400000000001450)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71400000000001630)
,p_event_id=>wwv_flow_imp.id(71400000000001600)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71400000000001230)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71400000000001640)
,p_event_id=>wwv_flow_imp.id(71400000000001600)
,p_event_result=>'TRUE'
,p_action_sequence=>40
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71400000000001130)
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71400000000001120)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save policy'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  PROCEDURE put(p_key IN VARCHAR2, p_value IN VARCHAR2) IS',
'  BEGIN',
'    IF NVL(afh_security_pkg.config_value(p_key), ''~'') <> NVL(p_value, ''~'') THEN',
'      afh_security_pkg.set_config(p_key, p_value);',
'    END IF;',
'  END put;',
'BEGIN',
'  put(''ATTACH_ALLOWED_EXT'',      UPPER(REPLACE(:P66_ATTACH_ALLOWED_EXT, '' '', '''')));',
'  put(''ATTACH_MAX_FILE_BYTES'',   TRIM(:P66_ATTACH_MAX_FILE_BYTES));',
'  put(''ATTACH_MAX_TICKET_BYTES'', TRIM(:P66_ATTACH_MAX_TICKET_BYTES));',
'  put(''DEFAULT_RETENTION_DAYS'',  TRIM(:P66_DEFAULT_RETENTION_DAYS));',
'  put(''ARCHIVE_AFTER_DAYS'',      TRIM(:P66_ARCHIVE_AFTER_DAYS));',
'  put(''RETENTION_JOB_ARMED'',     NVL(:P66_RETENTION_JOB_ARMED, ''N''));',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71400000000001080)
,p_process_success_message=>'Policy saved.'
,p_internal_uid=>71400000000001120
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71400000000001700)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Archive or unarchive'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_ticket_id NUMBER;',
'BEGIN',
'  afh_security_pkg.assert_admin;',
'  l_ticket_id := afh_ticket_pkg.get_ticket_id(p_ticket_no => :P66_TICKET_NO);',
'  IF l_ticket_id IS NULL THEN',
'    afh_security_pkg.raise_error(''AFH-VAL-001'', ''No ticket matches '' || :P66_TICKET_NO || ''.'');',
'  END IF;',
'  IF :REQUEST = ''ARCHIVE'' THEN',
'    afh_retention_pkg.archive_ticket(p_ticket_id => l_ticket_id, p_reason => :P66_ARCHIVE_REASON);',
'  ELSE',
'    afh_retention_pkg.unarchive_ticket(p_ticket_id => l_ticket_id);',
'  END IF;',
'  :P66_TICKET_NO      := NULL;',
'  :P66_ARCHIVE_REASON := NULL;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'ARCHIVE,UNARCHIVE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_process_success_message=>'Ticket archive state updated.'
,p_internal_uid=>71400000000001700
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71400000000001590)
,p_process_sequence=>10
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'PREVIEW_POLICY'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_security_pkg.assert_admin;',
'  IF apex_application.g_x01 NOT IN (''ARCHIVE_CLOSED'', ''PURGE_ATTACHMENTS'', ''DELETE_TICKETS'') THEN',
'    afh_security_pkg.raise_error(''AFH-VAL-001'', ''Unknown retention policy.'');',
'  END IF;',
'  apex_json.open_object; apex_json.write(''ok'', TRUE); apex_json.write(''run_id'', afh_retention_pkg.preview(p_policy_code => apex_application.g_x01)); apex_json.close_object;',
'EXCEPTION WHEN OTHERS THEN',
'  apex_json.open_object; apex_json.write(''ok'', FALSE); apex_json.write(''message'', REGEXP_REPLACE(SQLERRM, ''^ORA-\d+: '', '''')); apex_json.close_object;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_security_scheme=>wwv_flow_imp.id(68797704657367743)
,p_internal_uid=>71400000000001590
);
wwv_flow_imp.component_end;
end;
/
