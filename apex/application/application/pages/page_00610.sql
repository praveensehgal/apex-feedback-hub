prompt --application/pages/page_00610
begin
--   Manifest
--     PAGE: 00610
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
 p_id=>610
,p_name=>'Application'
,p_alias=>'APPLICATION'
,p_page_mode=>'MODAL'
,p_step_title=>'Application'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>2100407606326202693
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68797704657367743)
,p_dialog_width=>'640'
,p_dialog_chained=>'N'
,p_protection_level=>'C'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71000000000001010)
,p_plug_name=>'Application'
,p_region_name=>'afh-app-form'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71000000000001020)
,p_plug_name=>'New shared secret'
,p_region_name=>'afh-app-secret'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<div class="t-Alert t-Alert--warning t-Alert--horizontal" role="alert">',
'  <div class="t-Alert-body">',
'    <p>Copy this shared secret into the host application''s configuration now. It is shown <strong>once</strong> and is not stored anywhere you can read it again.</p>',
'    <pre class="afh-secret" style="user-select:all">&P610_SECRET.</pre>',
'  </div>',
'</div>'))
,p_plug_display_condition_type=>'ITEM_IS_NOT_NULL'
,p_plug_display_when_condition=>'P610_SECRET'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71000000000001030)
,p_plug_name=>'Buttons'
,p_region_name=>'afh-app-buttons'
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
 p_id=>wwv_flow_imp.id(71000000000001150)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71000000000001030)
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
 p_id=>wwv_flow_imp.id(71000000000001160)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(71000000000001030)
,p_button_name=>'DEACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Deactivate'
,p_button_position=>'DELETE'
,p_button_condition=>'RETURN :P610_APPLICATION_ID IS NOT NULL AND :P610_IS_ACTIVE = ''Y'';'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-ban'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71000000000001170)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(71000000000001030)
,p_button_name=>'REACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Reactivate'
,p_button_position=>'DELETE'
,p_button_condition=>'RETURN :P610_IS_ACTIVE = ''N'';'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-refresh'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71000000000001180)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(71000000000001030)
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
 p_id=>wwv_flow_imp.id(71000000000001040)
,p_name=>'P610_APPLICATION_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(71000000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000001050)
,p_name=>'P610_REQUEST'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(71000000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000001060)
,p_name=>'P610_APP_KEY'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(71000000000001010)
,p_prompt=>'App key'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>30
,p_read_only_when=>'P610_APPLICATION_ID'
,p_read_only_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_help_text=>'Stable uppercase code used by the host adapter, e.g. FINANCE'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000001070)
,p_name=>'P610_DISPLAY_NAME'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(71000000000001010)
,p_prompt=>'Display name'
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
 p_id=>wwv_flow_imp.id(71000000000001080)
,p_name=>'P610_APEX_APP_ID'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(71000000000001010)
,p_prompt=>'APEX application ID'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>12
,p_read_only_when=>'P610_APPLICATION_ID'
,p_read_only_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'virtual_keyboard', 'TEXT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000001090)
,p_name=>'P610_OWNER_USER_ID'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(71000000000001010)
,p_prompt=>'Application owner'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT display_name || '' ('' || subject_display || '')'' AS d, user_id AS r',
'  FROM afh_v_users',
' WHERE is_active = ''Y''',
' ORDER BY display_name'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Select owner -'
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000001100)
,p_name=>'P610_IDENTITY_MODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(71000000000001010)
,p_item_default=>'SHARED_SESSION'
,p_prompt=>'Identity mode'
,p_display_as=>'NATIVE_RADIOGROUP'
,p_lov=>'STATIC2:Shared session;SHARED_SESSION,Signed envelope;SIGNED_ENVELOPE'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '2',
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000001110)
,p_name=>'P610_MIN_ADAPTER_VERSION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(71000000000001010)
,p_prompt=>'Minimum adapter version'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>20
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
 p_id=>wwv_flow_imp.id(71000000000001120)
