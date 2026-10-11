prompt --application/shared_components/logic/application_processes/view_attachment
begin
--   Manifest
--     APPLICATION PROCESS: VIEW_ATTACHMENT
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
 p_id=>wwv_flow_imp.id(70300000000009900)
,p_process_sequence=>20
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'VIEW_ATTACHMENT'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  afh_attachment_pkg.download(',
'    p_attachment_id => TO_NUMBER(apex_application.g_x01),',
'    p_inline        => ''Y'');',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>wwv_flow_imp.id(68608126239417213)
,p_version_scn=>165934671
);
wwv_flow_imp.component_end;
end;
/
