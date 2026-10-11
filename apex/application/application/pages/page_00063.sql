prompt --application/pages/page_00063
begin
--   Manifest
--     PAGE: 00063
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
 p_id=>63
,p_name=>'Users and Roles'
,p_alias=>'USERS'
,p_step_title=>'Users and Roles'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>4072355960268175073
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68797704657367743)
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71200000000001010)
,p_name=>'Users'
,p_region_name=>'afh-users'
,p_template=>4072358936313175081
,p_display_sequence=>10
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT user_id,',
'       display_name,',
'       subject_display,',
'       email,',
'       install_role,',
'       assigned_open_count,',
'       is_active,',
'       last_seen_at,',
'       creation_date',
'  FROM afh_v_users',
' ORDER BY is_active DESC, display_name'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>100
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No users yet.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001020)
,p_query_column_id=>1
,p_column_alias=>'USER_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001030)
,p_query_column_id=>2
,p_column_alias=>'DISPLAY_NAME'
,p_column_display_sequence=>20
,p_column_heading=>'Name'
,p_column_link=>'f?p=&APP_ID.:630:&SESSION.::&DEBUG.:630:P630_USER_ID:#USER_ID#'
,p_column_linktext=>'#DISPLAY_NAME#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001040)
,p_query_column_id=>3
,p_column_alias=>'SUBJECT_DISPLAY'
,p_column_display_sequence=>30
,p_column_heading=>'Subject'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001050)
,p_query_column_id=>4
,p_column_alias=>'EMAIL'
,p_column_display_sequence=>40
,p_column_heading=>'E-mail'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001060)
,p_query_column_id=>5
,p_column_alias=>'INSTALL_ROLE'
,p_column_display_sequence=>50
,p_column_heading=>'Installation role'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001070)
,p_query_column_id=>6
,p_column_alias=>'ASSIGNED_OPEN_COUNT'
,p_column_display_sequence=>60
,p_column_heading=>'Open assigned'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001080)
,p_query_column_id=>7
,p_column_alias=>'IS_ACTIVE'
,p_column_display_sequence=>70
,p_column_heading=>'Active'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001090)
,p_query_column_id=>8
,p_column_alias=>'LAST_SEEN_AT'
,p_column_display_sequence=>80
,p_column_heading=>'Last seen'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001100)
,p_query_column_id=>9
,p_column_alias=>'CREATION_DATE'
,p_column_display_sequence=>90
,p_column_heading=>'Since'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(71200000000001110)
,p_name=>'Role Grants'
,p_region_name=>'afh-roles'
,p_template=>4072358936313175081
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT user_role_id,',
'       user_id,',
'       display_name,',
'       subject_display,',
'       role_code,',
'       application_id,',
'       NVL(application_name, ''Whole installation'') AS scope,',
'       effective_date,',
'       expiration_date,',
'       is_effective,',
'       created_by,',
'       creation_date,',
'       ''Revoke'' AS revoke_link',
'  FROM afh_v_user_roles',
' ORDER BY display_name, role_code, scope'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>200
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No roles granted.'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001120)
,p_query_column_id=>1
,p_column_alias=>'USER_ROLE_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001130)
,p_query_column_id=>2
,p_column_alias=>'USER_ID'
,p_column_display_sequence=>20
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001140)
,p_query_column_id=>3
,p_column_alias=>'DISPLAY_NAME'
,p_column_display_sequence=>30
,p_column_heading=>'User'
,p_column_link=>'f?p=&APP_ID.:631:&SESSION.::&DEBUG.:631:P631_USER_ROLE_ID:#USER_ROLE_ID#'
,p_column_linktext=>'#DISPLAY_NAME#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001150)
,p_query_column_id=>4
,p_column_alias=>'SUBJECT_DISPLAY'
,p_column_display_sequence=>40
,p_column_heading=>'Subject'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001160)
,p_query_column_id=>5
,p_column_alias=>'ROLE_CODE'
,p_column_display_sequence=>50
,p_column_heading=>'Role'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001170)
,p_query_column_id=>6
,p_column_alias=>'APPLICATION_ID'
,p_column_display_sequence=>60
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001180)
,p_query_column_id=>7
,p_column_alias=>'SCOPE'
,p_column_display_sequence=>70
,p_column_heading=>'Scope'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001190)
,p_query_column_id=>8
,p_column_alias=>'EFFECTIVE_DATE'
,p_column_display_sequence=>80
,p_column_heading=>'Effective'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001200)
,p_query_column_id=>9
,p_column_alias=>'EXPIRATION_DATE'
,p_column_display_sequence=>90
,p_column_heading=>'Expires'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001210)
,p_query_column_id=>10
,p_column_alias=>'IS_EFFECTIVE'
,p_column_display_sequence=>100
,p_column_heading=>'In force'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001220)
,p_query_column_id=>11
,p_column_alias=>'CREATED_BY'
,p_column_display_sequence=>110
,p_column_heading=>'Granted by'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001230)
,p_query_column_id=>12
,p_column_alias=>'CREATION_DATE'
,p_column_display_sequence=>120
,p_column_heading=>'Granted'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(71200000000001240)
,p_query_column_id=>13
,p_column_alias=>'REVOKE_LINK'
,p_column_display_sequence=>130
,p_column_link=>'f?p=&APP_ID.:631:&SESSION.::&DEBUG.:631:P631_USER_ROLE_ID,P631_REQUEST:#USER_ROLE_ID#,REVOKE'
,p_column_linktext=>'Revoke'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71200000000001250)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71200000000001110)
,p_button_name=>'GRANT_ROLE'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Grant role'
,p_button_redirect_url=>'f?p=&APP_ID.:631:&SESSION.::&DEBUG.:631::'
,p_icon_css_classes=>'fa-user-plus'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71200000000001260)
,p_name=>'Refresh after user dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(71200000000001010)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71200000000001270)
,p_event_id=>wwv_flow_imp.id(71200000000001260)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71200000000001010)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71200000000001280)
,p_event_id=>wwv_flow_imp.id(71200000000001260)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71200000000001110)
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71200000000001290)
,p_name=>'Refresh after role dialog'
,p_event_sequence=>20
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(71200000000001110)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71200000000001300)
,p_event_id=>wwv_flow_imp.id(71200000000001290)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71200000000001010)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71200000000001310)
,p_event_id=>wwv_flow_imp.id(71200000000001290)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(71200000000001110)
);
wwv_flow_imp.component_end;
end;
/
