prompt --application/pages/page_00002
begin
--   Manifest
--     PAGE: 00002
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
 p_id=>2
,p_name=>'All Feedback'
,p_alias=>'FEEDBACK'
,p_step_title=>'All Feedback'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>2526643373347724467
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68608126239417213)
,p_protection_level=>'C'
,p_page_component_map=>'22'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70200000000001010)
,p_plug_name=>'Tickets'
,p_region_name=>'afh-search'
,p_region_css_classes=>'afh-ticket-cards'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT s.ticket_id,',
'       s.ticket_no,',
'       s.title,',
'       s.type_code, s.type_label, s.type_icon,',
'       s.application_id, s.application_name,',
'       s.env_code, s.env_label,',
'       s.page_id, s.page_name,',
'       s.category_label,',
'       s.status_code, s.status_label, s.status_is_terminal, s.status_color,',
'       s.priority_code, s.priority_label,',
'       s.severity_code, s.severity_label,',
'       s.impact_code, s.impact_label,',
'       s.reporter_user_id, s.reporter_display_name,',
'       s.assignee_user_id, s.assignee_display_name,',
'       s.release_id, s.release_label,',
'       s.submitted_at,',
'       s.last_activity_at,',
'       s.is_archived,',
'       s.master_ticket_no,',
'       s.follower_count, s.affected_count, s.comment_count, s.attachment_count,',
'       s.description_excerpt,',
'       0 AS search_rank',
'  FROM afh_v_ticket_search s',
' WHERE :P2_SEARCH IS NULL',
'    OR s.ticket_id IN (SELECT column_value FROM TABLE(CAST(afh_search_pkg.search_ticket_ids(:P2_SEARCH) AS apex_t_number)))',
' ORDER BY s.last_activity_at DESC'))
,p_plug_source_type=>'NATIVE_CARDS'
,p_ajax_items_to_submit=>'P2_SEARCH'
,p_plug_query_num_rows=>24
,p_plug_query_no_data_found=>'No tickets match.'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001020)
,p_name=>'TICKET_ID'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>10
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001030)
,p_name=>'TICKET_NO'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>20
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001040)
,p_name=>'TITLE'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>30
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001050)
,p_name=>'TYPE_CODE'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>40
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001060)
,p_name=>'TYPE_LABEL'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>50
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001070)
,p_name=>'TYPE_ICON'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>60
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001080)
,p_name=>'APPLICATION_ID'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>70
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001090)
,p_name=>'APPLICATION_NAME'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>80
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001100)
,p_name=>'ENV_CODE'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>90
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001110)
,p_name=>'ENV_LABEL'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>100
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001120)
,p_name=>'PAGE_ID'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>110
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001130)
,p_name=>'PAGE_NAME'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>120
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001140)
,p_name=>'CATEGORY_LABEL'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>130
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001150)
,p_name=>'STATUS_CODE'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>140
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001160)
,p_name=>'STATUS_LABEL'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>150
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001170)
,p_name=>'STATUS_IS_TERMINAL'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>160
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001180)
,p_name=>'STATUS_COLOR'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>170
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001190)
,p_name=>'PRIORITY_CODE'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>180
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001200)
,p_name=>'PRIORITY_LABEL'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>190
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001210)
,p_name=>'SEVERITY_CODE'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>200
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001220)
,p_name=>'SEVERITY_LABEL'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>210
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001230)
,p_name=>'IMPACT_CODE'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>220
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001240)
,p_name=>'IMPACT_LABEL'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>230
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001250)
,p_name=>'REPORTER_USER_ID'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>240
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001260)
,p_name=>'REPORTER_DISPLAY_NAME'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>250
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001270)
,p_name=>'ASSIGNEE_USER_ID'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>260
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001280)
,p_name=>'ASSIGNEE_DISPLAY_NAME'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>270
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001290)
,p_name=>'RELEASE_ID'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>280
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001300)
,p_name=>'RELEASE_LABEL'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>290
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001310)
,p_name=>'SUBMITTED_AT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>300
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001320)
,p_name=>'LAST_ACTIVITY_AT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>310
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001330)
,p_name=>'IS_ARCHIVED'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>320
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001340)
,p_name=>'MASTER_TICKET_NO'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>330
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001350)
,p_name=>'FOLLOWER_COUNT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>340
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001360)
,p_name=>'AFFECTED_COUNT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>350
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001370)
,p_name=>'COMMENT_COUNT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>360
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001380)
,p_name=>'ATTACHMENT_COUNT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>370
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001390)
,p_name=>'DESCRIPTION_EXCERPT'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>380
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(70200000000001400)
,p_name=>'SEARCH_RANK'
,p_session_state_data_type=>'VARCHAR2'
,p_display_sequence=>390
,p_use_as_row_header=>false
);
wwv_flow_imp_page.create_card(
 p_id=>wwv_flow_imp.id(70200000000001410)
,p_region_id=>wwv_flow_imp.id(70200000000001010)
,p_layout_type=>'GRID'
,p_grid_column_count=>2
,p_card_appearance=>'BLOCK'
,p_title_adv_formatting=>true
,p_title_html_expr=>'<span class="afh-card-no">&TICKET_NO.</span> <span class="afh-card-title">&TITLE.</span>'
,p_sub_title_adv_formatting=>true
,p_sub_title_html_expr=>unistr('&APPLICATION_NAME. \00B7 &ENV_LABEL. \00B7 &PAGE_NAME.')
,p_body_adv_formatting=>false
,p_body_column_name=>'DESCRIPTION_EXCERPT'
,p_second_body_adv_formatting=>true
,p_second_body_html_expr=>unistr('<span class="afh-pill afh-pill--neutral">&TYPE_LABEL.</span> <span class="afh-pill afh-pill--dot">&PRIORITY_LABEL.</span> <span class="afh-meta">&REPORTER_DISPLAY_NAME. \00B7 &ASSIGNEE_DISPLAY_NAME. \00B7 &LAST_ACTIVITY_AT.</span>')
,p_icon_source_type=>'STATIC_CLASS'
,p_icon_css_classes=>'fa-comment-o'
,p_icon_position=>'START'
,p_badge_column_name=>'STATUS_LABEL'
,p_badge_label=>'Status'
,p_media_adv_formatting=>false
);
wwv_flow_imp_page.create_card_action(
 p_id=>wwv_flow_imp.id(70200000000001420)
,p_card_id=>wwv_flow_imp.id(70200000000001410)
,p_action_type=>'FULL_CARD'
,p_display_sequence=>10
,p_link_target_type=>'REDIRECT_PAGE'
,p_link_target=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:10:P10_TICKET_NO:&TICKET_NO.'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70200000000001480)
,p_plug_name=>'Saved views'
,p_region_name=>'afh-saved-views'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_point=>'REGION_POSITION_02'
,p_list_id=>wwv_flow_imp.id(70200000000000900)
,p_plug_source_type=>'NATIVE_LIST'
,p_list_template_id=>4072361143931175087
,p_plug_query_no_data_found=>'No saved views yet.'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70200000000001490)
,p_plug_name=>'Filters'
,p_region_name=>'afh-filters'
,p_region_template_options=>'#DEFAULT#:t-Region--noPadding:t-Region--hideHeader js-addHiddenHeadingRoleDesc:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_02'
,p_plug_source_type=>'NATIVE_FACETED_SEARCH'
,p_filtered_region_id=>wwv_flow_imp.id(70200000000001010)
,p_landmark_label=>'Filters'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'batch_facet_search', 'N',
  'compact_numbers_threshold', '10000',
  'current_facets_selector', '#active_facets',
  'display_chart_for_top_n_values', '10',
  'show_charts', 'N',
  'show_current_facets', 'E',
  'show_total_row_count', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70200000000001590)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70200000000001480)
