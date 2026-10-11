prompt --application/pages/page_00611
begin
--   Manifest
--     PAGE: 00611
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
 p_id=>611
,p_name=>'Environment'
,p_alias=>'ENVIRONMENT'
,p_page_mode=>'MODAL'
,p_step_title=>'Environment'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>2100407606326202693
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68797704657367743)
,p_dialog_width=>'560'
,p_dialog_chained=>'N'
,p_protection_level=>'C'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71000000000002010)
,p_plug_name=>'Environment'
,p_region_name=>'afh-env-form'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71000000000002020)
,p_plug_name=>'Buttons'
,p_region_name=>'afh-env-buttons'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>20
,p_plug_display_point=>'REGION_POSITION_03'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71000000000002120)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71000000000002020)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Cancel'
,p_button_position=>'CLOSE'
,p_icon_css_classes=>'fa-times'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71000000000002130)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(71000000000002020)
,p_button_name=>'DEACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Deactivate'
,p_button_position=>'DELETE'
,p_button_condition=>'RETURN :P611_ENVIRONMENT_ID IS NOT NULL AND :P611_IS_ACTIVE = ''Y'';'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-ban'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71000000000002140)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(71000000000002020)
,p_button_name=>'REACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Reactivate'
,p_button_position=>'DELETE'
,p_button_condition=>'RETURN :P611_IS_ACTIVE = ''N'';'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-refresh'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71000000000002150)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(71000000000002020)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save'
,p_button_position=>'NEXT'
,p_icon_css_classes=>'fa-save'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000002030)
,p_name=>'P611_ENVIRONMENT_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(71000000000002010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000002040)
,p_name=>'P611_APPLICATION_ID'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(71000000000002010)
,p_prompt=>'Application'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT display_name d, application_id r FROM afh_v_applications WHERE is_active = ''Y'' ORDER BY 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Select application -'
,p_read_only_when=>'P611_ENVIRONMENT_ID'
,p_read_only_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000002050)
,p_name=>'P611_ENV_CODE'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(71000000000002010)
,p_prompt=>'Environment code'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>30
,p_read_only_when=>'P611_ENVIRONMENT_ID'
,p_read_only_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000002060)
,p_name=>'P611_LABEL'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(71000000000002010)
,p_prompt=>'Label'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>60
,p_cMaxlength=>255
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000002070)
,p_name=>'P611_SOURCE_IDENTIFIER'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(71000000000002010)
,p_prompt=>'Source identifier'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>60
,p_cMaxlength=>255
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000002080)
,p_name=>'P611_BASE_URL_PATTERN'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(71000000000002010)
,p_prompt=>'Base URL pattern'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>60
,p_cMaxlength=>1000
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_help_text=>'LIKE pattern, e.g. https://test.example.com/%'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000002090)
,p_name=>'P611_APP_VERSION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(71000000000002010)
,p_prompt=>'Application version'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>50
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000002100)
,p_name=>'P611_DISPLAY_SEQ'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(71000000000002010)
,p_item_default=>'10'
,p_prompt=>'Display sequence'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>6
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'virtual_keyboard', 'TEXT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000002110)
,p_name=>'P611_IS_ACTIVE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(71000000000002010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'I'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(71000000000002190)
,p_validation_name=>'Environment code format'
,p_validation_sequence=>10
,p_validation=>'P611_ENV_CODE'
,p_validation2=>'^[A-Z][A-Z0-9_]{0,29}$'
,p_validation_type=>'REGULAR_EXPRESSION'
,p_error_message=>'Environment code: uppercase letters, digits, underscores.'
,p_when_button_pressed=>wwv_flow_imp.id(71000000000002150)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71000000000002160)
,p_name=>'Cancel dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71000000000002120)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71000000000002170)
,p_event_id=>wwv_flow_imp.id(71000000000002160)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71000000000002200)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save environment'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_id NUMBER;',
'BEGIN',
'  IF :P611_ENVIRONMENT_ID IS NULL THEN',
'    l_id := afh_registry_pkg.add_environment(',
'              p_application_id    => :P611_APPLICATION_ID,',
'              p_env_code          => :P611_ENV_CODE,',
'              p_label             => :P611_LABEL,',
'              p_source_identifier => :P611_SOURCE_IDENTIFIER,',
'              p_base_url_pattern  => :P611_BASE_URL_PATTERN,',
'              p_app_version       => :P611_APP_VERSION,',
'              p_display_seq       => :P611_DISPLAY_SEQ);',
'    :P611_ENVIRONMENT_ID := l_id;',
'  ELSE',
'    afh_registry_pkg.update_environment(',
'      p_environment_id    => :P611_ENVIRONMENT_ID,',
'      p_label             => :P611_LABEL,',
'      p_source_identifier => :P611_SOURCE_IDENTIFIER,',
'      p_base_url_pattern  => :P611_BASE_URL_PATTERN,',
'      p_app_version       => :P611_APP_VERSION,',
'      p_display_seq       => :P611_DISPLAY_SEQ);',
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71000000000002150)
,p_process_success_message=>'Environment saved.'
,p_internal_uid=>71000000000002200
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71000000000002210)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Deactivate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_registry_pkg.set_environment_active(:P611_ENVIRONMENT_ID, ''N'');',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71000000000002130)
,p_process_success_message=>'Environment deactivated.'
,p_internal_uid=>71000000000002210
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71000000000002220)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reactivate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_registry_pkg.set_environment_active(:P611_ENVIRONMENT_ID, ''Y'');',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71000000000002140)
,p_process_success_message=>'Environment reactivated.'
,p_internal_uid=>71000000000002220
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71000000000002230)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close dialog'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'SAVE,DEACTIVATE,REACTIVATE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>71000000000002230
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71000000000002180)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load environment'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  SELECT application_id, env_code, label, source_identifier, base_url_pattern, app_version, display_seq, is_active',
'    INTO :P611_APPLICATION_ID, :P611_ENV_CODE, :P611_LABEL, :P611_SOURCE_IDENTIFIER, :P611_BASE_URL_PATTERN, :P611_APP_VERSION, :P611_DISPLAY_SEQ, :P611_IS_ACTIVE',
'    FROM afh_v_environments',
'   WHERE environment_id = :P611_ENVIRONMENT_ID;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'P611_ENVIRONMENT_ID'
,p_process_when_type=>'ITEM_IS_NOT_NULL'
,p_internal_uid=>71000000000002180
);
wwv_flow_imp.component_end;
end;
/
