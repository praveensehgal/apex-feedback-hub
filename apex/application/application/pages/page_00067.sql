prompt --application/pages/page_00067
begin
--   Manifest
--     PAGE: 00067
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
 p_id=>67
,p_name=>'Integration Health'
,p_alias=>'INTEGRATION-HEALTH'
,p_step_title=>'Integration Health'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'document.addEventListener(''click'', function (e) {',
'  var a = e.target.closest(''.afh-mail-retry''); if (!a) { return; }',
'  e.preventDefault();',
'  apex.server.process(''MAIL_RETRY'', { x01: a.dataset.id }, { dataType: ''json'' })',
'    .then(function (r) { if (r.ok) { apex.message.showPageSuccess(r.message); apex.region(''afh-mail-failures'').refresh(); } else { apex.message.alert(r.message); } })',
'    .catch(function () { apex.message.alert(''Retry failed. Check the integration events for details.''); });',
'});'))
,p_inline_css=>'.afh-chip--none { opacity: 0.6; }'
,p_step_template=>4072355960268175073
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68797704657367743)
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71500000000001010)
,p_plug_name=>'Mail disabled'
,p_region_name=>'afh-mail-disabled'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>5
,p_plug_source=>'<div class="t-Alert t-Alert--warning t-Alert--horizontal" role="alert"><div class="t-Alert-body">E-mail is disabled (MAIL_ENABLED = N). Notifications stay in-app only and the mail queue is not processed.</div></div>'
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'afh_security_pkg.config_yn(''MAIL_ENABLED'') = ''N'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71500000000001020)
,p_name=>'Applications'
,p_region_name=>'afh-int-apps'
,p_template=>4072358936313175081
,p_display_sequence=>10
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT application_id,',
'       app_key,',
'       application_name,',
'       identity_mode,',
'       adapter_version,',
'       min_adapter_version,',
'       adapter_supported_yn,',
'       CASE WHEN adapter_version IS NULL      THEN ''No launch yet''',
'            WHEN adapter_supported_yn = ''N''   THEN ''Unsupported''',
'            ELSE ''Supported'' END AS adapter_status,',
'       CASE WHEN adapter_version IS NULL      THEN ''none''',
'            WHEN adapter_supported_yn = ''N''   THEN ''danger''',
'            ELSE ''success'' END AS adapter_chip,',
'       last_launch_at,',
'       launches_7d,',
'       failures_7d,',
'       partial_captures_7d,',
'       mail_failures_7d,',
'       handoffs_7d,',
'       tickets_from_handoffs_7d',
'  FROM afh_v_integration_summary',
' ORDER BY CASE WHEN adapter_supported_yn = ''N'' AND adapter_version IS NOT NULL THEN 0 ELSE 1 END,',
'          application_name'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>50
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No applications registered.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001030)
,p_query_column_id=>1
,p_column_alias=>'APPLICATION_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001040)
,p_query_column_id=>2
,p_column_alias=>'APP_KEY'
,p_column_display_sequence=>20
,p_column_heading=>'Key'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001050)
,p_query_column_id=>3
,p_column_alias=>'APPLICATION_NAME'
,p_column_display_sequence=>30
,p_column_heading=>'Application'
,p_column_link=>'f?p=&APP_ID.:610:&SESSION.::&DEBUG.:610:P610_APPLICATION_ID:#APPLICATION_ID#'
,p_column_linktext=>'#APPLICATION_NAME#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001060)
,p_query_column_id=>4
,p_column_alias=>'IDENTITY_MODE'
,p_column_display_sequence=>40
,p_column_heading=>'Identity'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001070)
,p_query_column_id=>5
,p_column_alias=>'ADAPTER_VERSION'
,p_column_display_sequence=>50
,p_column_heading=>'Adapter'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001080)
,p_query_column_id=>6
,p_column_alias=>'MIN_ADAPTER_VERSION'
,p_column_display_sequence=>60
,p_column_heading=>'Minimum'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001090)
,p_query_column_id=>7
,p_column_alias=>'ADAPTER_SUPPORTED_YN'
,p_column_display_sequence=>70
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001100)
,p_query_column_id=>8
,p_column_alias=>'ADAPTER_STATUS'
,p_column_display_sequence=>80
,p_column_heading=>'Status'
,p_column_html_expression=>'<span class="afh-chip afh-chip--#ADAPTER_CHIP#">#ADAPTER_STATUS#</span>'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001110)
,p_query_column_id=>9
,p_column_alias=>'ADAPTER_CHIP'
,p_column_display_sequence=>90
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001120)
,p_query_column_id=>10
,p_column_alias=>'LAST_LAUNCH_AT'
,p_column_display_sequence=>100
,p_column_heading=>'Last launch'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001130)
,p_query_column_id=>11
,p_column_alias=>'LAUNCHES_7D'
,p_column_display_sequence=>110
,p_column_heading=>'Launches (7d)'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001140)
,p_query_column_id=>12
,p_column_alias=>'FAILURES_7D'
,p_column_display_sequence=>120
,p_column_heading=>'Failures (7d)'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001150)
,p_query_column_id=>13
,p_column_alias=>'PARTIAL_CAPTURES_7D'
,p_column_display_sequence=>130
,p_column_heading=>'Partial captures (7d)'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001160)
,p_query_column_id=>14
,p_column_alias=>'MAIL_FAILURES_7D'
,p_column_display_sequence=>140
,p_column_heading=>'Mail failures (7d)'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001170)
,p_query_column_id=>15
,p_column_alias=>'HANDOFFS_7D'
,p_column_display_sequence=>150
,p_column_heading=>'Handoffs (7d)'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001180)
,p_query_column_id=>16
,p_column_alias=>'TICKETS_FROM_HANDOFFS_7D'
,p_column_display_sequence=>160
,p_column_heading=>'Tickets from handoffs (7d)'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71500000000001210)
,p_name=>'Events (30 days)'
,p_region_name=>'afh-int-events'
,p_template=>2664334895415463485
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT integration_event_id,',
'       event_at,',
'       event_code,',
'       result_code,',
'       severity,',
'       application_id,',
'       application_name,',
'       app_key,',
'       environment_id,',
'       env_code,',
'       correlation_id,',
'       adapter_version,',
'       safe_detail',
'  FROM afh_v_integration_health',
' ORDER BY event_at DESC'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>50
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No integration events in the last 30 days.'
,p_query_num_rows_type=>'ROW_RANGES_WITH_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001220)
,p_query_column_id=>1
,p_column_alias=>'INTEGRATION_EVENT_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001230)
,p_query_column_id=>2
,p_column_alias=>'EVENT_AT'
,p_column_display_sequence=>20
,p_column_heading=>'When'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001240)
,p_query_column_id=>3
,p_column_alias=>'EVENT_CODE'
,p_column_display_sequence=>30
,p_column_heading=>'Event'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001250)
,p_query_column_id=>4
,p_column_alias=>'RESULT_CODE'
,p_column_display_sequence=>40
,p_column_heading=>'Result'
,p_column_html_expression=>'<span class="afh-chip afh-chip--#SEVERITY#">#RESULT_CODE#</span>'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001260)
,p_query_column_id=>5
,p_column_alias=>'SEVERITY'
,p_column_display_sequence=>50
,p_column_heading=>'Severity'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001270)
,p_query_column_id=>6
,p_column_alias=>'APPLICATION_ID'
,p_column_display_sequence=>60
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001280)
,p_query_column_id=>7
,p_column_alias=>'APPLICATION_NAME'
,p_column_display_sequence=>70
,p_column_heading=>'Application'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001290)
,p_query_column_id=>8
,p_column_alias=>'APP_KEY'
,p_column_display_sequence=>80
,p_column_heading=>'Key'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001300)
,p_query_column_id=>9
,p_column_alias=>'ENVIRONMENT_ID'
,p_column_display_sequence=>90
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001310)
,p_query_column_id=>10
,p_column_alias=>'ENV_CODE'
,p_column_display_sequence=>100
,p_column_heading=>'Environment'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001320)
,p_query_column_id=>11
,p_column_alias=>'CORRELATION_ID'
,p_column_display_sequence=>110
,p_column_heading=>'Correlation'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001330)
,p_query_column_id=>12
,p_column_alias=>'ADAPTER_VERSION'
,p_column_display_sequence=>120
,p_column_heading=>'Adapter'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001340)
,p_query_column_id=>13
,p_column_alias=>'SAFE_DETAIL'
,p_column_display_sequence=>130
,p_column_heading=>'Detail'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71500000000001350)
,p_name=>'Mail failures'
,p_region_name=>'afh-mail-failures'
,p_template=>4072358936313175081
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT notification_id,',
'       recipient_user_id,',
'       recipient_name,',
'       ticket_id,',
'       ticket_no,',
'       event_code,',
'       subject,',
'       delivery_attempts,',
'       last_attempt_at,',
'       error_code,',
'       error_detail,',
'       creation_date,',
'       ''Retry'' AS retry_action',
'  FROM afh_v_mail_failures',
' ORDER BY last_attempt_at DESC'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>50
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No e-mail has exhausted its retries.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001360)
,p_query_column_id=>1
,p_column_alias=>'NOTIFICATION_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001370)
,p_query_column_id=>2
,p_column_alias=>'RECIPIENT_USER_ID'
,p_column_display_sequence=>20
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001380)
,p_query_column_id=>3
,p_column_alias=>'RECIPIENT_NAME'
,p_column_display_sequence=>30
,p_column_heading=>'Recipient'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001390)
,p_query_column_id=>4
,p_column_alias=>'TICKET_ID'
,p_column_display_sequence=>40
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001400)
,p_query_column_id=>5
,p_column_alias=>'TICKET_NO'
,p_column_display_sequence=>50
,p_column_heading=>'Ticket'
,p_column_link=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:10:P10_TICKET_NO:#TICKET_NO#'
,p_column_linktext=>'#TICKET_NO#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001410)
,p_query_column_id=>6
,p_column_alias=>'EVENT_CODE'
,p_column_display_sequence=>60
,p_column_heading=>'Event'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001420)
,p_query_column_id=>7
,p_column_alias=>'SUBJECT'
,p_column_display_sequence=>70
,p_column_heading=>'Subject'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001430)
,p_query_column_id=>8
,p_column_alias=>'DELIVERY_ATTEMPTS'
,p_column_display_sequence=>80
,p_column_heading=>'Attempts'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001440)
,p_query_column_id=>9
,p_column_alias=>'LAST_ATTEMPT_AT'
,p_column_display_sequence=>90
,p_column_heading=>'Last attempt'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001450)
,p_query_column_id=>10
,p_column_alias=>'ERROR_CODE'
,p_column_display_sequence=>100
,p_column_heading=>'Error'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001460)
,p_query_column_id=>11
,p_column_alias=>'ERROR_DETAIL'
,p_column_display_sequence=>110
,p_column_heading=>'Detail'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001470)
,p_query_column_id=>12
,p_column_alias=>'CREATION_DATE'
,p_column_display_sequence=>120
,p_column_heading=>'Created'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001480)
,p_query_column_id=>13
,p_column_alias=>'RETRY_ACTION'
,p_column_display_sequence=>130
,p_column_html_expression=>'<a href="#" class="t-Button t-Button--small afh-mail-retry" data-id="#NOTIFICATION_ID#">#RETRY_ACTION#</a>'
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71500000000001500)
,p_name=>'Scheduler'
,p_region_name=>'afh-int-jobs'
,p_template=>2664334895415463485
,p_display_sequence=>40
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
 p_id=>wwv_flow_imp.id(71500000000001510)
