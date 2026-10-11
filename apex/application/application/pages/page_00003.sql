prompt --application/pages/page_00003
begin
--   Manifest
--     PAGE: 00003
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
 p_id=>3
,p_name=>'Application Health'
,p_alias=>'HEALTH'
,p_step_title=>'Application Health'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'.afh-health { display: grid; grid-template-columns: auto 1fr; gap: 2px 12px; margin: 0; font-size: 0.875rem; }',
'.afh-health dt { color: var(--ut-component-text-muted-color, #6b7280); }',
'.afh-health dd { margin: 0; font-variant-numeric: tabular-nums; }',
'/* Application Health bars (AFH_UI_PKG.render_aging / render_by_dimension). */',
'.afh-hbars { display: flex; flex-direction: column; gap: 6px; }',
'.afh-hbar { display: grid; grid-template-columns: minmax(90px, 160px) 1fr auto; gap: 10px; align-items: center; font-size: 0.85rem; }',
'.afh-hbar-label { color: var(--afh-ink-soft); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }',
'.afh-hbar-track { position: relative; height: 14px; background: var(--afh-paper-3); border-radius: 999px; overflow: hidden; }',
'.afh-hbar-fill { position: absolute; left: 0; top: 0; bottom: 0; background: var(--ut-palette-primary, var(--afh-teal)); border-radius: 999px; transition: width var(--afh-enter); }',
'.afh-hbar-fill--alt { background: var(--afh-signal); }',
'.afh-hbar-value { font-variant-numeric: tabular-nums; font-weight: 600; color: var(--afh-ink); min-width: 32px; text-align: right; }'))
,p_step_template=>4072355960268175073
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68608126239417213)
,p_protection_level=>'C'
,p_page_component_map=>'23'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71600000000001010)
,p_plug_name=>'Filters'
,p_region_name=>'afh-filters'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71600000000001060)
,p_plug_name=>'Backlog by application'
,p_region_name=>'afh-backlog'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT application_id,',
'       app_key,',
'       application_name,',
'       owner_user_id,',
'       owner_name,',
'       open_count,',
'       new_count,',
'       triage_count,',
'       in_progress_count,',
'       ready_test_count,',
'       overdue_count,',
'       critical_count,',
'       oldest_open_at,',
'       CASE WHEN oldest_open_at IS NULL THEN NULL',
'            ELSE ROUND(SYSDATE - CAST(oldest_open_at AS DATE)) END AS oldest_open_days,',
'       resolved_last_30d,',
'       reopened_last_30d,',
'       submitted_last_30d',
'  FROM afh_v_health_backlog',
' WHERE (:P3_APPLICATION_ID IS NULL OR application_id = :P3_APPLICATION_ID)',
' ORDER BY open_count DESC, application_name'))
,p_plug_source_type=>'NATIVE_CARDS'
,p_ajax_items_to_submit=>'P3_APPLICATION_ID,P3_ENVIRONMENT_ID'
,p_plug_query_no_data_found=>'No applications.'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001070)
,p_name=>'APPLICATION_ID'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>10
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001080)
,p_name=>'APP_KEY'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>20
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001090)
,p_name=>'APPLICATION_NAME'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>30
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001100)
,p_name=>'OWNER_USER_ID'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>40
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001110)
,p_name=>'OWNER_NAME'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>50
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001120)
,p_name=>'OPEN_COUNT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>60
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001130)
,p_name=>'NEW_COUNT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>70
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001140)
,p_name=>'TRIAGE_COUNT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>80
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001150)
,p_name=>'IN_PROGRESS_COUNT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>90
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001160)
,p_name=>'READY_TEST_COUNT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>100
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001170)
,p_name=>'OVERDUE_COUNT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>110
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001180)
,p_name=>'CRITICAL_COUNT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>120
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001190)
,p_name=>'OLDEST_OPEN_AT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>130
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001200)
,p_name=>'OLDEST_OPEN_DAYS'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>140
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001210)
,p_name=>'RESOLVED_LAST_30D'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>150
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001220)
,p_name=>'REOPENED_LAST_30D'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>160
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(71600000000001230)
,p_name=>'SUBMITTED_LAST_30D'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>170
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_card(
 p_id=>wwv_flow_imp.id(71600000000001240)
,p_region_id=>wwv_flow_imp.id(71600000000001060)
,p_layout_type=>'GRID'
,p_grid_column_count=>3
,p_card_appearance=>'BLOCK'
,p_title_adv_formatting=>false
,p_title_column_name=>'APPLICATION_NAME'
,p_sub_title_adv_formatting=>false
,p_sub_title_column_name=>'OWNER_NAME'
,p_body_adv_formatting=>true
,p_body_html_expr=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<dl class="afh-health">',
'  <dt>Open</dt><dd>&OPEN_COUNT.</dd>',
'  <dt>New</dt><dd>&NEW_COUNT.</dd>',
'  <dt>Triage</dt><dd>&TRIAGE_COUNT.</dd>',
'  <dt>In progress</dt><dd>&IN_PROGRESS_COUNT.</dd>',
'  <dt>Ready to test</dt><dd>&READY_TEST_COUNT.</dd>',
'  <dt>Critical</dt><dd>&CRITICAL_COUNT.</dd>',
'  <dt>Oldest open</dt><dd>&OLDEST_OPEN_DAYS. days</dd>',
'  <dt>Last 30 days</dt><dd>&SUBMITTED_LAST_30D. submitted, &RESOLVED_LAST_30D. resolved, &REOPENED_LAST_30D. reopened</dd>',
'</dl>'))
,p_second_body_adv_formatting=>false
,p_second_body_column_name=>'APP_KEY'
,p_badge_column_name=>'OVERDUE_COUNT'
,p_badge_label=>'Overdue'
,p_media_adv_formatting=>false
);
wwv_flow_imp_page.create_card_action(
 p_id=>wwv_flow_imp.id(71600000000001250)
,p_card_id=>wwv_flow_imp.id(71600000000001240)
,p_action_type=>'FULL_CARD'
,p_display_sequence=>10
,p_link_target_type=>'REDIRECT_PAGE'
,p_link_target=>'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:RP,3:P3_APPLICATION_ID:&APPLICATION_ID.'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71600000000001260)
,p_plug_name=>'Aging'
,p_region_name=>'afh-aging'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN afh_ui_pkg.render_aging(TO_NUMBER(:P3_APPLICATION_ID));',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
,p_ajax_items_to_submit=>'P3_APPLICATION_ID,P3_ENVIRONMENT_ID'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71600000000001270)
,p_plug_name=>'Open by dimension'
,p_region_name=>'afh-dimension'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN afh_ui_pkg.render_by_dimension(:P3_DIMENSION, TO_NUMBER(:P3_APPLICATION_ID), TO_NUMBER(:P3_ENVIRONMENT_ID));',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
,p_ajax_items_to_submit=>'P3_DIMENSION,P3_APPLICATION_ID,P3_ENVIRONMENT_ID'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71600000000001290)
,p_name=>'Pages with repeated reports'
,p_region_name=>'afh-repeated'
,p_template=>4072358936313175081
,p_display_sequence=>50
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT application_id,',
'       application_name,',
'       page_id,',
'       page_name,',
'       ticket_count,',
'       open_count,',
'       last_reported_at',
'  FROM TABLE(afh_reporting_pkg.repeated_pages(p_days => 90, p_min_reports => 2, p_application_id => :P3_APPLICATION_ID))',
' ORDER BY ticket_count DESC, last_reported_at DESC'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P3_APPLICATION_ID,P3_ENVIRONMENT_ID'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No page has two or more reports in the last 90 days.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001300)
,p_query_column_id=>1
,p_column_alias=>'APPLICATION_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001310)
,p_query_column_id=>2
,p_column_alias=>'APPLICATION_NAME'
,p_column_display_sequence=>20
,p_column_heading=>'Application'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001320)
,p_query_column_id=>3
,p_column_alias=>'PAGE_ID'
,p_column_display_sequence=>30
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001330)
,p_query_column_id=>4
,p_column_alias=>'PAGE_NAME'
,p_column_display_sequence=>40
,p_column_heading=>'Page'
,p_column_link=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.:2:P2_SEARCH:#PAGE_NAME#'
,p_column_linktext=>'#PAGE_NAME#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001340)
,p_query_column_id=>5
,p_column_alias=>'TICKET_COUNT'
,p_column_display_sequence=>50
,p_column_heading=>'Reports'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001350)
,p_query_column_id=>6
,p_column_alias=>'OPEN_COUNT'
,p_column_display_sequence=>60
,p_column_heading=>'Open'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001360)
,p_query_column_id=>7
,p_column_alias=>'LAST_REPORTED_AT'
,p_column_display_sequence=>70
,p_column_heading=>'Last reported'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71600000000001370)
,p_name=>'Recently resolved and reopened'
,p_region_name=>'afh-recent'
,p_template=>4072358936313175081
,p_display_sequence=>60
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ticket_id,',
'       ticket_no,',
'       title,',
'       application_id,',
'       application_name,',
'       status_code,',
'       status_label,',
'       status_color,',
'       kind,',
'       CASE kind WHEN ''RESOLVED'' THEN ''success'' ELSE ''warning'' END AS kind_class,',
'       at_time,',
'       assignee_name',
'  FROM afh_v_health_recent',
' WHERE (:P3_APPLICATION_ID IS NULL OR application_id = :P3_APPLICATION_ID)',
' ORDER BY at_time DESC',
' FETCH FIRST 50 ROWS ONLY'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P3_APPLICATION_ID,P3_ENVIRONMENT_ID'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'Nothing resolved or reopened in the last 30 days.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001380)
,p_query_column_id=>1
,p_column_alias=>'TICKET_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001390)
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
 p_id=>wwv_flow_imp.id(71600000000001400)
