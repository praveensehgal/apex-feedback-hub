# Runbook: DEV to UAT

Use this after the AFH schema and the Hub application have been moved from DEV to UAT. The same
steps work for UAT to PROD; read "UAT" as the target tier.

It assumes shared session: the Hub and the host application sit in the same APEX workspace. If
your host uses signed envelope, steps 1 to 6 still apply and the secret handling is in
`integration/host-adapter/README.md`.

Run the SQL in SQL Workshop > SQL Commands inside the APEX builder, with `AFH` as the schema,
unless a step says otherwise. From SQLcl or any other client the APEX views only list applications
owned by `AFH`, so the host application seems to be missing, and the ORDS address comes back empty.
The exception is `install.sql` and `uninstall.sql` (step 8): SQL Workshop cannot run them, so use
SQLcl or SQL*Plus for those.

Do the steps in order. Users should not be let in until step 9 passes.

## Fill in first

| What | UAT value |
|---|---|
| Hub application ID in UAT | |
| Host application ID in UAT | |
| UAT ORDS root, e.g. `https://uat.example.gov/ords` | |
| Environment code the UAT host will send (`AFH_ENV_CODE`), e.g. `UAT` | |
| Sender address for UAT mail | |
| `APP_USER` of the person who will be the first UAT admin | |
| `APP_USER` of the person who gets tickets nobody else claims | |

## How did the schema get to UAT?

```sql
SELECT (SELECT COUNT(*) FROM afh_tickets) AS tickets,
       (SELECT COUNT(*) FROM afh_users)   AS users
  FROM dual;
```

- Both zero: the schema was installed fresh with `install.sql`. Skip step 8.
- Anything else: it is a copy of DEV (Data Pump or similar). DEV's settings, users, roles, tickets
  and job states came with it. Every step applies.

## 1. Database checks (DBA)

1. `AFH` is assigned to the UAT workspace:

   ```sql
   SELECT workspace_name, schema FROM apex_workspace_schemas WHERE schema = 'AFH';
   ```

   Expect one row naming the UAT workspace. If none, a workspace admin adds it under
   Administration > Manage Workspace > Manage Workspace Schema Assignments. If there are two,
   make sure you know which workspace the Hub and the host are in (next check). A stray
   assignment is harmless, but it makes it easy to work in the wrong workspace.

2. The Hub exists once, and it sits in the same workspace as the host:

   ```sql
   SELECT workspace, application_id, application_name, alias, owner
     FROM apex_applications
    ORDER BY workspace, application_id;
   ```

   Expect one application owned by `AFH` (the Hub) and the host, both in the same workspace.
   If the Hub is there twice, decide which ID is the UAT Hub, write it in the table above and
   remove the other one. Otherwise testers and mail links end up in different copies. If the
   Hub and host are in different workspaces, shared session will not work.

3. The `DBMS_CRYPTO` grant exists. A schema copy does not always bring grants made by SYS.

   ```sql
   SELECT privilege FROM user_tab_privs WHERE table_name = 'DBMS_CRYPTO';
   ```

   Expect `EXECUTE`. If no row, the DBA runs `GRANT EXECUTE ON sys.dbms_crypto TO afh;` and then,
   as `AFH`:

   ```sql
   BEGIN DBMS_UTILITY.compile_schema(schema => 'AFH', compile_all => FALSE); END;
   /
   ```

4. No invalid product objects:

   ```sql
   SELECT object_type, object_name FROM user_objects
    WHERE status = 'INVALID'
      AND NOT (object_type IN ('PACKAGE','PACKAGE BODY')
               AND object_name LIKE 'AFH\_TEST\_%' ESCAPE '\')
    ORDER BY object_type, object_name;
   ```

   Expect no rows. If DEV had the test packages (`AFH_TEST_*_PKG`), they came across too. They
   are invalid on purpose and are never run. `AFH_TEST_RESULTS` and its trigger are part of
   the product and are not excluded.

## 2. Sign-in scheme (APEX developer)

Check which scheme is current in the Hub: Shared Components > Authentication Schemes.
Depending on how the application was exported and imported, it is either the host's scheme
(carried over from DEV) or *Oracle APEX Accounts*.

- If the current scheme is the same as the UAT host's (same type, same settings), go to item 2
  and check the cookie.
- If it is Oracle APEX Accounts, or a scheme that only fits DEV, replace it:

1. In the Hub application, Shared Components > Authentication Schemes > Create > As a copy of an
   existing scheme. Copy the UAT host application's scheme.
2. Session cookie name: exactly the same as the UAT host's. If the host leaves it empty (the
   default), leave the Hub's empty too. Secure cookie: on.
3. Make the new scheme Current. Leave Oracle APEX Accounts in the list as a fallback.
4. Leave the application process `AFH_AFTER_AUTH` alone.
5. Test: sign in to the UAT host, then open `f?p=<hub app id>:1:&SESSION.` in the same browser.
   Expect the Hub home page with no second login.

