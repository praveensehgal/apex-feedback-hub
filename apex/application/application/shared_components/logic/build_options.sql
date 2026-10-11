prompt --application/shared_components/logic/build_options
begin
--   Manifest
--     BUILD OPTIONS: 108
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>68393727750894466
,p_default_application_id=>108
,p_default_id_offset=>0
,p_default_owner=>'AFH'
);
wwv_flow_imp_shared.create_build_option(
 p_id=>wwv_flow_imp.id(68602306378417169)
,p_build_option_name=>'Commented Out'
,p_build_option_status=>'EXCLUDE'
,p_version_scn=>138444481
);
wwv_flow_imp_shared.create_build_option(
 p_id=>wwv_flow_imp.id(72000000000000010)
,p_build_option_name=>'AI_PREVIEW'
,p_build_option_status=>'EXCLUDE'
,p_version_scn=>239287379
,p_build_option_comment=>'Demo of the planned AI Recommends region on Ticket Detail (page 10). Rule-based stand-in for the AI service; set to Exclude for customer installs until that service ships.'
);
wwv_flow_imp.component_end;
end;
/
