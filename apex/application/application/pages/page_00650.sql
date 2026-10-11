prompt --application/pages/page_00650
begin
--   Manifest
--     PAGE: 00650
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
 p_id=>650
,p_name=>'Template'
,p_alias=>'TEMPLATE'
,p_page_mode=>'MODAL'
,p_step_title=>'Template'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'.afh-health { display: grid; grid-template-columns: auto 1fr; gap: 2px 16px; margin: 0; font-size: 0.875rem; }',
'.afh-health dt { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }',
'.afh-health dd { margin: 0; }'))
,p_step_template=>2100407606326202693
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68797704657367743)
,p_dialog_height=>'720'
,p_dialog_width=>'820'
,p_dialog_chained=>'N'
,p_protection_level=>'C'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71300000000002010)
,p_plug_name=>'Template'
,p_region_name=>'afh-template-form'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71300000000002020)
,p_plug_name=>'Placeholders'
,p_region_name=>'afh-placeholders'
,p_region_template_options=>'#DEFAULT#:is-collapsed'
,p_plug_template=>2664334895415463485
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<dl class="afh-health">',
'  <dt>#TICKET_NO#</dt><dd>Public ticket number, e.g. FB-0042</dd>',
'  <dt>#TITLE#</dt><dd>Ticket title</dd>',
'  <dt>#STATUS#</dt><dd>Current status label</dd>',
'  <dt>#ACTOR#</dt><dd>Display name of the person whose action raised the event</dd>',
'  <dt>#APPLICATION#</dt><dd>Host application display name</dd>',
'  <dt>#SUMMARY#</dt><dd>Short safe text supplied by the event, e.g. "Status changed to Accepted"</dd>',
'  <dt>#LINK#</dt><dd>Absolute link to the ticket (config BASE_URL and FEEDBACK_APP_ID)</dd>',
'  <dt>#RECIPIENT#</dt><dd>Display name of the person receiving the message</dd>',
'  <dt>#PRODUCT_NAME#</dt><dd>Product name from installation configuration</dd>',
'  <dt>#ITEMS#</dt><dd>DIGEST channel only: the list of tickets collected for the digest</dd>',
'</dl>',
'<p class="afh-muted">Unknown placeholders are left as typed. HTML is not interpreted in the IN_APP channel.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71300000000002030)
,p_plug_name=>'Preview'
,p_region_name=>'afh-preview'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71300000000002040)
,p_plug_name=>'Buttons'
,p_region_name=>'afh-template-buttons'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>40
,p_plug_display_point=>'REGION_POSITION_03'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71300000000002150)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71300000000002030)
,p_button_name=>'PREVIEW'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Preview'
,p_icon_css_classes=>'fa-eye'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71300000000002160)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71300000000002040)
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
 p_id=>wwv_flow_imp.id(71300000000002170)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(71300000000002040)
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
 p_id=>wwv_flow_imp.id(71300000000002050)
,p_name=>'P650_TEMPLATE_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(71300000000002010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71300000000002060)
,p_name=>'P650_EVENT_CODE'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(71300000000002010)
,p_prompt=>'Event'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:New ticket;NEW_TICKET,Assignment;ASSIGNMENT,Mention;MENTION,Comment;COMMENT,Information request;INFO_REQUEST,Information response;INFO_RESPONSE,Status change;STATUS_CHANGE,Priority change;PRIORITY_CHANGE,Release change;RELEASE_CHANGE,Ready to'
||' test;READY_TEST,Test request;TEST_REQUEST,Test outcome;TEST_OUTCOME,Resolution;RESOLUTION,Closure;CLOSURE,Reopened;REOPENED,Duplicate merge;DUPLICATE_MERGE'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Select event -'
,p_read_only_when=>'P650_TEMPLATE_ID'
,p_read_only_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71300000000002070)
,p_name=>'P650_CHANNEL_CODE'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(71300000000002010)
,p_prompt=>'Channel'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:In-app;IN_APP,E-mail;EMAIL,Digest;DIGEST'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Select channel -'
,p_read_only_when=>'P650_TEMPLATE_ID'
,p_read_only_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71300000000002080)
,p_name=>'P650_SUBJECT_TEMPLATE'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(71300000000002010)
,p_prompt=>'Subject'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>80
,p_cMaxlength=>500
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
 p_id=>wwv_flow_imp.id(71300000000002090)
