prompt --application/pages/page_00001
begin
--   Manifest
--     PAGE: 00001
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
 p_id=>1
,p_name=>'My Work'
,p_alias=>'MY-WORK'
,p_step_title=>'My Work'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function afhCounts(r) {',
'  [''assigned'', ''info'', ''tests'', ''following'', ''reported'', ''unread''].forEach(function (k) {',
'    var el = document.getElementById(''afh-count-'' + k);',
'    if (el && r[k] !== undefined) { el.textContent = r[k]; }',
'  });',
'}',
'function afhRefresh(ids) {',
'  ids.forEach(function (id) { var rg = apex.region(id); if (rg) { rg.refresh(); } });',
'}',
'function afhCall(proc, data, okMessage, regions) {',
'  apex.server.process(proc, data, { dataType: ''json'' })',
'    .then(function (r) {',
'      if (!r.ok) { apex.message.alert(r.message || ''The action could not be completed.''); return; }',
'      afhCounts(r);',
'      afhRefresh(regions);',
'      apex.message.showPageSuccess(okMessage);',
'    })',
'    .catch(function () { apex.message.alert(''The action could not be completed. Reload and try again.''); });',
'}',
'document.addEventListener(''click'', function (e) {',
'  var done = e.target.closest(''.afh-task-done'');',
'  if (done) {',
'    e.preventDefault();',
'    afhCall(''TASK_DONE'', { x01: done.dataset.taskId }, ''Task completed.'', [''afh-tasks'', ''afh-following'']);',
'    return;',
'  }',
'  var act = e.target.closest(''.afh-follow-action'');',
'  if (act) {',
'    e.preventDefault();',
'    afhCall(''FOLLOW_ACTION'', { x01: act.dataset.ticketId, x02: act.dataset.action }, ''Updated.'', [''afh-following'', ''afh-recent'']);',
'  }',
'});'))
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'.afh-counts { display: flex; flex-wrap: wrap; gap: 12px; margin: 4px 0 12px; }',
'.afh-count { display: flex; flex-direction: column; min-width: 140px; padding: 10px 14px; border-radius: 6px;',
'  background: color-mix(in srgb, var(--ut-palette-primary, #1F4E79) 8%, #ffffff); border: 1px solid color-mix(in srgb, var(--ut-palette-primary, #1F4E79) 25%, #ffffff); text-decoration: none; color: inherit; }',
'.afh-count-value { font-size: 1.6rem; font-weight: 600; line-height: 1.1; color: var(--ut-palette-primary, #1F4E79); }',
'.afh-count-label { font-size: 0.8rem; opacity: 0.8; }',
'.afh-overdue { color: #b42318; font-weight: 600; }',
'.afh-muted { opacity: 0.6; }'))
,p_step_template=>2526646919027767344
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68608126239417213)
,p_protection_level=>'C'
,p_page_component_map=>'13'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70100000000001010)
,p_plug_name=>'Counts'
,p_region_name=>'afh-counts'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_out CLOB;',
'  c afh_reporting_pkg.t_my_counts := afh_reporting_pkg.my_counts;',
'  PROCEDURE badge(p_id IN VARCHAR2, p_label IN VARCHAR2, p_value IN NUMBER, p_anchor IN VARCHAR2) IS',
'  BEGIN',
'    l_out := l_out || (''<a class="afh-count" href="#'' || p_anchor || ''">''',
'          || ''<span class="afh-count-value" id="afh-count-'' || p_id || ''">'' || NVL(p_value, 0) || ''</span>''',
'          || ''<span class="afh-count-label">'' || apex_escape.html(p_label) || ''</span></a>'');',
'  END badge;',
'BEGIN',
'  l_out := l_out || (''<div class="afh-counts">'');',
'  badge(''assigned'',  ''Assigned to me'',        c.assigned_open, ''afh-assigned'');',
'  badge(''info'',      ''Information requests'',  c.info_requests, ''afh-tasks'');',
'  badge(''tests'',     ''Tests to run'',          c.test_requests, ''afh-tests'');',
'  badge(''following'', ''Following'',             c.following,     ''afh-following'');',
'  badge(''reported'',  ''Reported by me (open)'', c.reported_open, ''afh-reported'');',
'  l_out := l_out || (''<a class="afh-count" href="''',
'        || apex_util.prepare_url(''f?p='' || :APP_ID || '':50:'' || :APP_SESSION) || ''">''',
'        || ''<span class="afh-count-value" id="afh-count-unread">'' || NVL(c.unread_notifs, 0) || ''</span>''',
'        || ''<span class="afh-count-label">Unread notifications</span></a>'');',
'  l_out := l_out || (''</div>'');',
'  RETURN l_out;',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70100000000001020)
,p_name=>'My tasks'
,p_region_name=>'afh-tasks'
,p_template=>4072358936313175081
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--altRowsDefault:t-Report--rowHighlight'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT task_label,',
'       task_id,',
'       task_type_code,',
'       ticket_id,',
'       ticket_no,',
'       title,',
'       status_label,',
'       status_code,',
'       status_color,',
'       application_name,',
'       summary,',
'       CASE WHEN is_overdue_yn = ''Y''',
'            THEN ''<span class="afh-overdue">'' || TO_CHAR(due_date, ''DD-MON-YYYY HH24:MI'') || '' (overdue)</span>''',
'            ELSE TO_CHAR(due_date, ''DD-MON-YYYY HH24:MI'') END                                   AS due_text,',
'       due_date,',
'       is_overdue_yn,',
'       created_at,',
'       created_by,',
'       related_id,',
'       CASE WHEN task_type_code IN (''REVIEW'', ''INFO_REQUEST'')',
'            THEN ''<button type="button" class="t-Button t-Button--small t-Button--simple afh-task-done" data-task-id="''',
'                 || task_id || ''">Done</button>'' END                                             AS done_html,',
'       type_label,',
'       apex_app_id,',
'       requested_by_name',
'  FROM afh_v_my_tasks',
' ORDER BY CASE task_type_code WHEN ''ASSIGNMENT'' THEN 1 WHEN ''INFO_REQUEST'' THEN 2 WHEN ''TEST_REQUEST'' THEN 3 ELSE 4 END,',
'          NVL(due_date, created_at),',
'          task_id'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_break_cols=>'1'
,p_query_no_data_found=>'Nothing is waiting on you.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_break_type_flag=>'DEFAULT_BREAK_FORMATTING'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001030)
,p_query_column_id=>1
,p_column_alias=>'TASK_LABEL'
,p_column_display_sequence=>10
,p_column_heading=>'Task'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001040)
,p_query_column_id=>2
,p_column_alias=>'TASK_ID'
,p_column_display_sequence=>20
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001050)
,p_query_column_id=>3
,p_column_alias=>'TASK_TYPE_CODE'
,p_column_display_sequence=>30
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001060)
,p_query_column_id=>4
,p_column_alias=>'TICKET_ID'
,p_column_display_sequence=>40
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001070)
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
 p_id=>wwv_flow_imp.id(70100000000001080)
