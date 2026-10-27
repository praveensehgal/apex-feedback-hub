# Installing APEX Feedback Hub

For the database administrator and APEX workspace administrator of a customer instance. One
installation serves every host application in that instance. Development, test and production are
three installations, each following this document.

| | |
|---|---|
| Requires | Oracle Database 19c or later, Oracle APEX 24.2 or later, HTTPS in front of ORDS |
| You need | a DBA session (SYSDBA or equivalent), a workspace administrator sign-in, SQLcl or SQL*Plus |
| Time | about 30 minutes per environment, plus the host application wiring |
| Rollback | §8. Nothing in this procedure touches the host application's schema. |

The bundle layout this document refers to:

```
database/            ordered installer, uninstall, upgrades
apex/application/    the Hub application export (split, install.sql at the top)
integration/host-adapter/   files the host application installs
docs/                this file, CONFIGURATION.md, UPGRADE-AND-ROLLBACK.md
licenses/            third-party browser libraries and their licenses
MANIFEST.sha256      checksums of every file in the bundle
```

Verify the bundle before anything else: `shasum -a 256 -c MANIFEST.sha256` must report every file `OK`.

---

## 1. Decide the identity mode

The Hub never authenticates users itself. It trusts the identity the host application already
established, in one of two ways:

| Mode | When | What it needs |
|---|---|---|
| **Shared session** (default) | Host application and Hub are in the **same APEX workspace** | The Hub's authentication scheme must use the same session cookie name as the host's, so the host session is valid in the Hub. Nothing else. |
| **Signed envelope** | Different workspaces or different APEX instances | A PL/SQL package in the host schema signs a short-lived launch token with a shared secret. See `integration/host-adapter/README.md`. |

For a first installation next to an existing application, use shared session: import the Hub into
the workspace that owns the host application and give that workspace the Hub schema. Everything
below assumes this. Signed envelope adds two files and a shared secret; it does not change the
database or application installation.

## 2. Database prerequisites (DBA)

Create the product schema. The name `AFH` is assumed throughout; if your standards require another
name, use it consistently and note that the uninstall and demo scripts reference `AFH`.

```sql
CREATE USER afh IDENTIFIED BY "<strong password>"
  DEFAULT TABLESPACE <data tablespace> TEMPORARY TABLESPACE temp
  QUOTA UNLIMITED ON <data tablespace>;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE PROCEDURE,
      CREATE TRIGGER, CREATE JOB, CREATE TYPE, CREATE SYNONYM TO afh;
GRANT EXECUTE ON sys.dbms_crypto TO afh;
```

No DBA role and no `APEX_ADMINISTRATOR_ROLE`. `UTL_MATCH`, `DBMS_SCHEDULER`, `DBMS_LOB` and the
`APEX_*` packages are PUBLIC-executable and need no grant. If outbound mail will be used, the
schema also needs a network ACL for the SMTP host (§6), exactly as any APEX application that calls
`APEX_MAIL` does.

Then, as a workspace administrator, add `AFH` to the workspace that owns the host application
(Administration → Manage Workspace → Manage Workspace Schema Assignments, or
`apex_instance_admin.add_schema`). The Hub is imported with `AFH` as its parsing schema.

## 3. Install the database layer

Run as `AFH`, from the `database/install` directory, with SQLcl or SQL*Plus:

```
cd database/install
sql afh/"<password>"@//<host>:<port>/<service> @install.sql
```

The installer:

- checks database and APEX versions and the `DBMS_CRYPTO` grant, and refuses to continue on a
  schema that holds a *different* installed version (`AFH-INS-005`; use `database/upgrades`);
- creates every `AFH_` object in dependency order, each step guarded so a re-run is safe;
- creates six scheduler jobs **disabled** (§6 enables the ones you want);
- seeds configuration, taxonomy, workflow, templates, navigation and theme tokens, never
  overwriting a value you have already changed;
- ends with `==== install complete` after a verification block that lists object counts.

Expected result: `install complete`, no `ORA-` lines, and

```sql
SELECT COUNT(*) FROM user_objects
 WHERE status = 'INVALID' AND object_name NOT LIKE 'AFH\_TEST\_%' ESCAPE '\';
```

returns `0`. The `AFH_TEST_*` packages are the product's own test harness; their bodies are invalid
at rest on purpose (the test-only code path is compiled out) and are never executed on a customer
installation.

## 4. Import the application

