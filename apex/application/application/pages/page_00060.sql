prompt --application/pages/page_00060
begin
--   Manifest
--     PAGE: 00060
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
 p_id=>60
,p_name=>'Administration'
,p_alias=>'ADMINISTRATION'
,p_step_title=>'Administration'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'document.addEventListener(''click'', function (e) {',
'  var a = e.target.closest(''.afh-job-toggle''); if (!a) { return; }',
'  e.preventDefault();',
'  apex.server.process(''TOGGLE_JOB'', { x01: a.dataset.job, x02: a.dataset.enabled }, { dataType: ''json'' })',
'    .then(function (r) { if (r.ok) { apex.region(''afh-jobs'').refresh(); apex.message.showPageSuccess(''Job updated.''); } else { apex.message.alert(r.message); } })',
'    .catch(function () { apex.message.alert(''The job could not be changed. Reload and try again.''); });',
'});'))
,p_step_template=>4072355960268175073
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68798393905371806)
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70900000000001010)
,p_name=>'Warnings'
,p_region_name=>'afh-warnings'
,p_template=>4501440665235496320
,p_display_sequence=>10
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ''warning'' AS alert_type, ''BASE_URL is not set; notification links will be omitted.'' AS alert_text',
'  FROM dual WHERE afh_security_pkg.config_value(''BASE_URL'') IS NULL',
'UNION ALL',
'SELECT ''warning'', ''FEEDBACK_APP_ID is not set; run the block in Plan P00.''',
'  FROM dual WHERE afh_security_pkg.config_value(''FEEDBACK_APP_ID'') IS NULL',
'UNION ALL',
'SELECT ''info'', ''Mail delivery is disabled (MAIL_ENABLED = N). Notifications are recorded but not sent.''',
'  FROM dual WHERE afh_security_pkg.config_yn(''MAIL_ENABLED'') = ''N''',
'UNION ALL',
'SELECT ''warning'', ''No application owner or fallback queue: set FALLBACK_OWNER_SUBJECT or give every application an owner.''',
'  FROM dual WHERE afh_security_pkg.config_value(''FALLBACK_OWNER_SUBJECT'') IS NULL',
'          AND EXISTS (SELECT 1 FROM afh_applications WHERE is_active = ''Y'' AND owner_user_id IS NULL)',
'UNION ALL',
'SELECT ''danger'', ''Adapter version below minimum on '' || display_name || '' ('' || adapter_version || '').''',
'  FROM afh_v_applications WHERE is_active = ''Y'' AND adapter_supported_yn = ''N'' AND adapter_version IS NOT NULL'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2882902941739462796
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>' '
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001020)
,p_query_column_id=>1
,p_column_alias=>'ALERT_TYPE'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001030)
,p_query_column_id=>2
,p_column_alias=>'ALERT_TEXT'
,p_column_display_sequence=>20
,p_column_heading=>'Warning'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70900000000001040)
,p_plug_name=>'Administration'
,p_region_name=>'afh-admin-cards'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#:t-Cards--featured t-Cards--block force-fa-lg:t-Cards--displayIcons:t-Cards--4cols:t-Cards--animColorFill'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>20
,p_list_id=>wwv_flow_imp.id(70900000000000900)
,p_plug_source_type=>'NATIVE_LIST'
,p_list_template_id=>2886769488667748277
,p_plug_required_role=>wwv_flow_imp.id(68798393905371806)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70900000000001070)
,p_plug_name=>'License'
,p_region_name=>'afh-license'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_source=>'<div class="t-Alert t-Alert--info t-Alert--horizontal" role="status"><div class="t-Alert-body">&P60_LICENSE_TEXT.</div></div>'
,p_plug_display_condition_type=>'ITEM_IS_NOT_NULL'
,p_plug_display_when_condition=>'P60_LICENSE_TEXT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70900000000001080)
,p_name=>'Configuration'
,p_region_name=>'afh-config'
,p_template=>2664334895415463485
,p_display_sequence=>40
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT c.config_id, c.config_key, c.display_value, c.data_type, c.description, c.is_secret, c.is_editable, c.last_updated_by, c.last_update_date,',
'       CASE WHEN c.is_editable = ''Y'' THEN ''<a class="afh-card-no" href="'' || apex_util.prepare_url(''f?p='' || :APP_ID || '':600:'' || :APP_SESSION || ''::NO:600:P600_CONFIG_KEY:'' || c.config_key) || ''">'' || apex_escape.html(c.config_key) || ''</a>''',
'            ELSE ''<span class="afh-card-no">'' || apex_escape.html(c.config_key) || ''</span>'' END AS key_html',
'  FROM (SELECT config_id, config_key, display_value, data_type, description, is_secret, is_editable, last_updated_by, last_update_date',
'  FROM afh_v_config_summary',
' ORDER BY config_key) c'))
,p_required_role=>wwv_flow_imp.id(68797704657367743)
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>100
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001090)
,p_query_column_id=>1
,p_column_alias=>'CONFIG_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001100)
,p_query_column_id=>2
,p_column_alias=>'CONFIG_KEY'
,p_column_display_sequence=>20
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001110)
,p_query_column_id=>3
,p_column_alias=>'DISPLAY_VALUE'
,p_column_display_sequence=>30
,p_column_heading=>'Value'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001120)
,p_query_column_id=>4
,p_column_alias=>'DATA_TYPE'
,p_column_display_sequence=>40
,p_column_heading=>'Type'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001130)
,p_query_column_id=>5
,p_column_alias=>'DESCRIPTION'
,p_column_display_sequence=>50
,p_column_heading=>'Description'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001140)
,p_query_column_id=>6
,p_column_alias=>'IS_SECRET'
,p_column_display_sequence=>60
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001150)
,p_query_column_id=>7
,p_column_alias=>'IS_EDITABLE'
,p_column_display_sequence=>70
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001160)
,p_query_column_id=>8
,p_column_alias=>'LAST_UPDATED_BY'
,p_column_display_sequence=>80
,p_column_heading=>'Updated by'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001170)
,p_query_column_id=>9
,p_column_alias=>'LAST_UPDATE_DATE'
,p_column_display_sequence=>90
,p_column_heading=>'Updated'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001180)
,p_query_column_id=>10
,p_column_alias=>'KEY_HTML'
,p_column_display_sequence=>100
,p_column_heading=>'Key'
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70900000000001210)
,p_name=>'Scheduled Jobs'
,p_region_name=>'afh-jobs'
,p_template=>2664334895415463485
,p_display_sequence=>50
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT job_name,',
'       comments,',
'       repeat_interval,',
'       enabled,',
'       state,',
'       last_start_date,',
'       next_run_date,',
'       run_count,',
'       failure_count,',
'       CASE WHEN enabled = ''TRUE'' THEN ''Disable'' ELSE ''Enable'' END AS action',
'  FROM user_scheduler_jobs',
' WHERE job_name LIKE ''AFH\_JOB\_%'' ESCAPE ''\''',
' ORDER BY job_name'))
,p_required_role=>wwv_flow_imp.id(68797704657367743)
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No AFH jobs are installed.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001220)
,p_query_column_id=>1
,p_column_alias=>'JOB_NAME'
,p_column_display_sequence=>10
,p_column_heading=>'Job'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001230)
,p_query_column_id=>2
,p_column_alias=>'COMMENTS'
,p_column_display_sequence=>20
,p_column_heading=>'Purpose'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001240)
,p_query_column_id=>3
,p_column_alias=>'REPEAT_INTERVAL'
,p_column_display_sequence=>30
,p_column_heading=>'Schedule'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001250)
,p_query_column_id=>4
,p_column_alias=>'ENABLED'
,p_column_display_sequence=>40
,p_column_heading=>'Enabled'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001260)
,p_query_column_id=>5
,p_column_alias=>'STATE'
,p_column_display_sequence=>50
,p_column_heading=>'State'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001270)
,p_query_column_id=>6
,p_column_alias=>'LAST_START_DATE'
,p_column_display_sequence=>60
,p_column_heading=>'Last start'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001280)
,p_query_column_id=>7
,p_column_alias=>'NEXT_RUN_DATE'
,p_column_display_sequence=>70
,p_column_heading=>'Next run'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001290)
,p_query_column_id=>8
,p_column_alias=>'RUN_COUNT'
,p_column_display_sequence=>80
,p_column_heading=>'Runs'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001300)
,p_query_column_id=>9
,p_column_alias=>'FAILURE_COUNT'
,p_column_display_sequence=>90
,p_column_heading=>'Failures'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70900000000001310)
,p_query_column_id=>10
,p_column_alias=>'ACTION'
,p_column_display_sequence=>100
,p_column_html_expression=>'<a href="#" class="t-Button t-Button--small afh-job-toggle" data-job="#JOB_NAME#" data-enabled="#ENABLED#">#ACTION#</a>'
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70900000000001050)
,p_name=>'P60_LICENSE_TEXT'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70900000000001040)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'I'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_computation(
 p_id=>wwv_flow_imp.id(70900000000001060)
,p_computation_sequence=>10
,p_computation_item=>'P60_LICENSE_TEXT'
,p_computation_point=>'BEFORE_HEADER'
,p_computation_type=>'FUNCTION_BODY'
,p_computation_language=>'PLSQL'
,p_computation=>'RETURN afh_license_pkg.status_text;'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(70900000000001190)
,p_name=>'Refresh configuration after dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(70900000000001080)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(70900000000001200)
,p_event_id=>wwv_flow_imp.id(70900000000001190)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(70900000000001080)
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70900000000001320)
,p_process_sequence=>10
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'TOGGLE_JOB'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_job VARCHAR2(128);',
'BEGIN',
'  afh_security_pkg.assert_admin;',
'  SELECT job_name INTO l_job FROM user_scheduler_jobs',
'   WHERE job_name = apex_application.g_x01 AND job_name LIKE ''AFH\_JOB\_%'' ESCAPE ''\'';',
'  IF apex_application.g_x02 = ''TRUE'' THEN',
'    DBMS_SCHEDULER.disable(l_job, force => TRUE);',
'  ELSE',
'    DBMS_SCHEDULER.enable(l_job);',
'  END IF;',
'  afh_audit_pkg.log_event(',
'    p_entity_type => afh_audit_pkg.c_entity_config,',
'    p_entity_id   => 0,',
'    p_event_code  => ''JOB_TOGGLED'',',
'    p_summary     => l_job || CASE WHEN apex_application.g_x02 = ''TRUE'' THEN '' disabled'' ELSE '' enabled'' END,',
'    p_is_public   => ''N'');',
'  apex_json.open_object; apex_json.write(''ok'', TRUE); apex_json.close_object;',
'EXCEPTION WHEN OTHERS THEN',
'  apex_json.open_object; apex_json.write(''ok'', FALSE); apex_json.write(''message'', REGEXP_REPLACE(SQLERRM, ''^ORA-\d+: '', '''')); apex_json.close_object;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_security_scheme=>wwv_flow_imp.id(68797704657367743)
,p_internal_uid=>70900000000001320
);
wwv_flow_imp.component_end;
end;
/
