prompt --application/pages/page_00040
begin
--   Manifest
--     PAGE: 00040
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
 p_id=>40
,p_name=>'Releases'
,p_alias=>'RELEASES'
,p_step_title=>'Releases'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Releases: release card (AFH_UI_PKG.render_release). */',
'.afh-release-head { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-bottom: 10px; }',
'.afh-release-title { margin: 0; font-family: var(--afh-display); font-size: 1.4rem; font-weight: 600; }',
'.afh-release-label { font-family: var(--afh-body); font-weight: 400; color: var(--afh-ink-soft); }',
'.afh-release-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); gap: 10px; margin: 8px 0; }',
'.afh-release-bar { margin: 6px 0 10px; }',
'.afh-release-notes { color: var(--afh-ink-soft); font-size: 0.9rem; }'))
,p_step_template=>4072355960268175073
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68798083122369972)
,p_protection_level=>'C'
,p_page_component_map=>'25'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70600000000001010)
,p_plug_name=>'Filter'
,p_region_name=>'afh-filter'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70600000000001060)
,p_name=>'Releases'
,p_region_name=>'afh-releases'
,p_template=>4072358936313175081
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT release_id,',
'       application_id,',
'       app_key,',
'       application_name,',
'       release_code,',
'       label,',
'       target_date,',
'       completed_date,',
'       state_code,',
'       CASE state_code WHEN ''IN_PROGRESS'' THEN 1 WHEN ''PLANNED'' THEN 2 WHEN ''COMPLETED'' THEN 3 ELSE 4 END AS state_seq,',
'       ticket_count,',
'       unresolved_count,',
'       resolved_count,',
'       CASE WHEN unresolved_count > 0 AND state_code NOT IN (''COMPLETED'', ''CANCELLED'') THEN ''afh-unresolved'' END AS unresolved_class,',
'       notes,',
'       ''Edit'' AS edit_link',
'  FROM afh_v_releases',
' WHERE :P40_APPLICATION_ID IS NULL OR application_id = :P40_APPLICATION_ID'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P40_APPLICATION_ID'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No releases yet.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001070)
,p_query_column_id=>1
,p_column_alias=>'RELEASE_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001080)
,p_query_column_id=>2
,p_column_alias=>'APPLICATION_ID'
,p_column_display_sequence=>20
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001090)
,p_query_column_id=>3
,p_column_alias=>'APP_KEY'
,p_column_display_sequence=>30
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001100)
,p_query_column_id=>4
,p_column_alias=>'APPLICATION_NAME'
,p_column_display_sequence=>40
,p_column_heading=>'Application'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001110)
,p_query_column_id=>5
,p_column_alias=>'RELEASE_CODE'
,p_column_display_sequence=>50
,p_column_heading=>'Release'
,p_column_link=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.::P40_RELEASE_ID:#RELEASE_ID#'
,p_column_linktext=>'#RELEASE_CODE#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001120)
,p_query_column_id=>6
,p_column_alias=>'LABEL'
,p_column_display_sequence=>60
,p_column_heading=>'Label'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001130)
,p_query_column_id=>7
,p_column_alias=>'TARGET_DATE'
,p_column_display_sequence=>70
,p_column_heading=>'Target'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001140)
,p_query_column_id=>8
,p_column_alias=>'COMPLETED_DATE'
,p_column_display_sequence=>80
,p_column_heading=>'Completed'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001150)
,p_query_column_id=>9
,p_column_alias=>'STATE_CODE'
,p_column_display_sequence=>90
,p_column_heading=>'State'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001160)
,p_query_column_id=>10
,p_column_alias=>'STATE_SEQ'
,p_column_display_sequence=>100
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001170)
,p_query_column_id=>11
,p_column_alias=>'TICKET_COUNT'
,p_column_display_sequence=>110
,p_column_heading=>'Tickets'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001180)
,p_query_column_id=>12
,p_column_alias=>'UNRESOLVED_COUNT'
,p_column_display_sequence=>120
,p_column_heading=>'Unresolved'
,p_column_html_expression=>'<span class="#UNRESOLVED_CLASS#">#UNRESOLVED_COUNT#</span>'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001190)
,p_query_column_id=>13
,p_column_alias=>'RESOLVED_COUNT'
,p_column_display_sequence=>130
,p_column_heading=>'Resolved'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001200)
,p_query_column_id=>14
,p_column_alias=>'UNRESOLVED_CLASS'
,p_column_display_sequence=>140
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001210)
,p_query_column_id=>15
,p_column_alias=>'NOTES'
,p_column_display_sequence=>150
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001220)
,p_query_column_id=>16
,p_column_alias=>'EDIT_LINK'
,p_column_display_sequence=>160
,p_column_link=>'f?p=&APP_ID.:400:&SESSION.::&DEBUG.:400:P400_RELEASE_ID:#RELEASE_ID#'
,p_column_linktext=>'Edit'
,p_heading_alignment=>'LEFT'
,p_report_column_required_role=>wwv_flow_imp.id(68798393905371806)
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70600000000001230)
,p_plug_name=>'Release'
,p_region_name=>'afh-release'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN afh_ui_pkg.render_release(:P40_RELEASE_ID);',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
,p_plug_display_condition_type=>'ITEM_IS_NOT_NULL'
,p_plug_display_when_condition=>'P40_RELEASE_ID'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70600000000001270)
,p_name=>'Tickets in release'
,p_region_name=>'afh-release-tickets'
,p_template=>4072358936313175081
,p_display_sequence=>40
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT release_id,',
'       ticket_id,',
'       ticket_no,',
'       title,',
'       status_code,',
'       status_label,',
'       CASE WHEN status_code NOT IN (''RESOLVED'', ''CLOSED'', ''DUPLICATE'', ''REJECTED'', ''CANNOT_REPRODUCE'') THEN ''Y'' ELSE ''N'' END AS unresolved_yn,',
'       CASE WHEN status_code NOT IN (''RESOLVED'', ''CLOSED'', ''DUPLICATE'', ''REJECTED'', ''CANNOT_REPRODUCE'') THEN ''afh-unresolved'' END AS status_class,',
'       assignee_user_id,',
'       assignee_display_name,',
'       severity_code,',
'       priority_code,',
'       last_activity_at',
'  FROM afh_v_release_tickets',
' WHERE release_id = :P40_RELEASE_ID',
' ORDER BY CASE WHEN status_code NOT IN (''RESOLVED'', ''CLOSED'', ''DUPLICATE'', ''REJECTED'', ''CANNOT_REPRODUCE'') THEN 0 ELSE 1 END,',
'          priority_code, ticket_no'))
,p_display_when_condition=>'P40_RELEASE_ID'
,p_display_condition_type=>'ITEM_IS_NOT_NULL'
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No tickets are planned for this release.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001280)
,p_query_column_id=>1
,p_column_alias=>'RELEASE_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001290)
,p_query_column_id=>2
,p_column_alias=>'TICKET_ID'
,p_column_display_sequence=>20
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001300)
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
 p_id=>wwv_flow_imp.id(70600000000001310)
