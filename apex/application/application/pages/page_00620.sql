prompt --application/pages/page_00620
begin
--   Manifest
--     PAGE: 00620
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
 p_id=>620
,p_name=>'Routing Rule'
,p_alias=>'ROUTING-RULE'
,p_page_mode=>'MODAL'
,p_step_title=>'Routing Rule'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>2100407606326202693
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68798393905371806)
,p_dialog_width=>'600'
,p_dialog_chained=>'N'
,p_protection_level=>'C'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71100000000002010)
,p_plug_name=>'Routing rule'
,p_region_name=>'afh-rule-form'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71100000000002020)
,p_plug_name=>'Buttons'
,p_region_name=>'afh-rule-buttons'
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
 p_id=>wwv_flow_imp.id(71100000000002140)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71100000000002020)
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
 p_id=>wwv_flow_imp.id(71100000000002150)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(71100000000002020)
,p_button_name=>'DELETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Delete'
,p_button_position=>'DELETE'
,p_button_execute_validations=>'N'
,p_confirm_message=>'Delete this rule?'
,p_confirm_style=>'danger'
,p_button_condition=>'RETURN :P620_ROUTING_RULE_ID IS NOT NULL;'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-trash'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71100000000002160)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(71100000000002020)
,p_button_name=>'DEACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Deactivate'
,p_button_position=>'DELETE'
,p_button_condition=>'RETURN :P620_ROUTING_RULE_ID IS NOT NULL AND :P620_IS_ACTIVE = ''Y'';'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-ban'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71100000000002170)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(71100000000002020)
,p_button_name=>'REACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Reactivate'
,p_button_position=>'DELETE'
,p_button_condition=>'RETURN :P620_IS_ACTIVE = ''N'';'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'FUNCTION_BODY'
,p_icon_css_classes=>'fa-refresh'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71100000000002180)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(71100000000002020)
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
 p_id=>wwv_flow_imp.id(71100000000002030)
,p_name=>'P620_ROUTING_RULE_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(71100000000002010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71100000000002040)
,p_name=>'P620_APPLICATION_ID'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(71100000000002010)
,p_prompt=>'Application'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT display_name AS d, application_id AS r',
'  FROM afh_v_applications',
' WHERE is_active = ''Y''',
'   AND (afh_security_pkg.is_admin_yn = ''Y'' OR owner_user_id = afh_security_pkg.current_user_id)',
' ORDER BY display_name'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Select application -'
,p_read_only_when=>'P620_ROUTING_RULE_ID'
,p_read_only_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71100000000002050)
,p_name=>'P620_PAGE_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(71100000000002010)
,p_prompt=>'Page ID'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>8
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'virtual_keyboard', 'TEXT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71100000000002060)
,p_name=>'P620_ENVIRONMENT_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(71100000000002010)
,p_prompt=>'Environment'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, environment_id r FROM afh_v_environments WHERE application_id = :P620_APPLICATION_ID ORDER BY display_seq'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Any'
,p_lov_cascade_parent_items=>'P620_APPLICATION_ID'
,p_ajax_items_to_submit=>'P620_APPLICATION_ID'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71100000000002070)
,p_name=>'P620_TYPE_CODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(71100000000002010)
,p_prompt=>'Feedback type'
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
 p_id=>wwv_flow_imp.id(71100000000002080)
,p_name=>'P620_CATEGORY_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(71100000000002010)
,p_prompt=>'Category'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, category_id r FROM afh_categories WHERE is_active = ''Y'' AND (application_id IS NULL OR application_id = :P620_APPLICATION_ID) ORDER BY label'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Any'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71100000000002090)
,p_name=>'P620_ASSIGNEE_USER_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(71100000000002010)
,p_prompt=>'Assign to'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT u.display_name || '' ('' || u.subject_display || '')'' AS d, u.user_id AS r',
'  FROM afh_v_users u',
' WHERE u.is_active = ''Y''',
' ORDER BY u.display_name'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Nobody -'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71100000000002100)
,p_name=>'P620_OWNER_USER_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(71100000000002010)
,p_prompt=>'Queue owner'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT u.display_name || '' ('' || u.subject_display || '')'' AS d, u.user_id AS r',
'  FROM afh_v_users u',
' WHERE u.is_active = ''Y''',
' ORDER BY u.display_name'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Application owner -'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71100000000002110)
,p_name=>'P620_PRIORITY_ORDER'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(71100000000002010)
,p_item_default=>'100'
,p_prompt=>'Priority order'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>6
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_help_text=>'Lower runs first'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'virtual_keyboard', 'TEXT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71100000000002120)
,p_name=>'P620_DESCRIPTION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(71100000000002010)
,p_prompt=>'Description'
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
 p_id=>wwv_flow_imp.id(71100000000002130)