,p_query_column_id=>3
,p_column_alias=>'TITLE'
,p_column_display_sequence=>30
,p_column_heading=>'Title'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001410)
,p_query_column_id=>4
,p_column_alias=>'APPLICATION_ID'
,p_column_display_sequence=>40
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001420)
,p_query_column_id=>5
,p_column_alias=>'APPLICATION_NAME'
,p_column_display_sequence=>50
,p_column_heading=>'Application'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001430)
,p_query_column_id=>6
,p_column_alias=>'STATUS_CODE'
,p_column_display_sequence=>60
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001440)
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
 p_id=>wwv_flow_imp.id(71600000000001450)
,p_query_column_id=>8
,p_column_alias=>'STATUS_COLOR'
,p_column_display_sequence=>80
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001460)
,p_query_column_id=>9
,p_column_alias=>'KIND'
,p_column_display_sequence=>90
,p_column_heading=>'Change'
,p_column_html_expression=>'<span class="afh-chip afh-chip--#KIND_CLASS#">#KIND#</span>'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001470)
,p_query_column_id=>10
,p_column_alias=>'KIND_CLASS'
,p_column_display_sequence=>100
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001480)
,p_query_column_id=>11
,p_column_alias=>'AT_TIME'
,p_column_display_sequence=>110
,p_column_heading=>'When'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001490)
,p_query_column_id=>12
,p_column_alias=>'ASSIGNEE_NAME'
,p_column_display_sequence=>120
,p_column_heading=>'Assignee'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71600000000001500)
,p_name=>'Open tickets'
,p_region_name=>'afh-open'
,p_template=>2664334895415463485
,p_display_sequence=>70
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT q.ticket_id, q.ticket_no, q.title, q.type_label, q.application_name, q.env_code, q.page_id, q.page_name,',
'       q.status_code, q.status_label, q.status_seq, q.priority_code, q.priority_label, q.priority_seq,',
'       q.severity_label, q.impact_label, q.reporter_name, q.assignee_user_id, q.assignee_name, q.owner_name,',
'       q.release_label, q.due_date, q.is_overdue_yn, q.days_open, q.age_bucket,',
'       q.open_task_count, q.pending_test_count, q.comment_count, q.internal_note_count, q.attachment_count, q.has_context_yn,',
'       q.submitted_at, q.last_activity_at, q.row_version',
'  FROM afh_v_ticket_queue q',
' WHERE (:P3_APPLICATION_ID IS NULL OR q.application_id = :P3_APPLICATION_ID)',
'   AND (:P3_ENVIRONMENT_ID IS NULL OR q.environment_id = :P3_ENVIRONMENT_ID)',
' ORDER BY q.priority_seq DESC, q.last_activity_at DESC'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P3_APPLICATION_ID,P3_ENVIRONMENT_ID'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No open tickets for these filters.'
,p_query_num_rows_type=>'ROW_RANGES_WITH_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'Y'
,p_csv_output_link_text=>'Download CSV'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_exp_filename=>'&P3_EXPORT_NAME.'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001510)
,p_query_column_id=>1
,p_column_alias=>'TICKET_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001520)
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
 p_id=>wwv_flow_imp.id(71600000000001530)
