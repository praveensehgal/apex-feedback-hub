prompt --application/pages/page_groups
begin
--   Manifest
--     PAGE GROUPS: 108
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>68393727750894466
,p_default_application_id=>108
,p_default_id_offset=>0
,p_default_owner=>'AFH'
);
wwv_flow_imp_page.create_page_group(
 p_id=>wwv_flow_imp.id(68608482558417214)
,p_group_name=>'Administration'
);
wwv_flow_imp.component_end;
end;
/
