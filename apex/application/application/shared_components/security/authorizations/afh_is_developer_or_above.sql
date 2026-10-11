prompt --application/shared_components/security/authorizations/afh_is_developer_or_above
begin
--   Manifest
--     SECURITY SCHEME: AFH_IS_DEVELOPER_OR_ABOVE
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>68393727750894466
,p_default_application_id=>108
,p_default_id_offset=>0
,p_default_owner=>'AFH'
);
wwv_flow_imp_shared.create_security_scheme(
 p_id=>wwv_flow_imp.id(68798083122369972)
,p_name=>'AFH_IS_DEVELOPER_OR_ABOVE'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'RETURN afh_security_pkg.is_developer_or_above;'
,p_error_message=>'Insufficient privileges, user is not an Administrator'
,p_version_scn=>138973215
,p_caching=>'BY_USER_BY_SESSION'
);
wwv_flow_imp.component_end;
end;
/