,p_query_column_id=>4
,p_column_alias=>'TITLE'
,p_column_display_sequence=>40
,p_column_heading=>'Title'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001320)
,p_query_column_id=>5
,p_column_alias=>'STATUS_CODE'
,p_column_display_sequence=>50
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001330)
,p_query_column_id=>6
,p_column_alias=>'STATUS_LABEL'
,p_column_display_sequence=>60
,p_column_heading=>'Status'
,p_column_html_expression=>'<span class="#STATUS_CLASS#">#STATUS_LABEL#</span>'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001340)
,p_query_column_id=>7
,p_column_alias=>'UNRESOLVED_YN'
,p_column_display_sequence=>70
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001350)
,p_query_column_id=>8
,p_column_alias=>'STATUS_CLASS'
,p_column_display_sequence=>80
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001360)
,p_query_column_id=>9
,p_column_alias=>'ASSIGNEE_USER_ID'
,p_column_display_sequence=>90
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001370)
,p_query_column_id=>10
,p_column_alias=>'ASSIGNEE_DISPLAY_NAME'
,p_column_display_sequence=>100
,p_column_heading=>'Assignee'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001380)
,p_query_column_id=>11
,p_column_alias=>'SEVERITY_CODE'
,p_column_display_sequence=>110
,p_column_heading=>'Severity'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001390)
,p_query_column_id=>12
,p_column_alias=>'PRIORITY_CODE'
,p_column_display_sequence=>120
,p_column_heading=>'Priority'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001400)
,p_query_column_id=>13
,p_column_alias=>'LAST_ACTIVITY_AT'
,p_column_display_sequence=>130
,p_column_heading=>'Last activity'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70600000000001410)
,p_name=>'Tests in release'
,p_region_name=>'afh-release-tests'
,p_template=>4072358936313175081
,p_display_sequence=>50
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT test_result_id,',
'       ticket_id,',
'       ticket_no,',
'       environment_label,',
'       app_version,',
'       assignee_display_name,',
'       requested_by_display_name,',
'       requested_at,',
'       result_code,',
'       result_label,',
'       completed_at,',
'       completed_by_display_name',
'  FROM afh_v_ticket_tests',
' WHERE release_id = :P40_RELEASE_ID',
' ORDER BY CASE result_code WHEN ''PENDING'' THEN 0 ELSE 1 END, requested_at DESC'))
,p_display_when_condition=>'P40_RELEASE_ID'
,p_display_condition_type=>'ITEM_IS_NOT_NULL'
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No test requests reference this release.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001420)
,p_query_column_id=>1
,p_column_alias=>'TEST_RESULT_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001430)
,p_query_column_id=>2
,p_column_alias=>'TICKET_ID'
,p_column_display_sequence=>20
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001440)
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
 p_id=>wwv_flow_imp.id(70600000000001450)
