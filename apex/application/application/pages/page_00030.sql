prompt --application/pages/page_00030
begin
--   Manifest
--     PAGE: 00030
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
 p_id=>30
,p_name=>'Developer Workbench'
,p_alias=>'WORKBENCH'
,p_step_title=>'Developer Workbench'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'var AFH_WB = (function () {',
'  var FILTERS = [''P30_SCOPE'',''P30_APPLICATION_ID'',''P30_STATUS_CODE'',''P30_PRIORITY_CODE'',''P30_TYPE_CODE'',''P30_OVERDUE_YN'',''P30_SEARCH''];',
'  function refreshAll() { [''afh-board'',''afh-queue'',''afh-workload''].forEach(function (id) { var r = apex.region(id); if (r) { r.refresh(); } }); }',
'  function alertBar(msg) {',
'    var bar = document.getElementById(''afh-board-alert''); if (!bar) { return; }',
'    bar.textContent = msg; bar.hidden = !msg;',
'  }',
'  function bindBoard() {',
'    var board = document.getElementById(''afh-board-grid''), dragging = null, origin = null;',
'    if (!board || board.dataset.bound) { return; }',
'    board.dataset.bound = ''1'';',
'    board.querySelectorAll(''.afh-board-col'').forEach(function (col) {',
'      var n = col.querySelectorAll(''.afh-card'').length, c = col.querySelector(''[data-count]''); if (c) { c.textContent = n; }',
'    });',
'    board.addEventListener(''dragstart'', function (e) {',
'      var card = e.target.closest(''.afh-card''); if (!card) { return; }',
'      dragging = card; origin = card.parentNode; card.classList.add(''is-dragging'');',
'      e.dataTransfer.effectAllowed = ''move''; e.dataTransfer.setData(''text/plain'', card.dataset.ticket);',
'    });',
'    board.addEventListener(''dragend'', function () { if (dragging) { dragging.classList.remove(''is-dragging''); } board.querySelectorAll(''.is-over'').forEach(function (c) { c.classList.remove(''is-over''); }); });',
'    board.addEventListener(''dragover'', function (e) { var col = e.target.closest(''.afh-board-col''); if (col) { e.preventDefault(); col.classList.add(''is-over''); } });',
'    board.addEventListener(''dragleave'', function (e) { var col = e.target.closest(''.afh-board-col''); if (col && !col.contains(e.relatedTarget)) { col.classList.remove(''is-over''); } });',
'    board.addEventListener(''drop'', function (e) {',
'      var col = e.target.closest(''.afh-board-col''); if (!col || !dragging) { return; }',
'      e.preventDefault(); col.classList.remove(''is-over'');',
'      var card = dragging, to = col.dataset.status, from = card.dataset.status;',
'      if (to === from) { return; }',
'      col.querySelector(''.afh-board-cards'').appendChild(card);',
'      apex.server.process(''BOARD_MOVE'', { x01: card.dataset.ticket, x02: to, x03: card.dataset.version }, { dataType: ''json'' })',
'        .then(function (r) {',
'          if (r.ok) { card.dataset.status = to; card.dataset.version = r.version; alertBar(''''); apex.message.showPageSuccess(''Moved.''); refreshAll(); return; }',
'          origin.appendChild(card);',
'          alertBar(r.message || ''The ticket could not be moved.'');',
'          if (r.needs === ''DIALOG'') {',
'            apex.navigation.dialog(apex.util.makeApplicationUrl({ pageId: 100, itemNames: [''P100_TICKET_ID'', ''P100_TO_STATUS''], itemValues: [card.dataset.ticket, to] }),',
'              { title: ''Workflow action'', height: ''auto'', width: 640, modal: true }, ''t-Dialog-page--standard'', board);',
'          }',
'        })',
'        .catch(function () { origin.appendChild(card); alertBar(''The ticket could not be moved. Reload and try again.''); });',
'    });',
'    board.addEventListener(''keydown'', function (e) { var card = e.target.closest(''.afh-card''); if (card && e.key === ''Enter'') { card.querySelector(''a'').click(); } });',
'  }',
'  function bindQueue() {',
'    var all = document.getElementById(''afh-queue-all''); if (!all || all.dataset.bound) { return; }',
'    all.dataset.bound = ''1'';',
'    all.addEventListener(''change'', function () {',
'      document.querySelectorAll(''.afh-queue-pick'').forEach(function (cb) { cb.checked = all.checked; cb.closest(''tr'').classList.toggle(''is-picked'', all.checked); });',
'    });',
'    document.getElementById(''afh-queue-table'').addEventListener(''change'', function (e) {',
'      if (e.target.classList.contains(''afh-queue-pick'')) { e.target.closest(''tr'').classList.toggle(''is-picked'', e.target.checked); }',
'    });',
'  }',
'  function bulkApply() {',
'    var ids = Array.prototype.map.call(document.querySelectorAll(''.afh-queue-pick:checked''), function (cb) { return cb.value; });',
'    var out = document.getElementById(''afh-bulk-result'');',
'    if (!ids.length) { out.textContent = ''Select at least one ticket first.''; return; }',
'    out.textContent = ''Applying to '' + ids.length + '' ticket(s)...'';',
'    apex.server.process(''BULK_APPLY'', { x01: ids.join('',''), x02: $v(''P30_BULK_ASSIGNEE''), x03: $v(''P30_BULK_PRIORITY''), x04: $v(''P30_BULK_RELEASE'') }, { dataType: ''json'' })',
'      .then(function (r) { out.textContent = r.message; if (r.ok) { refreshAll(); } })',
'      .catch(function () { out.textContent = ''The bulk action failed. Reload and try again.''; });',
'  }',
'  return { refreshAll: refreshAll, bindBoard: bindBoard, bindQueue: bindQueue, bulkApply: bulkApply };',
'})();'))
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'AFH_WB.bindBoard(); AFH_WB.bindQueue();',
'apex.jQuery(''#afh-board'').on(''apexafterrefresh'', AFH_WB.bindBoard);',
'apex.jQuery(''#afh-queue'').on(''apexafterrefresh'', AFH_WB.bindQueue);',
'apex.jQuery(document).on(''apexafterclosedialog'', function () { AFH_WB.refreshAll(); });'))
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Developer Workbench: Kanban board and workload cards (AFH_UI_PKG.render_board / render_workload). */',
'.afh-board { display: grid; grid-auto-flow: column; grid-auto-columns: minmax(250px, 1fr); gap: 12px; overflow-x: auto; padding: 4px 0 12px; }',
'.afh-board-col { background: var(--afh-paper-2); border: 1px solid var(--afh-border); border-radius: var(--afh-radius-md); min-height: 260px; display: flex; flex-direction: column; transition: background var(--afh-ease), box-shadow var(--afh-ease); }',
'.afh-board-col.is-over { background: var(--afh-signal-soft); box-shadow: inset 0 0 0 2px var(--afh-signal); }',
'.afh-board-head { margin: 0; padding: 10px 12px; font-size: 0.82rem; font-weight: 700; text-transform: uppercase; letter-spacing: .04em; border-bottom: 1px solid var(--afh-border); border-radius: var(--afh-radius-md) var(--afh-radius-md) 0 0; display'
||': flex; justify-content: space-between; align-items: center; }',
'.afh-board-count { font-weight: 600; opacity: .7; }',
'.afh-board-cards { padding: 8px; display: flex; flex-direction: column; gap: 8px; flex: 1; min-height: 80px; }',
'.afh-board .afh-card { cursor: grab; padding: 10px 12px; border: 1px solid var(--afh-border); border-radius: var(--afh-radius-sm); background: var(--afh-paper); box-shadow: var(--afh-shadow); transition: box-shadow 120ms ease, transform 120ms ease, o'
||'pacity 120ms ease; }',
'.afh-board .afh-card:hover { box-shadow: var(--afh-shadow-md); transform: translateY(-1px); }',
'.afh-board .afh-card:focus-visible { outline: 2px solid var(--afh-blue); outline-offset: 2px; }',
'.afh-board .afh-card.is-dragging { opacity: .45; cursor: grabbing; }',
'.afh-board-alert { margin-bottom: 8px; }',
'.afh-workload { display: grid; grid-template-columns: repeat(auto-fill, minmax(230px, 1fr)); gap: 12px; }',
'.afh-workload-card { padding: 14px 16px; border: 1px solid var(--afh-border); border-radius: var(--afh-radius-md); background: var(--afh-paper); box-shadow: var(--afh-shadow); }',
'.afh-workload-head { display: flex; align-items: center; gap: 8px; margin-bottom: 6px; }',
'.afh-workload-head .afh-card-title { margin: 0; flex: 1; }',
'.afh-avatar { width: 28px; height: 28px; border-radius: 50%; background: var(--ut-palette-primary, var(--afh-teal)); color: #fff; display: inline-flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.8rem; }',
'.afh-workload-big { font-family: var(--afh-display); font-size: 2rem; line-height: 1; color: var(--afh-ink); margin: 4px 0 8px; }'))
,p_step_template=>2526643373347724467
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68798083122369972)
,p_protection_level=>'C'
,p_page_component_map=>'25'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70400000000001010)
,p_plug_name=>'Filters'
,p_region_name=>'afh-filters'
,p_region_css_classes=>'afh-filters'
,p_region_template_options=>'#DEFAULT#:t-Region--hideHeader js-addHiddenHeadingRoleDesc:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_02'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70400000000001020)
,p_plug_name=>'Views'
,p_region_name=>'afh-views'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>3223171818405608528
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70400000000001030)
,p_plug_name=>'Board'
,p_region_name=>'afh-board'
,p_parent_plug_id=>wwv_flow_imp.id(70400000000001020)
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN afh_ui_pkg.render_board(afh_ui_pkg.queue_filter(:P30_SCOPE, TO_NUMBER(:P30_APPLICATION_ID), :P30_STATUS_CODE, :P30_PRIORITY_CODE, :P30_TYPE_CODE, :P30_OVERDUE_YN, :P30_SEARCH), :APP_ID, :APP_SESSION);',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
,p_ajax_items_to_submit=>'P30_SCOPE,P30_APPLICATION_ID,P30_STATUS_CODE,P30_PRIORITY_CODE,P30_TYPE_CODE,P30_OVERDUE_YN,P30_SEARCH'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70400000000001040)
,p_plug_name=>'Queue'
,p_region_name=>'afh-queue'
,p_parent_plug_id=>wwv_flow_imp.id(70400000000001020)
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN afh_ui_pkg.render_queue(afh_ui_pkg.queue_filter(:P30_SCOPE, TO_NUMBER(:P30_APPLICATION_ID), :P30_STATUS_CODE, :P30_PRIORITY_CODE, :P30_TYPE_CODE, :P30_OVERDUE_YN, :P30_SEARCH), :APP_ID, :APP_SESSION);',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
,p_ajax_items_to_submit=>'P30_SCOPE,P30_APPLICATION_ID,P30_STATUS_CODE,P30_PRIORITY_CODE,P30_TYPE_CODE,P30_OVERDUE_YN,P30_SEARCH'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70400000000001060)
,p_plug_name=>'Bulk actions'
,p_region_name=>'afh-bulk'
,p_parent_plug_id=>wwv_flow_imp.id(70400000000001040)
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_point=>'SUB_REGIONS'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70400000000001070)
,p_plug_name=>'Bulk result'
,p_region_name=>'afh-bulk-result-region'
,p_parent_plug_id=>wwv_flow_imp.id(70400000000001060)
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>20
,p_plug_display_point=>'SUB_REGIONS'
,p_plug_source=>'<div id="afh-bulk-result" class="afh-bulk-result" aria-live="polite"></div>'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(70400000000001050)
,p_plug_name=>'Workload'
,p_region_name=>'afh-workload'
,p_parent_plug_id=>wwv_flow_imp.id(70400000000001020)
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>30
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN afh_ui_pkg.render_workload;',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
,p_ajax_items_to_submit=>'P30_SCOPE,P30_APPLICATION_ID,P30_STATUS_CODE,P30_PRIORITY_CODE,P30_TYPE_CODE,P30_OVERDUE_YN,P30_SEARCH'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(70400000000001080)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(70400000000001060)
,p_button_name=>'BULK_APPLY'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--large:t-Button--iconLeft:t-Button--stretch'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Apply to selected'
,p_icon_css_classes=>'fa-check-square-o'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70400000000001090)
,p_name=>'P30_SCOPE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70400000000001010)
,p_item_default=>'MINE'
,p_prompt=>'Queue'
,p_display_as=>'NATIVE_RADIOGROUP'
,p_lov=>'STATIC2:Mine;MINE,My queue;OWNER,All;ALL'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '3',
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70400000000001100)
,p_name=>'P30_SEARCH'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70400000000001010)
,p_prompt=>'Find'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>200
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'SEARCH',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70400000000001110)
,p_name=>'P30_APPLICATION_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(70400000000001010)
,p_prompt=>'Application'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT display_name d, application_id r FROM afh_v_applications WHERE is_active = ''Y'' ORDER BY 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'All'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70400000000001120)
,p_name=>'P30_STATUS_CODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(70400000000001010)
,p_prompt=>'Status'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'SELECT label d, status_code r FROM afh_v_workflow_statuses WHERE is_terminal = ''N'' AND is_active = ''Y'' ORDER BY display_seq'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70400000000001130)
,p_name=>'P30_PRIORITY_CODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(70400000000001010)
,p_prompt=>'Priority'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'SELECT label d, value_code r FROM afh_v_classification_values WHERE class_type = ''PRIORITY'' AND is_active = ''Y'' ORDER BY display_seq'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70400000000001140)
,p_name=>'P30_TYPE_CODE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(70400000000001010)
,p_prompt=>'Type'
,p_display_as=>'NATIVE_CHECKBOX'
,p_lov=>'SELECT label d, type_code r FROM afh_feedback_types WHERE is_active = ''Y'' ORDER BY display_seq'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70400000000001150)
,p_name=>'P30_OVERDUE_YN'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(70400000000001010)
,p_prompt=>'Overdue only'
,p_display_as=>'NATIVE_YES_NO'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'off_label', 'No',
  'off_value', 'N',
  'on_label', 'Yes',
  'on_value', 'Y',
  'use_defaults', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70400000000001160)
,p_name=>'P30_BULK_ASSIGNEE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(70400000000001060)
,p_prompt=>'Assign to'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT display_name d, user_id r FROM afh_v_users WHERE is_active = ''Y'' ORDER BY 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Leave unchanged'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70400000000001170)
,p_name=>'P30_BULK_PRIORITY'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(70400000000001060)
,p_prompt=>'Priority'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label d, value_code r FROM afh_v_classification_values WHERE class_type = ''PRIORITY'' AND is_active = ''Y'' ORDER BY display_seq'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Leave unchanged'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(70400000000001180)
,p_name=>'P30_BULK_RELEASE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(70400000000001060)
,p_prompt=>'Release'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT label || '' ('' || application_name || '')'' d, release_id r FROM afh_v_releases WHERE state_code IN (''PLANNED'',''IN_PROGRESS'') ORDER BY 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Leave unchanged'
,p_field_template=>3031561666792084173
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(70400000000001190)
,p_name=>'Filters changed'
,p_event_sequence=>10
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P30_SCOPE,P30_APPLICATION_ID,P30_STATUS_CODE,P30_PRIORITY_CODE,P30_TYPE_CODE,P30_OVERDUE_YN,P30_SEARCH'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(70400000000001200)
,p_event_id=>wwv_flow_imp.id(70400000000001190)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(70400000000001030)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(70400000000001210)
,p_event_id=>wwv_flow_imp.id(70400000000001190)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(70400000000001040)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(70400000000001220)
,p_event_id=>wwv_flow_imp.id(70400000000001190)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(70400000000001050)
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(70400000000001230)
,p_name=>'Bulk apply'
,p_event_sequence=>20
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(70400000000001080)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(70400000000001240)
,p_event_id=>wwv_flow_imp.id(70400000000001230)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'AFH_WB.bulkApply();'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70400000000001250)
,p_process_sequence=>10
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'BOARD_MOVE'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_ticket  NUMBER := TO_NUMBER(apex_application.g_x01 DEFAULT NULL ON CONVERSION ERROR);',
'  l_to      VARCHAR2(30) := apex_application.g_x02;',
'  l_version NUMBER := TO_NUMBER(apex_application.g_x03 DEFAULT NULL ON CONVERSION ERROR);',
'  l_missing VARCHAR2(200);',
'BEGIN',
'  IF NOT afh_workflow_pkg.can_transition(l_ticket, l_to) THEN',
'    apex_json.open_object; apex_json.write(''ok'', FALSE);',
'    apex_json.write(''message'', ''This ticket cannot move to that status from where it is, or you are not allowed to move it.'');',
'    apex_json.close_object; RETURN;',
'  END IF;',
'  l_missing := afh_workflow_pkg.missing_facts(l_ticket, l_to);',
'  IF l_missing IS NOT NULL THEN',
'    apex_json.open_object; apex_json.write(''ok'', FALSE); apex_json.write(''needs'', ''DIALOG'');',
'    apex_json.write(''message'', ''Needs '' || LOWER(REPLACE(l_missing, ''_'', '' '')) || '' - opening the action dialog.'');',
'    apex_json.close_object; RETURN;',
'  END IF;',
'  afh_workflow_pkg.transition(l_ticket, l_to, l_version, afh_workflow_pkg.empty_payload);',
'  apex_json.open_object; apex_json.write(''ok'', TRUE); apex_json.write(''version'', afh_ticket_pkg.row_version_of(l_ticket)); apex_json.close_object;',
'EXCEPTION WHEN OTHERS THEN',
'  apex_json.open_object; apex_json.write(''ok'', FALSE);',
'  apex_json.write(''message'', REGEXP_REPLACE(SQLERRM, ''^ORA-\d+: '', ''''));',
'  apex_json.close_object;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>wwv_flow_imp.id(68798083122369972)
,p_internal_uid=>70400000000001250
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(70400000000001260)
,p_process_sequence=>20
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'BULK_APPLY'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_ok   PLS_INTEGER := 0;',
'  l_fail PLS_INTEGER := 0;',
'  l_msgs VARCHAR2(4000);',
'  l_id   NUMBER;',
'  l_ver  NUMBER;',
'  l_no   VARCHAR2(30);',
'  l_assignee NUMBER := TO_NUMBER(apex_application.g_x02 DEFAULT NULL ON CONVERSION ERROR);',
'  l_priority VARCHAR2(30) := apex_application.g_x03;',
'  l_release  NUMBER := TO_NUMBER(apex_application.g_x04 DEFAULT NULL ON CONVERSION ERROR);',
'BEGIN',
'  FOR r IN (SELECT column_value AS pair FROM TABLE(apex_string.split(apex_application.g_x01, '',''))) LOOP',
'    l_id  := TO_NUMBER(SUBSTR(r.pair, 1, INSTR(r.pair, '':'') - 1));',
'    l_ver := TO_NUMBER(SUBSTR(r.pair, INSTR(r.pair, '':'') + 1));',
'    BEGIN',
'      SAVEPOINT one_ticket;',
'      IF l_assignee IS NOT NULL THEN',
'        afh_ticket_pkg.assign(l_id, l_ver, l_assignee);',
'        l_ver := afh_ticket_pkg.row_version_of(l_id);',
'      END IF;',
'      IF l_priority IS NOT NULL THEN',
'        DECLARE r2 afh_v_ticket_detail%ROWTYPE;',
'        BEGIN',
'          SELECT * INTO r2 FROM afh_v_ticket_detail WHERE ticket_id = l_id;',
'          afh_ticket_pkg.set_classification(l_id, l_ver, l_priority, r2.severity_code, r2.impact_code);',
'          l_ver := afh_ticket_pkg.row_version_of(l_id);',
'        END;',
'      END IF;',
'      IF l_release IS NOT NULL THEN',
'        afh_ticket_pkg.set_release(l_id, l_ver, l_release);',
'      END IF;',
'      l_ok := l_ok + 1;',
'    EXCEPTION WHEN OTHERS THEN',
'      ROLLBACK TO one_ticket;',
'      l_fail := l_fail + 1;',
'      BEGIN SELECT ticket_no INTO l_no FROM afh_tickets WHERE ticket_id = l_id; EXCEPTION WHEN NO_DATA_FOUND THEN l_no := l_id; END;',
'      l_msgs := SUBSTR(l_msgs || l_no || '': '' || REGEXP_REPLACE(SQLERRM, ''^ORA-\d+: '', '''') || ''; '', 1, 4000);',
'    END;',
'  END LOOP;',
'  apex_json.open_object;',
'  apex_json.write(''ok'', TRUE);',
'  apex_json.write(''updated'', l_ok);',
'  apex_json.write(''failed'', l_fail);',
'  apex_json.write(''message'', l_ok || '' updated, '' || l_fail || '' failed'' || CASE WHEN l_msgs IS NOT NULL THEN '': '' || l_msgs END);',
'  apex_json.close_object;',
'EXCEPTION WHEN OTHERS THEN',
'  apex_json.open_object; apex_json.write(''ok'', FALSE);',
'  apex_json.write(''message'', REGEXP_REPLACE(SQLERRM, ''^ORA-\d+: '', ''''));',
'  apex_json.close_object;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>wwv_flow_imp.id(68798083122369972)
,p_internal_uid=>70400000000001260
);
wwv_flow_imp.component_end;
end;
/
