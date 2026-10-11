prompt --application/pages/page_00051
begin
--   Manifest
--     PAGE: 00051
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
 p_id=>51
,p_name=>'Notification Preferences'
,p_alias=>'NOTIFICATION-PREFS'
,p_step_title=>'Notification Preferences'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function afhSaveOverrides() {',
'  var rows = document.querySelectorAll(''#afh-pref-table tbody tr''), f01 = [], f02 = [], f03 = [];',
'  rows.forEach(function (tr) {',
'    f01.push(tr.dataset.event);',
'    f02.push(tr.querySelector(''[data-channel="EMAIL"]'').value);',
'    f03.push(tr.querySelector(''[data-channel="IN_APP"]'').value);',
'  });',
'  apex.server.process(''SAVE_OVERRIDES'', { x01: $v(''P51_APPLICATION_ID''), f01: f01, f02: f02, f03: f03 }, { dataType: ''json'' })',
'    .then(function (r) { if (r.ok) { apex.message.showPageSuccess(r.message); apex.region(''afh-prefs'').refresh(); } else { apex.message.alert(r.message); } })',
'    .catch(function () { apex.message.alert(''The preferences could not be saved. Reload and try again.''); });',
'}'))
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Notification preferences grid (AFH_UI_PKG.render_pref_grid). */',
'.afh-pref-select { padding: 4px 8px; border: 1px solid var(--afh-border); border-radius: var(--afh-radius-xs); background: var(--afh-paper); font: inherit; }'))
,p_step_template=>4072355960268175073
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68608126239417213)
,p_protection_level=>'C'
,p_page_component_map=>'25'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70800000000001010)
,p_plug_name=>'How do you want to be notified?'
,p_region_name=>'afh-preset'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70800000000001050)
,p_plug_name=>'Per application'
,p_region_name=>'afh-per-app'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70800000000001110)
,p_plug_name=>'Per event'
,p_region_name=>'afh-prefs'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN afh_ui_pkg.render_pref_grid(TO_NUMBER(:P51_APPLICATION_ID));',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
,p_ajax_items_to_submit=>'P51_APPLICATION_ID'
,p_plug_header=>'<p>Choose On or Off to override the preset for one event. Choose Use preset on both columns to remove the override. Direct tasks always appear in My Work regardless of these settings.</p>'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70800000000001030)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70800000000001010)
,p_button_name=>'SAVE_PRESET'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft:t-Button--stretch'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save preset'
,p_icon_css_classes=>'fa-save'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70800000000001090)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70800000000001050)
,p_button_name=>'SAVE_APP_PRESET'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft:t-Button--stretch'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save application preset'
,p_button_condition=>'P51_APPLICATION_ID'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_icon_css_classes=>'fa-save'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70800000000001120)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70800000000001110)
,p_button_name=>'SAVE_OVERRIDES'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft:t-Button--stretch'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save overrides'
,p_icon_css_classes=>'fa-save'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70800000000001020)
,p_name=>'P51_PRESET'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70800000000001010)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Preset'
,p_source=>'RETURN afh_notification_pkg.effective_preset(NULL);'
,p_source_type=>'FUNCTION_BODY'
,p_source_language=>'PLSQL'
,p_display_as=>'NATIVE_RADIOGROUP'
,p_lov=>'STATIC2:Immediate - every followed event by email and in-app;IMMEDIATE,Important only - assignments, mentions, information and test requests, resolution, reopening;IMPORTANT,Daily digest - direct events now, everything else once a day;DAILY,Weekly di'
||'gest - direct events now, everything else once a week;WEEKLY,In-app only - no email;IN_APP'
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1',
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70800000000001060)
,p_name=>'P51_APPLICATION_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70800000000001050)
,p_prompt=>'Application'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT display_name AS d, application_id AS r',
'  FROM afh_v_applications',
' WHERE is_active = ''Y''',
' ORDER BY display_name'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- All applications (global) -'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70800000000001070)
,p_name=>'P51_APP_PRESET'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70800000000001050)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Preset for this application'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT MAX(scope_preset_code)',
'  FROM afh_v_notification_prefs',
' WHERE scope_code = ''APP''',
'   AND application_id = :P51_APPLICATION_ID'))
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_RADIOGROUP'
,p_lov=>'STATIC2:Immediate - every followed event by email and in-app;IMMEDIATE,Important only - assignments, mentions, information and test requests, resolution, reopening;IMPORTANT,Daily digest - direct events now, everything else once a day;DAILY,Weekly di'
||'gest - direct events now, everything else once a week;WEEKLY,In-app only - no email;IN_APP'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Use the global preset'
,p_display_when=>'P51_APPLICATION_ID'
,p_display_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1',
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70800000000001080)
,p_name=>'P51_APP_EFFECTIVE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(70800000000001050)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Effective preset'
,p_source=>'RETURN afh_notification_pkg.effective_preset(:P51_APPLICATION_ID);'
,p_source_type=>'FUNCTION_BODY'
,p_source_language=>'PLSQL'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_display_when=>'P51_APPLICATION_ID'
,p_display_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(70800000000001130)
,p_name=>'Save overrides'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(70800000000001120)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(70800000000001140)
,p_event_id=>wwv_flow_imp.id(70800000000001130)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'afhSaveOverrides();'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70800000000001040)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save preset'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_notification_pkg.set_preset(p_preset_code => :P51_PRESET, p_application_id => NULL);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(70800000000001030)
,p_process_success_message=>'Preset saved.'
,p_internal_uid=>70800000000001040
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70800000000001100)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save application preset'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  IF :P51_APP_PRESET IS NULL THEN',
'    afh_notification_pkg.clear_preset(p_application_id => :P51_APPLICATION_ID);',
'  ELSE',
'    afh_notification_pkg.set_preset(p_preset_code => :P51_APP_PRESET, p_application_id => :P51_APPLICATION_ID);',
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(70800000000001090)
,p_process_success_message=>'Application preset saved.'
,p_internal_uid=>70800000000001100
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70800000000001150)
,p_process_sequence=>30
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'SAVE_OVERRIDES'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_app NUMBER := TO_NUMBER(apex_application.g_x01 DEFAULT NULL ON CONVERSION ERROR);',
'  l_email VARCHAR2(1); l_inapp VARCHAR2(1); l_n PLS_INTEGER := 0;',
'BEGIN',
'  FOR i IN 1 .. apex_application.g_f01.COUNT LOOP',
'    l_email := NULLIF(apex_application.g_f02(i), ''''); l_inapp := NULLIF(apex_application.g_f03(i), '''');',
'    IF l_email IS NULL AND l_inapp IS NULL THEN',
'      afh_notification_pkg.clear_event_override(p_event_code => apex_application.g_f01(i), p_application_id => l_app);',
'    ELSE',
'      SELECT NVL(l_email, MAX(effective_email_yn)), NVL(l_inapp, MAX(effective_in_app_yn)) INTO l_email, l_inapp',
'        FROM afh_v_notification_prefs',
'       WHERE event_code = apex_application.g_f01(i)',
'         AND ((l_app IS NULL AND scope_code = ''GLOBAL'') OR (scope_code = ''APP'' AND application_id = l_app));',
'      afh_notification_pkg.set_event_override(p_event_code => apex_application.g_f01(i), p_email_enabled => l_email, p_in_app_enabled => l_inapp, p_application_id => l_app);',
'    END IF;',
'    l_n := l_n + 1;',
'  END LOOP;',
'  apex_json.open_object; apex_json.write(''ok'', TRUE); apex_json.write(''message'', ''Preferences saved for '' || l_n || '' event(s).''); apex_json.close_object;',
'EXCEPTION WHEN OTHERS THEN',
'  apex_json.open_object; apex_json.write(''ok'', FALSE); apex_json.write(''message'', REGEXP_REPLACE(SQLERRM, ''^ORA-\d+: '', '''')); apex_json.close_object;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_security_scheme=>wwv_flow_imp.id(68608126239417213)
,p_internal_uid=>70800000000001150
);
wwv_flow_imp.component_end;
end;
/
