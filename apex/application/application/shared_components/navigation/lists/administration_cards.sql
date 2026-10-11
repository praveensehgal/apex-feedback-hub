prompt --application/shared_components/navigation/lists/administration_cards
begin
--   Manifest
--     LIST: Administration Cards
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>68393727750894466
,p_default_application_id=>108
,p_default_id_offset=>0
,p_default_owner=>'AFH'
);
wwv_flow_imp_shared.create_list(
 p_id=>wwv_flow_imp.id(70900000000000900)
,p_name=>'Administration Cards'
,p_list_status=>'PUBLIC'
,p_version_scn=>165981225
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(70900000000000901)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'Applications and Environments'
,p_list_item_link_target=>'f?p=&APP_ID.:61:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-cubes'
,p_security_scheme=>wwv_flow_imp.id(68797704657367743)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(70900000000000902)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'Routing and Ownership'
,p_list_item_link_target=>'f?p=&APP_ID.:62:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-random'
,p_security_scheme=>wwv_flow_imp.id(68798393905371806)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(70900000000000903)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'Users and Roles'
,p_list_item_link_target=>'f?p=&APP_ID.:63:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-users'
,p_security_scheme=>wwv_flow_imp.id(68797704657367743)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(70900000000000904)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'Taxonomy and Workflow'
,p_list_item_link_target=>'f?p=&APP_ID.:64:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-sitemap'
,p_security_scheme=>wwv_flow_imp.id(68797704657367743)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(70900000000000905)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'Notification Templates'
,p_list_item_link_target=>'f?p=&APP_ID.:65:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-envelope-o'
,p_security_scheme=>wwv_flow_imp.id(68797704657367743)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(70900000000000906)
,p_list_item_display_sequence=>60
,p_list_item_link_text=>'Attachments and Retention'
,p_list_item_link_target=>'f?p=&APP_ID.:66:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-archive'
,p_security_scheme=>wwv_flow_imp.id(68797704657367743)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(70900000000000907)
,p_list_item_display_sequence=>70
,p_list_item_link_text=>'Integration Health'
,p_list_item_link_target=>'f?p=&APP_ID.:67:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-plug'
,p_security_scheme=>wwv_flow_imp.id(68797704657367743)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