,p_query_column_id=>4
,p_column_alias=>'ENVIRONMENT_LABEL'
,p_column_display_sequence=>40
,p_column_heading=>'Environment'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001460)
,p_query_column_id=>5
,p_column_alias=>'APP_VERSION'
,p_column_display_sequence=>50
,p_column_heading=>'Version'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001470)
,p_query_column_id=>6
,p_column_alias=>'ASSIGNEE_DISPLAY_NAME'
,p_column_display_sequence=>60
,p_column_heading=>'Tester'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001480)
,p_query_column_id=>7
,p_column_alias=>'REQUESTED_BY_DISPLAY_NAME'
,p_column_display_sequence=>70
,p_column_heading=>'Requested by'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001490)
,p_query_column_id=>8
,p_column_alias=>'REQUESTED_AT'
,p_column_display_sequence=>80
,p_column_heading=>'Requested'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001500)
,p_query_column_id=>9
,p_column_alias=>'RESULT_CODE'
,p_column_display_sequence=>90
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001510)
,p_query_column_id=>10
,p_column_alias=>'RESULT_LABEL'
,p_column_display_sequence=>100
,p_column_heading=>'Result'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001520)
,p_query_column_id=>11
,p_column_alias=>'COMPLETED_AT'
,p_column_display_sequence=>110
,p_column_heading=>'Completed'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70600000000001530)
,p_query_column_id=>12
,p_column_alias=>'COMPLETED_BY_DISPLAY_NAME'
,p_column_display_sequence=>120
,p_column_heading=>'Completed by'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70600000000001050)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70600000000001010)
,p_button_name=>'NEW_RELEASE'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'New release'
,p_button_redirect_url=>'f?p=&APP_ID.:400:&SESSION.::&DEBUG.:400:P400_APPLICATION_ID:&P40_APPLICATION_ID.'
,p_icon_css_classes=>'fa-plus'
,p_grid_new_row=>'Y'
,p_security_scheme=>wwv_flow_imp.id(68798393905371806)
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70600000000001240)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70600000000001230)
,p_button_name=>'EDIT_RELEASE'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Edit release'
,p_button_redirect_url=>'f?p=&APP_ID.:400:&SESSION.::&DEBUG.:400:P400_RELEASE_ID:&P40_RELEASE_ID.'
,p_icon_css_classes=>'fa-edit'
,p_grid_new_row=>'Y'
,p_security_scheme=>wwv_flow_imp.id(68798393905371806)
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70600000000001250)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(70600000000001230)
,p_button_name=>'COMPLETE_RELEASE'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Complete release'
,p_button_redirect_url=>'f?p=&APP_ID.:401:&SESSION.::&DEBUG.:401:P401_RELEASE_ID:&P40_RELEASE_ID.'
,p_button_condition=>'RETURN :P40_RELEASE_STATE NOT IN (''COMPLETED'', ''CANCELLED'');'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-flag-checkered'
,p_grid_new_row=>'Y'
,p_security_scheme=>wwv_flow_imp.id(68798393905371806)
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70600000000001020)
,p_name=>'P40_APPLICATION_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70600000000001010)
,p_prompt=>'Application'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT display_name d, application_id r FROM afh_v_applications WHERE is_active = ''Y'' ORDER BY 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- All applications -'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70600000000001030)
,p_name=>'P40_RELEASE_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70600000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70600000000001040)
,p_name=>'P40_RELEASE_STATE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(70600000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'I'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_computation(
 p_id=>wwv_flow_imp.id(70600000000001260)
,p_computation_sequence=>10
,p_computation_item=>'P40_RELEASE_STATE'
,p_computation_point=>'BEFORE_HEADER'
,p_computation_type=>'QUERY'
,p_computation=>'SELECT state_code FROM afh_v_releases WHERE release_id = :P40_RELEASE_ID'
,p_compute_when=>'P40_RELEASE_ID'
,p_compute_when_type=>'ITEM_IS_NOT_NULL'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(70600000000001540)
,p_name=>'Refresh after dialog (list)'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(70600000000001060)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(70600000000001550)
,p_event_id=>wwv_flow_imp.id(70600000000001540)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_SUBMIT_PAGE'
,p_attribute_01=>'DIALOG_CLOSED'
,p_attribute_02=>'N'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(70600000000001560)
,p_name=>'Refresh after dialog (release)'
,p_event_sequence=>20
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(70600000000001230)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(70600000000001570)
,p_event_id=>wwv_flow_imp.id(70600000000001560)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_SUBMIT_PAGE'
,p_attribute_01=>'DIALOG_CLOSED'
,p_attribute_02=>'N'
);
wwv_flow_imp.component_end;
end;
/
