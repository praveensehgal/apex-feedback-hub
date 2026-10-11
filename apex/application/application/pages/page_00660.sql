prompt --application/pages/page_00660
begin
--   Manifest
--     PAGE: 00660
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
 p_id=>660
,p_name=>'Execute retention policy'
,p_alias=>'EXECUTE-RETENTION'
,p_page_mode=>'MODAL'
,p_step_title=>'Execute retention policy'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>2100407606326202693
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68797704657367743)
,p_dialog_width=>'600'
,p_dialog_chained=>'N'
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71400000000002010)
,p_name=>'Latest preview'
,p_region_name=>'afh-latest-preview'
,p_template=>4072358936313175081
,p_display_sequence=>10
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT policy_label,',
'       started_at,',
'       actor_subject,',
'       ticket_count,',
'       attachment_count,',
'       mb_affected,',
'       result_code',
'  FROM afh_v_retention_runs',
' WHERE policy_code = :P660_POLICY_CODE',
'   AND mode_code   = ''PREVIEW''',
' ORDER BY started_at DESC',
' FETCH FIRST 1 ROWS ONLY'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2100515439059797523
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No preview yet. Close this dialog and run Preview first.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000002020)
,p_query_column_id=>1
,p_column_alias=>'POLICY_LABEL'
,p_column_display_sequence=>10
,p_column_heading=>'Policy'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000002030)
,p_query_column_id=>2
,p_column_alias=>'STARTED_AT'
,p_column_display_sequence=>20
,p_column_heading=>'Previewed'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000002040)
,p_query_column_id=>3
,p_column_alias=>'ACTOR_SUBJECT'
,p_column_display_sequence=>30
,p_column_heading=>'By'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000002050)
,p_query_column_id=>4
,p_column_alias=>'TICKET_COUNT'
,p_column_display_sequence=>40
,p_column_heading=>'Tickets'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000002060)
,p_query_column_id=>5
,p_column_alias=>'ATTACHMENT_COUNT'
,p_column_display_sequence=>50
,p_column_heading=>'Attachments'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000002070)
,p_query_column_id=>6
,p_column_alias=>'MB_AFFECTED'
,p_column_display_sequence=>60
,p_column_heading=>'MB'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71400000000002080)
,p_query_column_id=>7
,p_column_alias=>'RESULT_CODE'
,p_column_display_sequence=>70
,p_column_heading=>'Result'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71400000000002090)
,p_plug_name=>'Warning'
,p_region_name=>'afh-exec-warning'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>20
,p_plug_source=>'<div class="t-Alert t-Alert--warning t-Alert--horizontal" role="alert"><div class="t-Alert-body">This run removes data permanently. A non-public audit event survives for every ticket; the content does not.</div></div>'
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P660_CONFIRM_WORD = ''DELETE'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71400000000002100)
,p_plug_name=>'Confirm'
,p_region_name=>'afh-exec-form'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71400000000002110)
,p_plug_name=>'Buttons'
,p_region_name=>'afh-exec-buttons'
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
 p_id=>wwv_flow_imp.id(71400000000002170)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71400000000002110)
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
 p_id=>wwv_flow_imp.id(71400000000002180)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(71400000000002110)
,p_button_name=>'EXECUTE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft:t-Button--danger'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Execute'
,p_button_position=>'NEXT'
,p_icon_css_classes=>'fa-bolt'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71400000000002120)
,p_name=>'P660_POLICY_CODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(71400000000002100)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71400000000002130)
,p_name=>'P660_POLICY_LABEL'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(71400000000002100)
,p_prompt=>'Policy'
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
 p_id=>wwv_flow_imp.id(71400000000002140)
,p_name=>'P660_CONFIRM_WORD'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(71400000000002100)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'I'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71400000000002150)
,p_name=>'P660_RUN_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(71400000000002100)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'I'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(71400000000002160)
,p_name=>'P660_CONFIRM'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(71400000000002100)
,p_prompt=>'Type &P660_CONFIRM_WORD. to confirm'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>12
,p_cMaxlength=>10
,p_field_template=>3031561932232085882
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(71400000000002220)
,p_validation_name=>'Confirmation word'
,p_validation_sequence=>10
,p_validation=>':P660_CONFIRM = :P660_CONFIRM_WORD'
,p_validation2=>'PLSQL'
,p_validation_type=>'EXPRESSION'
,p_error_message=>'Type the confirmation word exactly as shown.'
,p_when_button_pressed=>wwv_flow_imp.id(71400000000002180)
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71400000000002190)
,p_name=>'Cancel dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71400000000002170)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71400000000002200)
,p_event_id=>wwv_flow_imp.id(71400000000002190)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71400000000002230)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Execute policy'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_security_pkg.assert_admin;',
'  :P660_RUN_ID := afh_retention_pkg.execute_policy(',
'                    p_policy_code    => :P660_POLICY_CODE,',
'                    p_confirmation   => :P660_CONFIRM,',
'                    p_commit_batches => ''N'');',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71400000000002180)
,p_process_success_message=>'Retention policy executed.'
,p_internal_uid=>71400000000002230
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71400000000002240)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close dialog'
,p_attribute_01=>'P660_RUN_ID'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(71400000000002180)
,p_internal_uid=>71400000000002240
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71400000000002210)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Resolve policy'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_security_pkg.assert_admin;',
'  IF :P660_POLICY_CODE NOT IN (''ARCHIVE_CLOSED'', ''PURGE_ATTACHMENTS'', ''DELETE_TICKETS'') THEN',
'    afh_security_pkg.raise_error(''AFH-VAL-001'', ''Unknown retention policy.'');',
'  END IF;',
'  :P660_CONFIRM_WORD := CASE WHEN :P660_POLICY_CODE = ''ARCHIVE_CLOSED'' THEN ''ARCHIVE'' ELSE ''DELETE'' END;',
'  :P660_POLICY_LABEL := CASE :P660_POLICY_CODE',
'                          WHEN ''ARCHIVE_CLOSED''    THEN ''Archive closed tickets''',
'                          WHEN ''PURGE_ATTACHMENTS'' THEN ''Purge attachment bytes''',
'                          ELSE ''Delete (anonymize) tickets''',
'                        END;',
'  :P660_CONFIRM := NULL;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>71400000000002210
);
wwv_flow_imp.component_end;
end;
/
