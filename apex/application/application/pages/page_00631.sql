prompt --application/pages/page_00631
begin
--   Manifest
--     PAGE: 00631
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
 p_id=>631
,p_name=>'Role Grant'
,p_alias=>'ROLE-GRANT'
,p_page_mode=>'MODAL'
,p_step_title=>'Role Grant'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>2100407606326202693
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68797704657367743)
,p_dialog_width=>'520'
,p_dialog_chained=>'N'
,p_protection_level=>'C'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71200000000003010)
,p_plug_name=>'Role grant'
,p_region_name=>'afh-grant-form'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71200000000003020)
,p_plug_name=>'Buttons'
,p_region_name=>'afh-grant-buttons'
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
 p_id=>wwv_flow_imp.id(71200000000003100)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71200000000003020)
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
 p_id=>wwv_flow_imp.id(71200000000003110)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(71200000000003020)
,p_button_name=>'REVOKE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Revoke'
,p_button_position=>'DELETE'
,p_button_execute_validations=>'N'
,p_confirm_message=>'Revoke this role?'
,p_confirm_style=>'danger'
,p_button_condition=>'RETURN :P631_USER_ROLE_ID IS NOT NULL;'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-user-times'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71200000000003120)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(71200000000003020)
,p_button_name=>'GRANT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Grant'
,p_button_position=>'NEXT'
,p_button_condition=>'RETURN :P631_USER_ROLE_ID IS NULL;'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-user-plus'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71200000000003030)
,p_name=>'P631_USER_ROLE_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(71200000000003010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71200000000003040)
,p_name=>'P631_REQUEST'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(71200000000003010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71200000000003050)
,p_name=>'P631_USER_ID'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(71200000000003010)
,p_prompt=>'User'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT display_name || '' ('' || subject_display || '')'' d, user_id r FROM afh_v_users WHERE is_active = ''Y'' ORDER BY display_name'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Select user -'
,p_read_only_when=>'P631_USER_ROLE_ID'
,p_read_only_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71200000000003060)
,p_name=>'P631_ROLE_CODE'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(71200000000003010)
,p_prompt=>'Role'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:User;USER,Tester;TESTER,Developer;DEVELOPER,Application owner;APP_OWNER,Feedback administrator;AFH_ADMIN'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Select role -'
,p_read_only_when=>'P631_USER_ROLE_ID'
,p_read_only_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71200000000003070)
,p_name=>'P631_APPLICATION_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(71200000000003010)
,p_prompt=>'Application'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT display_name d, application_id r FROM afh_v_applications ORDER BY 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Whole installation'
,p_read_only_when=>'P631_USER_ROLE_ID'
,p_read_only_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_help_text=>'Feedback administrator is always installation-wide; leave this empty for it.'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71200000000003080)
,p_name=>'P631_EFFECTIVE_DATE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(71200000000003010)
,p_prompt=>'Effective from'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71200000000003090)
,p_name=>'P631_EXPIRATION_DATE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(71200000000003010)
,p_prompt=>'Expires'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71200000000003130)
,p_name=>'Cancel dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71200000000003100)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71200000000003140)
,p_event_id=>wwv_flow_imp.id(71200000000003130)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71200000000003180)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Grant role'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_security_pkg.grant_role(',
'    p_user_id         => :P631_USER_ID,',
'    p_role_code       => :P631_ROLE_CODE,',
'    p_application_id  => :P631_APPLICATION_ID,',
'    p_effective_date  => :P631_EFFECTIVE_DATE,',
'    p_expiration_date => :P631_EXPIRATION_DATE);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71200000000003120)
,p_process_success_message=>'Role granted.'
,p_internal_uid=>71200000000003180
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71200000000003190)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Revoke role'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_security_pkg.revoke_role(:P631_USER_ROLE_ID);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71200000000003110)
,p_process_success_message=>'Role revoked.'
,p_internal_uid=>71200000000003190
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71200000000003200)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close dialog'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'GRANT,REVOKE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>71200000000003200
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71200000000003150)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load grant'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  SELECT user_id, role_code, application_id, effective_date, expiration_date',
'    INTO :P631_USER_ID, :P631_ROLE_CODE, :P631_APPLICATION_ID, :P631_EFFECTIVE_DATE, :P631_EXPIRATION_DATE',
'    FROM afh_v_user_roles',
'   WHERE user_role_id = :P631_USER_ROLE_ID;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'P631_USER_ROLE_ID'
,p_process_when_type=>'ITEM_IS_NOT_NULL'
,p_internal_uid=>71200000000003150
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71200000000003160)
,p_process_sequence=>20
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Revoke on request'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_security_pkg.revoke_role(:P631_USER_ROLE_ID);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':P631_REQUEST = ''REVOKE'''
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_internal_uid=>71200000000003160
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71200000000003170)
,p_process_sequence=>30
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close after revoke'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':P631_REQUEST = ''REVOKE'''
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_internal_uid=>71200000000003170
);
wwv_flow_imp.component_end;
end;
/
