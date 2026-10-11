prompt --application/pages/page_00100
begin
--   Manifest
--     PAGE: 00100
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
 p_id=>100
,p_name=>'Workflow action'
,p_alias=>'WORKFLOW-ACTION'
,p_page_mode=>'MODAL'
,p_step_title=>'&P100_TO_LABEL.'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>2100407606326202693
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68608126239417213)
,p_dialog_width=>'640'
,p_dialog_chained=>'N'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70300000000002230)
,p_plug_name=>'Workflow action'
,p_region_name=>'afh-wf-form'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70300000000002240)
,p_plug_name=>'Buttons'
,p_region_name=>'afh-wf-buttons'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>20
,p_plug_display_point=>'REGION_POSITION_03'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70300000000002250)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70300000000002240)
,p_button_name=>'CONFIRM'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Confirm'
,p_button_position=>'NEXT'
,p_icon_css_classes=>'fa-check'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000002260)
,p_name=>'P100_TICKET_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000002270)
,p_name=>'P100_TO_STATUS'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000002280)
,p_name=>'P100_MISSING'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'I'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000002290)
,p_name=>'P100_TO_LABEL'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Action'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000002300)
,p_name=>'P100_REASON'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Reason / note'
,p_display_as=>'NATIVE_TEXTAREA'
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
 p_id=>wwv_flow_imp.id(70300000000002310)
,p_name=>'P100_ASSIGNEE_USER_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Assignee'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT display_name d, user_id r FROM afh_v_users WHERE is_active = ''Y'' ORDER BY 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Unassigned'
,p_display_when=>'INSTR(:P100_MISSING, ''ASSIGNEE'') > 0 OR :P100_TO_STATUS IN (''IN_PROGRESS'')'
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000002320)
,p_name=>'P100_MASTER_TICKET_NO'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Master ticket number'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>30
,p_display_when=>':P100_TO_STATUS = ''DUPLICATE'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
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
 p_id=>wwv_flow_imp.id(70300000000002330)
,p_name=>'P100_RELEASE_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Release'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, release_id r FROM afh_v_releases WHERE application_id = (SELECT application_id FROM afh_tickets WHERE ticket_id = :P100_TICKET_ID) AND state_code IN (''PLANNED'',''IN_PROGRESS'') ORDER BY target_date'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'None'
,p_display_when=>':P100_TO_STATUS = ''PLANNED'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000002340)
,p_name=>'P100_PRIORITY_CODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Priority'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, value_code r FROM afh_v_classification_values WHERE class_type = ''PRIORITY'' AND is_active = ''Y'' ORDER BY display_seq'
,p_display_when=>':P100_TO_STATUS = ''ACCEPTED'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000002350)
,p_name=>'P100_SEVERITY_CODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Severity'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, value_code r FROM afh_v_classification_values WHERE class_type = ''SEVERITY'' AND is_active = ''Y'' ORDER BY display_seq'
,p_display_when=>':P100_TO_STATUS = ''ACCEPTED'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000002360)
,p_name=>'P100_IMPACT_CODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Impact'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, value_code r FROM afh_v_classification_values WHERE class_type = ''IMPACT'' AND is_active = ''Y'' ORDER BY display_seq'
,p_display_when=>':P100_TO_STATUS = ''ACCEPTED'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000002370)
,p_name=>'P100_ROOT_CAUSE'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Root cause'
,p_source=>'SELECT root_cause FROM afh_tickets WHERE ticket_id = :P100_TICKET_ID'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cHeight=>3
,p_display_when=>':P100_TO_STATUS = ''READY_TEST'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
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
 p_id=>wwv_flow_imp.id(70300000000002380)
,p_name=>'P100_RESOLUTION'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Resolution'
,p_source=>'SELECT resolution FROM afh_tickets WHERE ticket_id = :P100_TICKET_ID'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cHeight=>3
,p_display_when=>':P100_TO_STATUS = ''READY_TEST'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
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
 p_id=>wwv_flow_imp.id(70300000000002390)
,p_name=>'P100_TEST_ASSIGNEE_USER_ID'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>140
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Tester'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT display_name d, user_id r FROM afh_v_users WHERE is_active = ''Y'' ORDER BY 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Choose'
,p_display_when=>':P100_TO_STATUS = ''READY_TEST'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000002400)
,p_name=>'P100_TEST_ENVIRONMENT_ID'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>150
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Test environment'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, environment_id r FROM afh_v_environments WHERE application_id = (SELECT application_id FROM afh_tickets WHERE ticket_id = :P100_TICKET_ID) AND is_active = ''Y'' ORDER BY display_seq'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Choose'
,p_display_when=>':P100_TO_STATUS = ''READY_TEST'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000002410)
,p_name=>'P100_TEST_APP_VERSION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>160
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Version / build'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>100
,p_display_when=>':P100_TO_STATUS = ''READY_TEST'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
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
 p_id=>wwv_flow_imp.id(70300000000002420)
,p_name=>'P100_TEST_CRITERIA'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>170
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Acceptance criteria'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cHeight=>3
,p_display_when=>':P100_TO_STATUS = ''READY_TEST'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
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
 p_id=>wwv_flow_imp.id(70300000000002430)
,p_name=>'P100_EVIDENCE_TEXT'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>180
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Evidence'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cHeight=>3
,p_display_when=>':P100_TO_STATUS = ''REOPENED'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
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
 p_id=>wwv_flow_imp.id(70300000000002440)