,p_query_column_id=>3
,p_column_alias=>'TITLE'
,p_column_display_sequence=>30
,p_column_heading=>'Title'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001540)
,p_query_column_id=>4
,p_column_alias=>'TYPE_LABEL'
,p_column_display_sequence=>40
,p_column_heading=>'Type'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001550)
,p_query_column_id=>5
,p_column_alias=>'APPLICATION_NAME'
,p_column_display_sequence=>50
,p_column_heading=>'Application'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001560)
,p_query_column_id=>6
,p_column_alias=>'ENV_CODE'
,p_column_display_sequence=>60
,p_column_heading=>'Env'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001570)
,p_query_column_id=>7
,p_column_alias=>'PAGE_ID'
,p_column_display_sequence=>70
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001580)
,p_query_column_id=>8
,p_column_alias=>'PAGE_NAME'
,p_column_display_sequence=>80
,p_column_heading=>'Page'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001590)
,p_query_column_id=>9
,p_column_alias=>'STATUS_CODE'
,p_column_display_sequence=>90
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001600)
,p_query_column_id=>10
,p_column_alias=>'STATUS_LABEL'
,p_column_display_sequence=>100
,p_column_heading=>'Status'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001610)
,p_query_column_id=>11
,p_column_alias=>'STATUS_SEQ'
,p_column_display_sequence=>110
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001620)
,p_query_column_id=>12
,p_column_alias=>'PRIORITY_CODE'
,p_column_display_sequence=>120
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001630)
,p_query_column_id=>13
,p_column_alias=>'PRIORITY_LABEL'
,p_column_display_sequence=>130
,p_column_heading=>'Priority'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001640)
,p_query_column_id=>14
,p_column_alias=>'PRIORITY_SEQ'
,p_column_display_sequence=>140
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001650)
,p_query_column_id=>15
,p_column_alias=>'SEVERITY_LABEL'
,p_column_display_sequence=>150
,p_column_heading=>'Severity'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001660)
,p_query_column_id=>16
,p_column_alias=>'IMPACT_LABEL'
,p_column_display_sequence=>160
,p_column_heading=>'Impact'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001670)
,p_query_column_id=>17
,p_column_alias=>'REPORTER_NAME'
,p_column_display_sequence=>170
,p_column_heading=>'Reporter'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001680)
,p_query_column_id=>18
,p_column_alias=>'ASSIGNEE_USER_ID'
,p_column_display_sequence=>180
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001690)
,p_query_column_id=>19
,p_column_alias=>'ASSIGNEE_NAME'
,p_column_display_sequence=>190
,p_column_heading=>'Assignee'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001700)
,p_query_column_id=>20
,p_column_alias=>'OWNER_NAME'
,p_column_display_sequence=>200
,p_column_heading=>'Owner'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001710)
,p_query_column_id=>21
,p_column_alias=>'RELEASE_LABEL'
,p_column_display_sequence=>210
,p_column_heading=>'Release'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001720)
,p_query_column_id=>22
,p_column_alias=>'DUE_DATE'
,p_column_display_sequence=>220
,p_column_heading=>'Due'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001730)
,p_query_column_id=>23
,p_column_alias=>'IS_OVERDUE_YN'
,p_column_display_sequence=>230
,p_column_heading=>'Overdue'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001740)
,p_query_column_id=>24
,p_column_alias=>'DAYS_OPEN'
,p_column_display_sequence=>240
,p_column_heading=>'Days open'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001750)
,p_query_column_id=>25
,p_column_alias=>'AGE_BUCKET'
,p_column_display_sequence=>250
,p_column_heading=>'Age'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001760)
,p_query_column_id=>26
,p_column_alias=>'OPEN_TASK_COUNT'
,p_column_display_sequence=>260
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001770)
,p_query_column_id=>27
,p_column_alias=>'PENDING_TEST_COUNT'
,p_column_display_sequence=>270
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001780)
,p_query_column_id=>28
,p_column_alias=>'COMMENT_COUNT'
,p_column_display_sequence=>280
,p_column_heading=>'Comments'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001790)
,p_query_column_id=>29
,p_column_alias=>'INTERNAL_NOTE_COUNT'
,p_column_display_sequence=>290
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001800)
,p_query_column_id=>30
,p_column_alias=>'ATTACHMENT_COUNT'
,p_column_display_sequence=>300
,p_column_heading=>'Attachments'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001810)
,p_query_column_id=>31
,p_column_alias=>'HAS_CONTEXT_YN'
,p_column_display_sequence=>310
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001820)
,p_query_column_id=>32
,p_column_alias=>'SUBMITTED_AT'
,p_column_display_sequence=>320
,p_column_heading=>'Submitted'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001830)
,p_query_column_id=>33
,p_column_alias=>'LAST_ACTIVITY_AT'
,p_column_display_sequence=>330
,p_column_heading=>'Last activity'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71600000000001840)
,p_query_column_id=>34
,p_column_alias=>'ROW_VERSION'
,p_column_display_sequence=>340
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71600000000001020)
,p_name=>'P3_APPLICATION_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(71600000000001010)
,p_prompt=>'Application'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT display_name AS d, application_id AS r',
'  FROM afh_v_applications',
' WHERE is_active = ''Y''',
' ORDER BY display_name'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'All applications'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71600000000001030)
,p_name=>'P3_ENVIRONMENT_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(71600000000001010)
,p_prompt=>'Environment'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT label || '' ('' || env_code || '')'' AS d, environment_id AS r',
'  FROM afh_v_environments',
' WHERE application_id = :P3_APPLICATION_ID',
'   AND is_active = ''Y''',
' ORDER BY display_seq, env_code'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'All environments'
,p_lov_cascade_parent_items=>'P3_APPLICATION_ID'
,p_ajax_items_to_submit=>'P3_APPLICATION_ID'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71600000000001040)
,p_name=>'P3_EXPORT_NAME'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(71600000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'I'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71600000000001280)
,p_name=>'P3_DIMENSION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(71600000000001270)
,p_item_default=>'STATUS'
,p_prompt=>'Group open tickets by'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Status;STATUS,Type;TYPE,Severity;SEVERITY,Priority;PRIORITY,Page;PAGE,Owner;OWNER,Release;RELEASE,Environment;ENVIRONMENT'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_computation(
 p_id=>wwv_flow_imp.id(71600000000001050)