1. In the target workspace, App Builder → Import → `apex/application/install.sql` (upload the
   whole `apex/application` folder zipped, or run `install.sql` with SQLcl connected as `AFH`
   from inside that folder).
2. Install options:
   - **Parsing schema**: `AFH`
   - **Application ID**: a new ID that is free in **every** environment you will install (the
     same ID in DEV, TEST and PROD keeps host configuration identical across tiers). Write it down.
   - **Build option `AI_PREVIEW`**: leave at *Exclude*. It gates a demonstration region that is
     not part of this release.
3. After the import the application is `AVAILABLE` with **Oracle APEX Accounts** as its current
   authentication scheme and the secure-cookie flag on. That scheme is only there so the import is
   complete; §5 replaces it.

The export carries no workspace credentials and no client secret of any kind.

## 5. Attach the host's authentication (shared session)

1. Shared Components → Authentication Schemes → *Create* → *As a copy of an existing scheme* and
   copy the host application's scheme (or create the same type with the same settings). The
   essentials:
   - **Session cookie name** identical to the host application's (Authentication Scheme →
     Session Cookie Attributes). Without this the host session is not accepted and the Hub shows
     its own sign-in page inside the overlay.
   - **Secure** cookie on; the instance is HTTPS.
2. Make the new scheme **Current**. Leave *Oracle APEX Accounts* in place as a lockout fallback.
3. Keep the application process `AFH_AFTER_AUTH` as it is. It is scheme-agnostic: it records the
   authenticated subject (`APP_USER`), a display name and an e-mail when the subject looks like
   one, and stores NULL e-mail for opaque subjects (certificate UPNs, SAML NameIDs).
4. Test: sign in to the host application, then open `f?p=<HUB_APP_ID>:1:&SESSION.` in the same
   browser. You should land on the Hub home page signed in as the same user, with no second prompt.

If your host application uses a scheme with a *post-authentication* procedure that reads host
tables, make sure that procedure tolerates being called from the Hub's parsing schema, or point the
copied scheme at a Hub-side wrapper.

## 6. Configure

All installation settings live in one table, `AFH_INSTALL_CONFIG`, editable from
Administration → Configuration (page 60) once an administrator exists, or by SQL as `AFH`.
`docs/CONFIGURATION.md` lists every key. The ones that must be set on day one:

| Key | Set to |
|---|---|
| `FEEDBACK_APP_ID` | the application ID chosen in §4 |
| `BASE_URL` | the bare ORDS root, e.g. `https://apex.example.gov/ords` (no `/r/…`; links are generated as `f?p=`) |
| `PRODUCT_NAME`, `BRAND_LOGO_URL`, `BRAND_PRIMARY_COLOR`, `BRAND_ACCENT_COLOR` | your branding, or leave the defaults |
| `FALLBACK_OWNER_SUBJECT` | the `APP_USER` value of the person who receives tickets no rule or owner claims |
| `MAIL_ENABLED`, `MAIL_FROM` | `Y` and a sender address only once instance mail works (below); `N` keeps in-app notifications only |
| `ATTACH_ALLOWED_EXT`, `ATTACH_MAX_FILE_BYTES`, `ATTACH_MAX_TICKET_BYTES` | your attachment policy; defaults are 25 MB per file, 100 MB per ticket, images, PDF, text, CSV, XLSX, DOCX |

```sql
UPDATE afh_install_config SET config_value = '<value>' WHERE config_key = '<KEY>';
COMMIT;
```

**First administrator.** Nobody can open Users and Roles until someone holds `AFH_ADMIN`. Grant
it once by SQL, using the exact `APP_USER` value the host shows for that person:

```sql
DECLARE
  l_user_id NUMBER;
BEGIN
  l_user_id := afh_security_pkg.ensure_user(p_subject => '<APP_USER value>',
                                            p_display_name => '<Name>', p_email => '<address or NULL>');
  afh_security_pkg.grant_role(p_user_id => l_user_id, p_role_code => 'AFH_ADMIN');
  COMMIT;
END;
/
```

**Scheduler jobs.** All six are created disabled. Enable per environment:

| Job | Enable when | Default schedule |
|---|---|---|
| `AFH_JOB_HANDOFF_PURGE` | always | hourly; removes expired launch handoffs |
| `AFH_JOB_AUTO_CLOSE` | always | daily 01:00; closes resolved tickets after `AUTO_CLOSE_DAYS` |
| `AFH_JOB_MAIL_WORKER` | `MAIL_ENABLED = Y` | every 2 minutes; no-op while mail is off |
| `AFH_JOB_DAILY_DIGEST`, `AFH_JOB_WEEKLY_DIGEST` | `MAIL_ENABLED = Y` | daily 06:00, Monday 06:00 |
| `AFH_JOB_RETENTION` | after the retention policy is agreed | daily 02:00; **previews only** until `RETENTION_JOB_ARMED = Y` |

