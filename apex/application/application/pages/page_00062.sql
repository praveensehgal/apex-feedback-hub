prompt --application/pages/page_00062
begin
--   Manifest
--     PAGE: 00062
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
 p_id=>62
,p_name=>'Routing and Ownership'
,p_alias=>'ROUTING'
,p_step_title=>'Routing and Ownership'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function afhResolveRoute() {',
'  var out = document.getElementById(''afh-route-result'');',
'  apex.server.process(''RESOLVE_ROUTE'', { x01: $v(''P62_APPLICATION_ID''), x02: $v(''P62_TRY_PAGE_ID''), x03: $v(''P62_TRY_ENVIRONMENT_ID''), x04: $v(''P62_TRY_TYPE_CODE''), x05: $v(''P62_TRY_CATEGORY_ID'') }, { dataType: ''json'' })',
'    .then(function (r) { out.textContent = r.message; out.className = ''afh-bulk-result '' + (r.ok ? '''' : ''afh-overdue''); })',
'    .catch(function () { out.textContent = ''The route could not be resolved. Reload and try again.''; });',
'}'))
,p_step_template=>4072355960268175073
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68798393905371806)
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71100000000001010)
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
 p_id=>wwv_flow_imp.id(71100000000001040)
,p_name=>'Routing Rules'
,p_region_name=>'afh-rules'
,p_template=>4072358936313175081
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT routing_rule_id,',
'       application_id,',
'       application_name,',
'       priority_order,',
'       criteria_text,',
'       page_id,',
'       env_code,',
'       type_code,',
'       category_label,',
'       assignee_display_name,',
'       owner_display_name,',
'       is_active,',
'       description',
'  FROM afh_v_routing_rules',
' WHERE (:P62_APPLICATION_ID IS NULL OR application_id = :P62_APPLICATION_ID)',
'   AND (afh_security_pkg.is_admin_yn = ''Y'' OR afh_security_pkg.is_app_owner_yn(application_id) = ''Y'')',
' ORDER BY application_name, priority_order, routing_rule_id'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P62_APPLICATION_ID'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>100
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No routing rules yet - tickets go to the application owner.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71100000000001050)
,p_query_column_id=>1
,p_column_alias=>'ROUTING_RULE_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71100000000001060)
,p_query_column_id=>2
,p_column_alias=>'APPLICATION_ID'
,p_column_display_sequence=>20
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71100000000001070)
,p_query_column_id=>3
,p_column_alias=>'APPLICATION_NAME'
,p_column_display_sequence=>30
,p_column_heading=>'Application'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71100000000001080)
,p_query_column_id=>4
,p_column_alias=>'PRIORITY_ORDER'
,p_column_display_sequence=>40
,p_column_heading=>'Order'
,p_column_link=>'f?p=&APP_ID.:620:&SESSION.::&DEBUG.:620:P620_ROUTING_RULE_ID:#ROUTING_RULE_ID#'
,p_column_linktext=>'#PRIORITY_ORDER#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71100000000001090)
,p_query_column_id=>5
,p_column_alias=>'CRITERIA_TEXT'
,p_column_display_sequence=>50
,p_column_heading=>'Criteria'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71100000000001100)
,p_query_column_id=>6
,p_column_alias=>'PAGE_ID'
,p_column_display_sequence=>60
,p_column_heading=>'Page'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71100000000001110)
,p_query_column_id=>7
,p_column_alias=>'ENV_CODE'
,p_column_display_sequence=>70
,p_column_heading=>'Environment'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71100000000001120)
,p_query_column_id=>8
,p_column_alias=>'TYPE_CODE'
,p_column_display_sequence=>80
,p_column_heading=>'Type'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71100000000001130)
,p_query_column_id=>9
,p_column_alias=>'CATEGORY_LABEL'
,p_column_display_sequence=>90
,p_column_heading=>'Category'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71100000000001140)
,p_query_column_id=>10
,p_column_alias=>'ASSIGNEE_DISPLAY_NAME'
,p_column_display_sequence=>100
,p_column_heading=>'Assignee'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71100000000001150)
,p_query_column_id=>11
,p_column_alias=>'OWNER_DISPLAY_NAME'
,p_column_display_sequence=>110
,p_column_heading=>'Queue owner'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71100000000001160)
,p_query_column_id=>12
,p_column_alias=>'IS_ACTIVE'
,p_column_display_sequence=>120
,p_column_heading=>'Active'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71100000000001170)
,p_query_column_id=>13
,p_column_alias=>'DESCRIPTION'
,p_column_display_sequence=>130
,p_column_heading=>'Description'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71100000000001200)
,p_plug_name=>'Try a route'
,p_region_name=>'afh-try'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2664334895415463485
,p_plug_display_sequence=>30
,p_plug_source=>'<div id="afh-route-result" class="afh-bulk-result" aria-live="polite"></div>'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71100000000001030)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71100000000001010)
,p_button_name=>'ADD_RULE'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Add rule'
,p_button_redirect_url=>'f?p=&APP_ID.:620:&SESSION.::&DEBUG.:620:P620_APPLICATION_ID:&P62_APPLICATION_ID.'
,p_icon_css_classes=>'fa-plus'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71100000000001250)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71100000000001200)
,p_button_name=>'RESOLVE'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Resolve'
,p_icon_css_classes=>'fa-check'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71100000000001020)
,p_name=>'P62_APPLICATION_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(71100000000001010)
,p_prompt=>'Application'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT display_name AS d, application_id AS r',
'  FROM afh_v_applications',
' WHERE is_active = ''Y''',
'   AND (afh_security_pkg.is_admin_yn = ''Y'' OR owner_user_id = afh_security_pkg.current_user_id)',
' ORDER BY display_name'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'All my applications'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71100000000001210)
,p_name=>'P62_TRY_PAGE_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(71100000000001200)
,p_prompt=>'Page'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>8
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'virtual_keyboard', 'TEXT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71100000000001220)
,p_name=>'P62_TRY_ENVIRONMENT_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(71100000000001200)
,p_prompt=>'Environment'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, environment_id r FROM afh_v_environments WHERE application_id = :P62_APPLICATION_ID ORDER BY display_seq'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Any'
,p_lov_cascade_parent_items=>'P62_APPLICATION_ID'
,p_ajax_items_to_submit=>'P62_APPLICATION_ID'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71100000000001230)
,p_name=>'P62_TRY_TYPE_CODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(71100000000001200)
,p_prompt=>'Type'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, type_code r FROM afh_feedback_types WHERE is_active = ''Y'' ORDER BY display_seq'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Any'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71100000000001240)
,p_name=>'P62_TRY_CATEGORY_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(71100000000001200)
,p_prompt=>'Category'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, category_id r FROM afh_categories WHERE is_active = ''Y'' AND (application_id IS NULL OR application_id = :P62_APPLICATION_ID) ORDER BY label'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Any'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71100000000001180)
,p_name=>'Refresh after dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(71100000000001040)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71100000000001190)
,p_event_id=>wwv_flow_imp.id(71100000000001180)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71100000000001040)
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71100000000001260)
,p_name=>'Resolve route'
,p_event_sequence=>20
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71100000000001250)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71100000000001270)
,p_event_id=>wwv_flow_imp.id(71100000000001260)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'afhResolveRoute();'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71100000000001280)
,p_process_sequence=>10
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'RESOLVE_ROUTE'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_assignee NUMBER;',
'  l_owner    NUMBER;',
'  l_rule     NUMBER;',
'  l_text     VARCHAR2(1000);',
'BEGIN',
'  afh_registry_pkg.resolve_route(',
'    p_application_id   => TO_NUMBER(apex_application.g_x01),',
'    p_page_id          => TO_NUMBER(apex_application.g_x02 DEFAULT NULL ON CONVERSION ERROR),',
'    p_category_id      => TO_NUMBER(apex_application.g_x05 DEFAULT NULL ON CONVERSION ERROR),',
'    p_environment_id   => TO_NUMBER(apex_application.g_x03 DEFAULT NULL ON CONVERSION ERROR),',
'    p_type_code        => apex_application.g_x04,',
'    o_assignee_user_id => l_assignee,',
'    o_owner_user_id    => l_owner,',
'    o_routing_rule_id  => l_rule);',
'  SELECT ''Owner: '' || (SELECT display_name FROM afh_users WHERE user_id = l_owner)',
unistr('         || CASE WHEN l_assignee IS NOT NULL THEN '' \00B7 Assignee: '' || (SELECT display_name FROM afh_users WHERE user_id = l_assignee) ELSE '' \00B7 Unassigned queue'' END'),
unistr('         || CASE WHEN l_rule IS NOT NULL THEN '' \00B7 Rule #'' || l_rule ELSE '' \00B7 No rule matched (application owner fallback)'' END'),
'    INTO l_text FROM dual;',
'  apex_json.open_object; apex_json.write(''ok'', TRUE); apex_json.write(''message'', l_text); apex_json.close_object;',
'EXCEPTION WHEN OTHERS THEN',
'  apex_json.open_object; apex_json.write(''ok'', FALSE); apex_json.write(''message'', REGEXP_REPLACE(SQLERRM, ''^ORA-\d+: '', '''')); apex_json.close_object;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_security_scheme=>wwv_flow_imp.id(68798393905371806)
,p_internal_uid=>71100000000001280
);
wwv_flow_imp.component_end;
end;
/
