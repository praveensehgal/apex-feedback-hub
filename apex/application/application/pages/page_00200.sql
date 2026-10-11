prompt --application/pages/page_00200
begin
--   Manifest
--     PAGE: 00200
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
 p_id=>200
,p_name=>'Save view'
,p_alias=>'SAVE-VIEW'
,p_page_mode=>'MODAL'
,p_step_title=>'Save view'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>2100407606326202693
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68608126239417213)
,p_dialog_width=>'480'
,p_dialog_chained=>'N'
,p_protection_level=>'C'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70200000000001620)
,p_plug_name=>'Save view'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70200000000001630)
,p_plug_name=>'Buttons'
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
 p_id=>wwv_flow_imp.id(70200000000001640)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70200000000001630)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save'
,p_button_position=>'NEXT'
,p_button_alignment=>'RIGHT'
,p_icon_css_classes=>'fa-save'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70200000000001650)
,p_name=>'P200_FILTER_NAME'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70200000000001620)
,p_prompt=>'Name'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>100
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
 p_id=>wwv_flow_imp.id(70200000000001660)
,p_name=>'P200_IS_SHARED'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70200000000001620)
,p_prompt=>'Share with everyone'
,p_display_as=>'NATIVE_YES_NO'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_security_scheme=>wwv_flow_imp.id(68798083122369972)
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'off_label', 'No',
  'off_value', 'N',
  'on_label', 'Yes',
  'on_value', 'Y',
  'use_defaults', 'N')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70200000000001670)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save view'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_items apex_t_varchar2 := apex_t_varchar2(''P2_SEARCH'', ''P2_F_APPLICATION'', ''P2_F_STATUS'', ''P2_F_TYPE'', ''P2_F_ENV'',',
'                                              ''P2_F_PRIORITY'', ''P2_F_SEVERITY'', ''P2_F_ASSIGNEE'', ''P2_F_RELEASE'', ''P2_F_ARCHIVED'');',
'  l_json  CLOB;',
'  l_id    NUMBER;',
'BEGIN',
'  apex_json.initialize_clob_output;',
'  apex_json.open_object;',
'  apex_json.open_object(''items'');',
'  FOR i IN 1 .. l_items.COUNT LOOP',
'    apex_json.write(l_items(i), v(l_items(i)));',
'  END LOOP;',
'  apex_json.close_object;',
'  apex_json.close_object;',
'  l_json := apex_json.get_clob_output;',
'  apex_json.free_output;',
'  l_id := afh_search_pkg.save_filter(',
'            p_scope_code  => ''ALL_FEEDBACK'',',
'            p_filter_name => :P200_FILTER_NAME,',
'            p_filter_json => l_json,',
'            p_is_shared   => NVL(:P200_IS_SHARED, ''N''));',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(70200000000001640)
,p_internal_uid=>70200000000001670
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70200000000001680)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(70200000000001640)
,p_internal_uid=>70200000000001680
);
wwv_flow_imp.component_end;
end;
/
