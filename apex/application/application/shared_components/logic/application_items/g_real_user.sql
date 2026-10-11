prompt --application/shared_components/logic/application_items/g_real_user
begin
--   Manifest
--     APPLICATION ITEM: G_REAL_USER
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
 p_id=>wwv_flow_imp.id(70300000000001000)
,p_name=>'G_REAL_USER'
,p_protection_level=>'I'
,p_item_comment=>'Act as (development aid): the subject that signed in, while the session is switched to another user. Set only by AFH_SECURITY_PKG.act_as; Restricted so a browser can never set it.'
,p_version_scn=>167029828
);
wwv_flow_imp.component_end;
end;
/