,p_computation_sequence=>10
,p_computation_item=>'P3_EXPORT_NAME'
,p_computation_point=>'BEFORE_HEADER'
,p_computation_type=>'FUNCTION_BODY'
,p_computation_language=>'PLSQL'
,p_computation=>'RETURN afh_reporting_pkg.export_file_name(''application-health'');'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71600000000001850)
,p_name=>'Filters changed'
,p_event_sequence=>10
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P3_APPLICATION_ID,P3_ENVIRONMENT_ID'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71600000000001860)
,p_event_id=>wwv_flow_imp.id(71600000000001850)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71600000000001060)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71600000000001870)
,p_event_id=>wwv_flow_imp.id(71600000000001850)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71600000000001260)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71600000000001880)
,p_event_id=>wwv_flow_imp.id(71600000000001850)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71600000000001270)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71600000000001890)
,p_event_id=>wwv_flow_imp.id(71600000000001850)
,p_event_result=>'TRUE'
,p_action_sequence=>40
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71600000000001290)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71600000000001900)
,p_event_id=>wwv_flow_imp.id(71600000000001850)
,p_event_result=>'TRUE'
,p_action_sequence=>50
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71600000000001370)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71600000000001910)
,p_event_id=>wwv_flow_imp.id(71600000000001850)
,p_event_result=>'TRUE'
,p_action_sequence=>60
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71600000000001500)
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71600000000001920)
,p_name=>'Dimension changed'
,p_event_sequence=>20
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P3_DIMENSION'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71600000000001930)
,p_event_id=>wwv_flow_imp.id(71600000000001920)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71600000000001270)
);
wwv_flow_imp.component_end;
end;
/