,p_query_column_id=>1
,p_column_alias=>'JOB_NAME'
,p_column_display_sequence=>10
,p_column_heading=>'Job'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001520)
,p_query_column_id=>2
,p_column_alias=>'COMMENTS'
,p_column_display_sequence=>20
,p_column_heading=>'Purpose'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001530)
,p_query_column_id=>3
,p_column_alias=>'REPEAT_INTERVAL'
,p_column_display_sequence=>30
,p_column_heading=>'Schedule'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001540)
,p_query_column_id=>4
,p_column_alias=>'ENABLED'
,p_column_display_sequence=>40
,p_column_heading=>'Enabled'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001550)
,p_query_column_id=>5
,p_column_alias=>'STATE'
,p_column_display_sequence=>50
,p_column_heading=>'State'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001560)
,p_query_column_id=>6
,p_column_alias=>'LAST_START_DATE'
,p_column_display_sequence=>60
,p_column_heading=>'Last start'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001570)
,p_query_column_id=>7
,p_column_alias=>'NEXT_RUN_DATE'
,p_column_display_sequence=>70
,p_column_heading=>'Next run'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001580)
,p_query_column_id=>8
,p_column_alias=>'RUN_COUNT'
,p_column_display_sequence=>80
,p_column_heading=>'Runs'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001590)
,p_query_column_id=>9
,p_column_alias=>'FAILURE_COUNT'
,p_column_display_sequence=>90
,p_column_heading=>'Failures'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001600)
,p_query_column_id=>10
,p_column_alias=>'ACTION'
,p_column_display_sequence=>100
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71500000000001620)
,p_name=>'Mail configuration'
,p_region_name=>'afh-int-mail-config'
,p_template=>2664334895415463485
,p_display_sequence=>50
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT config_key,',
'       display_value,',
'       description',
'  FROM afh_v_config_summary',
' WHERE config_key IN (''MAIL_ENABLED'', ''MAIL_FROM'', ''BASE_URL'', ''FEEDBACK_APP_ID'')',
' ORDER BY CASE config_key WHEN ''MAIL_ENABLED'' THEN 1 WHEN ''MAIL_FROM'' THEN 2 WHEN ''BASE_URL'' THEN 3 ELSE 4 END'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001630)
,p_query_column_id=>1
,p_column_alias=>'CONFIG_KEY'
,p_column_display_sequence=>10
,p_column_heading=>'Key'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001640)
,p_query_column_id=>2
,p_column_alias=>'DISPLAY_VALUE'
,p_column_display_sequence=>20
,p_column_heading=>'Value'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71500000000001650)
,p_query_column_id=>3
,p_column_alias=>'DESCRIPTION'
,p_column_display_sequence=>30
,p_column_heading=>'Description'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71500000000001610)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71500000000001500)
,p_button_name=>'MANAGE_JOBS'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Manage jobs'
,p_button_redirect_url=>'f?p=&APP_ID.:60:&SESSION.::&DEBUG.:::'
,p_icon_css_classes=>'fa-clock-o'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71500000000001660)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71500000000001620)
,p_button_name=>'EDIT_CONFIG'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Edit configuration'
,p_button_redirect_url=>'f?p=&APP_ID.:60:&SESSION.::&DEBUG.:::'
,p_icon_css_classes=>'fa-cog'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71500000000001190)
,p_name=>'Refresh after dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(71500000000001020)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71500000000001200)
,p_event_id=>wwv_flow_imp.id(71500000000001190)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71500000000001020)
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71500000000001490)
,p_process_sequence=>10
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'MAIL_RETRY'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_id NUMBER;',
'BEGIN',
'  afh_security_pkg.assert_admin;',
'  l_id := TO_NUMBER(apex_application.g_x01);',
'  afh_notification_pkg.requeue(p_notification_id => l_id);',
'  apex_json.open_object;',
'  apex_json.write(''ok'', TRUE);',
'  apex_json.write(''message'', ''Queued for the next mail run.'');',
'  apex_json.close_object;',
'EXCEPTION',
'  WHEN OTHERS THEN',
'    apex_json.open_object;',
'    apex_json.write(''ok'', FALSE);',
'    apex_json.write(''message'', ''Retry failed: '' || SUBSTR(SQLERRM, 1, 200));',
'    apex_json.close_object;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_security_scheme=>wwv_flow_imp.id(68797704657367743)
,p_internal_uid=>71500000000001490
);
wwv_flow_imp.component_end;
end;
/
