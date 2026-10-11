prompt --application/pages/page_00020
begin
--   Manifest
--     PAGE: 00020
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
 p_id=>20
,p_name=>'Submit Feedback'
,p_alias=>'SUBMIT'
,p_step_title=>'Submit Feedback'
,p_autocomplete_on_off=>'OFF'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#APP_FILES#vendor/fabric-5.3.0.min.js',
'#APP_FILES#afh_hub.js',
'#APP_FILES#afh_hub.fields.js',
'#APP_FILES#afh_hub.evidence.js',
'#APP_FILES#afh_hub.annotate.js'))
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'AFH_HUB.init({',
'  cid:  $v(''P20_CORR''),',
'  mode: $v(''P20_MODE'') === ''SIGNED'' ? ''SIGNED'' : ''SHARED''',
'});'))
,p_css_file_urls=>'#APP_FILES#afh_hub.css'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Page 20 always runs inside the host application''s overlay: the Hub''s own header (logo,',
'   Act as, Notifications, user menu) must not appear there. Universal Theme has no template',
'   option for this, so it is this page''s inline rule (never in afh_theme.css). */',
'.t-Header { display: none; }',
'.t-Body { padding-top: 0; }',
'/* and no footer either: the host shows its own, and the two applications carry different release numbers */',
'.t-Footer { display: none; }'))
,p_step_template=>2979075366320325194
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68608126239417213)
,p_overwrite_navigation_list=>'Y'
,p_deep_linking=>'Y'
,p_page_component_map=>'17'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001010)
,p_plug_name=>'Launch'
,p_region_name=>'afh-launch'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001020)
,p_plug_name=>'Alert'
,p_region_name=>'afh-alert'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001030)
,p_plug_name=>'Blocked'
,p_region_name=>'afh-blocked'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001040)
,p_plug_name=>'Stepper'
,p_region_name=>'afh-stepper'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001050)
,p_plug_name=>'Describe'
,p_region_name=>'afh-step-1'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001060)
,p_plug_name=>'Type fields'
,p_region_name=>'afh-type-fields'
,p_parent_plug_id=>wwv_flow_imp.id(70500000000001050)
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>3371237801798025892
,p_plug_display_sequence=>10
,p_plug_display_point=>'SUB_REGIONS'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001070)
,p_plug_name=>'Similar tickets'
,p_region_name=>'afh-dup-candidates'
,p_parent_plug_id=>wwv_flow_imp.id(70500000000001050)
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>3371237801798025892
,p_plug_display_sequence=>20
,p_plug_display_point=>'SUB_REGIONS'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001080)
,p_plug_name=>'Evidence'
,p_region_name=>'afh-step-2'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>50
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001090)
,p_plug_name=>'Screenshot'
,p_region_name=>'afh-evidence'
,p_parent_plug_id=>wwv_flow_imp.id(70500000000001080)
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--noPadding:t-Region--noBorder:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_point=>'SUB_REGIONS'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001100)
,p_plug_name=>'Attachments'
,p_region_name=>'afh-files'
,p_parent_plug_id=>wwv_flow_imp.id(70500000000001080)
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>3371237801798025892
,p_plug_display_sequence=>20
,p_plug_display_point=>'SUB_REGIONS'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001110)
,p_plug_name=>'Captured context'
,p_region_name=>'afh-capture-inventory'
,p_parent_plug_id=>wwv_flow_imp.id(70500000000001080)
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>3371237801798025892
,p_plug_display_sequence=>30
,p_plug_display_point=>'SUB_REGIONS'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001120)
,p_plug_name=>'Confirm'
,p_region_name=>'afh-step-3'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>60
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001130)
,p_plug_name=>'Summary'
,p_region_name=>'afh-summary'
,p_parent_plug_id=>wwv_flow_imp.id(70500000000001120)
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>3371237801798025892
,p_plug_display_sequence=>10
,p_plug_display_point=>'SUB_REGIONS'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001140)
,p_plug_name=>'Done'
,p_region_name=>'afh-success'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>70
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70500000000001150)
,p_plug_name=>'Navigation'
,p_region_name=>'afh-nav'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>80
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70500000000001160)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70500000000001150)
,p_button_name=>'BACK'
,p_button_static_id=>'afh-back'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Back'
,p_icon_css_classes=>'fa-chevron-left'
,p_grid_new_row=>'N'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70500000000001210)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70500000000001100)
,p_button_name=>'ADD_FILE'
,p_button_static_id=>'afh-add-file'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Add file'
,p_icon_css_classes=>'fa-paperclip'
,p_grid_new_row=>'N'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70500000000001170)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(70500000000001150)
,p_button_name=>'NEXT'
,p_button_static_id=>'afh-next'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Next'
,p_icon_css_classes=>'fa-chevron-right'
,p_grid_new_row=>'N'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70500000000001180)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(70500000000001150)
,p_button_name=>'SUBMIT'
,p_button_static_id=>'afh-submit'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Send feedback'
,p_icon_css_classes=>'fa-paper-plane'
,p_grid_new_row=>'N'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70500000000001190)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70500000000001090)
,p_button_name=>'ANNOTATE'
,p_button_static_id=>'afh-annotate'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Annotate'
,p_button_position=>'NEXT'
,p_icon_css_classes=>'fa-pencil'
,p_grid_new_row=>'N'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70500000000001200)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(70500000000001090)
,p_button_name=>'REMOVE_SHOT'
,p_button_static_id=>'afh-remove-shot'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Remove screenshot'
,p_button_position=>'NEXT'
,p_icon_css_classes=>'fa-trash'
,p_grid_new_row=>'N'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001220)
,p_name=>'P20_CORR'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70500000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001230)
,p_name=>'P20_TOKEN'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70500000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001240)
,p_name=>'P20_MODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(70500000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001250)
,p_name=>'P20_HOST_APP'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(70500000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001260)
,p_name=>'P20_HOST_PAGE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(70500000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001270)
,p_name=>'P20_FIELDS_JSON'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(70500000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001280)
,p_name=>'P20_AFFECTED_TICKET'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(70500000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_field_template=>2040785906935475274
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001290)
,p_name=>'P20_TYPE_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70500000000001050)
,p_prompt=>'What kind of feedback?'
,p_display_as=>'NATIVE_RADIOGROUP'
,p_lov=>'SELECT label d, type_code r FROM afh_feedback_types WHERE is_active = ''Y'' ORDER BY display_seq'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '4',
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001300)
,p_name=>'P20_TITLE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70500000000001050)
,p_prompt=>'Title'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>60
,p_cMaxlength=>120
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001310)
,p_name=>'P20_DESCRIPTION'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(70500000000001050)
,p_prompt=>'What happened?'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cMaxlength=>32000
,p_cHeight=>6
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001320)
,p_name=>'P20_PRIORITY_CODE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(70500000000001050)
,p_item_default=>'SELECT value_code FROM afh_classification_values WHERE class_type = ''PRIORITY'' AND is_default = ''Y'''
,p_item_default_type=>'SQL_QUERY'
,p_prompt=>'Priority'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, value_code r FROM afh_v_classification_values WHERE class_type = ''PRIORITY'' AND is_active = ''Y'' ORDER BY display_seq'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001330)
,p_name=>'P20_SEVERITY_CODE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(70500000000001050)
,p_item_default=>'SELECT value_code FROM afh_classification_values WHERE class_type = ''SEVERITY'' AND is_default = ''Y'''
,p_item_default_type=>'SQL_QUERY'
,p_prompt=>'Severity'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, value_code r FROM afh_v_classification_values WHERE class_type = ''SEVERITY'' AND is_active = ''Y'' ORDER BY display_seq'
,p_begin_on_new_line=>'N'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001340)
,p_name=>'P20_IMPACT_CODE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(70500000000001050)
,p_item_default=>'SELECT value_code FROM afh_classification_values WHERE class_type = ''IMPACT'' AND is_default = ''Y'''
,p_item_default_type=>'SQL_QUERY'
,p_prompt=>'Impact'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, value_code r FROM afh_v_classification_values WHERE class_type = ''IMPACT'' AND is_active = ''Y'' ORDER BY display_seq'
,p_begin_on_new_line=>'N'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001350)
,p_name=>'P20_CATEGORY_ID'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(70500000000001050)
,p_prompt=>'Category'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, category_id r FROM afh_categories WHERE is_active = ''Y'' AND application_id IS NULL ORDER BY display_seq, label'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- none -'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs:t-Form-fieldContainer--large'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70500000000001360)
,p_name=>'P20_FOLLOW_YN'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70500000000001120)
,p_item_default=>'Y'
,p_prompt=>'Notify me about this ticket'
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
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70500000000001370)
,p_process_sequence=>10
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'VALIDATE_LAUNCH'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_submit_pkg.validate_launch(',
'    p_cid             => apex_application.g_x01,',
'    p_mode            => apex_application.g_x02,',
'    p_host_app_id     => TO_NUMBER(apex_application.g_x03 DEFAULT NULL ON CONVERSION ERROR),',
'    p_page_id         => TO_NUMBER(apex_application.g_x04 DEFAULT NULL ON CONVERSION ERROR),',
'    p_app_key         => apex_application.g_x05,',
'    p_env_code        => apex_application.g_x06,',
'    p_page_name       => apex_application.g_x07,',
'    p_source_url      => apex_application.g_x08,',
'    p_adapter_version => apex_application.g_x09,',
'    p_token           => :P20_TOKEN);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>wwv_flow_imp.id(68608126239417213)
,p_internal_uid=>70500000000001370
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70500000000001380)
,p_process_sequence=>20
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'UPLOAD_CAPTURE'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_submit_pkg.upload_capture(',
'    p_cid          => apex_application.g_x01,',
'    p_capture_json => apex_application.g_clob_01);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>wwv_flow_imp.id(68608126239417213)
,p_internal_uid=>70500000000001380
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70500000000001390)
,p_process_sequence=>30
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'TYPE_FIELDS'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_submit_pkg.type_fields(p_type_code => apex_application.g_x01);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>wwv_flow_imp.id(68608126239417213)
,p_internal_uid=>70500000000001390
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70500000000001400)
,p_process_sequence=>40
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'DUP_CANDIDATES'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_submit_pkg.dup_candidates(',
'    p_cid         => :P20_CORR,',
'    p_title       => apex_application.g_x01,',
'    p_type_code   => apex_application.g_x02,',
'    p_description => apex_application.g_clob_01);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>wwv_flow_imp.id(68608126239417213)
,p_internal_uid=>70500000000001400
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70500000000001410)
,p_process_sequence=>50
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'STAGE_FILE'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_submit_pkg.stage_file(',
'    p_cid       => apex_application.g_x01,',
'    p_file_name => apex_application.g_x02,',
'    p_mime_type => apex_application.g_x03,',
'    p_size      => TO_NUMBER(apex_application.g_x04 DEFAULT NULL ON CONVERSION ERROR),',
'    p_data_url  => apex_application.g_clob_01);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>wwv_flow_imp.id(68608126239417213)
,p_internal_uid=>70500000000001410
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70500000000001420)
,p_process_sequence=>60
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'REMOVE_FILE'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_submit_pkg.remove_file(',
'    p_cid => apex_application.g_x01,',
'    p_seq => TO_NUMBER(apex_application.g_x02 DEFAULT NULL ON CONVERSION ERROR));',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>wwv_flow_imp.id(68608126239417213)
,p_internal_uid=>70500000000001420
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70500000000001430)
,p_process_sequence=>70
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'ANNOTATE'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  -- APEX AJAX carries one CLOB: the PNG is p_clob_01, the annotation JSON arrives as f01 slices',
'  afh_submit_pkg.annotate_ajax(',
'    p_cid          => apex_application.g_x01,',
'    p_png_data_url => apex_application.g_clob_01,',
'    p_json_parts   => apex_application.g_f01);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>wwv_flow_imp.id(68608126239417213)
,p_internal_uid=>70500000000001430
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70500000000001440)
,p_process_sequence=>80
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'SUBMIT'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_submit_pkg.submit(',
'    p_cid               => apex_application.g_x01,',
'    p_remove_screenshot => apex_application.g_x02);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>wwv_flow_imp.id(68608126239417213)
,p_internal_uid=>70500000000001440
);
wwv_flow_imp.component_end;
end;
/
