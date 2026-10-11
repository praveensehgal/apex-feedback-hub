# APEX Feedback Hub — host adapter

Files a host application installs so its users can send feedback to the Hub.
Binding contract: `docs/architecture/browser-integration.md`. Adapter version **1.0.0**.

| File | Purpose |
|---|---|
| `afh_adapter.js` | Creates the single global `AFH`; collects page items, screenshot, client facts; opens the Hub in an overlay iframe |
| `afh_adapter.css` | Overlay, iframe, floating button, loading/error states (`.afh-*` only, z-index 10000) |
| `afh_host_pkg.pks` / `.pkb` | Signed-envelope mode only: issues launch tokens and server item JSON |
| `grant_host_schema.sql` | Grants the host schema needs for `afh_host_pkg` |
| `test/host.html` | Static harness with an `apex` shim — open in a browser to click through |

## Installation (host application)

1. Upload `apex/static/vendor/html2canvas-1.4.1.min.js`, `afh_adapter.js` and `afh_adapter.css`
   as **application static files** of the host application.
2. Shared Components → User Interface Attributes: add the two scripts to *JavaScript → File URLs*
   (html2canvas first, then `afh_adapter.js`) and the stylesheet to *CSS → File URLs*.
3. On the host **Global Page (Page 0)** add a Static Content region (template *Blank with
   Attributes*) whose source publishes the configuration:

   ```html
   <script>
   window.AFH_CONFIG = { hubAppId: '&HUB_APP_ID.', appKey: '&AFH_APP_KEY.', envCode: '&AFH_ENV_CODE.',
                         mode: 'SHARED_SESSION', adapterVersion: '1.0.0', createButton: false };
   </script>
   ```

   The adapter calls `AFH.init(window.AFH_CONFIG)` itself when it loads, so the order in which
   APEX emits the files does not matter (APEX 24.2 puts the file URLs at the end of the body, and
   the Global Page's *Execute when Page Loads* is not applied to other pages). Values come from
   the host's own configuration — application substitution strings such as `HUB_APP_ID` keep
   the Hub application ID out of the page. `envCode` may be a function so the host can derive
   it from `location.hostname`. Never hardcode a Hub application ID in a shared artifact.
4. Add a **Feedback** entry to the navigation bar list (target `#`, icon `fa-comment-o`, *List
   Item CSS Classes* `afh-feedback-entry`) and set `buttonSelector: '.afh-feedback-entry a'`;
   the Universal Theme navigation-bar template has no slot for an element ID. Any element that
   matches `buttonSelector` (default `#afh-feedback`) works. If nothing matches the adapter
   creates a floating button (`createButton: true`).
5. **Signed-envelope mode only:** install `afh_host_pkg` in the host schema, run
   `grant_host_schema.sql`, and add two Global Page AJAX callbacks: `AFH_LAUNCH_TOKEN`
   (calls `afh_host_pkg.get_launch_token`) and `AFH_SERVER_ITEMS` (calls
   `afh_host_pkg.server_items_json`). Set `mode: 'SIGNED_ENVELOPE'`.
6. On the Hub side, Page 20 must allow framing (*Security → Browser → Embed in Frames* =
   **Allow from same origin**) and the host and Hub must share an origin.

The adapter is a no-op until `AFH.init` is called. A Hub outage shows a safe message inside the
overlay; the host page is never affected. `AFH.status()` returns `{initialized, lastResult}` for
the Integration Health page.

## `AFH.init(cfg)` reference

| Option | Default | Meaning |
|---|---|---|
| `hubAppId` | — (required) | Hub application ID the iframe URL points at |
| `appKey` | — (required) | Host application key as registered in the Hub |
| `envCode` | `null` | Environment code (`'DEV'`, `'TEST'`, …) or a function returning one |
| `mode` | `'SHARED_SESSION'` | `'SHARED_SESSION'` (same workspace) or `'SIGNED_ENVELOPE'` (token) |
| `adapterVersion` | `'1.0.0'` | Reported to the Hub for compatibility checks |
| `screenshot` | `true` | Set `false` to send `{result:'DENIED'}` instead of an html2canvas capture |
| `buttonSelector` | `'#afh-feedback'` | Element the adapter binds the click handler to |
| `createButton` | `true` | Create a floating `.afh-launcher` when the selector matches nothing |
| `tokenProcess` | `'AFH_LAUNCH_TOKEN'` | Host AJAX callback name (signed mode) |
| `serverItemsProcess` | `'AFH_SERVER_ITEMS'` | Host AJAX callback name (signed mode) |
| `hubBaseUrl` | `null` | Override the ORDS base path (defaults to the host's own `/ords/…/` path) |
| `dialogWidth` | `'min(1100px, 96vw)'` | CSS width of the overlay dialog |
| `labels` | `{button:'Feedback', title:'Send feedback', close:'Close'}` | UI strings |

Public API: `AFH.init(cfg)`, `AFH.open(triggerEl)`, `AFH.close()`, `AFH.status()`, `AFH.version`.
A `afh:created` DOM `CustomEvent` (`detail: {ticketNo, ticketUrl}`) fires on `document` when a
ticket is created.
