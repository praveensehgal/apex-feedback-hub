prompt --application/shared_components/logic/application_processes/afh_after_auth
begin
--   Manifest
--     APPLICATION PROCESS: AFH_AFTER_AUTH
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>68393727750894466
,p_default_application_id=>108
,p_default_id_offset=>0
,p_default_owner=>'AFH'
);
wwv_flow_imp_shared.create_flow_process(
 p_id=>wwv_flow_imp.id(68796929141360403)
,p_process_sequence=>10
,p_process_point=>'AFTER_LOGIN'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'AFH_AFTER_AUTH'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_email   VARCHAR2(255 CHAR) := NVL(apex_util.get_email(p_username => :APP_USER),',
'                                      CASE WHEN INSTR(:APP_USER, ''@'') > 1 THEN :APP_USER END);',
'  l_user_id NUMBER;',
'BEGIN',
'  l_user_id := afh_security_pkg.touch_current_user(',
'                 p_display_name => TRIM(apex_util.get_first_name(p_username => :APP_USER) || '' '' ||',
'                                        apex_util.get_last_name(p_username => :APP_USER)),',
'                 p_email        => l_email);',
'  :G_CURRENT_USER_ID := l_user_id;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_process_error_message=>'Your account could not be initialised. Please sign in again.'
,p_version_scn=>139119588
);
wwv_flow_imp.component_end;
end;
/
