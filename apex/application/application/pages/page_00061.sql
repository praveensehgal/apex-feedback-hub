prompt --application/pages/page_00061
begin
--   Manifest
--     PAGE: 00061
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
 p_id=>61
,p_name=>'Applications and Environments'
,p_alias=>'APPLICATIONS-AND-ENVIRONMENTS'
,p_step_title=>'Applications and Environments'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68797704657367743)
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(34422877042281643)
,p_plug_name=>'Registered Applications'
,p_region_name=>'afh-apps'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>15
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT application_id,',
'       app_key,',
'       display_name,',
'       apex_app_id,',
'       identity_mode,',
'       owner_display_name,',
'       owner_user_id,',
'       environment_count,',
'       open_ticket_count,',
'       last_ticket_at,',
'       adapter_version,',
'       min_adapter_version,',
'       adapter_supported_yn,',
'       is_active,',
'       description,',
'       ''Rotate secret'' AS secret_action',
'  FROM afh_v_applications',
' ORDER BY is_active DESC, display_name'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_content_disposition=>'ATTACHMENT'
,p_prn_units=>'INCHES'
,p_prn_paper_size=>'LETTER'
,p_prn_width=>11
,p_prn_height=>8.5
,p_prn_orientation=>'HORIZONTAL'
,p_prn_page_header_font_color=>'#000000'
,p_prn_page_header_font_family=>'Helvetica'
,p_prn_page_header_font_weight=>'normal'
,p_prn_page_header_font_size=>'12'
,p_prn_page_footer_font_color=>'#000000'
,p_prn_page_footer_font_family=>'Helvetica'
,p_prn_page_footer_font_weight=>'normal'
,p_prn_page_footer_font_size=>'12'
,p_prn_header_bg_color=>'#EEEEEE'
,p_prn_header_font_color=>'#000000'
,p_prn_header_font_family=>'Helvetica'
,p_prn_header_font_weight=>'bold'
,p_prn_header_font_size=>'10'
,p_prn_body_bg_color=>'#FFFFFF'
,p_prn_body_font_color=>'#000000'
,p_prn_body_font_family=>'Helvetica'
,p_prn_body_font_weight=>'normal'
,p_prn_body_font_size=>'10'
,p_prn_border_width=>.5
,p_prn_page_header_alignment=>'CENTER'
,p_prn_page_footer_alignment=>'CENTER'
,p_prn_border_color=>'#666666'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(34422955627281644)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_detail_link=>'f?p=&APP_ID.:610:&SESSION.::&DEBUG.:610:P610_APPLICATION_ID:#APPLICATION_ID#'
,p_detail_link_text=>'<span role="img" aria-label="Edit" class="fa fa-edit" title="Edit"></span>'
,p_owner=>'AFH'
,p_internal_uid=>34422955627281644
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(34423020754281645)
,p_db_column_name=>'APPLICATION_ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'Application Id'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(34423153447281646)
,p_db_column_name=>'APP_KEY'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'App Key'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(34423253436281647)
,p_db_column_name=>'DISPLAY_NAME'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Display Name'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(34423336522281648)
,p_db_column_name=>'APEX_APP_ID'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'Apex App Id'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(34423436773281649)
,p_db_column_name=>'IDENTITY_MODE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Identity Mode'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(34423588828281650)
,p_db_column_name=>'OWNER_DISPLAY_NAME'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Owner Display Name'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69000752794804401)
,p_db_column_name=>'OWNER_USER_ID'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Owner User Id'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69000832284804402)
,p_db_column_name=>'ENVIRONMENT_COUNT'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'Environment Count'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69000917603804403)
,p_db_column_name=>'OPEN_TICKET_COUNT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'Open Ticket Count'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69001049172804404)
,p_db_column_name=>'LAST_TICKET_AT'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'Last Ticket At'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'Y'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69001142724804405)
,p_db_column_name=>'ADAPTER_VERSION'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'Adapter Version'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69001276020804406)
,p_db_column_name=>'MIN_ADAPTER_VERSION'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'Min Adapter Version'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69001324482804407)
,p_db_column_name=>'ADAPTER_SUPPORTED_YN'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'Adapter Supported Yn'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69001453949804408)
,p_db_column_name=>'IS_ACTIVE'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'Is Active'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69001537116804409)
,p_db_column_name=>'DESCRIPTION'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'Description'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69001680070804410)
,p_db_column_name=>'SECRET_ACTION'
,p_display_order=>160
,p_column_identifier=>'P'
,p_column_label=>'Secret Action'
,p_column_link=>'f?p=&APP_ID.:610:&SESSION.::&DEBUG.::P610_APPLICATION_ID,P610_REQUEST:#APPLICATION_ID#,ROTATE'
,p_column_linktext=>'Rotate secret'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(69011520590822061)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'690116'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'APPLICATION_ID:APP_KEY:DISPLAY_NAME:APEX_APP_ID:IDENTITY_MODE:OWNER_DISPLAY_NAME:OWNER_USER_ID:ENVIRONMENT_COUNT:OPEN_TICKET_COUNT:LAST_TICKET_AT:ADAPTER_VERSION:MIN_ADAPTER_VERSION:ADAPTER_SUPPORTED_YN:IS_ACTIVE:DESCRIPTION:SECRET_ACTION'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(69001819395804412)
,p_plug_name=>'Environments'
,p_region_name=>'afh-envs'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>25
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT environment_id,',
'       application_id,',
'       application_name,',
'       app_key,',
'       env_code,',
'       label,',
'       app_version,',
'       base_url_pattern,',
'       source_identifier,',
'       display_seq,',
'       is_active,',
'       open_ticket_count',
'  FROM afh_v_environments',
' ORDER BY application_name, display_seq, env_code'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_content_disposition=>'ATTACHMENT'
,p_prn_units=>'INCHES'
,p_prn_paper_size=>'LETTER'
,p_prn_width=>11
,p_prn_height=>8.5
,p_prn_orientation=>'HORIZONTAL'
,p_prn_page_header_font_color=>'#000000'
,p_prn_page_header_font_family=>'Helvetica'
,p_prn_page_header_font_weight=>'normal'
,p_prn_page_header_font_size=>'12'
,p_prn_page_footer_font_color=>'#000000'
,p_prn_page_footer_font_family=>'Helvetica'
,p_prn_page_footer_font_weight=>'normal'
,p_prn_page_footer_font_size=>'12'
,p_prn_header_bg_color=>'#EEEEEE'
,p_prn_header_font_color=>'#000000'
,p_prn_header_font_family=>'Helvetica'
,p_prn_header_font_weight=>'bold'
,p_prn_header_font_size=>'10'
,p_prn_body_bg_color=>'#FFFFFF'
,p_prn_body_font_color=>'#000000'
,p_prn_body_font_family=>'Helvetica'
,p_prn_body_font_weight=>'normal'
,p_prn_body_font_size=>'10'
,p_prn_border_width=>.5
,p_prn_page_header_alignment=>'CENTER'
,p_prn_page_footer_alignment=>'CENTER'
,p_prn_border_color=>'#666666'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(69001933668804413)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_detail_link=>'f?p=&APP_ID.:611:&SESSION.::&DEBUG.:611:P611_ENVIRONMENT_ID:#ENVIRONMENT_ID#'
,p_detail_link_text=>'<span role="img" aria-label="Edit" class="fa fa-edit" title="Edit"></span>'
,p_owner=>'AFH'
,p_internal_uid=>69001933668804413
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69002049599804414)
,p_db_column_name=>'ENVIRONMENT_ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'Environment Id'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69002135937804415)
,p_db_column_name=>'APPLICATION_ID'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'Application Id'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69002269386804416)
,p_db_column_name=>'APPLICATION_NAME'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Application Name'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69002328850804417)
,p_db_column_name=>'APP_KEY'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'App Key'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69002427685804418)
,p_db_column_name=>'ENV_CODE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Env Code'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69002537879804419)
,p_db_column_name=>'LABEL'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Label'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69002623905804420)
,p_db_column_name=>'APP_VERSION'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'App Version'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69002751734804421)
,p_db_column_name=>'BASE_URL_PATTERN'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'Base Url Pattern'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69002881831804422)
,p_db_column_name=>'SOURCE_IDENTIFIER'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'Source Identifier'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69002996706804423)
,p_db_column_name=>'DISPLAY_SEQ'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'Display Seq'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69003090369804424)
,p_db_column_name=>'IS_ACTIVE'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'Is Active'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(69003162967804425)
,p_db_column_name=>'OPEN_TICKET_COUNT'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'Open Ticket Count'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(69016877409840722)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'690169'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ENVIRONMENT_ID:APPLICATION_ID:APPLICATION_NAME:APP_KEY:ENV_CODE:LABEL:APP_VERSION:BASE_URL_PATTERN:SOURCE_IDENTIFIER:DISPLAY_SEQ:IS_ACTIVE:OPEN_TICKET_COUNT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(69001732920804411)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(34422877042281643)
,p_button_name=>'BTN_REG_APP'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Register Application'
,p_button_redirect_url=>'f?p=&APP_ID.:610:&SESSION.::&DEBUG.:610::'
,p_icon_css_classes=>'fa-cube'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(69003271169804426)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(69001819395804412)
,p_button_name=>'BTN_ADD_ENV'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Add Environment'
,p_button_redirect_url=>'f?p=&APP_ID.:611:&SESSION.::&DEBUG.:611::'
,p_icon_css_classes=>'fa-server'
,p_grid_new_row=>'Y'
);
wwv_flow_imp.component_end;
end;
/
