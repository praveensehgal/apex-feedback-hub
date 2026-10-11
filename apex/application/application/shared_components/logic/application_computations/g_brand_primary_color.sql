prompt --application/shared_components/logic/application_computations/g_brand_primary_color
begin
--   Manifest
--     APPLICATION COMPUTATION: G_BRAND_PRIMARY_COLOR
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>68393727750894466
,p_default_application_id=>108
,p_default_id_offset=>0
,p_default_owner=>'AFH'
);
wwv_flow_imp_shared.create_flow_computation(
 p_id=>wwv_flow_imp.id(68621833845027412)
,p_computation_sequence=>10
,p_computation_item=>'G_BRAND_PRIMARY_COLOR'
,p_computation_point=>'BEFORE_HEADER'
,p_computation_type=>'FUNCTION_BODY'
,p_computation_language=>'PLSQL'
,p_computation_processed=>'REPLACE_EXISTING'
,p_computation=>'RETURN NVL(afh_security_pkg.config_value(''BRAND_PRIMARY_COLOR''), ''#1F4E79'');'
,p_version_scn=>138589459
);
wwv_flow_imp.component_end;
end;
/
