prompt --application/pages/page_00000
begin
--   Manifest
--     PAGE: 00000
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>68393727750894466
,p_default_application_id=>108
,p_default_id_offset=>0
,p_default_owner=>'AFH'
);
wwv_flow_imp_page.create_page(
 p_id=>0
,p_name=>'Global Page'
,p_step_title=>'Global Page'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'D'
,p_page_component_map=>'14'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(34422607680281641)
,p_plug_name=>'Feedback Hub branding'
,p_region_name=>'afh-branding'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>5
,p_location=>null
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<style>',
':root {',
'  --ut-palette-primary: &G_BRAND_PRIMARY_COLOR.;',
'  --ut-palette-primary-contrast: #ffffff;',
'  --ut-palette-primary-shade: color-mix(in srgb, &G_BRAND_PRIMARY_COLOR. 85%, black);',
'  --ut-header-background-color: &G_BRAND_PRIMARY_COLOR.;',
'  --ut-header-text-color: #ffffff;',
'  --ut-link-text-color: &G_BRAND_PRIMARY_COLOR.;',
'  --a-base-link-text-color: &G_BRAND_PRIMARY_COLOR.;',
'  --ut-focus-outline-color: &G_BRAND_PRIMARY_COLOR.;',
'  --afh-accent: &G_BRAND_ACCENT_COLOR.;',
'}',
'</style>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(34422739673281642)
,p_plug_name=>'Feedback Hub status'
,p_region_name=>'afh-status'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_05'
,p_location=>null
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<div class="t-Alert t-Alert--warning t-Alert--horizontal" role="alert">',
'  <div class="t-Alert-body">This installation is not licensed. Contact your administrator.</div>',
'</div>'))
,p_plug_display_condition_type=>'FUNCTION_BODY'
,p_plug_display_when_condition=>'RETURN NOT afh_license_pkg.is_ok;'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp.component_end;
end;
/
