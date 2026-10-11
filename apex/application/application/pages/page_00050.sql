prompt --application/pages/page_00050
begin
--   Manifest
--     PAGE: 00050
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
 p_id=>50
,p_name=>'Notification Center'
,p_alias=>'NOTIFICATIONS'
,p_step_title=>'Notification Center'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Notification Center rows (AFH_UI_PKG.render_notifications). */',
'.afh-notifs { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 8px; }',
'.afh-notif { display: flex; gap: 12px; align-items: flex-start; padding: 12px 14px; border: 1px solid var(--afh-border); border-radius: var(--afh-radius-md); background: var(--afh-paper); }',
'.afh-notif--unread { border-left: 4px solid var(--ut-palette-primary, var(--afh-teal)); }',
'.afh-notif--unread .afh-notif-subject { font-weight: 700; }',
'.afh-notif--read { opacity: .75; }',
'.afh-notif-icon { width: 34px; height: 34px; border-radius: 50%; background: var(--afh-paper-3); display: inline-flex; align-items: center; justify-content: center; color: var(--afh-ink-soft); flex: none; }',
'.afh-notif-body { flex: 1; min-width: 0; }',
'.afh-notif-subject { font-size: 0.95rem; color: var(--afh-ink); display: block; }',
'.afh-notif-text { margin: 4px 0; font-size: 0.86rem; color: var(--afh-ink-soft); }',
'.afh-notif-actions { display: flex; gap: 6px; flex: none; }'))
,p_step_template=>4072355960268175073
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68608126239417213)
,p_protection_level=>'C'
,p_page_component_map=>'25'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70700000000001010)
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
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70700000000001090)
,p_plug_name=>'Notifications'
,p_region_name=>'afh-notifs'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN afh_ui_pkg.render_notifications(:P50_FILTER, :APP_ID, :APP_SESSION);',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(70700000000001100)
,p_name=>'Your open tasks'
,p_region_name=>'afh-tasks'
,p_template=>2664334895415463485
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
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
'       due_date,',
'       is_overdue_yn,',
'       related_id,',
'       created_at,',
'       created_by',
'  FROM afh_v_my_tasks',
' ORDER BY CASE task_type_code WHEN ''ASSIGNMENT'' THEN 1 WHEN ''INFO_REQUEST'' THEN 2 WHEN ''TEST_REQUEST'' THEN 3 ELSE 4 END,',
'          NVL(due_date, created_at),',
'          task_id'))
,p_header=>'<p class="afh-notif-actions">Direct tasks (assignment, information request, test request) stay here even when the ticket is muted or email is off.</p>'
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No open tasks.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001110)
,p_query_column_id=>1
,p_column_alias=>'TASK_LABEL'
,p_column_display_sequence=>10
,p_column_heading=>'Task'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001120)
,p_query_column_id=>2
,p_column_alias=>'TASK_ID'
,p_column_display_sequence=>20
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001130)
,p_query_column_id=>3
,p_column_alias=>'TASK_TYPE_CODE'
,p_column_display_sequence=>30
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001140)
,p_query_column_id=>4
,p_column_alias=>'TICKET_ID'
,p_column_display_sequence=>40
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001150)
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
 p_id=>wwv_flow_imp.id(70700000000001160)
,p_query_column_id=>6
,p_column_alias=>'TITLE'
,p_column_display_sequence=>60
,p_column_heading=>'Title'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001170)
,p_query_column_id=>7
,p_column_alias=>'STATUS_LABEL'
,p_column_display_sequence=>70
,p_column_heading=>'Status'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001180)
,p_query_column_id=>8
,p_column_alias=>'STATUS_CODE'
,p_column_display_sequence=>80
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001190)
,p_query_column_id=>9
,p_column_alias=>'STATUS_COLOR'
,p_column_display_sequence=>90
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001200)
,p_query_column_id=>10
,p_column_alias=>'APPLICATION_NAME'
,p_column_display_sequence=>100
,p_column_heading=>'Application'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001210)
,p_query_column_id=>11
,p_column_alias=>'SUMMARY'
,p_column_display_sequence=>110
,p_column_heading=>'Summary'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001220)
,p_query_column_id=>12
,p_column_alias=>'DUE_DATE'
,p_column_display_sequence=>120
,p_column_heading=>'Due'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001230)
,p_query_column_id=>13
,p_column_alias=>'IS_OVERDUE_YN'
,p_column_display_sequence=>130
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001240)
,p_query_column_id=>14
,p_column_alias=>'RELATED_ID'
,p_column_display_sequence=>140
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001250)
,p_query_column_id=>15
,p_column_alias=>'CREATED_AT'
,p_column_display_sequence=>150
,p_column_heading=>'Created'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(70700000000001260)
,p_query_column_id=>16
,p_column_alias=>'CREATED_BY'
,p_column_display_sequence=>160
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70700000000001040)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70700000000001010)
,p_button_name=>'MARK_ALL_READ'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Mark all read'
,p_button_condition=>'RETURN NVL(:G_UNREAD_COUNT, 0) > 0;'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-check'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70700000000001050)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(70700000000001010)
,p_button_name=>'PREFERENCES'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Preferences'
,p_button_redirect_url=>'f?p=&APP_ID.:51:&SESSION.::&DEBUG.:::'
,p_icon_css_classes=>'fa-sliders'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70700000000001020)
,p_name=>'P50_FILTER'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70700000000001010)
,p_item_default=>'UNREAD'
,p_prompt=>'Show'
,p_display_as=>'NATIVE_RADIOGROUP'
,p_lov=>'STATIC2:Unread;UNREAD,All;ALL'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '2',
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70700000000001030)
,p_name=>'P50_NOTIFICATION_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70700000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70700000000001080)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Mark all read'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_notification_pkg.mark_all_read;',
'  :G_UNREAD_COUNT := 0;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'MARK_ALL_READ'
,p_process_when_type=>'REQUEST_EQUALS_CONDITION'
,p_process_success_message=>'All notifications marked as read.'
,p_internal_uid=>70700000000001080
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70700000000001060)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Open notification'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_url VARCHAR2(500);',
'BEGIN',
'  afh_notification_pkg.mark_read(:P50_NOTIFICATION_ID);',
'  SELECT link_target',
'    INTO l_url',
'    FROM afh_v_my_notifications',
'   WHERE notification_id = :P50_NOTIFICATION_ID;',
'  :G_UNREAD_COUNT     := afh_notification_pkg.unread_count;',
'  :P50_NOTIFICATION_ID := NULL;',
'  IF l_url IS NOT NULL THEN',
'    l_url := REPLACE(REPLACE(l_url, ''&APP_ID.'', :APP_ID), ''&SESSION.'', :APP_SESSION);',
'    apex_util.redirect_url(apex_util.prepare_url(l_url));',
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_process_error_message=>'That notification is no longer available.'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'OPEN'
,p_process_when_type=>'REQUEST_EQUALS_CONDITION'
,p_internal_uid=>70700000000001060
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70700000000001070)
,p_process_sequence=>20
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Mark read'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_notification_pkg.mark_read(:P50_NOTIFICATION_ID);',
'  :G_UNREAD_COUNT      := afh_notification_pkg.unread_count;',
'  :P50_NOTIFICATION_ID := NULL;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'MARK_READ'
,p_process_when_type=>'REQUEST_EQUALS_CONDITION'
,p_internal_uid=>70700000000001070
);
wwv_flow_imp.component_end;
end;
/