If you get the Hub's own login page, the cookie names don't match.

## 3. Settings

Replace each `<...>` and run the whole block. Leave mail off for now; step 7 turns it on.

```sql
UPDATE afh_install_config SET config_value = '<hub app id>'
 WHERE config_key = 'FEEDBACK_APP_ID';
UPDATE afh_install_config SET config_value = '<uat ords root>'
 WHERE config_key = 'BASE_URL';
UPDATE afh_install_config SET config_value = '<uat sender address>'
 WHERE config_key = 'MAIL_FROM';
UPDATE afh_install_config SET config_value = '<fallback APP_USER>'
 WHERE config_key = 'FALLBACK_OWNER_SUBJECT';
UPDATE afh_install_config SET config_value = 'N'
 WHERE config_key = 'MAIL_ENABLED';
UPDATE afh_install_config SET config_value = 'N'
 WHERE config_key = 'ACT_AS_ENABLED';
UPDATE afh_install_config SET config_value = 'N'
 WHERE config_key = 'RETENTION_JOB_ARMED';
COMMIT;
```

`BASE_URL` is the bare ORDS root, with no `/r/...` on the end. A trailing `/` does no harm; it is
removed when mail links are built.

Check:

```sql
SELECT config_key, config_value FROM afh_install_config
 WHERE config_key IN ('FEEDBACK_APP_ID','BASE_URL','MAIL_FROM','FALLBACK_OWNER_SUBJECT',
                      'MAIL_ENABLED','ACT_AS_ENABLED','RETENTION_JOB_ARMED')
 ORDER BY config_key;
```

Branding, attachment limits and the rest are on Administration > Configuration (page 60) and
usually don't change between tiers. `docs/CONFIGURATION.md` lists every key.

## 4. Scheduler jobs

A copy brings each job over in whatever state it had in DEV. Look first:

```sql
SELECT job_name, enabled, state FROM user_scheduler_jobs ORDER BY job_name;
```

Set them for UAT with mail still off:

```sql
BEGIN
  DBMS_SCHEDULER.enable('AFH_JOB_HANDOFF_PURGE');
  DBMS_SCHEDULER.enable('AFH_JOB_AUTO_CLOSE');
  DBMS_SCHEDULER.disable('AFH_JOB_MAIL_WORKER');
  DBMS_SCHEDULER.disable('AFH_JOB_DAILY_DIGEST');
  DBMS_SCHEDULER.disable('AFH_JOB_WEEKLY_DIGEST');
  DBMS_SCHEDULER.disable('AFH_JOB_RETENTION');
END;
/
```

Run the first query again. Expect `TRUE` for the purge and auto-close jobs and `FALSE` for the
other four.

## 5. Administrators

Fresh install: create the first admin with the exact `APP_USER` the UAT host shows for that person.

```sql
BEGIN
  afh_security_pkg.bootstrap_admin(
    p_subject      => '<admin APP_USER>',
    p_display_name => '<Name>');
  COMMIT;
END;
/
```

Copy of DEV: see who holds roles now.

```sql
SELECT u.subject_display, u.display_name, u.is_active, r.role_code
  FROM afh_users u
  JOIN afh_user_roles r ON r.user_id = u.user_id
 WHERE r.expiration_date IS NULL OR r.expiration_date > SYSTIMESTAMP
 ORDER BY r.role_code, u.subject_display;
```

If at least one `AFH_ADMIN` on that list can sign in to UAT, that person removes the DEV-only
grants and accounts on Users and Roles (page 63) and grants the UAT ones.

If none of them can sign in to UAT, `bootstrap_admin` will refuse with `AFH-AUTH-002` because DEV's
admins still count. End their admin grants (the rows stay, for history), then bootstrap:

```sql
UPDATE afh_user_roles SET expiration_date = SYSTIMESTAMP
 WHERE role_code = 'AFH_ADMIN'
   AND (expiration_date IS NULL OR expiration_date > SYSTIMESTAMP);

BEGIN
  afh_security_pkg.bootstrap_admin(
    p_subject      => '<admin APP_USER>',
    p_display_name => '<Name>');
END;
/
COMMIT;
```

Either way, the new admin signs out of the Hub and back in before the role shows. Role checks are
cached per session.

E-mail addresses copied from DEV stay as they are. Fix any that are wrong on page 63.

## 6. Register UAT (Hub admin)

On Applications and Environments (page 61):

1. If the host has a different application ID in UAT, edit the application (pencil icon) and set
   APEX application ID to the UAT host's ID. Save.
2. Add Environment. Application: the host. Environment code: the value the UAT host will send in
   `AFH_ENV_CODE`. Label: e.g. `User acceptance`. Save.