,p_name=>'P610_DESCRIPTION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(71000000000001010)
,p_prompt=>'Description'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cMaxlength=>1000
,p_cHeight=>3
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000001130)
,p_name=>'P610_IS_ACTIVE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(71000000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'I'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71000000000001140)
,p_name=>'P610_SECRET'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(71000000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'I'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(71000000000001230)
,p_validation_name=>'App key format'
,p_validation_sequence=>10
,p_validation=>'P610_APP_KEY'
,p_validation2=>'^[A-Z][A-Z0-9_]{0,29}$'
,p_validation_type=>'REGULAR_EXPRESSION'
,p_error_message=>'App key: uppercase letters, digits, underscores; start with a letter.'
,p_when_button_pressed=>wwv_flow_imp.id(71000000000001180)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71000000000001190)
,p_name=>'Cancel dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71000000000001150)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71000000000001200)
,p_event_id=>wwv_flow_imp.id(71000000000001190)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71000000000001240)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save application'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_id     NUMBER;',
'  l_secret VARCHAR2(100);',
'BEGIN',
'  IF :P610_APPLICATION_ID IS NULL THEN',
'    l_id := afh_registry_pkg.register_application(',
'              p_app_key       => :P610_APP_KEY,',
'              p_apex_app_id   => :P610_APEX_APP_ID,',
'              p_display_name  => :P610_DISPLAY_NAME,',
'              p_owner_user_id => :P610_OWNER_USER_ID,',
'              p_identity_mode => :P610_IDENTITY_MODE,',
'              p_description   => :P610_DESCRIPTION,',
'              o_secret_b64url => l_secret);',
'    :P610_APPLICATION_ID := l_id;',
'    :P610_SECRET := l_secret;',
'    :P610_REQUEST := ''SHOW_SECRET'';',
'  ELSE',
'    afh_registry_pkg.update_application(',
'      p_application_id      => :P610_APPLICATION_ID,',
'      p_display_name        => :P610_DISPLAY_NAME,',
'      p_owner_user_id       => :P610_OWNER_USER_ID,',
'      p_identity_mode       => :P610_IDENTITY_MODE,',
'      p_description         => :P610_DESCRIPTION,',
'      p_min_adapter_version => :P610_MIN_ADAPTER_VERSION);',
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71000000000001180)
,p_process_success_message=>'Application saved.'
,p_internal_uid=>71000000000001240
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71000000000001250)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Deactivate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_registry_pkg.set_application_active(:P610_APPLICATION_ID, ''N'');',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71000000000001160)
,p_process_success_message=>'Application deactivated.'
,p_internal_uid=>71000000000001250
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71000000000001260)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reactivate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_registry_pkg.set_application_active(:P610_APPLICATION_ID, ''Y'');',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71000000000001170)
,p_process_success_message=>'Application reactivated.'
,p_internal_uid=>71000000000001260
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71000000000001270)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close dialog'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':REQUEST IN (''DEACTIVATE'', ''REACTIVATE'') OR (:REQUEST = ''SAVE'' AND NVL(:P610_REQUEST, ''X'') <> ''SHOW_SECRET'')'
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_internal_uid=>71000000000001270
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71000000000001210)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load application'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  SELECT app_key, display_name, apex_app_id, owner_user_id, identity_mode, min_adapter_version, description, is_active',
'    INTO :P610_APP_KEY, :P610_DISPLAY_NAME, :P610_APEX_APP_ID, :P610_OWNER_USER_ID, :P610_IDENTITY_MODE, :P610_MIN_ADAPTER_VERSION, :P610_DESCRIPTION, :P610_IS_ACTIVE',
'    FROM afh_v_applications',
'   WHERE application_id = :P610_APPLICATION_ID;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'P610_APPLICATION_ID'
,p_process_when_type=>'ITEM_IS_NOT_NULL'
,p_internal_uid=>71000000000001210
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71000000000001220)
,p_process_sequence=>20
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Rotate secret'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  :P610_SECRET := afh_registry_pkg.rotate_secret(:P610_APPLICATION_ID);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':P610_REQUEST = ''ROTATE'''
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_internal_uid=>71000000000001220
);
wwv_flow_imp.component_end;
end;
/
