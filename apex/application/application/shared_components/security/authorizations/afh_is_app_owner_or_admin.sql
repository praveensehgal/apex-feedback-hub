prompt --application/shared_components/security/authorizations/afh_is_app_owner_or_admin
begin
--   Manifest
--     SECURITY SCHEME: AFH_IS_APP_OWNER_OR_ADMIN
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
 p_id=>wwv_flow_imp.id(68798393905371806)
,p_name=>'AFH_IS_APP_OWNER_OR_ADMIN'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'RETURN afh_security_pkg.is_app_owner OR afh_security_pkg.is_admin;'
,p_error_message=>'Insufficient privileges, user is not an Administrator'
,p_version_scn=>138973558
,p_caching=>'BY_USER_BY_SESSION'
);
wwv_flow_imp.component_end;
end;
/
