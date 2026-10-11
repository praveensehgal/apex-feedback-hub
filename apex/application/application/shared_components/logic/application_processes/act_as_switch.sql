prompt --application/shared_components/logic/application_processes/act_as_switch
begin
--   Manifest
--     APPLICATION PROCESS: ACT_AS_SWITCH
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
 p_id=>wwv_flow_imp.id(70300000000001010)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'ACT_AS_SWITCH'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- Act as (development aid). The navigation bar fires ACT_AS_U<user_id> or ACT_AS_REVERT;',
'-- the package enforces ACT_AS_ENABLED, audits the switch against the real user and',
'-- re-registers the session through apex_custom_auth.post_login, which redirects to page 1.',
'BEGIN',
'  IF :REQUEST = ''ACT_AS_REVERT'' THEN',
'    afh_security_pkg.act_as_revert;',
'  ELSIF :REQUEST LIKE ''ACT_AS_U%'' THEN',
'    afh_security_pkg.act_as(TO_NUMBER(SUBSTR(:REQUEST, 9)));',
'  ELSE',
'    RETURN;',
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_process_error_message=>'The user could not be switched.'
,p_process_when=>'RETURN :REQUEST LIKE ''ACT_AS%'';'
,p_process_when_type=>'FUNCTION_BODY'
,p_process_when2=>'PLSQL'
,p_process_comment=>'Development aid, see docs/decisions/010-act-as-development-aid.md. Inert unless AFH_INSTALL_CONFIG.ACT_AS_ENABLED = Y.'
,p_version_scn=>167029825
);
wwv_flow_imp.component_end;
end;
/
