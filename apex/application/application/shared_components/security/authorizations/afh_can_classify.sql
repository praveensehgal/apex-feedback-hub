prompt --application/shared_components/security/authorizations/afh_can_classify
begin
--   Manifest
--     SECURITY SCHEME: AFH_CAN_CLASSIFY
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
 p_id=>wwv_flow_imp.id(68798936619375152)
,p_name=>'AFH_CAN_CLASSIFY'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'RETURN afh_security_pkg.can_classify(:P10_TICKET_ID);'
,p_error_message=>'Insufficient privileges, user is not an Administrator'
,p_version_scn=>139117911
,p_caching=>'BY_USER_BY_PAGE_VIEW'
);
wwv_flow_imp.component_end;
end;
/
