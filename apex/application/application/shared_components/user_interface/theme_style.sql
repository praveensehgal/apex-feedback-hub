prompt --application/shared_components/user_interface/theme_style
begin
--   Manifest
--     THEME STYLE: 108
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>68393727750894466
,p_default_application_id=>108
,p_default_id_offset=>0
,p_default_owner=>'AFH'
);
wwv_flow_imp_shared.create_theme_style(
 p_id=>wwv_flow_imp.id(69798686808956758)
,p_theme_id=>42
,p_name=>'Vita (v1)'
,p_is_public=>true
,p_is_accessible=>true
,p_theme_roller_input_file_urls=>'#THEME_FILES#less/theme/Vita.less'
,p_theme_roller_config=>'{"classes":[],"vars":{"@g_Nav_Style":"light"},"customCSS":"","useCustomLess":"N"}'
,p_theme_roller_output_file_url=>'#THEME_DB_FILES#69798686808956758.css'
,p_theme_roller_read_only=>false
);
wwv_flow_imp.component_end;
end;
/