```sql
BEGIN
  DBMS_SCHEDULER.enable('AFH_JOB_HANDOFF_PURGE');
  DBMS_SCHEDULER.enable('AFH_JOB_AUTO_CLOSE');
END;
/
```

**Mail.** The Hub sends through `APEX_MAIL`, so instance mail must already be configured
(Manage Instance → Instance Settings → Email) and the `AFH` schema must be allowed to reach the
SMTP host by network ACL. Until then leave `MAIL_ENABLED = N`; every notification still appears in
the user's in-app inbox and nothing is lost.

## 7. Register the host application and wire it up

Hub side, as an administrator:

1. **Applications and Environments** (page 61) → *Register Application*. App key: a stable
   uppercase code the host will send (for example `FINANCE`); host APEX application ID; owner;
   identity mode *Shared session*.
2. Add one **environment** per installation (`DEV`, `TEST`, `PROD`) with its base URL pattern,
   e.g. `https://test.example.gov/%`. Launches from URLs outside the pattern are rejected.
3. **Routing and Ownership** (page 62): optional rules; unmatched tickets go to the application
   owner, then to `FALLBACK_OWNER_SUBJECT`.
4. **Users and Roles** (page 63): grant `DEVELOPER`, `TESTER`, `APP_OWNER` as needed.

Host side, in the host application (full detail in `integration/host-adapter/README.md`):

1. Upload `html2canvas-1.4.1.min.js`, `afh_adapter.js`, `afh_adapter.css` as application static
   files.
2. User Interface Attributes → JavaScript file URLs: html2canvas first, then the adapter; CSS file
   URL: the adapter stylesheet.
3. Three application substitution strings: `HUB_APP_ID`, `AFH_APP_KEY`, `AFH_ENV_CODE`. The Hub
   application ID is never typed into a page.
4. A Global Page (page 0) Static Content region, template *Blank with Attributes*, that publishes
   `window.AFH_CONFIG = { hubAppId: '&HUB_APP_ID.', appKey: '&AFH_APP_KEY.', envCode: '&AFH_ENV_CODE.',
   mode: 'SHARED_SESSION', adapterVersion: '1.0.0', createButton: false, buttonSelector: '.afh-feedback-entry a' };`
5. A navigation-bar entry *Feedback* with list item CSS class `afh-feedback-entry` and target `#`.

**Acceptance.** From a host page: press Feedback, the overlay opens signed in as the host user, the
screenshot is captured, submit a ticket with an annotation and an attachment. In the Hub: the ticket
shows the host page's items and the server-versus-browser diff; a plain submitter cannot open the
Developer Workbench or Administration; an administrator can. This is the identity handoff proof
(decision gate DG-01) and should be recorded for the environment.

## 8. Rollback

Order matters: remove the application before the schema objects so nothing references a missing
package.

1. Host application: remove the three static files, the two file URL entries, the page 0 region,
   the navigation entry and the three substitution strings. The host is back to its previous state.
2. App Builder → delete the Hub application.
3. As `AFH`, after exporting anything you want to keep (`expdp … schemas=AFH` keeps tickets,
   attachments and audit history):
   ```
   cd database/uninstall
   sql afh/"<password>"@//<host>:<port>/<service>
   DEFINE afh_confirm_uninstall = 'YES'
   @uninstall.sql
   ```
   `DEFINE afh_keep_data = 'YES'` drops code only and keeps the tables.
4. DBA: `DROP USER afh CASCADE` if the schema is no longer wanted.

Upgrades between product versions follow `docs/UPGRADE-AND-ROLLBACK.md`; this release (0.1.1) is a
first install and has no upgrade path yet. 0.1.1 replaces 0.1.0, which did not install on 19c
(ORA-00920 in `AFH_V_INTEGRATION_SUMMARY`); a partial 0.1.0 install is repaired by running the
0.1.1 `install.sql` over it.

## 9. What the bundle does not include

- Any customer-specific authentication scheme, credential or secret. §5 is yours.
- The product's test harness runner and fixtures, the development environment scripts, and the
  demonstration data scripts.
- A local Docker stack. The product is installed into your existing database and APEX instance.
