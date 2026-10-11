prompt --application/shared_components/navigation/lists/afh_navigation_bar
begin
--   Manifest
--     LIST: AFH Navigation Bar
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
 p_id=>wwv_flow_imp.id(68993900470501138)
,p_name=>'AFH Navigation Bar'
,p_list_type=>'SQL_QUERY'
,p_list_query=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT LEVEL          AS lvl,',
'       n.label        AS label,',
'       CASE n.target_type',
'         WHEN ''LOGOUT''  THEN ''&LOGOUT_URL.''',
'         WHEN ''REQUEST'' THEN ''f?p=&APP_ID.:&APP_PAGE_ID.:&SESSION.:'' || n.request_value',
'         ELSE ''f?p=&APP_ID.:'' || n.page_no || '':&SESSION.''',
'       END            AS target,',
'       CASE WHEN n.page_no = :APP_PAGE_ID THEN ''YES'' ELSE ''NO'' END AS is_current,',
'       n.icon_css     AS image,',
'       NULL           AS image_attr,',
'       NULL           AS image_alt,',
'       n.badge_value  AS attribute1',
'  FROM afh_v_nav_entries n',
' WHERE n.list_code = ''NAVBAR''',
' START WITH n.parent_entry_code IS NULL',
'CONNECT BY PRIOR n.entry_code = n.parent_entry_code',
' ORDER SIBLINGS BY n.display_seq'))
,p_list_status=>'PUBLIC'
,p_version_scn=>139044775
);
wwv_flow_imp.component_end;
end;
/
