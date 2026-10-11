prompt --application/shared_components/navigation/lists/afh_navigation_menu
begin
--   Manifest
--     LIST: AFH Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>68393727750894466
,p_default_application_id=>108
,p_default_id_offset=>0
,p_default_owner=>'AFH'
);
wwv_flow_imp_shared.create_list(
 p_id=>wwv_flow_imp.id(68993713960499084)
,p_name=>'AFH Navigation Menu'
,p_list_type=>'SQL_QUERY'
,p_list_query=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT LEVEL          AS lvl,',
'       n.label        AS label,',
'       ''f?p=&APP_ID.:'' || n.page_no || '':&SESSION.'' AS target,',
'       CASE WHEN n.page_no = :APP_PAGE_ID THEN ''YES'' ELSE ''NO'' END AS is_current,',
'       n.icon_css     AS image',
'  FROM afh_v_nav_entries n',
' WHERE n.list_code = ''MENU''',
' START WITH n.parent_entry_code IS NULL',
'CONNECT BY PRIOR n.entry_code = n.parent_entry_code',
' ORDER SIBLINGS BY n.display_seq'))
,p_list_status=>'PUBLIC'
,p_version_scn=>139044260
);
wwv_flow_imp.component_end;
end;
/