,p_button_name=>'SAVE_VIEW'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft:t-Button--stretch'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Save this view'
,p_button_redirect_url=>'f?p=&APP_ID.:200:&SESSION.::&DEBUG.:200::'
,p_icon_css_classes=>'fa-bookmark'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70200000000001430)
,p_name=>'P2_SEARCH'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70200000000001010)
,p_prompt=>'Search'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>60
,p_cMaxlength=>200
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_help_text=>'Ticket number, words in the title, description or public comments, people, application, page.'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'Y',
  'subtype', 'SEARCH',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70200000000001440)
,p_name=>'P2_SAVED_FILTER_ID'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70200000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70200000000001450)
,p_name=>'P2_EXPORT_NAME'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(70200000000001010)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70200000000001500)
,p_name=>'P2_F_APPLICATION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70200000000001490)
,p_prompt=>'Application'
,p_source=>'APPLICATION_NAME'
,p_source_type=>'FACET_COLUMN'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov_sort_direction=>'ASC'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1')).to_clob
,p_fc_collapsible=>false
,p_fc_initial_collapsed=>false
,p_fc_compute_counts=>true
,p_fc_show_counts=>true
,p_fc_zero_count_entries=>'H'
,p_fc_show_more_count=>7
,p_fc_filter_values=>false
,p_fc_sort_by_top_counts=>true
,p_fc_show_chart=>false
,p_fc_initial_chart=>false
,p_fc_actions_filter=>true
,p_fc_display_as=>'INLINE'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70200000000001510)
,p_name=>'P2_F_STATUS'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70200000000001490)
,p_prompt=>'Status'
,p_source=>'STATUS_LABEL'
,p_source_type=>'FACET_COLUMN'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov_sort_direction=>'ASC'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1')).to_clob
,p_fc_collapsible=>false
,p_fc_initial_collapsed=>false
,p_fc_compute_counts=>true
,p_fc_show_counts=>true
,p_fc_zero_count_entries=>'H'
,p_fc_show_more_count=>7
,p_fc_filter_values=>false
,p_fc_sort_by_top_counts=>true
,p_fc_show_chart=>false
,p_fc_initial_chart=>false
,p_fc_actions_filter=>true
,p_fc_display_as=>'INLINE'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70200000000001520)
,p_name=>'P2_F_TYPE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(70200000000001490)
,p_prompt=>'Type'
,p_source=>'TYPE_LABEL'
,p_source_type=>'FACET_COLUMN'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov_sort_direction=>'ASC'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1')).to_clob
,p_fc_collapsible=>false
,p_fc_initial_collapsed=>false
,p_fc_compute_counts=>true
,p_fc_show_counts=>true
,p_fc_zero_count_entries=>'H'
,p_fc_show_more_count=>7
,p_fc_filter_values=>false
,p_fc_sort_by_top_counts=>true
,p_fc_show_chart=>false
,p_fc_initial_chart=>false
,p_fc_actions_filter=>true
,p_fc_display_as=>'INLINE'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70200000000001530)
,p_name=>'P2_F_ENV'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(70200000000001490)
,p_prompt=>'Environment'
,p_source=>'ENV_LABEL'
,p_source_type=>'FACET_COLUMN'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov_sort_direction=>'ASC'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1')).to_clob
,p_fc_collapsible=>false
,p_fc_initial_collapsed=>false
,p_fc_compute_counts=>true
,p_fc_show_counts=>true
,p_fc_zero_count_entries=>'H'
,p_fc_show_more_count=>7
,p_fc_filter_values=>false
,p_fc_sort_by_top_counts=>true
,p_fc_show_chart=>false
,p_fc_initial_chart=>false
,p_fc_actions_filter=>true
,p_fc_display_as=>'INLINE'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70200000000001540)
,p_name=>'P2_F_PRIORITY'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(70200000000001490)
,p_prompt=>'Priority'
,p_source=>'PRIORITY_LABEL'
,p_source_type=>'FACET_COLUMN'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov_sort_direction=>'ASC'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1')).to_clob
,p_fc_collapsible=>false
,p_fc_initial_collapsed=>false
,p_fc_compute_counts=>true
,p_fc_show_counts=>true
,p_fc_zero_count_entries=>'H'
,p_fc_show_more_count=>7
,p_fc_filter_values=>false
,p_fc_sort_by_top_counts=>true
,p_fc_show_chart=>false
,p_fc_initial_chart=>false
,p_fc_actions_filter=>true
,p_fc_display_as=>'INLINE'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70200000000001550)
,p_name=>'P2_F_SEVERITY'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(70200000000001490)
,p_prompt=>'Severity'
,p_source=>'SEVERITY_LABEL'
,p_source_type=>'FACET_COLUMN'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov_sort_direction=>'ASC'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1')).to_clob
,p_fc_collapsible=>false
,p_fc_initial_collapsed=>false
,p_fc_compute_counts=>true
,p_fc_show_counts=>true
,p_fc_zero_count_entries=>'H'
,p_fc_show_more_count=>7
,p_fc_filter_values=>false
,p_fc_sort_by_top_counts=>true
,p_fc_show_chart=>false
,p_fc_initial_chart=>false
,p_fc_actions_filter=>true
,p_fc_display_as=>'INLINE'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70200000000001560)
,p_name=>'P2_F_ASSIGNEE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(70200000000001490)
,p_prompt=>'Assignee'
,p_source=>'ASSIGNEE_DISPLAY_NAME'
,p_source_type=>'FACET_COLUMN'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov_sort_direction=>'ASC'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1')).to_clob
,p_fc_collapsible=>false
,p_fc_initial_collapsed=>false
,p_fc_compute_counts=>true
,p_fc_show_counts=>true
,p_fc_zero_count_entries=>'H'
,p_fc_show_more_count=>7
,p_fc_filter_values=>false
,p_fc_sort_by_top_counts=>true
,p_fc_show_chart=>false
,p_fc_initial_chart=>false
,p_fc_actions_filter=>true
,p_fc_display_as=>'INLINE'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70200000000001570)
,p_name=>'P2_F_RELEASE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(70200000000001490)
,p_prompt=>'Release'
,p_source=>'RELEASE_LABEL'
,p_source_type=>'FACET_COLUMN'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov_sort_direction=>'ASC'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1')).to_clob
,p_fc_collapsible=>false
,p_fc_initial_collapsed=>false
,p_fc_compute_counts=>true
,p_fc_show_counts=>true
,p_fc_zero_count_entries=>'H'
,p_fc_show_more_count=>7
,p_fc_filter_values=>false
,p_fc_sort_by_top_counts=>true
,p_fc_show_chart=>false
,p_fc_initial_chart=>false
,p_fc_actions_filter=>true
,p_fc_display_as=>'INLINE'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70200000000001580)
,p_name=>'P2_F_ARCHIVED'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(70200000000001490)
,p_item_default=>'N'
,p_prompt=>'Archived'
,p_source=>'IS_ARCHIVED'
,p_source_type=>'FACET_COLUMN'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'STATIC:No;N,Yes;Y'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1')).to_clob
,p_fc_collapsible=>false
,p_fc_initial_collapsed=>false
,p_fc_compute_counts=>true
,p_fc_show_counts=>true
,p_fc_zero_count_entries=>'H'
,p_fc_show_more_count=>7
,p_fc_filter_values=>false
,p_fc_sort_by_top_counts=>true
,p_fc_show_chart=>false
,p_fc_initial_chart=>false
,p_fc_actions_filter=>true
,p_fc_display_as=>'INLINE'
);
wwv_flow_imp_page.create_page_computation(
 p_id=>wwv_flow_imp.id(70200000000001460)
,p_computation_sequence=>10
,p_computation_item=>'P2_EXPORT_NAME'
,p_computation_point=>'BEFORE_HEADER'
,p_computation_type=>'FUNCTION_BODY'
,p_computation_language=>'PLSQL'
,p_computation=>'RETURN afh_reporting_pkg.export_file_name(''all-feedback'');'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(70200000000001600)
,p_name=>'Refresh saved views'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(70200000000001480)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(70200000000001610)
,p_event_id=>wwv_flow_imp.id(70200000000001600)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(70200000000001480)
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70200000000001470)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Apply saved view'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_json  CLOB;',
'  l_items apex_t_varchar2 := apex_t_varchar2(''P2_SEARCH'', ''P2_F_APPLICATION'', ''P2_F_STATUS'', ''P2_F_TYPE'', ''P2_F_ENV'',',
'                                              ''P2_F_PRIORITY'', ''P2_F_SEVERITY'', ''P2_F_ASSIGNEE'', ''P2_F_RELEASE'', ''P2_F_ARCHIVED'');',
'BEGIN',
'  SELECT filter_json INTO l_json FROM afh_v_saved_filters WHERE saved_filter_id = :P2_SAVED_FILTER_ID;',
'  apex_json.parse(l_json);',
'  FOR i IN 1 .. l_items.COUNT LOOP',
'    apex_util.set_session_state(l_items(i), apex_json.get_varchar2(p_path => ''items.'' || l_items(i)));',
'  END LOOP;',
'  :P2_SAVED_FILTER_ID := NULL;',
'EXCEPTION WHEN NO_DATA_FOUND THEN',
'  :P2_SAVED_FILTER_ID := NULL;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_process_when=>'P2_SAVED_FILTER_ID'
,p_process_when_type=>'ITEM_IS_NOT_NULL'
,p_internal_uid=>70200000000001470
);
wwv_flow_imp.component_end;
end;
/
