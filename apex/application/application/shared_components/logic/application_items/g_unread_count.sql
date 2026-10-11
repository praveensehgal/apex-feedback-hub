prompt --application/shared_components/logic/application_items/g_unread_count
begin
--   Manifest
--     APPLICATION ITEM: G_UNREAD_COUNT
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>68393727750894466
,p_default_application_id=>108
,p_default_id_offset=>0
,p_default_owner=>'AFH'
);
wwv_flow_imp_shared.create_flow_item(
 p_id=>wwv_flow_imp.id(68620905355020409)
,p_name=>'G_UNREAD_COUNT'
,p_protection_level=>'I'
,p_version_scn=>138587805
);
wwv_flow_imp.component_end;
end;
/
