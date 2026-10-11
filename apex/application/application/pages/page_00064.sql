prompt --application/pages/page_00064
begin
--   Manifest
--     PAGE: 00064
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
 p_id=>64
,p_name=>'Taxonomy and Workflow'
,p_alias=>'TAXONOMY'
,p_step_title=>'Taxonomy and Workflow'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'var AFH_TAX = (function () {',
'  function rows(table) {',
'    var out = [];',
'    table.querySelectorAll(''tbody tr:not(.afh-tax-template)'').forEach(function (tr) {',
'      if (!tr.classList.contains(''is-dirty'') && !tr.classList.contains(''is-new'')) { return; }',
'      var row = { ID: tr.dataset.id || null };',
'      tr.querySelectorAll(''[data-col]'').forEach(function (el) {',
'        if (el.type === ''checkbox'') { row[el.dataset.col] = el.checked ? ''Y'' : ''N''; }',
'        else if (el.tagName === ''SPAN'') { row[el.dataset.col] = el.textContent; }',
'        else { row[el.dataset.col] = el.value; }',
'      });',
'      out.push(row);',
'    });',
'    return out;',
'  }',
'  function bind() {',
'    document.querySelectorAll(''.afh-tax'').forEach(function (table) {',
'      if (table.dataset.bound) { return; }',
'      table.dataset.bound = ''1'';',
'      table.addEventListener(''input'', function (e) { var tr = e.target.closest(''tr''); if (tr) { tr.classList.add(''is-dirty''); } });',
'      table.addEventListener(''change'', function (e) { var tr = e.target.closest(''tr''); if (tr) { tr.classList.add(''is-dirty''); } });',
'    });',
'  }',
'  function add(regionId) {',
'    var table = document.querySelector(''#'' + regionId + '' .afh-tax''), tpl = table && table.querySelector(''.afh-tax-template'');',
'    if (!tpl) { return; }',
'    var tr = tpl.cloneNode(true); tr.classList.remove(''afh-tax-template''); tr.classList.add(''is-new''); tr.hidden = false; tr.dataset.id = '''';',
'    tpl.parentNode.insertBefore(tr, tpl); tr.querySelector(''input,select'').focus();',
'  }',
'  function save(regionId, section) {',
'    var table = document.querySelector(''#'' + regionId + '' .afh-tax''), msg = document.querySelector(''#'' + regionId + '' .afh-tax-msg'');',
'    var data = rows(table);',
'    if (!data.length) { msg.textContent = ''Nothing changed.''; return; }',
'    msg.textContent = ''Saving '' + data.length + '' row(s)...'';',
'    apex.server.process(''TAXONOMY_SAVE'', { x01: section, p_clob_01: JSON.stringify({ rows: data }) }, { dataType: ''json'' })',
'      .then(function (r) { msg.textContent = r.message; if (r.ok) { apex.region(regionId).refresh(); apex.message.showPageSuccess(r.message); } else { apex.message.alert(r.message); } })',
'      .catch(function () { msg.textContent = ''The save failed. Reload and try again.''; });',
'  }',
'  return { bind: bind, add: add, save: save };',
'})();'))
,p_javascript_code_onload=>'AFH_TAX.bind(); apex.jQuery(document).on(''apexafterrefresh'', ''.afh-tax-region'', AFH_TAX.bind);'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Taxonomy and workflow editor tables (AFH_UI_PKG.render_taxonomy). */',
'.afh-tax .afh-tax-input { font: inherit; font-size: 0.85rem; padding: 4px 6px; border: 1px solid var(--afh-border); border-radius: var(--afh-radius-xs); background: var(--afh-paper); max-width: 100%; }',
'.afh-tax .afh-tax-num { width: 64px; }',
'.afh-tax tr.is-dirty td:first-child { box-shadow: inset 3px 0 0 var(--afh-signal); }',
'.afh-tax tr.is-new { background: var(--afh-signal-soft); }',
'.afh-tax-ro { font-family: var(--afh-mono); font-size: 0.8rem; color: var(--afh-ink-soft); }',
'.afh-tax-toolbar { display: flex; gap: 8px; align-items: center; margin: 6px 0 10px; }',
'.afh-tax-msg { font-size: 0.85rem; color: var(--afh-ink-muted); }'))
,p_step_template=>4072355960268175073
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68797704657367743)
,p_protection_level=>'C'
,p_page_component_map=>'25'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71700000000001010)
,p_plug_name=>'Sections'
,p_region_name=>'afh-sections'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>3223171818405608528
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71700000000001020)
,p_plug_name=>'Feedback types'
,p_region_name=>'afh-tax-types'
,p_parent_plug_id=>wwv_flow_imp.id(71700000000001010)
,p_region_css_classes=>'afh-tax-region'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_plug_display_point=>'SUB_REGIONS'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN ''<div class="afh-tax-msg" aria-live="polite"></div>'' || afh_ui_pkg.render_taxonomy(''TYPES'');',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71700000000001090)
,p_plug_name=>'Fields'
,p_region_name=>'afh-tax-fields'
,p_parent_plug_id=>wwv_flow_imp.id(71700000000001010)
,p_region_css_classes=>'afh-tax-region'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>20
,p_plug_display_point=>'SUB_REGIONS'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN ''<div class="afh-tax-msg" aria-live="polite"></div>'' || afh_ui_pkg.render_taxonomy(''FIELDS'');',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71700000000001160)
,p_plug_name=>'Type fields'
,p_region_name=>'afh-tax-type-fields'
,p_parent_plug_id=>wwv_flow_imp.id(71700000000001010)
,p_region_css_classes=>'afh-tax-region'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>30
,p_plug_display_point=>'SUB_REGIONS'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN ''<div class="afh-tax-msg" aria-live="polite"></div>'' || afh_ui_pkg.render_taxonomy(''TYPE_FIELDS'');',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71700000000001230)
,p_plug_name=>'Categories'
,p_region_name=>'afh-tax-categories'
,p_parent_plug_id=>wwv_flow_imp.id(71700000000001010)
,p_region_css_classes=>'afh-tax-region'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>40
,p_plug_display_point=>'SUB_REGIONS'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN ''<div class="afh-tax-msg" aria-live="polite"></div>'' || afh_ui_pkg.render_taxonomy(''CATEGORIES'');',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71700000000001300)
,p_plug_name=>'Classification values'
,p_region_name=>'afh-tax-classification'
,p_parent_plug_id=>wwv_flow_imp.id(71700000000001010)
,p_region_css_classes=>'afh-tax-region'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>50
,p_plug_display_point=>'SUB_REGIONS'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN ''<div class="afh-tax-msg" aria-live="polite"></div>'' || afh_ui_pkg.render_taxonomy(''CLASSIFICATION'');',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71700000000001370)
,p_plug_name=>'Statuses'
,p_region_name=>'afh-tax-statuses'
,p_parent_plug_id=>wwv_flow_imp.id(71700000000001010)
,p_region_css_classes=>'afh-tax-region'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>60
,p_plug_display_point=>'SUB_REGIONS'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN ''<div class="afh-tax-msg" aria-live="polite"></div>'' || afh_ui_pkg.render_taxonomy(''STATUSES'');',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(71700000000001410)
,p_plug_name=>'Transitions'
,p_region_name=>'afh-tax-transitions'
,p_parent_plug_id=>wwv_flow_imp.id(71700000000001010)
,p_region_css_classes=>'afh-tax-region'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>70
,p_plug_display_point=>'SUB_REGIONS'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN ''<div class="afh-tax-msg" aria-live="polite"></div>'' || afh_ui_pkg.render_taxonomy(''TRANSITIONS'');',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71700000000001030)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71700000000001020)
,p_button_name=>'SAVE_TYPES'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save feedback types'
,p_icon_css_classes=>'fa-save'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71700000000001100)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71700000000001090)
,p_button_name=>'SAVE_FIELDS'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save fields'
,p_icon_css_classes=>'fa-save'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71700000000001170)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71700000000001160)
,p_button_name=>'SAVE_TYPE_FIELDS'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save type fields'
,p_icon_css_classes=>'fa-save'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71700000000001240)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71700000000001230)
,p_button_name=>'SAVE_CATEGORIES'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save categories'
,p_icon_css_classes=>'fa-save'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71700000000001310)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71700000000001300)
,p_button_name=>'SAVE_CLASSIFICATION'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save classification values'
,p_icon_css_classes=>'fa-save'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71700000000001380)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71700000000001370)
,p_button_name=>'SAVE_STATUSES'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save statuses'
,p_icon_css_classes=>'fa-save'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71700000000001420)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(71700000000001410)
,p_button_name=>'SAVE_TRANSITIONS'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Save transitions'
,p_icon_css_classes=>'fa-save'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71700000000001060)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(71700000000001020)
,p_button_name=>'ADD_TYPES'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Add row'
,p_icon_css_classes=>'fa-plus'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71700000000001130)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(71700000000001090)
,p_button_name=>'ADD_FIELDS'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Add row'
,p_icon_css_classes=>'fa-plus'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71700000000001200)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(71700000000001160)
,p_button_name=>'ADD_TYPE_FIELDS'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Add row'
,p_icon_css_classes=>'fa-plus'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71700000000001270)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(71700000000001230)
,p_button_name=>'ADD_CATEGORIES'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Add row'
,p_icon_css_classes=>'fa-plus'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(71700000000001340)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(71700000000001300)
,p_button_name=>'ADD_CLASSIFICATION'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Add row'
,p_icon_css_classes=>'fa-plus'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71700000000001040)
,p_name=>'Save Feedback types'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71700000000001030)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71700000000001050)
,p_event_id=>wwv_flow_imp.id(71700000000001040)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'AFH_TAX.save(''afh-tax-types'', ''TYPES'');'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71700000000001070)
,p_name=>'Add Feedback types'
,p_event_sequence=>15
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71700000000001060)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71700000000001080)
,p_event_id=>wwv_flow_imp.id(71700000000001070)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'AFH_TAX.add(''afh-tax-types'');'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71700000000001110)
,p_name=>'Save Fields'
,p_event_sequence=>20
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71700000000001100)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71700000000001120)
,p_event_id=>wwv_flow_imp.id(71700000000001110)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'AFH_TAX.save(''afh-tax-fields'', ''FIELDS'');'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71700000000001140)
,p_name=>'Add Fields'
,p_event_sequence=>25
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71700000000001130)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71700000000001150)
,p_event_id=>wwv_flow_imp.id(71700000000001140)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'AFH_TAX.add(''afh-tax-fields'');'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71700000000001180)
,p_name=>'Save Type fields'
,p_event_sequence=>30
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71700000000001170)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71700000000001190)
,p_event_id=>wwv_flow_imp.id(71700000000001180)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'AFH_TAX.save(''afh-tax-type-fields'', ''TYPE_FIELDS'');'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71700000000001210)
,p_name=>'Add Type fields'
,p_event_sequence=>35
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71700000000001200)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71700000000001220)
,p_event_id=>wwv_flow_imp.id(71700000000001210)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'AFH_TAX.add(''afh-tax-type-fields'');'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71700000000001250)
,p_name=>'Save Categories'
,p_event_sequence=>40
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71700000000001240)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71700000000001260)
,p_event_id=>wwv_flow_imp.id(71700000000001250)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'AFH_TAX.save(''afh-tax-categories'', ''CATEGORIES'');'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71700000000001280)
,p_name=>'Add Categories'
,p_event_sequence=>45
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71700000000001270)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71700000000001290)
,p_event_id=>wwv_flow_imp.id(71700000000001280)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'AFH_TAX.add(''afh-tax-categories'');'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71700000000001320)
,p_name=>'Save Classification values'
,p_event_sequence=>50
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71700000000001310)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71700000000001330)
,p_event_id=>wwv_flow_imp.id(71700000000001320)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'AFH_TAX.save(''afh-tax-classification'', ''CLASSIFICATION'');'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71700000000001350)
,p_name=>'Add Classification values'
,p_event_sequence=>55
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71700000000001340)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71700000000001360)
,p_event_id=>wwv_flow_imp.id(71700000000001350)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'AFH_TAX.add(''afh-tax-classification'');'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71700000000001390)
,p_name=>'Save Statuses'
,p_event_sequence=>60
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71700000000001380)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71700000000001400)
,p_event_id=>wwv_flow_imp.id(71700000000001390)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'AFH_TAX.save(''afh-tax-statuses'', ''STATUSES'');'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(71700000000001430)
,p_name=>'Save Transitions'
,p_event_sequence=>70
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(71700000000001420)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(71700000000001440)
,p_event_id=>wwv_flow_imp.id(71700000000001430)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'AFH_TAX.save(''afh-tax-transitions'', ''TRANSITIONS'');'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(71700000000001450)
,p_process_sequence=>10
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'TAXONOMY_SAVE'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_msg VARCHAR2(400);',
'BEGIN',
'  l_msg := afh_ui_pkg.save_taxonomy(apex_application.g_x01, apex_application.g_clob_01);',
'  apex_json.open_object; apex_json.write(''ok'', TRUE); apex_json.write(''message'', l_msg); apex_json.close_object;',
'EXCEPTION WHEN OTHERS THEN',
'  apex_json.open_object; apex_json.write(''ok'', FALSE); apex_json.write(''message'', REGEXP_REPLACE(SQLERRM, ''^ORA-\d+: '', '''')); apex_json.close_object;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_security_scheme=>wwv_flow_imp.id(68797704657367743)
,p_internal_uid=>71700000000001450
);
wwv_flow_imp.component_end;
end;
/
