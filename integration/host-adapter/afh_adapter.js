/*!
 * APEX Feedback Hub — host adapter
 * Version 1.0.1 · contract docs/architecture/browser-integration.md
 *
 * The ONLY global this file creates is window.AFH (spec §7.4).
 * The host page must never break because of this file: every public entry
 * point is wrapped, and failures are reported with console.warn('[AFH] ...').
 *
 * Requires (optional, feature-detected): window.html2canvas for screenshots.
 * Requires: Oracle APEX 24.2 runtime (apex.items / apex.item / apex.server / apex.env).
 */
(function (window, document) {
  'use strict';

  var VERSION = '1.0.1';
  var CONTRACT_VERSION = '1.0';
  var SCREENSHOT_TIMEOUT_MS = 6000;
  var IFRAME_TIMEOUT_MS = 10000;
  var DIRTY_REPLY_TIMEOUT_MS = 500;
  var MAX_VALUE_CHARS = 4000;
  var MAX_DATA_URL_BYTES = 6 * 1024 * 1024;
  var CREDENTIAL_RE = /(passw|pwd|token|secret|cookie|authorization|api[_-]?key|credential)/i;
  var TOKEN_RE = /^[A-Za-z0-9_.\-]+$/;
  var UNAVAILABLE_MSG = 'Feedback is temporarily unavailable. Your work on this page is not affected.';

  var DEFAULTS = {
    hubAppId: null,
    appKey: null,
    envCode: null,
    mode: 'SHARED_SESSION',
    adapterVersion: VERSION,
    screenshot: true,
    buttonSelector: '#afh-feedback',
    createButton: true,
    tokenProcess: 'AFH_LAUNCH_TOKEN',
    serverItemsProcess: 'AFH_SERVER_ITEMS',
    hubBaseUrl: null,
    dialogWidth: 'min(1100px, 96vw)',
    labels: { button: 'Feedback', title: 'Send feedback', close: 'Close' }
  };

  var state = {
    initialized: false,
    lastResult: { code: 'NOT_INITIALIZED', at: null },
    cfg: null,
    button: null,
    overlay: null,
    frame: null,
    trigger: null,
    cid: null,
    loadTimer: null,
    dirtyTimer: null,
    opening: false,
    listening: false
  };

  /* ------------------------------------------------------------------ utils */

  function warn(message, err) {
    try {
      if (window.console && window.console.warn) {
        window.console.warn('[AFH] ' + message, err || '');
      }
    } catch (ignore) { /* nothing to do */ }
  }

  function setResult(code, extra) {
    var result = { code: code, at: new Date().toISOString() };
    var key;
    if (extra) {
      for (key in extra) {
        if (Object.prototype.hasOwnProperty.call(extra, key)) { result[key] = extra[key]; }
      }
    }
    state.lastResult = result;
    return result;
  }

  function merge(base, override) {
    var out = {}, key;
    for (key in base) { if (Object.prototype.hasOwnProperty.call(base, key)) { out[key] = base[key]; } }
    for (key in override || {}) {
      if (Object.prototype.hasOwnProperty.call(override, key) && override[key] !== undefined) {
        out[key] = override[key];
      }
    }
    return out;
  }

  function randomHex(bytes) {
    var arr = new Uint8Array(bytes), i, s = '';
    window.crypto.getRandomValues(arr);
    for (i = 0; i < arr.length; i++) { s += (arr[i] < 16 ? '0' : '') + arr[i].toString(16); }
    return s;
  }

  function el(tag, className, attrs) {
    var node = document.createElement(tag), key;
    if (className) { node.className = className; }
    for (key in attrs || {}) {
      if (Object.prototype.hasOwnProperty.call(attrs, key)) { node.setAttribute(key, attrs[key]); }
    }
    return node;
  }

  function apexEnv(name, fallback) {
    try {
      var env = window.apex && window.apex.env;
      return env && env[name] !== undefined && env[name] !== null ? env[name] : fallback;
    } catch (e) { return fallback; }
  }

  function resolveEnvCode(cfg) {
    try {
      return typeof cfg.envCode === 'function' ? String(cfg.envCode() || '') : String(cfg.envCode || '');
    } catch (e) {
      warn('envCode function threw; sending empty envCode', e);
      return '';
    }
  }

  function cut(value) {
    var s = value === null || value === undefined ? '' : String(value);
    return s.length > MAX_VALUE_CHARS ? s.substring(0, MAX_VALUE_CHARS) : s;
  }

  /* ------------------------------------------------------------- base URL */

  function hubBaseUrl(cfg) {
    var path, idx;
    if (cfg.hubBaseUrl) { return String(cfg.hubBaseUrl).replace(/\/?$/, '/'); }
    path = window.location.pathname || '/';
    idx = path.indexOf('/r/');
    if (idx < 0) { idx = path.lastIndexOf('/f'); }
    if (idx < 0) { idx = path.lastIndexOf('/'); }
    return path.substring(0, idx + 1);
  }

  function launchUrl(cfg, cid, token) {
    var base = hubBaseUrl(cfg) + 'f?p=' + encodeURIComponent(String(cfg.hubAppId)) + ':20:';
    if (cfg.mode === 'SIGNED_ENVELOPE') {
      return base + '0::NO::P20_TOKEN,P20_CORR,P20_MODE:' + token + ',' + cid + ',SIGNED';
    }
    return base + apexEnv('APP_SESSION', '0') + '::NO::P20_CORR,P20_HOST_APP,P20_HOST_PAGE,P20_MODE:' +
      cid + ',' + apexEnv('APP_ID', '') + ',' + apexEnv('APP_PAGE_ID', '') + ',SHARED';
  }

  /* ---------------------------------------------------------- item capture */

  function itemNames() {
    var names = [], key, nodes, i, id;
    if (window.apex && window.apex.items && typeof window.apex.items === 'object') {
      for (key in window.apex.items) {
        if (Object.prototype.hasOwnProperty.call(window.apex.items, key)) { names.push(key); }
      }
      return { names: names, source: 'apex.items' };
    }
    if (window.apex && typeof window.apex.item === 'function') {
      nodes = document.querySelectorAll('[id^="P"]');
      for (i = 0; i < nodes.length; i++) {
        id = nodes[i].id;
        if (/^P\d+_[A-Z0-9_]+$/.test(id)) { names.push(id); }
      }
      return { names: names, source: 'dom' };
    }
    return { names: null, source: 'none' };
  }

  function itemType(item, name) {
    var node = item && item.node;
    if (node && node.type) { return String(node.type).toLowerCase(); }
    if (item && item.item_type) { return String(item.item_type).toLowerCase(); }
    node = document.getElementById(name);
    return node && node.type ? String(node.type).toLowerCase() : 'unknown';
  }

  function readItem(name) {
    var item, type, value;
    try {
      item = window.apex.item(name);
      type = itemType(item, name);
      if (type === 'password') { return { name: name, type: type, result: 'EXCLUDED', reason: 'PASSWORD_INPUT' }; }
      if (CREDENTIAL_RE.test(name)) { return { name: name, type: type, result: 'EXCLUDED', reason: 'CREDENTIAL_PATTERN' }; }
      value = item.getValue();
      if (Array.isArray(value)) { value = value.join(':'); }
      return { name: name, type: type, browserValue: cut(value), result: 'SUCCESS' };
    } catch (e) {
      return { name: name, type: type || 'unknown', result: 'FAILED', reason: 'READ_ERROR' };
    }
  }

  function collectItems() {
    var found = itemNames(), items = [], i, rec, failed = 0;
    if (!found.names) { return { itemResult: 'FAILED', items: [] }; }
    for (i = 0; i < found.names.length; i++) {
      rec = readItem(found.names[i]);
      if (rec.result === 'FAILED') { failed++; }
      items.push(rec);
    }
    return { itemResult: failed > 0 ? 'PARTIAL' : 'SUCCESS', items: items };
  }

  /* ------------------------------------------------------------ screenshot */

  function canvasToResult(canvas) {
    var dataUrl;
    if (!canvas || !canvas.width || !canvas.height) { return { result: 'PARTIAL', reason: 'EMPTY_CANVAS' }; }
    try {
      dataUrl = canvas.toDataURL('image/png');
    } catch (e) {
      return { result: 'PARTIAL', reason: 'TAINTED_CANVAS' };
    }
    if (!dataUrl || dataUrl.length < 100) { return { result: 'PARTIAL', reason: 'EMPTY_CANVAS' }; }
    if (dataUrl.length > MAX_DATA_URL_BYTES) { return { result: 'PARTIAL', reason: 'TOO_LARGE' }; }
    return { result: 'SUCCESS', dataUrl: dataUrl, width: canvas.width, height: canvas.height };
  }

  /* html2canvas clones and paints every element it is given, on the page's only thread, so a
   * whole-document capture of a long report froze the browser. The screenshot is the visible
   * viewport. Before cloning, each run of in-flow siblings lying wholly outside the viewport is
   * marked: its first element is cloned as one empty box spanning the run, the rest of the run and
   * every descendant are not cloned at all. Out-of-flow elements off screen take no space and are
   * dropped. Tables keep their measured column widths, so the viewport lays out exactly as on the
   * page. The marks are attributes on the host page's elements, removed as soon as html2canvas
   * settles. */
  var SHOT_OFF = 'data-afh-off', SHOT_SKIP = 'data-afh-skip', SHOT_COLS = 'data-afh-cols', SHOT_SCROLL = 'data-afh-scroll', SHOT_ANCHOR = 'data-afh-anchor', SHOT_COLROW = 'data-afh-colrow';

  function shotMark(el, attr, value, marks) {
    el.setAttribute(attr, value);
    marks.push(el);
  }

  function shotOffscreen(r, view) {
    return (r.width > 0 || r.height > 0) && (r.bottom < 0 || r.top > view.h || r.right < 0 || r.left > view.w);
  }

  function shotCloseRun(run, marks, tables) {
    var first, last, table, i;
    if (!run.length) { return; }
    first = run[0];
    last = run[run.length - 1];
    shotMark(first.el, SHOT_OFF, [first.rect.width, last.rect.bottom - first.rect.top, last.style.marginBottom].join(' '), marks);
    for (i = 1; i < run.length; i++) { shotMark(run[i].el, SHOT_SKIP, '1', marks); }
    table = first.el.tagName === 'TR' && first.el.closest ? first.el.closest('table') : null;
    if (table && tables.indexOf(table) < 0) { tables.push(table); }
  }

  function shotMarkTree(parent, view, marks, tables) {
    var child, rect, style, run = [];
    for (child = parent.firstElementChild; child; child = child.nextElementSibling) {
      rect = child.getBoundingClientRect();
      if (!shotOffscreen(rect, view)) {
        shotCloseRun(run, marks, tables);
        run = [];
        if (child.scrollTop || child.scrollLeft) { shotMark(child, SHOT_SCROLL, child.scrollLeft + ' ' + child.scrollTop, marks); }
        shotMarkTree(child, view, marks, tables);
        continue;
      }
      style = window.getComputedStyle(child);
      if (style.position === 'absolute' || style.position === 'fixed') {
        shotMark(child, SHOT_SKIP, '1', marks);
      } else if (style.display.indexOf('inline') === 0 || style.cssFloat !== 'none') {
        shotCloseRun(run, marks, tables);
        run = [];
      } else {
        run.push({ el: child, rect: rect, style: style });
      }
    }
    shotCloseRun(run, marks, tables);
  }

  /* Column widths from one on-screen row without spans; the clone gets a fixed-layout colgroup.
   * A col width is not the cell's border-box width under collapsed borders, so the clone's cells
   * are measured against the page's and each col corrected by the difference. */
  function shotMarkColumns(tables, marks) {
    var t, r, rows, cells, widths, c, found;
    for (t = 0; t < tables.length; t++) {
      rows = tables[t].rows;
      for (r = 0, found = false; r < rows.length && !found; r++) {
        cells = rows[r].cells;
        if (rows[r].hasAttribute(SHOT_OFF) || rows[r].hasAttribute(SHOT_SKIP)) { continue; }
        for (c = 0, widths = []; c < cells.length && cells[c].colSpan === 1; c++) { widths.push(cells[c].getBoundingClientRect().width); }
        found = cells.length > 0 && widths.length === cells.length;
      }
      if (found) {
        shotMark(rows[r - 1], SHOT_COLROW, '1', marks);
        shotMark(tables[t], SHOT_COLS, widths.join(' ') + '|' + tables[t].getBoundingClientRect().width, marks);
      }
    }
  }

  function shotSampleRow(t) {
    var i;
    for (i = 0; i < t.rows.length; i++) {
      if (t.rows[i].hasAttribute(SHOT_COLROW)) { return t.rows[i]; }
    }
    return null;
  }

  function shotFixColumns(doc) {
    Array.prototype.forEach.call(doc.querySelectorAll('[' + SHOT_COLS + ']'), function (t) {
      var parts = t.getAttribute(SHOT_COLS).split('|'), want = parts[0].split(' ').map(Number);
      var group = doc.createElement('colgroup'), cols = [], set, row, pass, c, got;
      Array.prototype.forEach.call(t.querySelectorAll(':scope > colgroup'), function (g) { g.parentNode.removeChild(g); });
      want.forEach(function (w) {
        var col = doc.createElement('col');
        col.style.width = w + 'px';
        cols.push(col);
        group.appendChild(col);
      });
      t.insertBefore(group, t.firstChild);
      t.style.tableLayout = 'fixed';
      t.style.width = parts[1] + 'px';
      row = shotSampleRow(t);
      for (pass = 0, set = want.slice(); row && pass < 2; pass++) {
        for (c = 0; c < cols.length && c < row.cells.length; c++) {
          got = row.cells[c].getBoundingClientRect().width;
          if (got !== want[c]) {
            set[c] += want[c] - got;
            cols[c].style.width = set[c] + 'px';
          }
        }
      }
    });
  }

  function shotSizeBoxes(doc) {
    Array.prototype.forEach.call(doc.querySelectorAll('[' + SHOT_OFF + ']'), function (el) {
      var size = el.getAttribute(SHOT_OFF).split(' ');
      while (el.firstChild) { el.removeChild(el.firstChild); }
      el.style.boxSizing = 'border-box';
      el.style.height = el.style.minHeight = el.style.maxHeight = size[1] + 'px';
      el.style.marginBottom = size[2];
      if (el.tagName !== 'TR') { el.style.width = size[0] + 'px'; }
    });
  }

  /* html2canvas scrolls the clone before onclone, while the boxes are still collapsed, so the
   * window and every scrolled region are scrolled again once the boxes have their size. */
  function shotRescroll(doc, view) {
    Array.prototype.forEach.call(doc.querySelectorAll('[' + SHOT_SCROLL + ']'), function (el) {
      var pos = el.getAttribute(SHOT_SCROLL).split(' ');
      el.scrollLeft = Number(pos[0]);
      el.scrollTop = Number(pos[1]);
    });
    doc.defaultView.scrollTo(view.x, view.y);
  }

  /* An empty box can shift what follows by a fraction of a pixel (a collapsed table border that
   * belonged to the replaced row, for one). The element at the centre of the viewport is measured
   * in the page and in the clone, and the nearest box before it absorbs the difference. */
  function shotMarkAnchor(view, marks) {
    var el = document.elementFromPoint(view.w / 2, view.h / 2);
    if (el && el !== document.body && el !== document.documentElement) {
      shotMark(el, SHOT_ANCHOR, String(el.getBoundingClientRect().top), marks);
    }
  }

  function shotAlignAnchor(doc, view) {
    var anchor = doc.querySelector('[' + SHOT_ANCHOR + ']'), boxes = doc.querySelectorAll('[' + SHOT_OFF + ']');
    var i, box = null, dy, height;
    if (!anchor) { return; }
    for (i = 0; i < boxes.length; i++) {
      if (boxes[i].compareDocumentPosition(anchor) & 4) { box = boxes[i]; }
    }
    dy = anchor.getBoundingClientRect().top + doc.defaultView.pageYOffset - Number(anchor.getAttribute(SHOT_ANCHOR)) - view.y;
    if (!box || !dy) { return; }
    /* From the recorded size: style.height reads back rounded to six significant digits. */
    height = Math.max(0, Number(box.getAttribute(SHOT_OFF).split(' ')[1]) - dy);
    box.style.height = box.style.minHeight = box.style.maxHeight = height + 'px';
    doc.defaultView.scrollTo(view.x, view.y);
  }

  function viewportOptions(view) {
    return {
      useCORS: true, logging: false, scale: 1,
      x: view.x, y: view.y, width: view.w, height: view.h, windowWidth: view.w, windowHeight: view.h,
      ignoreElements: function (el) {
        return el.hasAttribute(SHOT_SKIP) || !!(el.parentElement && el.parentElement.hasAttribute(SHOT_OFF));
      },
      onclone: function (doc) {
        shotFixColumns(doc);
        shotSizeBoxes(doc);
        shotRescroll(doc, view);
        shotAlignAnchor(doc, view);
      }
    };
  }

  function renderViewport() {
    var root = document.documentElement, marks = [], tables = [];
    var view = { x: window.pageXOffset, y: window.pageYOffset, w: root.clientWidth || window.innerWidth, h: root.clientHeight || window.innerHeight };
    function unmark() {
      marks.forEach(function (el) { [SHOT_OFF, SHOT_SKIP, SHOT_COLS, SHOT_SCROLL, SHOT_ANCHOR, SHOT_COLROW].forEach(function (a) { el.removeAttribute(a); }); });
    }
    try {
      shotMarkTree(document.body, view, marks, tables);
      shotMarkColumns(tables, marks);
      shotMarkAnchor(view, marks);
    } catch (e) {
      unmark();
      throw e;
    }
    return window.html2canvas(root, viewportOptions(view)).then(
      function (canvas) { unmark(); return canvas; },
      function (e) { unmark(); throw e; });
  }

  function takeScreenshot(cfg) {
    var timer, timeout, capture;
    if (!cfg.screenshot) { return Promise.resolve({ result: 'DENIED' }); }
    if (typeof window.html2canvas !== 'function') { return Promise.resolve({ result: 'UNSUPPORTED' }); }
    timeout = new Promise(function (resolve) {
      timer = window.setTimeout(function () { resolve({ result: 'FAILED', reason: 'TIMEOUT' }); }, SCREENSHOT_TIMEOUT_MS);
    });
    capture = new Promise(function (resolve) {
      try {
        renderViewport()
          .then(function (canvas) { resolve(canvasToResult(canvas)); })
          .catch(function () { resolve({ result: 'FAILED', reason: 'RENDER_ERROR' }); });
      } catch (e) {
        resolve({ result: 'FAILED', reason: 'RENDER_ERROR' });
      }
    });
    return Promise.race([capture, timeout]).then(function (r) { window.clearTimeout(timer); return r; });
  }

  /* ---------------------------------------------------- signed-mode calls */

  function serverProcess(name, data) {
    return new Promise(function (resolve, reject) {
      try {
        window.apex.server.process(name, data, { dataType: 'json' }).then(resolve, function (jq) {
          reject(new Error(name + ' failed' + (jq && jq.status ? ' (' + jq.status + ')' : '')));
        });
      } catch (e) { reject(e); }
    });
  }

  function fetchServerItems(cfg, pageId) {
    if (cfg.mode !== 'SIGNED_ENVELOPE') { return Promise.resolve([]); }
    return serverProcess(cfg.serverItemsProcess, { x01: pageId }).then(function (res) {
      if (Array.isArray(res)) { return res; }
      return res && Array.isArray(res.items) ? res.items : [];
    }).catch(function (e) {
      warn('server items unavailable', e);
      return [];
    });
  }

  function fetchToken(cfg, facts) {
    if (cfg.mode !== 'SIGNED_ENVELOPE') { return Promise.resolve(null); }
    return serverProcess(cfg.tokenProcess, { x01: facts.pageId, x02: facts.pageName, x03: facts.url })
      .then(function (res) {
        var token = res && res.token;
        if (!token || !TOKEN_RE.test(token)) { throw new Error('launch token missing or malformed'); }
        return token;
      });
  }

  /* -------------------------------------------------------- client facts */

  function clientFacts() {
    var tz = '';
    try { tz = Intl.DateTimeFormat().resolvedOptions().timeZone || ''; } catch (e) { tz = ''; }
    return {
      userAgent: navigator.userAgent,
      platform: navigator.platform || '',
      viewport: window.innerWidth + 'x' + window.innerHeight,
      locale: navigator.language || '',
      timeZone: tz,
      apexVersion: String(apexEnv('APEX_VERSION', '')),
      pageTitle: document.title || ''
    };
  }

  function debugFacts() {
    try {
      if (window.apex && window.apex.debug && typeof window.apex.debug.getLevel === 'function') {
        return { result: window.apex.debug.getLevel() > 0 ? 'AVAILABLE' : 'UNAVAILABLE' };
      }
    } catch (e) { /* fall through */ }
    return { result: 'UNAVAILABLE' };
  }

  function pageFacts() {
    return {
      pageId: Number(apexEnv('APP_PAGE_ID', 0)) || 0,
      pageName: document.title || '',
      url: String(window.location.href).substring(0, 2000)
    };
  }

  function buildCapture(cfg, cid, items, shot, serverItems, facts) {
    return {
      v: CONTRACT_VERSION,
      cid: cid,
      mode: cfg.mode === 'SIGNED_ENVELOPE' ? 'SIGNED' : 'SHARED',
      appKey: String(cfg.appKey),
      envCode: resolveEnvCode(cfg),
      apexAppId: Number(apexEnv('APP_ID', 0)) || 0,
      pageId: facts.pageId,
      pageName: facts.pageName,
      url: facts.url,
      adapterVersion: String(cfg.adapterVersion || VERSION),
      client: clientFacts(),
      itemResult: items.itemResult,
      items: items.items,
      serverItems: serverItems,
      screenshot: shot,
      debug: debugFacts()
    };
  }

  function storeCapture(capture) {
    var key = 'afh.capture.' + capture.cid;
    try {
      window.sessionStorage.setItem(key, JSON.stringify(capture));
      return true;
    } catch (e) {
      warn('sessionStorage write failed; retrying without screenshot', e);
      try {
        capture.screenshot = { result: 'PARTIAL', reason: 'STORAGE_QUOTA' };
        window.sessionStorage.setItem(key, JSON.stringify(capture));
        return true;
      } catch (e2) {
        warn('sessionStorage unavailable', e2);
        return false;
      }
    }
  }

  /* ---------------------------------------------------------- overlay UI */

  function buildOverlay(cfg) {
    var overlay = el('div', 'afh-overlay', { role: 'dialog', 'aria-modal': 'true', 'aria-label': cfg.labels.title });
    var dialog = el('div', 'afh-dialog');
    var header = el('div', 'afh-dialog-header');
    var title = el('span', 'afh-dialog-title');
    var closeBtn = el('button', 'afh-close', { type: 'button', 'aria-label': cfg.labels.close });
    var status = el('div', 'afh-status', { role: 'status', 'aria-live': 'polite' });
    var confirm = el('div', 'afh-confirm', { hidden: '' });
    var frame = el('iframe', 'afh-frame', { title: 'Feedback', 'aria-label': 'Feedback' });
    var before = el('span', 'afh-sentinel', { tabindex: '0', 'aria-hidden': 'true' });
    var after = el('span', 'afh-sentinel', { tabindex: '0', 'aria-hidden': 'true' });
    dialog.style.width = cfg.dialogWidth;
    title.textContent = cfg.labels.title;
    closeBtn.textContent = '×';
    status.textContent = 'Loading feedback…';
    header.appendChild(title);
    header.appendChild(closeBtn);
    dialog.appendChild(header);
    dialog.appendChild(status);
    dialog.appendChild(confirm);
    dialog.appendChild(frame);
    overlay.appendChild(before);
    overlay.appendChild(dialog);
    overlay.appendChild(after);
    before.addEventListener('focus', function () { focusFrameOrClose(frame, closeBtn, true); });
    after.addEventListener('focus', function () { closeBtn.focus(); });
    closeBtn.addEventListener('click', function () { requestClose(); });
    overlay.addEventListener('keydown', onOverlayKeydown);
    return { overlay: overlay, frame: frame, status: status, confirm: confirm, closeBtn: closeBtn };
  }

  function focusFrameOrClose(frame, closeBtn, preferFrame) {
    try {
      if (preferFrame && frame.offsetParent !== null) { frame.focus(); return; }
    } catch (e) { /* ignore */ }
    closeBtn.focus();
  }

  function onOverlayKeydown(event) {
    if (event.key === 'Escape') {
      event.preventDefault();
      requestClose();
      return;
    }
    if (event.key === 'Tab' && state.overlay) {
      /* Close button is the only native focusable besides the iframe: cycle between them. */
      var closeBtn = state.overlay.querySelector('.afh-close');
      if (document.activeElement === closeBtn) {
        event.preventDefault();
        focusFrameOrClose(state.frame, closeBtn, true);
      }
    }
  }

  function showStatus(text, isError) {
    var status = state.overlay && state.overlay.querySelector('.afh-status');
    if (!status) { return; }
    status.textContent = text || '';
    status.hidden = !text;
    status.classList.toggle('afh-status-error', !!isError);
    if (state.frame) { state.frame.classList.toggle('afh-frame-hidden', !!isError); }
  }

  function showConfirm() {
    var box = state.overlay && state.overlay.querySelector('.afh-confirm');
    var text, keep, discard;
    if (!box || !box.hidden) { return; }
    text = el('span');
    text.textContent = 'Discard your unsent feedback?';
    keep = el('button', 'afh-btn', { type: 'button' });
    keep.textContent = 'Keep editing';
    discard = el('button', 'afh-btn afh-btn-danger', { type: 'button' });
    discard.textContent = 'Discard';
    keep.addEventListener('click', function () { hideConfirm(); focusFrameOrClose(state.frame, state.overlay.querySelector('.afh-close'), true); });
    discard.addEventListener('click', function () { closeNow(); });
    box.appendChild(text);
    box.appendChild(keep);
    box.appendChild(discard);
    box.hidden = false;
    keep.focus();
  }

  function hideConfirm() {
    var box = state.overlay && state.overlay.querySelector('.afh-confirm');
    if (!box) { return; }
    while (box.firstChild) { box.removeChild(box.firstChild); }
    box.hidden = true;
  }

  /* ------------------------------------------------------------ messaging */

  function postToFrame(message) {
    try {
      if (state.frame && state.frame.contentWindow) {
        message.source = 'AFH';
        state.frame.contentWindow.postMessage(message, window.location.origin);
      }
    } catch (e) { warn('postMessage to Hub failed', e); }
  }

  function onMessage(event) {
    var data = event.data;
    try {
      if (!state.frame || event.origin !== window.location.origin) { return; }
      if (!data || data.source !== 'AFH' || event.source !== state.frame.contentWindow) { return; }
      handleHubMessage(data);
    } catch (e) { warn('message handler failed', e); }
  }

  function handleHubMessage(data) {
    switch (data.type) {
      case 'afh:ready':
        clearLoadTimer();
        showStatus('');
        setResult('HUB_READY', { cid: state.cid });
        focusFrameOrClose(state.frame, state.overlay.querySelector('.afh-close'), true);
        break;
      case 'afh:resize':
        if (state.frame && data.height > 0) { state.frame.style.height = Math.ceil(Number(data.height)) + 'px'; }
        break;
      case 'afh:dirty':
        window.clearTimeout(state.dirtyTimer);
        if (data.dirty) { showConfirm(); } else { closeNow(); }
        break;
      case 'afh:created':
        setResult('TICKET_CREATED', { cid: state.cid, ticketNo: data.ticketNo, ticketUrl: data.ticketUrl });
        try { document.dispatchEvent(new CustomEvent('afh:created', { detail: { ticketNo: data.ticketNo, ticketUrl: data.ticketUrl } })); } catch (e) { /* ignore */ }
        break;
      case 'afh:close':
        closeNow();
        break;
      default:
        break;
    }
  }

  function ensureListener() {
    if (!state.listening) {
      window.addEventListener('message', onMessage, false);
      state.listening = true;
    }
  }

  function clearLoadTimer() {
    if (state.loadTimer) { window.clearTimeout(state.loadTimer); state.loadTimer = null; }
  }

  /* ------------------------------------------------------- open / close */

  function requestClose() {
    if (!state.overlay) { return; }
    if (!state.frame || state.frame.classList.contains('afh-frame-hidden') || state.lastResult.code === 'HUB_UNAVAILABLE') {
      closeNow();
      return;
    }
    window.clearTimeout(state.dirtyTimer);
    state.dirtyTimer = window.setTimeout(closeNow, DIRTY_REPLY_TIMEOUT_MS);
    postToFrame({ type: 'afh:query-dirty' });
  }

  function closeNow() {
    var trigger = state.trigger;
    clearLoadTimer();
    window.clearTimeout(state.dirtyTimer);
    try {
      if (state.overlay && state.overlay.parentNode) { state.overlay.parentNode.removeChild(state.overlay); }
      document.documentElement.classList.remove('afh-lock');
    } catch (e) { warn('overlay removal failed', e); }
    state.overlay = null;
    state.frame = null;
    state.trigger = null;
    if (state.lastResult.code !== 'TICKET_CREATED') { setResult('CLOSED', { cid: state.cid }); }
    try { if (trigger && typeof trigger.focus === 'function') { trigger.focus(); } } catch (e) { /* ignore */ }
  }

  function mountOverlay(cfg, url) {
    var ui = buildOverlay(cfg);
    state.overlay = ui.overlay;
    state.frame = ui.frame;
    document.body.appendChild(ui.overlay);
    document.documentElement.classList.add('afh-lock');
    ui.closeBtn.focus();
    state.loadTimer = window.setTimeout(function () {
      setResult('HUB_UNAVAILABLE', { cid: state.cid });
      showStatus(UNAVAILABLE_MSG, true);
    }, IFRAME_TIMEOUT_MS);
    ui.frame.addEventListener('error', function () {
      clearLoadTimer();
      setResult('HUB_UNAVAILABLE', { cid: state.cid });
      showStatus(UNAVAILABLE_MSG, true);
    });
    ui.frame.src = url;
  }

  function setBusy(busy) {
    try {
      if (state.trigger) {
        state.trigger.setAttribute('aria-busy', busy ? 'true' : 'false');
        state.trigger.classList.toggle('afh-busy', !!busy);
      }
    } catch (e) { /* ignore */ }
  }

  function doOpen(cfg, trigger) {
    var cid = randomHex(16), facts = pageFacts(), items, stored;
    state.cid = cid;
    state.trigger = trigger || state.button || document.activeElement;
    setBusy(true);
    items = collectItems();
    return Promise.all([takeScreenshot(cfg), fetchServerItems(cfg, facts.pageId), fetchToken(cfg, facts)])
      .then(function (parts) {
        stored = storeCapture(buildCapture(cfg, cid, items, parts[0], parts[1], facts));
        if (!stored) { throw new Error('browser storage unavailable'); }
        setResult('OPENED', { cid: cid, itemResult: items.itemResult, screenshotResult: parts[0].result });
        mountOverlay(cfg, launchUrl(cfg, cid, parts[2]));
      })
      .catch(function (e) {
        warn('open failed', e);
        setResult('OPEN_FAILED', { cid: cid, message: String(e && e.message || e) });
        if (!state.overlay) { mountOverlay(cfg, 'about:blank'); }
        clearLoadTimer();
        showStatus(UNAVAILABLE_MSG, true);
      })
      .then(function () { setBusy(false); state.opening = false; });
  }

  /* --------------------------------------------------------------- button */

  function bindButton(cfg) {
    var btn = null;
    try { btn = cfg.buttonSelector ? document.querySelector(cfg.buttonSelector) : null; } catch (e) { btn = null; }
    if (!btn && cfg.createButton) {
      btn = el('button', 'afh-launcher', { type: 'button', id: 'afh-feedback' });
      btn.textContent = cfg.labels.button;
      document.body.appendChild(btn);
    }
    if (btn) {
      btn.addEventListener('click', function (event) {
        try { event.preventDefault(); } catch (e) { /* ignore */ }
        AFH.open(btn);
      });
    }
    state.button = btn;
    return btn;
  }

  /* ------------------------------------------------------------ public API */

  var AFH = {
    version: VERSION,

    init: function (cfg) {
      try {
        var merged = merge(DEFAULTS, cfg || {});
        merged.labels = merge(DEFAULTS.labels, (cfg && cfg.labels) || {});
        if (!merged.hubAppId || !merged.appKey) { throw new Error('hubAppId and appKey are required'); }
        if (merged.mode !== 'SHARED_SESSION' && merged.mode !== 'SIGNED_ENVELOPE') { throw new Error('unknown mode ' + merged.mode); }
        if (!window.crypto || !window.crypto.getRandomValues) { throw new Error('crypto.getRandomValues unavailable'); }
        state.cfg = merged;
        ensureListener();
        bindButton(merged);
        state.initialized = true;
        setResult('INITIALIZED', { mode: merged.mode, button: !!state.button });
      } catch (e) {
        warn('init failed: ' + (e && e.message), e);
        state.initialized = false;
        setResult('INIT_FAILED', { message: String(e && e.message || e) });
      }
      return AFH;
    },

    open: function (triggerEl) {
      try {
        if (!state.initialized) { warn('open() called before init()'); return; }
        if (state.overlay || state.opening) { return; }
        state.opening = true;
        doOpen(state.cfg, triggerEl).catch(function (e) { warn('open failed', e); state.opening = false; });
      } catch (e) {
        warn('open failed', e);
        state.opening = false;
      }
    },

    close: function () {
      try { closeNow(); } catch (e) { warn('close failed', e); }
    },

    status: function () {
      return { initialized: state.initialized, lastResult: merge(state.lastResult, {}) };
    }
  };

  window.AFH = AFH;

  /* Order-independent initialisation: APEX emits the User Interface JavaScript file
   * URLs at the END of the body and the Global Page's "Execute when Page Loads" is not
   * applied to other pages, so a host page-0 region can only publish the configuration
   * (window.AFH_CONFIG = {...}) before this file has loaded. Consume it here. */
  try {
    if (window.AFH_CONFIG && typeof window.AFH_CONFIG === 'object') {
      AFH.init(window.AFH_CONFIG);
    }
  } catch (e) { warn('auto-init from AFH_CONFIG failed', e); }
}(window, document));