,p_name=>'P620_IS_ACTIVE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(71100000000002010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'I'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(71100000000002220)
,p_validation_name=>'Assignee or owner'
,p_validation_sequence=>10
,p_validation=>':P620_ASSIGNEE_USER_ID IS NOT NULL OR :P620_OWNER_USER_ID IS NOT NULL'
,p_validation2=>'PLSQL'
,p_validation_type=>'EXPRESSION'
,p_error_message=>'Choose an assignee, a queue owner, or both.'
,p_when_button_pressed=>wwv_flow_imp.id(71100000000002180)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71100000000002190)
,p_name=>'Cancel dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71100000000002140)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71100000000002200)
,p_event_id=>wwv_flow_imp.id(71100000000002190)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71100000000002230)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save rule'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_id NUMBER;',
'BEGIN',
'  IF :P620_ROUTING_RULE_ID IS NULL THEN',
'    l_id := afh_registry_pkg.add_routing_rule(',
'              p_application_id   => :P620_APPLICATION_ID,',
'              p_page_id          => :P620_PAGE_ID,',
'              p_category_id      => :P620_CATEGORY_ID,',
'              p_environment_id   => :P620_ENVIRONMENT_ID,',
'              p_type_code        => :P620_TYPE_CODE,',
'              p_assignee_user_id => :P620_ASSIGNEE_USER_ID,',
'              p_owner_user_id    => :P620_OWNER_USER_ID,',
'              p_priority_order   => :P620_PRIORITY_ORDER,',
'              p_description      => :P620_DESCRIPTION);',
'    :P620_ROUTING_RULE_ID := l_id;',
'  ELSE',
'    afh_registry_pkg.update_routing_rule(',
'      p_routing_rule_id  => :P620_ROUTING_RULE_ID,',
'      p_page_id          => :P620_PAGE_ID,',
'      p_category_id      => :P620_CATEGORY_ID,',
'      p_environment_id   => :P620_ENVIRONMENT_ID,',
'      p_type_code        => :P620_TYPE_CODE,',
'      p_assignee_user_id => :P620_ASSIGNEE_USER_ID,',
'      p_owner_user_id    => :P620_OWNER_USER_ID,',
'      p_priority_order   => :P620_PRIORITY_ORDER,',
'      p_description      => :P620_DESCRIPTION);',
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71100000000002180)
,p_process_success_message=>'Rule saved.'
,p_internal_uid=>71100000000002230
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71100000000002240)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Deactivate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_registry_pkg.set_routing_rule_active(:P620_ROUTING_RULE_ID, ''N'');',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71100000000002160)
,p_process_success_message=>'Rule deactivated.'
,p_internal_uid=>71100000000002240
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71100000000002250)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reactivate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_registry_pkg.set_routing_rule_active(:P620_ROUTING_RULE_ID, ''Y'');',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71100000000002170)
,p_process_success_message=>'Rule reactivated.'
,p_internal_uid=>71100000000002250
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71100000000002260)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Delete'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_registry_pkg.delete_routing_rule(:P620_ROUTING_RULE_ID);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71100000000002150)
,p_process_success_message=>'Rule deleted.'
,p_internal_uid=>71100000000002260
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71100000000002270)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close dialog'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'SAVE,DEACTIVATE,REACTIVATE,DELETE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>71100000000002270
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71100000000002210)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load rule'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  SELECT application_id, page_id, environment_id, type_code, category_id, assignee_user_id, owner_user_id, priority_order, description, is_active',
'    INTO :P620_APPLICATION_ID, :P620_PAGE_ID, :P620_ENVIRONMENT_ID, :P620_TYPE_CODE, :P620_CATEGORY_ID, :P620_ASSIGNEE_USER_ID, :P620_OWNER_USER_ID, :P620_PRIORITY_ORDER, :P620_DESCRIPTION, :P620_IS_ACTIVE',
'    FROM afh_v_routing_rules',
'   WHERE routing_rule_id = :P620_ROUTING_RULE_ID;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'P620_ROUTING_RULE_ID'
,p_process_when_type=>'ITEM_IS_NOT_NULL'
,p_internal_uid=>71100000000002210
);
wwv_flow_imp.component_end;
end;
/