,p_name=>'P650_BODY_TEMPLATE'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(71300000000002010)
,p_prompt=>'Body'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cMaxlength=>32000
,p_cHeight=>10
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71300000000002100)
,p_name=>'P650_IS_ACTIVE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(71300000000002010)
,p_item_default=>'Y'
,p_prompt=>'Active'
,p_display_as=>'NATIVE_YES_NO'
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
 p_id=>wwv_flow_imp.id(71300000000002110)
,p_name=>'P650_DESCRIPTION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(71300000000002010)
,p_prompt=>'Description'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>80
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
 p_id=>wwv_flow_imp.id(71300000000002120)
,p_name=>'P650_PREVIEW_TICKET_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(71300000000002030)
,p_prompt=>'Render for ticket'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ticket_no || ''  '' || title AS d, ticket_id AS r',
'  FROM afh_v_ticket_queue',
' ORDER BY submitted_at DESC',
' FETCH FIRST 25 ROWS ONLY'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Choose a ticket -'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71300000000002130)
,p_name=>'P650_PREVIEW_SUBJECT'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(71300000000002030)
,p_prompt=>'Rendered subject'
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
 p_id=>wwv_flow_imp.id(71300000000002140)
,p_name=>'P650_PREVIEW_BODY'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(71300000000002030)
,p_prompt=>'Rendered body'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cHeight=>8
,p_read_only_when_type=>'ALWAYS'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(71300000000002210)
,p_validation_name=>'Preview needs a ticket'
,p_validation_sequence=>10
,p_validation=>'P650_PREVIEW_TICKET_ID'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'Choose a ticket to render the preview.'
,p_when_button_pressed=>wwv_flow_imp.id(71300000000002150)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71300000000002180)
,p_name=>'Cancel dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71300000000002160)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71300000000002190)
,p_event_id=>wwv_flow_imp.id(71300000000002180)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71300000000002220)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save template'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_notification_pkg.upsert_template(',
'    p_event_code       => :P650_EVENT_CODE,',
'    p_channel_code     => :P650_CHANNEL_CODE,',
'    p_subject_template => :P650_SUBJECT_TEMPLATE,',
'    p_body_template    => :P650_BODY_TEMPLATE,',
'    p_is_active        => NVL(:P650_IS_ACTIVE, ''N''),',
'    p_description      => :P650_DESCRIPTION);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'SAVE,PREVIEW'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_process_success_message=>'Template saved.'
,p_internal_uid=>71300000000002220
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71300000000002230)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Render preview'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_subject VARCHAR2(4000);',
'  l_body    CLOB;',
'BEGIN',
'  afh_notification_pkg.render(',
'    p_event_code   => :P650_EVENT_CODE,',
'    p_channel_code => :P650_CHANNEL_CODE,',
'    p_ticket_id    => :P650_PREVIEW_TICKET_ID,',
'    p_recipient_id => afh_security_pkg.current_user_id,',
'    p_summary      => ''Preview rendered from the template editor'',',
'    o_subject      => l_subject,',
'    o_body         => l_body);',
'  :P650_PREVIEW_SUBJECT := l_subject;',
'  :P650_PREVIEW_BODY    := DBMS_LOB.SUBSTR(l_body, 32000, 1);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'PREVIEW'
,p_process_when_type=>'REQUEST_EQUALS_CONDITION'
,p_internal_uid=>71300000000002230
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71300000000002240)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close dialog'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'SAVE'
,p_process_when_type=>'REQUEST_EQUALS_CONDITION'
,p_internal_uid=>71300000000002240
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71300000000002200)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load template'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  SELECT notification_template_id,',
'         subject_template,',
'         DBMS_LOB.SUBSTR(body_template, 32000, 1),',
'         is_active,',
'         description',
'    INTO :P650_TEMPLATE_ID,',
'         :P650_SUBJECT_TEMPLATE,',
'         :P650_BODY_TEMPLATE,',
'         :P650_IS_ACTIVE,',
'         :P650_DESCRIPTION',
'    FROM afh_v_templates',
'   WHERE event_code   = :P650_EVENT_CODE',
'     AND channel_code = :P650_CHANNEL_CODE;',
'EXCEPTION',
'  WHEN NO_DATA_FOUND THEN',
'    :P650_TEMPLATE_ID := NULL;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':P650_EVENT_CODE IS NOT NULL AND :P650_CHANNEL_CODE IS NOT NULL'
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_internal_uid=>71300000000002200
);
wwv_flow_imp.component_end;
end;
/