3. Base URL pattern: leave it empty unless one Hub serves several tiers. If DEV had one set, set
   UAT's to match the address users actually type, e.g. `https://uat.example.gov/%`, or clear it.
   A wrong pattern refuses every launch with `AFH-CTX-001`.

Check:

```sql
SELECT a.app_key, a.apex_app_id, e.env_code, e.base_url_pattern, e.is_active
  FROM afh_applications a
  JOIN afh_environments e ON e.application_id = a.application_id
 ORDER BY a.app_key, e.display_seq;
```

## 7. UAT host application (APEX developer)

1. Shared Components > Application Definition > Substitutions:
   - `HUB_APP_ID` = Hub application ID in UAT
   - `AFH_APP_KEY` = unchanged from DEV
   - `AFH_ENV_CODE` = the environment code from step 6
2. Static application files include `html2canvas-1.4.1.min.js`, `afh_adapter.js` and
   `afh_adapter.css`, and User Interface > JavaScript/CSS file URLs still point at them. They come
   over with the host export, but check.
3. The page 0 region that sets `window.AFH_CONFIG` and the *Feedback* navigation entry are
   present.

## 8. DEV data (copy only)

Decide whether UAT keeps DEV's tickets.

- Keep them: nothing to do. Testers will see them in lists and searches.
- Start clean: don't delete rows by hand. The audit history is append-only and a partial delete
  leaves it pointing at nothing. Instead, take an export of the schema first if anyone might
  want DEV's tickets back, then start SQLcl or SQL*Plus in the release's `database/install`
  folder, connect as `AFH`, and run:

  ```sql
  DEFINE afh_confirm_uninstall = 'YES'
  DEFINE afh_keep_data = 'NO'
  @../uninstall/uninstall.sql
  @install.sql
  ```

  The uninstall drops every `AFH_` object in the schema: jobs, packages (test packages
  included), views, tables and sequences. Its last query should show no rows. Any line starting
  `FAILED` names an object it could not drop; drop that by hand before installing. The install
  checks the `DBMS_CRYPTO` grant again and ends with a verify step that should report no invalid
  objects. The applications, the workspace and step 2 are not touched.

  After a reinstall everything the schema held is back to the shipped defaults. That means all
  of the settings, the registered applications and environments, routing rules, users, roles and
  e-mail addresses, and any template edits. Redo, in this order:

  - Step 3 settings, and anything on page 60 that DEV had changed (product name, logo,
    templates).
  - Step 4 jobs. The install creates them in their default state.
  - Step 5 as a fresh install. There is no administrator, so run `bootstrap_admin`.
  - Step 6 in full. Register the host application itself (Register Application on page 61), then
    its UAT environment. Add routing rules again if DEV had any.
  - Steps 7 to 10 as written.

## 9. Acceptance

1. Sign in to the UAT host as an ordinary user. Press Feedback.
2. The panel opens signed in as that user and takes a screenshot.
3. Add an annotation and an attachment. Submit. Note the ticket number.
4. In the Hub, open the ticket. Environment shows the UAT code. The host page items are there.
5. As that ordinary user, Administration and the Developer Workbench are not offered.
6. As the UAT admin, Administration opens.
7. Integration Health (page 67) shows no refused launches for the test.

## 10. Mail (when UAT is allowed to send)

Needs instance mail set up (Manage Instance > Instance Settings > Email) and a network ACL letting
`APEX_240200` reach the SMTP host. If any other app on the instance already sends mail, both exist.

```sql
UPDATE afh_install_config SET config_value = 'Y'
 WHERE config_key = 'MAIL_ENABLED';
COMMIT;

BEGIN
  DBMS_SCHEDULER.enable('AFH_JOB_MAIL_WORKER');
  DBMS_SCHEDULER.enable('AFH_JOB_DAILY_DIGEST');
  DBMS_SCHEDULER.enable('AFH_JOB_WEEKLY_DIGEST');
END;
/
```

Test by assigning the step 9 ticket to someone with an e-mail address on page 63. Within a few
minutes:

```sql
SELECT channel_code, state_code, COUNT(*)
  FROM afh_notifications GROUP BY channel_code, state_code;
```

Expect `EMAIL` rows moving from `QUEUED` to `SENT`. `FAILED` means delivery gave up after the
retries; the reason shows on Integration Health. Rows marked `SKIPPED_DISABLED` were written while
mail was off and are not resent.

## Sign-off

| Step | Done by | Date | Notes |
|---|---|---|---|
| 1 Database checks | | | |
| 2 Sign-in scheme | | | |
| 3 Settings | | | |
| 4 Scheduler jobs | | | |
| 5 Administrators | | | |
| 6 Register UAT | | | |
| 7 Host application | | | |
| 8 DEV data | | | |
| 9 Acceptance | | | |
| 10 Mail | | | |
