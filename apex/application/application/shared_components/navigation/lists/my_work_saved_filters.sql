prompt --application/shared_components/navigation/lists/my_work_saved_filters
begin
--   Manifest
--     LIST: My Work Saved Filters
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
 p_id=>wwv_flow_imp.id(70100000000000900)
,p_name=>'My Work Saved Filters'
,p_list_type=>'SQL_QUERY'
,p_list_query=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT NULL AS lvl,',
'       filter_name || CASE WHEN is_mine_yn = ''N'' THEN '' (shared by '' || owner_display_name || '')'' END AS label,',
'       apex_page.get_url(p_page => 2, p_items => ''P2_SAVED_FILTER_ID'', p_values => saved_filter_id) AS target,',
'       ''NO'' AS is_current,',
'       CASE WHEN is_shared = ''Y'' THEN ''fa-users'' ELSE ''fa-bookmark-o'' END AS image',
'  FROM afh_v_saved_filters',
' WHERE scope_code = ''MY_WORK''',
' ORDER BY is_mine_yn DESC, filter_name'))
,p_list_status=>'PUBLIC'
,p_version_scn=>165878721
);
wwv_flow_imp.component_end;
end;
/
