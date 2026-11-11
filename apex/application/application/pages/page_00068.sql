prompt --application/pages/page_00068
begin
--   Manifest
--     PAGE: 00068
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
 p_id=>68
,p_name=>'FAQ for IT'
,p_alias=>'FAQ-FOR-IT'
,p_step_title=>'FAQ for IT'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () {',
'  var root = document.getElementById(''afh-faq'');',
'  if (!root) { return; }',
'  var input = root.querySelector(''.afh-faq-input'');',
'  var result = root.querySelector(''.afh-faq-result'');',
'  var empty = root.querySelector(''p.afh-faq-empty'');',
'  var toggle = root.querySelector(''.afh-faq-toggle'');',
'  var qas = Array.prototype.slice.call(root.querySelectorAll(''.afh-faq-qa''));',
'  var secs = Array.prototype.slice.call(root.querySelectorAll(''.afh-faq-sec''));',
'  if (!input || !qas.length) { return; }',
'  qas.forEach(function (d) { d.afhText = d.textContent.toLowerCase(); d.afhOpen = false; });',
'',
'  function clearMarks(el) {',
'    el.querySelectorAll(''mark'').forEach(function (m) { m.replaceWith(document.createTextNode(m.textContent)); });',
'    el.normalize();',
'  }',
'  function markIn(el, term) {',
'    var walker = document.createTreeWalker(el, NodeFilter.SHOW_TEXT, null);',
'    var nodes = [];',
'    var n = walker.nextNode();',
'    while (n) { if (n.nodeValue.toLowerCase().indexOf(term) !== -1) { nodes.push(n); } n = walker.nextNode(); }',
'    nodes.forEach(function (node) {',
'      var s = node.nodeValue;',
'      var lower = s.toLowerCase();',
'      var frag = document.createDocumentFragment();',
'      var i = 0;',
'      var j = lower.indexOf(term, i);',
'      while (j !== -1) {',
'        frag.appendChild(document.createTextNode(s.slice(i, j)));',
'        var m = document.createElement(''mark'');',
'        m.textContent = s.slice(j, j + term.length);',
'        frag.appendChild(m);',
'        i = j + term.length;',
'        j = lower.indexOf(term, i);',
'      }',
'      frag.appendChild(document.createTextNode(s.slice(i)));',
'      node.replaceWith(frag);',
'    });',
'  }',
'  function run() {',
'    var term = input.value.trim().toLowerCase();',
'    var shown = 0;',
'    qas.forEach(function (d) {',
'      clearMarks(d);',
'      var hit = !term || d.afhText.indexOf(term) !== -1;',
'      d.classList.toggle(''is-hidden'', !hit);',
'      if (term && hit) { d.open = true; markIn(d, term); shown += 1; } else if (!term) { d.open = d.afhOpen; }',
'    });',
'    secs.forEach(function (s) {',
'      var any = !!s.querySelector(''.afh-faq-qa:not(.is-hidden)'');',
'      s.classList.toggle(''is-hidden'', !any);',
'      var link = root.querySelector(''.afh-faq-toc a[href="#'' + s.id + ''"]'');',
'      if (link) { link.classList.toggle(''is-empty'', !any); }',
'    });',
'    empty.hidden = !(term && shown === 0);',
'    result.textContent = term ? shown + '' of '' + qas.length + '' questions match'' : '''';',
'  }',
'',
'  var timer;',
'  input.addEventListener(''input'', function () { clearTimeout(timer); timer = setTimeout(run, 120); });',
'  qas.forEach(function (d) {',
'    d.addEventListener(''toggle'', function () { if (!input.value.trim()) { d.afhOpen = d.open; } });',
'  });',
'  toggle.addEventListener(''click'', function () {',
'    var open = toggle.textContent === ''Expand all'';',
'    qas.forEach(function (d) { if (!d.classList.contains(''is-hidden'')) { d.open = open; d.afhOpen = open; } });',
'    toggle.textContent = open ? ''Collapse all'' : ''Expand all'';',
'  });',
'  document.addEventListener(''keydown'', function (e) {',
'    var t = e.target;',
'    var typing = t && (t.tagName === ''INPUT'' || t.tagName === ''TEXTAREA'' || t.isContentEditable);',
'    if (e.key === ''/'' && !typing) { e.preventDefault(); input.focus(); }',
'    if (e.key === ''Escape'' && t === input) { input.value = ''''; run(); input.blur(); }',
'  });',
'  function openHash() {',
'    var id = decodeURIComponent(location.hash.slice(1));',
'    var el = id && document.getElementById(id);',
'    if (el && el.classList.contains(''afh-faq-qa'')) { el.open = true; el.afhOpen = true; el.scrollIntoView({ block: ''start'' }); }',
'  }',
'  window.addEventListener(''hashchange'', openHash);',
'  openHash();',
'})();'))
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#afh-faq { max-width: 1040px; }',
'.afh-faq-bar { position: sticky; top: 0; z-index: 5; display: flex; gap: 10px; align-items: center; padding: 10px 0; background: var(--afh-paper-2); }',
'.afh-faq-search { flex: 1; min-width: 0; position: relative; margin: 0; }',
'.afh-faq-search .fa { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: var(--afh-ink-muted); }',
'.afh-faq-input { width: 100%; font: inherit; font-size: 1rem; color: var(--afh-ink); background: var(--afh-paper); border: 1px solid var(--afh-border); border-radius: var(--afh-radius-sm); padding: 9px 12px 9px 36px; }',
'.afh-faq-input:focus { outline: 2px solid var(--afh-teal); outline-offset: 1px; }',
'.afh-faq-result { min-height: 1.2em; margin: 0 0 8px; font-family: var(--afh-mono); font-size: .8rem; color: var(--afh-ink-muted); }',
'.afh-faq-empty { padding: 24px; text-align: center; color: var(--afh-ink-muted); border: 1px dashed var(--afh-border); border-radius: var(--afh-radius-md); }',
'.afh-faq-intro { background: var(--afh-paper); border: 1px solid var(--afh-border); border-left: 4px solid var(--afh-teal); border-radius: var(--afh-radius-md); padding: 16px 20px; margin-bottom: 14px; }',
'.afh-faq-intro p { margin: 0 0 8px; max-width: 78ch; }',
'.afh-faq-total { font-family: var(--afh-mono); font-size: .8rem; color: var(--afh-ink-muted); margin: 6px 0 0 !important; }',
'.afh-faq-toc { display: flex; flex-wrap: wrap; gap: 6px; margin: 0 0 22px; }',
'.afh-faq-toc a { font-size: .85rem; padding: 4px 10px; border: 1px solid var(--afh-border); border-radius: 999px; background: var(--afh-paper); color: var(--afh-ink-soft); text-decoration: none; }',
'.afh-faq-toc a:hover { border-color: var(--afh-teal); color: var(--afh-teal); }',
'.afh-faq-toc a.is-empty { opacity: .4; }',
'.afh-faq-num { font-family: var(--afh-mono); font-size: .75rem; color: var(--afh-gold); margin-right: 8px; }',
'.afh-faq-sec { margin: 0 0 28px; scroll-margin-top: 70px; }',
'.afh-faq-sec h2 { display: flex; align-items: baseline; gap: 4px; font-family: var(--afh-display); font-size: 1.45rem; font-weight: 600; margin: 0 0 2px; padding-bottom: 6px; border-bottom: 2px solid var(--afh-ink); }',
'.afh-faq-count { margin-left: auto; font-family: var(--afh-mono); font-size: .75rem; font-weight: 400; color: var(--afh-ink-muted); }',
'.afh-faq-qa { border-bottom: 1px solid var(--afh-border); scroll-margin-top: 70px; }',
'.afh-faq-qa > summary { list-style: none; cursor: pointer; display: flex; gap: 10px; padding: 11px 4px; font-weight: 600; line-height: 1.4; }',
'.afh-faq-qa > summary::-webkit-details-marker { display: none; }',
'.afh-faq-qa > summary::before { content: "+"; flex: 0 0 14px; font-family: var(--afh-mono); color: var(--afh-gold); }',
'.afh-faq-qa[open] > summary::before { content: "\2212"; }',
'.afh-faq-qa > summary:hover { color: var(--afh-teal); }',
'.afh-faq-a { padding: 0 4px 16px 28px; max-width: 82ch; }',
'.afh-faq-a p { margin: 0 0 10px; }',
'.afh-faq-a ul, .afh-faq-a ol { margin: 0 0 10px; padding-left: 1.3em; }',
'.afh-faq-a li { margin-bottom: 4px; }',
'.afh-faq-a code { font-family: var(--afh-mono); font-size: .86em; background: var(--afh-paper-3); padding: 1px 4px; border-radius: var(--afh-radius-xs); }',
'.afh-faq-a pre { font-family: var(--afh-mono); font-size: .82rem; line-height: 1.5; background: var(--afh-paper-3); border: 1px solid var(--afh-border); border-radius: var(--afh-radius-sm); padding: 12px 14px; white-space: pre-wrap; word-break: break'
||'-word; overflow-x: auto; margin: 0 0 12px; }',
'.afh-faq-a pre code { background: none; padding: 0; }',
'.afh-faq-a table { display: block; overflow-x: auto; border-collapse: collapse; margin: 0 0 12px; font-size: .9rem; background: var(--afh-paper); border: 1px solid var(--afh-border); border-radius: var(--afh-radius-sm); }',
'.afh-faq-a th { text-align: left; font-size: .75rem; text-transform: uppercase; letter-spacing: .04em; color: var(--afh-ink-muted); background: var(--afh-paper-2); padding: 7px 10px; border-bottom: 1px solid var(--afh-border); }',
'.afh-faq-a td { padding: 7px 10px; border-bottom: 1px solid var(--afh-border); vertical-align: top; }',
'.afh-faq-a tr:last-child td { border-bottom: 0; }',
'.afh-faq-a td code { white-space: nowrap; }',
'#afh-faq mark { background: var(--afh-gold-soft); color: inherit; padding: 0 1px; border-radius: 2px; }',
'#afh-faq .is-hidden { display: none; }',
'@media (max-width: 640px) { .afh-faq-bar { flex-wrap: wrap; } .afh-faq-a { padding-left: 4px; } }',
'@media print { .afh-faq-bar, .afh-faq-result, .afh-faq-toc { display: none; } }'))
,p_step_template=>4072355960268175073
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(68798393905371806)
,p_protection_level=>'C'
,p_page_component_map=>'11'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(72100000000001010)
,p_plug_name=>'FAQ for IT'
,p_region_name=>'afh-faq'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_file BLOB;',
'BEGIN',
'  SELECT file_content INTO l_file',
'    FROM apex_application_static_files',
'   WHERE application_id = :APP_ID',
'     AND file_name = ''afh_faq.html'';',
'  RETURN ''<div class="afh-faq-bar">''',
'      || ''<label class="afh-faq-search"><span class="fa fa-search" aria-hidden="true"></span>''',
'      || ''<input type="search" class="afh-faq-input" placeholder="Search questions, page numbers, error codes, job names"''',
'      || '' aria-label="Search the FAQ" autocomplete="off"></label>''',
'      || ''<button type="button" class="t-Button afh-faq-toggle">Expand all</button></div>''',
'      || ''<p class="afh-faq-result" aria-live="polite"></p>''',
'      || ''<p class="afh-faq-empty" hidden>No question matches that search.</p>''',
'      || apex_util.blob_to_clob(l_file);',
'EXCEPTION',
'  WHEN NO_DATA_FOUND THEN',
'    RETURN ''<p class="afh-faq-empty">The FAQ file afh_faq.html is missing from this application. ''',
'        || ''Re-import the application from the release bundle.</p>'';',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp.component_end;
end;
/
