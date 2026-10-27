# Configuration reference

Every installation-wide setting is a row in `AFH_INSTALL_CONFIG`, keyed by `config_key`. The
installer seeds each key with its default and **never overwrites a value you have changed**, so
settings survive re-runs and upgrades. Edit them from Administration → Configuration (page 60) as
an `AFH_ADMIN`, or by SQL connected as the product schema:

```sql
UPDATE afh_install_config SET config_value = '<value>' WHERE config_key = '<KEY>';
COMMIT;
```

Keys marked *installer* are maintained by the install and upgrade scripts and are not editable from
the UI. Keys marked *per tier* normally differ between DEV, TEST and PROD. Types: `TEXT`, `NUMBER`,
`YN` (`Y`/`N`), `URL`, `COLOR` (hex), `LIST` (comma-separated).

## Product and branding

| Key | Type | Default | Meaning |
|---|---|---|---|
| `PRODUCT_NAME` | TEXT | `APEX Feedback Hub` | Name shown in the header, page titles and mail subjects |
| `PRODUCT_VERSION` | TEXT | `0.1.1` | Installed product version. *Installer.* The pre-flight check compares it with the bundle version |
| `BRAND_LOGO_URL` | URL | *(blank)* | Logo URL (a workspace or application static file). Blank shows the product default |
| `BRAND_PRIMARY_COLOR` | COLOR | `#165F59` | Primary brand color |
| `BRAND_ACCENT_COLOR` | COLOR | `#1F756C` | Accent brand color |

## Installation identity

| Key | Type | Default | Meaning |
|---|---|---|---|
| `FEEDBACK_APP_ID` | NUMBER | *(blank)* | APEX application ID of the Hub, assigned at import. **Required.** *Per tier* if the IDs differ |
| `BASE_URL` | URL | *(blank)* | Absolute ORDS root used in mail links, e.g. `https://apex.example.gov/ords`. No `/r/…` suffix: links are built as `BASE_URL/f?p=…`. **Required for mail.** *Per tier* |
| `FALLBACK_OWNER_SUBJECT` | TEXT | *(blank)* | `APP_USER` value of the person who receives tickets no routing rule or application owner claims |
| `IDENTITY_DEFAULT_MODE` | TEXT | `SHARED_SESSION` | Identity mode pre-selected when registering a new host application: `SHARED_SESSION` or `SIGNED_ENVELOPE` |
| `LICENSE_KEY` | TEXT | *(blank)* | License key. Stored as a secret; validated by a future release and ignored today |

## Host integration contract

| Key | Type | Default | Meaning |
|---|---|---|---|
| `MIN_ADAPTER_VERSION` | TEXT | `1.0.0` | Lowest host adapter version the Hub accepts; older adapters are rejected at launch and reported on Integration Health |
| `CONTRACT_VERSION` | TEXT | `1.0` | Launch envelope contract version implemented by this release. *Installer* |
| `HANDOFF_TTL_SECONDS` | NUMBER | `120` | Seconds a launch handoff stays valid. Replays are rejected regardless |
| `CAPTURE_MAX_PAYLOAD_BYTES` | NUMBER | `1048576` | Largest diagnostic capture (page items, client facts, console) accepted from the adapter, in bytes |

## Lifecycle

| Key | Type | Default | Meaning |
|---|---|---|---|
| `AUTO_CLOSE_DAYS` | NUMBER | `14` | Days a resolved ticket waits without activity before `AFH_JOB_AUTO_CLOSE` closes it |
| `ARCHIVE_AFTER_DAYS` | NUMBER | `90` | Days after closure before a ticket is archived |
| `DEFAULT_RETENTION_DAYS` | NUMBER | `365` | Days a closed ticket is retained before the retention job may purge it |
| `RETENTION_JOB_ARMED` | YN | `N` | `AFH_JOB_RETENTION` deletes only while `Y`; otherwise every run is a preview written to the retention log |