,p_query_column_id=>6
,p_column_alias=>'TITLE'
,p_column_display_sequence=>60
,p_column_heading=>'Title'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001090)
,p_query_column_id=>7
,p_column_alias=>'STATUS_LABEL'
,p_column_display_sequence=>70
,p_column_heading=>'Status'
,p_column_html_expression=>'<span class="afh-chip afh-chip--#STATUS_COLOR#">#STATUS_LABEL#</span>'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001100)
,p_query_column_id=>8
,p_column_alias=>'STATUS_CODE'
,p_column_display_sequence=>80
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001110)
,p_query_column_id=>9
,p_column_alias=>'STATUS_COLOR'
,p_column_display_sequence=>90
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001120)
,p_query_column_id=>10
,p_column_alias=>'APPLICATION_NAME'
,p_column_display_sequence=>100
,p_column_heading=>'Application'
,p_column_html_expression=>'#APPLICATION_NAME# (#APEX_APP_ID#)'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001130)
,p_query_column_id=>11
,p_column_alias=>'SUMMARY'
,p_column_display_sequence=>110
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001140)
,p_query_column_id=>12
,p_column_alias=>'DUE_TEXT'
,p_column_display_sequence=>120
,p_column_heading=>'Due'
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001150)
,p_query_column_id=>13
,p_column_alias=>'DUE_DATE'
,p_column_display_sequence=>130
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001160)
,p_query_column_id=>14
,p_column_alias=>'IS_OVERDUE_YN'
,p_column_display_sequence=>140
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001170)
,p_query_column_id=>15
,p_column_alias=>'CREATED_AT'
,p_column_display_sequence=>150
,p_column_heading=>'Created'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001180)
,p_query_column_id=>16
,p_column_alias=>'CREATED_BY'
,p_column_display_sequence=>160
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001190)
,p_query_column_id=>17
,p_column_alias=>'RELATED_ID'
,p_column_display_sequence=>170
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001200)
,p_query_column_id=>18
,p_column_alias=>'DONE_HTML'
,p_column_display_sequence=>180
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001980)
,p_query_column_id=>19
,p_column_alias=>'TYPE_LABEL'
,p_column_display_sequence=>65
,p_column_heading=>'Type'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001990)
,p_query_column_id=>20
,p_column_alias=>'APEX_APP_ID'
,p_column_display_sequence=>105
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000002000)
,p_query_column_id=>21
,p_column_alias=>'REQUESTED_BY_NAME'
,p_column_display_sequence=>115
,p_column_heading=>'Requested by'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70100000000001210)
,p_name=>'Assigned to me'
,p_region_name=>'afh-assigned'
,p_template=>4072358936313175081
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ticket_id,',
'       ticket_no,',
'       title,',
'       type_label,',
'       application_name,',
'       status_label,',
'       status_color,',
'       priority_label,',
'       priority_color,',
'       CASE WHEN is_overdue_yn = ''Y''',
'            THEN ''<span class="afh-overdue">'' || TO_CHAR(due_date, ''DD-MON-YYYY'') || '' (overdue)</span>''',
'            ELSE TO_CHAR(due_date, ''DD-MON-YYYY'') END              AS due_text,',
'       is_overdue_yn,',
'       days_open,',
'       pending_test_count,',
'       open_task_count,',
'       last_activity_at',
'  FROM afh_v_ticket_queue',
' WHERE is_mine_yn = ''Y''',
' ORDER BY CASE WHEN is_overdue_yn = ''Y'' THEN 0 ELSE 1 END, due_date NULLS LAST, last_activity_at DESC'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No open tickets are assigned to you.'
,p_query_num_rows_type=>'ROW_RANGES_WITH_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001220)
,p_query_column_id=>1
,p_column_alias=>'TICKET_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001230)
,p_query_column_id=>2
,p_column_alias=>'TICKET_NO'
,p_column_display_sequence=>20
,p_column_heading=>'Ticket'
,p_column_link=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:10:P10_TICKET_NO:#TICKET_NO#'
,p_column_linktext=>'#TICKET_NO#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001240)
,p_query_column_id=>3
,p_column_alias=>'TITLE'
,p_column_display_sequence=>30
,p_column_heading=>'Title'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001250)
,p_query_column_id=>4
,p_column_alias=>'TYPE_LABEL'
,p_column_display_sequence=>40
,p_column_heading=>'Type'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001260)
,p_query_column_id=>5
,p_column_alias=>'APPLICATION_NAME'
,p_column_display_sequence=>50
,p_column_heading=>'Application'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001270)
,p_query_column_id=>6
,p_column_alias=>'STATUS_LABEL'
,p_column_display_sequence=>60
,p_column_heading=>'Status'
,p_column_html_expression=>'<span class="afh-chip afh-chip--#STATUS_COLOR#">#STATUS_LABEL#</span>'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001280)
,p_query_column_id=>7
,p_column_alias=>'STATUS_COLOR'
,p_column_display_sequence=>70
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001290)
,p_query_column_id=>8
,p_column_alias=>'PRIORITY_LABEL'
,p_column_display_sequence=>80
,p_column_heading=>'Priority'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001300)
,p_query_column_id=>9
,p_column_alias=>'PRIORITY_COLOR'
,p_column_display_sequence=>90
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001310)
,p_query_column_id=>10
,p_column_alias=>'DUE_TEXT'
,p_column_display_sequence=>100
,p_column_heading=>'Due'
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001320)
,p_query_column_id=>11
,p_column_alias=>'IS_OVERDUE_YN'
,p_column_display_sequence=>110
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001330)
,p_query_column_id=>12
,p_column_alias=>'DAYS_OPEN'
,p_column_display_sequence=>120
,p_column_heading=>'Days open'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001340)
,p_query_column_id=>13
,p_column_alias=>'PENDING_TEST_COUNT'
,p_column_display_sequence=>130
,p_column_heading=>'Pending tests'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001350)
,p_query_column_id=>14
,p_column_alias=>'OPEN_TASK_COUNT'
,p_column_display_sequence=>140
,p_column_heading=>'Open tasks'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001360)
,p_query_column_id=>15
,p_column_alias=>'LAST_ACTIVITY_AT'
,p_column_display_sequence=>150
,p_column_heading=>'Last activity'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70100000000001370)
,p_name=>'Tests to run'
,p_region_name=>'afh-tests'
,p_template=>4072358936313175081
,p_display_sequence=>40
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT test_result_id,',
'       ticket_no,',
'       environment_label,',
'       app_version,',
'       release_label,',
'       requested_by_display_name,',
'       requested_at,',
'       DBMS_LOB.substr(acceptance_criteria, 400, 1) AS criteria,',
'       ''Record result''                              AS record_link',
'  FROM afh_v_ticket_tests',
' WHERE assignee_user_id = afh_security_pkg.current_user_id',
'   AND result_code = ''PENDING''',
' ORDER BY requested_at'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No tests are waiting for you.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001380)
,p_query_column_id=>1
,p_column_alias=>'TEST_RESULT_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001390)
,p_query_column_id=>2
,p_column_alias=>'TICKET_NO'
,p_column_display_sequence=>20
,p_column_heading=>'Ticket'
,p_column_link=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:10:P10_TICKET_NO:#TICKET_NO#'
,p_column_linktext=>'#TICKET_NO#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001400)
,p_query_column_id=>3
,p_column_alias=>'ENVIRONMENT_LABEL'
,p_column_display_sequence=>30
,p_column_heading=>'Environment'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001410)
,p_query_column_id=>4
,p_column_alias=>'APP_VERSION'
,p_column_display_sequence=>40
,p_column_heading=>'Version'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001420)
,p_query_column_id=>5
,p_column_alias=>'RELEASE_LABEL'
,p_column_display_sequence=>50
,p_column_heading=>'Release'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001430)
,p_query_column_id=>6
,p_column_alias=>'REQUESTED_BY_DISPLAY_NAME'
,p_column_display_sequence=>60
,p_column_heading=>'Requested by'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001440)
,p_query_column_id=>7
,p_column_alias=>'REQUESTED_AT'
,p_column_display_sequence=>70
,p_column_heading=>'Requested'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001450)
,p_query_column_id=>8
,p_column_alias=>'CRITERIA'
,p_column_display_sequence=>80
,p_column_heading=>'Acceptance criteria'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001460)
,p_query_column_id=>9
,p_column_alias=>'RECORD_LINK'
,p_column_display_sequence=>90
,p_column_heading=>'Action'
,p_column_link=>'f?p=&APP_ID.:101:&SESSION.::&DEBUG.:101:P101_TEST_RESULT_ID:#TEST_RESULT_ID#'
,p_column_linktext=>'Record result'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70100000000001470)
,p_name=>'Following'
,p_region_name=>'afh-following'
,p_template=>4072358936313175081
,p_display_sequence=>50
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT follower_id,',
'       ticket_id,',
'       ticket_no,',
'       title,',
'       status_label,',
'       priority_code,',
'       application_name,',
'       follow_source_code,',
'       is_muted,',
'       followed_at,',
'       last_activity_at,',
'       is_archived,',
'       can_unfollow_yn,',
'       CASE WHEN is_muted = ''Y''',
'            THEN ''<button type="button" class="t-Button t-Button--small t-Button--simple afh-follow-action" data-action="UNMUTE" data-ticket-id="'' || ticket_id || ''">Unmute</button>''',
'            ELSE ''<button type="button" class="t-Button t-Button--small t-Button--simple afh-follow-action" data-action="MUTE" data-ticket-id="'' || ticket_id || ''">Mute</button>'' END',
'       || CASE WHEN can_unfollow_yn = ''Y''',
'            THEN '' <button type="button" class="t-Button t-Button--small t-Button--simple afh-follow-action" data-action="UNFOLLOW" data-ticket-id="'' || ticket_id || ''">Unfollow</button>'' END',
'                                                                    AS action_html',
'  FROM afh_v_my_work_followed',
' WHERE is_archived = ''N''',
' ORDER BY last_activity_at DESC'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'You are not following any tickets.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001480)
,p_query_column_id=>1
,p_column_alias=>'FOLLOWER_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001490)
,p_query_column_id=>2
,p_column_alias=>'TICKET_ID'
,p_column_display_sequence=>20
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001500)
,p_query_column_id=>3
,p_column_alias=>'TICKET_NO'
,p_column_display_sequence=>30
,p_column_heading=>'Ticket'
,p_column_link=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:10:P10_TICKET_NO:#TICKET_NO#'
,p_column_linktext=>'#TICKET_NO#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001510)
,p_query_column_id=>4
,p_column_alias=>'TITLE'
,p_column_display_sequence=>40
,p_column_heading=>'Title'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001520)
,p_query_column_id=>5
,p_column_alias=>'STATUS_LABEL'
,p_column_display_sequence=>50
,p_column_heading=>'Status'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001530)
,p_query_column_id=>6
,p_column_alias=>'PRIORITY_CODE'
,p_column_display_sequence=>60
,p_column_heading=>'Priority'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001540)
,p_query_column_id=>7
,p_column_alias=>'APPLICATION_NAME'
,p_column_display_sequence=>70
,p_column_heading=>'Application'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001550)
,p_query_column_id=>8
,p_column_alias=>'FOLLOW_SOURCE_CODE'
,p_column_display_sequence=>80
,p_column_heading=>'Why'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001560)
,p_query_column_id=>9
,p_column_alias=>'IS_MUTED'
,p_column_display_sequence=>90
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001570)
,p_query_column_id=>10
,p_column_alias=>'FOLLOWED_AT'
,p_column_display_sequence=>100
,p_column_heading=>'Followed'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001580)
,p_query_column_id=>11
,p_column_alias=>'LAST_ACTIVITY_AT'
,p_column_display_sequence=>110
,p_column_heading=>'Last activity'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001590)
,p_query_column_id=>12
,p_column_alias=>'IS_ARCHIVED'
,p_column_display_sequence=>120
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001600)
,p_query_column_id=>13
,p_column_alias=>'CAN_UNFOLLOW_YN'
,p_column_display_sequence=>130
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001610)
,p_query_column_id=>14
,p_column_alias=>'ACTION_HTML'
,p_column_display_sequence=>140
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70100000000001620)
,p_name=>'Recent'
,p_region_name=>'afh-recent'
,p_template=>2664334895415463485
,p_display_sequence=>60
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ticket_id, ticket_no, title, status_label, priority_code, application_name, source, at_time',
'  FROM (SELECT r.*,',
'               ROW_NUMBER() OVER (PARTITION BY r.ticket_id ORDER BY r.at_time DESC) AS rn',
'          FROM afh_v_my_work_recent r)',
' WHERE rn = 1',
' ORDER BY at_time DESC',
' FETCH FIRST 15 ROWS ONLY'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001630)
,p_query_column_id=>1
,p_column_alias=>'TICKET_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001640)
,p_query_column_id=>2
,p_column_alias=>'TICKET_NO'
,p_column_display_sequence=>20
,p_column_heading=>'Ticket'
,p_column_link=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:10:P10_TICKET_NO:#TICKET_NO#'
,p_column_linktext=>'#TICKET_NO#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001650)
,p_query_column_id=>3
,p_column_alias=>'TITLE'
,p_column_display_sequence=>30
,p_column_heading=>'Title'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001660)
,p_query_column_id=>4
,p_column_alias=>'STATUS_LABEL'
,p_column_display_sequence=>40
,p_column_heading=>'Status'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001670)
,p_query_column_id=>5
,p_column_alias=>'PRIORITY_CODE'
,p_column_display_sequence=>50
,p_column_heading=>'Priority'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001680)
,p_query_column_id=>6
,p_column_alias=>'APPLICATION_NAME'
,p_column_display_sequence=>60
,p_column_heading=>'Application'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001690)
,p_query_column_id=>7
,p_column_alias=>'SOURCE'
,p_column_display_sequence=>70
,p_column_heading=>'Reason'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70100000000001700)
,p_query_column_id=>8
,p_column_alias=>'AT_TIME'
,p_column_display_sequence=>80
,p_column_heading=>'When'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70100000000001710)
,p_plug_name=>'Reported by me'
,p_region_name=>'afh-reported'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2664334895415463485
,p_plug_display_sequence=>20
,p_plug_new_grid_row=>false
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ticket_id,',
'       ticket_no,',
'       title,',
'       type_label,',
'       application_name,',
'       env_label,',
'       page_name,',
'       status_code,',
'       status_label,',
'       status_is_terminal,',
'       priority_label,',
'       assignee_display_name,',
'       release_label,',
'       submitted_at,',
'       last_activity_at,',
'       comment_count,',
'       follower_count',
'  FROM afh_v_ticket_search',
' WHERE reporter_user_id = afh_security_pkg.current_user_id',
'   AND is_archived = ''N'''))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_content_disposition=>'ATTACHMENT'
,p_prn_units=>'INCHES'
,p_prn_paper_size=>'LETTER'
,p_prn_width=>11
,p_prn_height=>8.5
,p_prn_orientation=>'HORIZONTAL'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(70100000000001720)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'Y'
,p_download_formats=>'CSV'
,p_enable_mail_download=>'N'
,p_detail_link=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:10:P10_TICKET_NO:#TICKET_NO#'
,p_detail_link_text=>'<span role="img" aria-label="Open" class="fa fa-external-link" title="Open"></span>'
,p_owner=>'AFH'
,p_internal_uid=>70100000000001720
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001730)
,p_db_column_name=>'TICKET_ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'Ticket Id'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001740)
,p_db_column_name=>'TICKET_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'Ticket'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001750)
,p_db_column_name=>'TITLE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Title'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001760)
,p_db_column_name=>'TYPE_LABEL'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'Type'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001770)
,p_db_column_name=>'APPLICATION_NAME'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Application'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001780)
,p_db_column_name=>'ENV_LABEL'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Environment'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001790)
,p_db_column_name=>'PAGE_NAME'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Page'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001800)
,p_db_column_name=>'STATUS_CODE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'Status Code'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001810)
,p_db_column_name=>'STATUS_LABEL'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'Status'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001820)
,p_db_column_name=>'STATUS_IS_TERMINAL'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'Terminal'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001830)
,p_db_column_name=>'PRIORITY_LABEL'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'Priority'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001840)
,p_db_column_name=>'ASSIGNEE_DISPLAY_NAME'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'Assignee'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001850)
,p_db_column_name=>'RELEASE_LABEL'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'Release'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001860)
,p_db_column_name=>'SUBMITTED_AT'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'Submitted'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'Y'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001870)
,p_db_column_name=>'LAST_ACTIVITY_AT'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'Last activity'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'Y'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001880)
,p_db_column_name=>'COMMENT_COUNT'
,p_display_order=>160
,p_column_identifier=>'P'
,p_column_label=>'Comments'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(70100000000001890)
,p_db_column_name=>'FOLLOWER_COUNT'
,p_display_order=>170
,p_column_identifier=>'Q'
,p_column_label=>'Followers'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(70100000000001900)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'701001'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'TICKET_ID:TICKET_NO:TITLE:TYPE_LABEL:APPLICATION_NAME:ENV_LABEL:PAGE_NAME:STATUS_CODE:STATUS_LABEL:STATUS_IS_TERMINAL:PRIORITY_LABEL:ASSIGNEE_DISPLAY_NAME:RELEASE_LABEL:SUBMITTED_AT:LAST_ACTIVITY_AT:COMMENT_COUNT:FOLLOWER_COUNT'
,p_sort_column_1=>'LAST_ACTIVITY_AT'
,p_sort_direction_1=>'DESC'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70100000000001910)
,p_plug_name=>'Saved filters'
,p_region_name=>'afh-saved-filters'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_03'
,p_list_id=>wwv_flow_imp.id(70100000000000900)
,p_plug_source_type=>'NATIVE_LIST'
,p_list_template_id=>4072361143931175087
,p_plug_query_no_data_found=>'No saved filters yet.'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(70100000000001940)
,p_name=>'Refresh after test result'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(70100000000001370)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(70100000000001950)
,p_event_id=>wwv_flow_imp.id(70100000000001940)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(70100000000001370)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(70100000000001960)
,p_event_id=>wwv_flow_imp.id(70100000000001940)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(70100000000001020)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(70100000000001970)
,p_event_id=>wwv_flow_imp.id(70100000000001940)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(70100000000001210)
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70100000000001920)
,p_process_sequence=>10
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'TASK_DONE'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_task NUMBER := TO_NUMBER(apex_application.g_x01 DEFAULT NULL ON CONVERSION ERROR);',
'  c      afh_reporting_pkg.t_my_counts;',
'BEGIN',
'  afh_workflow_pkg.complete_task(l_task);',
'  c := afh_reporting_pkg.my_counts;',
'  apex_json.open_object;',
'  apex_json.write(''ok'', TRUE);',
'  apex_json.write(''assigned'', c.assigned_open);',
'  apex_json.write(''info'', c.info_requests);',
'  apex_json.write(''tests'', c.test_requests);',
'  apex_json.write(''following'', c.following);',
'  apex_json.write(''reported'', c.reported_open);',
'  apex_json.write(''unread'', c.unread_notifs);',
'  apex_json.close_object;',
'EXCEPTION WHEN OTHERS THEN',
'  apex_json.open_object; apex_json.write(''ok'', FALSE);',
'  apex_json.write(''message'', REGEXP_REPLACE(SQLERRM, ''^ORA-\d+: '', ''''));',
'  apex_json.close_object;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>wwv_flow_imp.id(68608126239417213)
,p_internal_uid=>70100000000001920
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70100000000001930)
,p_process_sequence=>20
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'FOLLOW_ACTION'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_ticket NUMBER       := TO_NUMBER(apex_application.g_x01 DEFAULT NULL ON CONVERSION ERROR);',
'  l_action VARCHAR2(20) := apex_application.g_x02;',
'  c        afh_reporting_pkg.t_my_counts;',
'BEGIN',
'  CASE l_action',
'    WHEN ''UNFOLLOW'' THEN afh_notification_pkg.unfollow(l_ticket);',
'    WHEN ''MUTE''     THEN afh_notification_pkg.set_mute(l_ticket, ''Y'');',
'    WHEN ''UNMUTE''   THEN afh_notification_pkg.set_mute(l_ticket, ''N'');',
'    ELSE afh_security_pkg.raise_error(''AFH-VAL-001'', ''Unknown follow action.'');',
'  END CASE;',
'  c := afh_reporting_pkg.my_counts;',
'  apex_json.open_object;',
'  apex_json.write(''ok'', TRUE);',
'  apex_json.write(''assigned'', c.assigned_open);',
'  apex_json.write(''info'', c.info_requests);',
'  apex_json.write(''tests'', c.test_requests);',
'  apex_json.write(''following'', c.following);',
'  apex_json.write(''reported'', c.reported_open);',
'  apex_json.write(''unread'', c.unread_notifs);',
'  apex_json.close_object;',
'EXCEPTION WHEN OTHERS THEN',
'  apex_json.open_object; apex_json.write(''ok'', FALSE);',
'  apex_json.write(''message'', REGEXP_REPLACE(SQLERRM, ''^ORA-\d+: '', ''''));',
'  apex_json.close_object;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>wwv_flow_imp.id(68608126239417213)
,p_internal_uid=>70100000000001930
);
wwv_flow_imp.component_end;
end;
/