,p_name=>'P100_UNLINK_YN'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>190
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Unlink from master'
,p_display_as=>'NATIVE_YES_NO'
,p_display_when=>':P100_TO_STATUS = ''REOPENED'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'off_label', 'No',
  'off_value', 'N',
  'on_label', 'Yes',
  'on_value', 'Y',
  'use_defaults', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70300000000002450)
,p_name=>'P100_RELATION_TICKET_NO'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>200
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Ticket number'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>30
,p_display_when=>':P100_TO_STATUS = ''RELATION'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
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
 p_id=>wwv_flow_imp.id(70300000000002460)
,p_name=>'P100_RELATION_CODE'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>210
,p_item_plug_id=>wwv_flow_imp.id(70300000000002230)
,p_prompt=>'Relation'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Related to;RELATED,Depends on;DEPENDS_ON,Blocks;BLOCKS'
,p_display_when=>':P100_TO_STATUS = ''RELATION'''
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(70300000000009970)
,p_validation_name=>'Reason required for this action'
,p_validation_sequence=>10
,p_validation=>'P100_REASON'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'A reason or note is required for this action.'
,p_validation_condition=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT 1',
'  FROM afh_workflow_transitions t',
'  JOIN afh_tickets k ON k.status_code = t.from_status_code',
' WHERE k.ticket_id = :P100_TICKET_ID',
'   AND t.to_status_code = :P100_TO_STATUS',
'   AND (t.reason_required = ''Y'' OR '','' || t.required_facts || '','' LIKE ''%,REASON,%'')'))
,p_validation_condition_type=>'EXISTS'
,p_when_button_pressed=>wwv_flow_imp.id(70300000000002250)
,p_associated_item=>wwv_flow_imp.id(70300000000002300)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70300000000002480)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Apply'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  p afh_workflow_pkg.t_payload := afh_workflow_pkg.empty_payload;',
'  l_id NUMBER;',
'BEGIN',
'  IF :P100_TO_STATUS = ''RELATION'' THEN',
'    l_id := afh_ticket_pkg.add_relation(',
'              p_source_ticket_id => :P100_TICKET_ID,',
'              p_target_ticket_id => afh_ticket_pkg.get_ticket_id(:P100_RELATION_TICKET_NO),',
'              p_relation_code    => :P100_RELATION_CODE,',
'              p_reason           => :P100_REASON);',
'    RETURN;',
'  END IF;',
'  p.reason                := :P100_REASON;',
'  p.assignee_user_id      := :P100_ASSIGNEE_USER_ID;',
'  p.master_ticket_id      := afh_ticket_pkg.get_ticket_id(:P100_MASTER_TICKET_NO);',
'  p.release_id            := :P100_RELEASE_ID;',
'  p.priority_code         := :P100_PRIORITY_CODE;',
'  p.severity_code         := :P100_SEVERITY_CODE;',
'  p.impact_code           := :P100_IMPACT_CODE;',
'  p.root_cause            := :P100_ROOT_CAUSE;',
'  p.resolution            := :P100_RESOLUTION;',
'  p.test_assignee_user_id := :P100_TEST_ASSIGNEE_USER_ID;',
'  p.test_environment_id   := :P100_TEST_ENVIRONMENT_ID;',
'  p.test_app_version      := :P100_TEST_APP_VERSION;',
'  p.test_criteria         := :P100_TEST_CRITERIA;',
'  p.evidence_text         := :P100_EVIDENCE_TEXT;',
'  p.unlink_duplicate_yn   := :P100_UNLINK_YN;',
'  IF :P100_TO_STATUS = ''DUPLICATE'' THEN',
'    afh_workflow_pkg.merge_duplicate(:P100_TICKET_ID, p.master_ticket_id, :P100_REASON, afh_ticket_pkg.row_version_of(:P100_TICKET_ID));',
'  ELSE',
'    afh_workflow_pkg.transition(:P100_TICKET_ID, :P100_TO_STATUS, afh_ticket_pkg.row_version_of(:P100_TICKET_ID), p);',
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(70300000000002250)
,p_internal_uid=>70300000000002480
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70300000000002490)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(70300000000002250)
,p_internal_uid=>70300000000002490
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70300000000002470)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Prepare'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  r afh_v_ticket_detail%ROWTYPE;',
'BEGIN',
'  SELECT * INTO r FROM afh_v_ticket_detail WHERE ticket_id = :P100_TICKET_ID;',
'  IF :P100_TO_STATUS = ''RELATION'' THEN',
'    :P100_TO_LABEL := ''Link another ticket'';',
'  ELSE',
'    SELECT label INTO :P100_TO_LABEL FROM afh_workflow_statuses WHERE status_code = :P100_TO_STATUS;',
'    :P100_MISSING := afh_workflow_pkg.missing_facts(:P100_TICKET_ID, :P100_TO_STATUS);',
'  END IF;',
'  :P100_PRIORITY_CODE := r.priority_code;  :P100_SEVERITY_CODE := r.severity_code;  :P100_IMPACT_CODE := r.impact_code;',
'  :P100_ASSIGNEE_USER_ID := r.assignee_user_id;  :P100_RELEASE_ID := r.release_id;',
'  :P100_ROOT_CAUSE := r.root_cause;  :P100_RESOLUTION := r.resolution;',
'  :P100_TEST_APP_VERSION := r.app_version;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>70300000000002470
);
wwv_flow_imp.component_end;
end;
/