## Duplicate detection

Scores are summed per candidate ticket; a candidate at or above `DUP_THRESHOLD` is suggested.

| Key | Type | Default | Meaning |
|---|---|---|---|
| `DUP_W_TITLE` | NUMBER | `55` | Weight of title similarity |
| `DUP_W_DESC` | NUMBER | `20` | Weight of description similarity |
| `DUP_W_APP` | NUMBER | `15` | Same host application |
| `DUP_W_PAGE` | NUMBER | `5` | Same host page |
| `DUP_W_TYPE` | NUMBER | `5` | Same feedback type |
| `DUP_THRESHOLD` | NUMBER | `65` | Minimum score to be suggested as a duplicate |
| `DUP_MAX` | NUMBER | `5` | Maximum candidates shown |

## Collaboration

| Key | Type | Default | Meaning |
|---|---|---|---|
| `COMMENT_EDIT_WINDOW_MIN` | NUMBER | `15` | Minutes during which an author may edit their own public comment |

## Mail and notifications

In-app notifications are always on. Mail is an additional channel through `APEX_MAIL`, so instance
mail and a network ACL for the product schema must exist before `MAIL_ENABLED` is set to `Y`.

| Key | Type | Default | Meaning |
|---|---|---|---|
| `MAIL_ENABLED` | YN | `N` | Send e-mail notifications. `N` queues nothing; the mail worker job is a no-op |
| `MAIL_FROM` | TEXT | *(blank)* | From address for outbound mail. **Required when mail is on.** *Per tier* |
| `MAIL_MAX_RETRIES` | NUMBER | `3` | Delivery attempts before a mail is marked permanently failed (visible on Integration Health) |
| `DIGEST_DAILY_HOUR` | NUMBER | `6` | Hour of day (0–23, database time) the daily digest is composed |
| `DEFAULT_NOTIFY_PRESET` | TEXT | `IMPORTANT` | Notification preset for users who have not chosen one |

## Attachments

| Key | Type | Default | Meaning |
|---|---|---|---|
| `ATTACH_ALLOWED_EXT` | LIST | `PNG,JPG,JPEG,PDF,TXT,CSV,XLSX,DOCX` | Accepted upload extensions. Executable and markup types are refused regardless of this list, and nothing uploaded is ever rendered inline |
| `ATTACH_MAX_FILE_BYTES` | NUMBER | `26214400` | Largest single attachment (25 MB) |
| `ATTACH_MAX_TICKET_BYTES` | NUMBER | `104857600` | Largest total attachment size per ticket (100 MB) |

## Development aids

| Key | Type | Default | Meaning |
|---|---|---|---|
| `ACT_AS_ENABLED` | YN | `N` | Lets any signed-in user act as another user from the navigation bar. **Development only. Must stay `N` on a customer installation.** Not editable from the UI; a development instance flips it by SQL |

## Scheduler jobs

Not configuration rows, but set per installation. All are created **disabled** by the installer.

| Job | Schedule | Action |
|---|---|---|
| `AFH_JOB_HANDOFF_PURGE` | hourly | Removes expired launch handoffs |
| `AFH_JOB_AUTO_CLOSE` | daily 01:00 | Closes resolved tickets older than `AUTO_CLOSE_DAYS` |
| `AFH_JOB_MAIL_WORKER` | every 2 minutes | Sends queued mail; no-op while `MAIL_ENABLED = N` |
| `AFH_JOB_DAILY_DIGEST` | daily 06:00 | Daily digest mail |
| `AFH_JOB_WEEKLY_DIGEST` | Monday 06:00 | Weekly digest mail |
| `AFH_JOB_RETENTION` | daily 02:00 | Retention run; preview unless `RETENTION_JOB_ARMED = Y` |

```sql
BEGIN DBMS_SCHEDULER.enable('AFH_JOB_HANDOFF_PURGE'); END;
/
```
