prompt --application/pages/page_00065
begin
--   Manifest
--     PAGE: 00065
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
 p_id=>65
,p_name=>'Notification Templates'
,p_alias=>'NOTIFICATION-TEMPLATES'
,p_step_title=>'Notification Templates'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>4072355960268175073
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68797704657367743)
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71300000000001010)
,p_name=>'Templates'
,p_region_name=>'afh-templates'
,p_template=>4072358936313175081
,p_display_sequence=>10
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT notification_template_id,',
'       event_code,',
'       event_label,',
'       channel_code,',
'       subject_template,',
'       DBMS_LOB.SUBSTR(body_template, 200, 1) AS body_preview,',
'       is_active,',
'       CASE is_active WHEN ''Y'' THEN ''success'' ELSE ''warning'' END AS active_class,',
'       CASE is_active WHEN ''Y'' THEN ''Active'' ELSE ''Inactive'' END   AS active_label,',
'       is_customized_yn,',
'       CASE is_customized_yn WHEN ''Y'' THEN ''warning'' ELSE ''success'' END AS custom_class,',
'       CASE is_customized_yn WHEN ''Y'' THEN ''Customized'' ELSE ''Seeded'' END AS custom_label,',
'       description,',
'       last_updated_by,',
'       last_update_date',
'  FROM afh_v_templates',
' ORDER BY event_label, channel_code'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>100
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No templates.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001020)
,p_query_column_id=>1
,p_column_alias=>'NOTIFICATION_TEMPLATE_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001030)
,p_query_column_id=>2
,p_column_alias=>'EVENT_CODE'
,p_column_display_sequence=>20
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001040)
,p_query_column_id=>3
,p_column_alias=>'EVENT_LABEL'
,p_column_display_sequence=>30
,p_column_heading=>'Event'
,p_column_link=>'f?p=&APP_ID.:650:&SESSION.::&DEBUG.:650:P650_EVENT_CODE,P650_CHANNEL_CODE:#EVENT_CODE#,#CHANNEL_CODE#'
,p_column_linktext=>'#EVENT_LABEL#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001050)
,p_query_column_id=>4
,p_column_alias=>'CHANNEL_CODE'
,p_column_display_sequence=>40
,p_column_heading=>'Channel'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001060)
,p_query_column_id=>5
,p_column_alias=>'SUBJECT_TEMPLATE'
,p_column_display_sequence=>50
,p_column_heading=>'Subject'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001070)
,p_query_column_id=>6
,p_column_alias=>'BODY_PREVIEW'
,p_column_display_sequence=>60
,p_column_heading=>'Body'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001080)
,p_query_column_id=>7
,p_column_alias=>'IS_ACTIVE'
,p_column_display_sequence=>70
,p_column_heading=>'Active'
,p_column_html_expression=>'<span class="afh-chip afh-chip--#ACTIVE_CLASS#">#ACTIVE_LABEL#</span>'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001090)
,p_query_column_id=>8
,p_column_alias=>'ACTIVE_CLASS'
,p_column_display_sequence=>80
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001100)
,p_query_column_id=>9
,p_column_alias=>'ACTIVE_LABEL'
,p_column_display_sequence=>90
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001110)
,p_query_column_id=>10
,p_column_alias=>'IS_CUSTOMIZED_YN'
,p_column_display_sequence=>100
,p_column_heading=>'Origin'
,p_column_html_expression=>'<span class="afh-chip afh-chip--#CUSTOM_CLASS#">#CUSTOM_LABEL#</span>'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001120)
,p_query_column_id=>11
,p_column_alias=>'CUSTOM_CLASS'
,p_column_display_sequence=>110
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001130)
,p_query_column_id=>12
,p_column_alias=>'CUSTOM_LABEL'
,p_column_display_sequence=>120
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001140)
,p_query_column_id=>13
,p_column_alias=>'DESCRIPTION'
,p_column_display_sequence=>130
,p_column_heading=>'Description'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001150)
,p_query_column_id=>14
,p_column_alias=>'LAST_UPDATED_BY'
,p_column_display_sequence=>140
,p_column_heading=>'Updated by'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71300000000001160)
,p_query_column_id=>15
,p_column_alias=>'LAST_UPDATE_DATE'
,p_column_display_sequence=>150
,p_column_heading=>'Updated'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71300000000001170)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71300000000001010)
,p_button_name=>'NEW_TEMPLATE'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'New template'
,p_button_redirect_url=>'f?p=&APP_ID.:650:&SESSION.::&DEBUG.:650::'
,p_icon_css_classes=>'fa-plus'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71300000000001180)
,p_name=>'Refresh after dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(71300000000001010)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71300000000001190)
,p_event_id=>wwv_flow_imp.id(71300000000001180)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71300000000001010)
);
wwv_flow_imp.component_end;
end;
/
