# APEX Feedback Hub: FAQ for IT

For the DBAs, APEX developers and administrators who install, run and support the Feedback Hub.
It assumes you know Oracle APEX and have not seen this product before. It describes product
version **0.1.1**, application **Release 1.0.60**. The step-by-step procedures are in
`INSTALL.md`, every setting is in `CONFIGURATION.md`, and upgrades are in `UPGRADE-AND-ROLLBACK.md`.
This FAQ explains how the parts fit together and answers the questions those documents don't.

Page numbers below are pages of the Hub application. *Admin* means a user who holds the
`AFH_ADMIN` role. The same text is in the Hub itself, under **Administration > FAQ for IT**
(page 68), for application owners and admins.

---

## 1. The product in brief

### What is the Feedback Hub?

An Oracle APEX application for collecting feedback and managing tickets. Users press **Feedback**
on any page of an integrated APEX application (the *host application*). The Hub opens in an
overlay on top of that page, captures what the user was looking at, and files a ticket.
Developers then triage, discuss, fix, test and close the ticket in the Hub. Every step is recorded.

### What does it capture that a generic bug tracker can't?

It runs inside APEX, so the ticket records:

- the application, page, environment and adapter version, taken from a trusted launch rather
  than a URL anyone could edit;
- every page item's name, type and value, both what the browser shows and what the server holds
  in session state, so a developer can see the user's unsaved changes;
- a screenshot of the page, which the user can annotate (arrows, boxes, freehand, blur, text);
- browser, viewport, locale, time zone and APEX version.

Passwords, tokens, cookies and anything that looks like a credential are never captured. See
section 3.

### Who uses which part?

| Who | Uses |
|---|---|
| Anyone signed in to a host application | Feedback button, My Work, All Feedback, ticket pages, notifications |
| Testers | The above, plus test requests and recording test results |
| Developers | The above, plus Developer Workbench (queue, board, bulk actions, workload) and Releases |
| Application owners | The above, plus routing rules and releases for their applications |
| Admins | Everything, including Administration (pages 60 to 67) |

### What gets installed?

| Part | Where | What it is |
|---|---|---|
| Database layer | One schema (`AFH` by default) | 37 tables, 46 views, 24 PL/SQL packages, 6 scheduler jobs |
| Hub application | The APEX workspace that owns your host applications | One application, 33 pages, imported with `AFH` as its parsing schema |
| Host adapter | Each host application | Two JavaScript files and one CSS file as static files, one Global Page region, one navigation entry |

Business rules live in the packages. The pages only call package APIs and read `AFH_V_*` views.

### Does it need anything outside the database and APEX?

No. There is no separate web server, message queue, search engine, CDN or external AI
service. Mail goes through `APEX_MAIL`. Duplicate matching uses `UTL_MATCH`. The one
third-party browser library (html2canvas, for screenshots) ships as a static file with its
license.

### How many Hubs do we need?

One per APEX instance. A Hub serves every host application in the instance it is installed
in. If DEV, TEST and PROD are separate instances (the usual case), each gets its own Hub,
installed the same way. Use the same Hub application ID in all three so host settings match
across tiers. If one instance hosts several tiers, one Hub can serve them all: register each
environment against the application (section 5).

### What versions does it support?

Oracle Database 19c or later, and Oracle APEX 24.2 or later. All DDL and PL/SQL is written to
the 19c subset, and HTTPS in front of ORDS is required.

### What does it cost, and who owns the data?

The product is MIT-licensed. Releases are published at
https://github.com/praveensehgal/apex-feedback-hub. It is installed into your own database,
so tickets, attachments, users and mail delivery stay with you. There is no hosted service
and no telemetry. `LICENSE_KEY` exists only as a hook for a future release, and nothing checks
it today.

---

## 2. Installation, upgrades and versions

### What privileges does the install need?

A DBA creates the schema with `CREATE SESSION`, `TABLE`, `VIEW`, `SEQUENCE`, `PROCEDURE`,
`TRIGGER`, `JOB`, `TYPE` and `SYNONYM`, plus `EXECUTE ON sys.dbms_crypto`. It needs no DBA role
and no `APEX_ADMINISTRATOR_ROLE`. A workspace administrator then assigns the schema to the
workspace. Everything else runs as the product schema.

### How long does it take?

About 30 minutes per environment, plus wiring each host application (section 5).

### In what order do things happen?

1. Verify the bundle: `shasum -a 256 -c MANIFEST.sha256` must report every file `OK`.
2. Run `database/install/install.sql` as the product schema.
3. Import `apex/application/install.sql` into the workspace.
4. Attach your authentication scheme to the Hub (section 3).
5. Set the day-one configuration and create the first admin (section 4).
6. Enable the scheduler jobs you want (section 9).
7. Register each host application and install the adapter in it (section 5).

### Is the database install safe to re-run?

Yes. Every step checks before it creates or changes anything, and the seed never overwrites a
value you have changed. Re-running the same version is the normal way to repair a partial
install. The installer refuses a schema that holds a *different* product version
(`AFH-INS-005`); a different version goes through `database/upgrades`.

### How do I know the install worked?

The script ends with `install complete` and no `ORA-` lines, and this returns `0`:

```sql
SELECT COUNT(*) FROM user_objects
 WHERE status = 'INVALID' AND object_name NOT LIKE 'AFH\_TEST\_%' ESCAPE '\';
```

### Why are some `AFH_TEST_*` packages invalid?

That is intended. They are the product's own test harness. Their test-only code is compiled out
of a customer installation, so they stay invalid and nothing calls them. Leave them out of your
invalid-object checks, as the query above does.

### Why does every application import reset the sign-in?

The authentication scheme is part of the APEX application, so importing a new release with
*Replace* puts the bundle's placeholder scheme (Oracle APEX Accounts) back as current. Re-attach
your scheme and make it current after every import, before users return. Export your scheme
once (Shared Components, Authentication Schemes) so this takes two minutes. Everything else you
configure lives in the database and survives the import: applications, environments, routing
rules, users, roles, templates and tickets.

### What is the order for an upgrade?

Database first, then the application. A new application release may call package code the old
database layer doesn't have, but never the reverse. Schedule the application import when users
are off, because a full import ends every session of that application.

### There are two version numbers. What do they mean?

| Number | Example | Where to read it | Changes when |
|---|---|---|---|
| Product version | `0.1.1` | `AFH_INSTALL_CONFIG.PRODUCT_VERSION`, page 60 | the database layer changes |
| Application release | `Release 1.0.60` | `APEX_APPLICATIONS.VERSION`, or App Builder | anything in the APEX application changes |

A public release is tagged with both, for example `v0.1.1-r1.0.60`.

### How do I roll back?

- **Application import failed:** APEX rolls it back and the previous application is untouched.
- **New application misbehaves:** re-import the previous bundle over the same ID and re-attach
  your authentication scheme.
- **Remove the Hub completely:** delete the application first, then run
  `database/uninstall/uninstall.sql` with `DEFINE afh_confirm_uninstall = 'YES'`. Take
  `expdp ... schemas=AFH` first if you want to keep the tickets. `DEFINE afh_keep_data = 'YES'`
  drops the code and keeps the tables.

Nothing in the install or uninstall touches a host application's schema, except the optional
signed-envelope package (section 5).

### Do we need the Docker stack or the test scripts?

No. The bundle leaves out the development stack, the test harness runner and the demo data. The
Hub installs into your existing database and APEX instance.

---

## 3. Identity, sign-in and security

### Does the Hub have its own login?

No. The Hub trusts the identity the host application has already established. It never sees a
password. There are two ways to pass that identity:

| Mode | Use when | How it works |
|---|---|---|
| **Shared session** (default) | The Hub and the host are in the same APEX workspace | The Hub's authentication scheme uses the host's session cookie name, so the user's existing APEX session is valid in the Hub |
| **Signed envelope** | Different workspaces or instances | A PL/SQL package in the host schema signs a short-lived launch token (HMAC-SHA256) with a secret shared with the Hub |

### What exactly do I set up for shared session?

In the Hub application, copy the host's authentication scheme (or create the same type with the
same settings) and make it current. The setting that matters is **Session cookie name**, which
must be identical to the host's. Keep the secure-cookie flag on, and keep *Oracle APEX Accounts*
as a lockout fallback. Test it: sign in to the host, then open `f?p=<HUB_APP_ID>:1:&SESSION.` in
the same browser. You should be signed in with no second prompt.

### Who is the user, as far as the Hub is concerned?

The APEX `APP_USER` value, upper-cased and trimmed. The first time someone opens the Hub, a row
is created for them in `AFH_USERS`. The after-authentication process also records a display
name and an e-mail address when it can find one (section 7).

### Why did the Feedback panel say "temporarily unavailable" after someone signed in again?

In shared-session mode the host and the Hub use the same session cookie. If someone signs in to
the Hub separately (a different account, or `f?p=<HUB_APP_ID>` on its own in the same browser),
that overwrites the shared cookie and the host's session no longer matches. Sign in once on the
host and open the Hub from there.

### Can a user forge a launch to file a ticket as someone else, or for another application?

No. Each press of Feedback creates a launch *handoff* that:

- expires after 120 seconds (`HANDOFF_TTL_SECONDS`, capped at 120);
- can be used once (a replayed nonce is refused);
- in shared mode, must come from the same APEX session as the signed-in user;
- in signed mode, must carry a valid signature from the host's PL/SQL;
- must name a registered, active application and environment.

A refused launch shows one generic message (`AFH-CTX-001`) that doesn't reveal which check
failed. The reason is written to `AFH_INTEGRATION_EVENTS.SAFE_DETAIL` (for example `EXPIRED`,
`REPLAY`, `SESSION`, `URL_POLICY`) and shown on Integration Health (page 67).

### Who can see what?

Every signed-in user can find and read every ticket: its description, public comments and public
attachments. This is deliberate, to stop people reporting the same problem twice. Roles control
actions, not visibility.

The sensitive parts are restricted to developers, application owners and admins, and checked on
the server on every read:

- the raw diagnostic snapshot (page items, server values, client facts);
- internal notes;
- restricted attachments.

Opening a ticket's diagnostic context is itself written to the audit log.

### What is never captured?

Password fields, and any item whose name looks like a credential (`passw`, `pwd`, `token`,
`secret`, `cookie`, `authorization`, `apikey`, `credential`), are recorded as *EXCLUDED* with no
value. The adapter filters them in the browser and the database filters them again on the
server. Session cookies and authentication tokens are never collected, logged or audited.

### Are uploads safe?

- Only the extensions in `ATTACH_ALLOWED_EXT` are accepted (default: PNG, JPG, JPEG, PDF, TXT,
  CSV, XLSX, DOCX).
- HTML, SVG, scripts and executables are always refused, whatever that list says.
- Image and PDF types must have a MIME type that matches the extension.
- Each file gets a SHA-256 checksum.
- Downloads are sent as attachments. Only images and PDFs display inline, and uploaded HTML is
  never rendered.
- Size limits are 25 MB per file and 100 MB per ticket by default.

### Can a comment carry a script?

No. Comments are stored as plain text with a small markup (bold, italic, code, lists, links,
@mentions). The HTML is built from that text only after everything has been escaped, and there is
no way to submit HTML. Links allow only http, https and mailto.

### Is there an audit trail?

Yes. `AFH_AUDIT_EVENTS` is append-only: an update or delete raises `AFH-SYS-002`. It records
ticket creation, field changes, assignments, comments and comment edits, merges, tests, status
changes, archiving, deletions, configuration changes, template changes and role grants. Each
change writes its audit row in the same transaction as the change.

### What is "Act As"?

A development aid that lets any signed-in user act as another user from the navigation bar. It
is controlled by `ACT_AS_ENABLED`, which must stay `N` on every customer installation. The
installer seeds `N`, and the setting can't be changed from the UI.

---

## 4. Roles and user administration

### What roles are there?

Roles are cumulative. Each one includes everything below it:

`USER` < `TESTER` < `DEVELOPER` < `APP_OWNER` < `AFH_ADMIN`

| Role | Adds |
|---|---|
| `USER` (everyone) | Submit feedback, search and read tickets, comment, attach files, follow, "This affects me too", answer questions, reopen their own resolved report |
| `TESTER` | Record test results, pass or fail a fix |
| `DEVELOPER` | Triage, change official severity and priority, assign, move status, internal notes, root cause and resolution, merge duplicates, Developer Workbench, Releases |
| `APP_OWNER` | Routing rules, releases, and queue ownership for their applications |
| `AFH_ADMIN` | Administration: applications, environments, users and roles, taxonomy and workflow, templates, retention, configuration |

A grant can apply to one host application or to the whole installation. Grants can have
effective and expiry dates.

### Who needs to be set up before they can use it?

Only people who need more than `USER`. Anyone signed in through a host application is registered
on first use and can submit feedback straight away.

### How do I create the first admin?

Nobody can open Users and Roles until someone holds `AFH_ADMIN`, so the first grant is done by
SQL, connected as the product schema:

```sql
BEGIN
  afh_security_pkg.bootstrap_admin(p_subject => '<APP_USER value>', p_display_name => '<Name>');
  COMMIT;
END;
/
```

This works only while no active admin exists, and refuses afterwards (`AFH-AUTH-002`). Use the
exact `APP_USER` value the host shows for that person. After that, all grants are made on
Users and Roles (page 63).

### I granted a role and nothing changed. Why?

APEX caches authorization results for the session. The user needs to sign out of the Hub and back
in.

### Why isn't someone in the grant list?

The list shows only users who have opened the Hub at least once. Ask them to open it (pressing
Feedback is enough), then grant the role.

### How do I remove someone?

Deactivate the user on Users and Roles. A deactivated user is locked out, and their history and
tickets stay as they are. To take away only a role, end the grant or set an expiry date.

### Which pages does each role see?

| Pages | Who |
|---|---|
| 1 My Work, 2 All Feedback, 3 Application Health, 10 Ticket, 20 Submit, 50 Notifications, 51 Notification Preferences | Everyone |
| 30 Developer Workbench, 40 Releases | Developer and above |
| 60 Administration, 62 Routing and Ownership, 68 FAQ for IT | Application owner and admin |
| 61 Applications and Environments, 63 Users and Roles, 64 Taxonomy and Workflow, 65 Notification Templates, 66 Attachments and Retention, 67 Integration Health | Admin |

The navigation menu shows each user only the pages they can open. Page-level authorization is
the control, and hiding a menu entry is only a convenience.

---

## 5. Connecting a host application

### What changes in the host application?

No business logic changes. You add:

1. Three static files: `html2canvas-1.4.1.min.js`, `afh_adapter.js`, `afh_adapter.css`, with the
   two scripts listed in User Interface Attributes (html2canvas first) and the stylesheet in CSS
   File URLs.
2. Three application substitution strings: `HUB_APP_ID`, `AFH_APP_KEY`, `AFH_ENV_CODE`.
3. A Global Page region (template *Blank with Attributes*) that publishes `window.AFH_CONFIG`
   from those strings. The full snippet is in `INSTALL.md` section 7.
4. A **Feedback** entry in the navigation bar, with list item CSS class `afh-feedback-entry`.

Signed-envelope mode also installs `afh_host_pkg` in the host schema and adds two Global Page
AJAX callbacks.

### What do I register on the Hub side?

On Applications and Environments (page 61):

- **Application:** a stable upper-case *app key* (the value of `AFH_APP_KEY`), the host's APEX
  application ID, an owner, and the identity mode. In signed mode the Hub shows the shared
  secret **once**. Put it in the host's secret store.
- **Environment:** one per tier the application reports from (`DEV`, `TEST`, `PROD`, and so on).
  The code must equal the host's `AFH_ENV_CODE`. This code appears on every ticket and in every
  e-mail.

### What is the environment's base URL pattern for?

It is optional, and it guards against misconfiguration rather than attack. Set it (for example
`https://test.example.com/%`) only when one Hub serves several tiers and you want a host that was
copied with the wrong `AFH_ENV_CODE` to be refused instead of filed under the wrong environment.
It must match the address users actually type, including port and path. A mismatch shows users
`AFH-CTX-001`, with `URL_POLICY` recorded on Integration Health.

### Does the Feedback button affect the host page?

No. The Hub opens in an iframe overlay, so the host page doesn't navigate and the user's unsaved
work stays in place. If the Hub is down, the overlay shows a safe message and the host page
carries on. Without `AFH.init` the adapter does nothing at all.

### Why does the Hub have to allow framing?

The overlay loads Hub page 20 in an iframe. The Hub application allows *Embed in Frames: from
same origin*, so the host and the Hub must be served from the same origin (scheme, host and
port).

### How reliable is the screenshot?

The screenshot is drawn from the page itself (html2canvas), not taken by the operating system.
It handles normal APEX pages well. Charts drawn on canvas, frozen grid headers and very heavy
pages can come out partly blank, and the ticket then records the screenshot as `PARTIAL`. Users
can always paste or upload their own image instead. Adapter 1.0.3 captures the visible area to
keep heavy pages responsive.

### How do I know which adapter version a host runs?

The adapter reports its version on every launch. Integration Health shows it per application.
`MIN_ADAPTER_VERSION` rejects adapters older than the minimum you set.

### Can the host react when a ticket is created?

Yes. The adapter fires an `afh:created` DOM event on `document`, with `detail.ticketNo` and
`detail.ticketUrl`.

---

## 6. Tickets and workflow

### What does a ticket go through?

```
New -> Under Review -> Accepted -> Planned -> In Progress -> Ready for Testing -> Resolved -> Closed
            |
            +-> More Information Needed (answering moves it back to Under Review)
```

A ticket can also end as **Duplicate**, **Rejected** or **Cannot Reproduce**. **Reopened**
brings a closed or resolved ticket back for triage. The final statuses are Closed, Duplicate,
Rejected and Cannot Reproduce.

### Who can move a ticket, and what does each step require?

Developers and above move tickets. Some transitions need facts before the Hub accepts them:

| Transition | Requires |
|---|---|
| Under Review to Accepted | Official classification |
| Accepted to Planned | A target release or a planning note |
| To In Progress | An assignee |
| In Progress to Ready for Testing | Root cause, resolution and a test request |
| Ready for Testing to Resolved or back to In Progress | A passed or failed test, recorded by the assigned tester or a developer |
| To More Information Needed, Rejected or Cannot Reproduce | A reason |
| To Duplicate | A master ticket and a reason |
| Reopen | A reason. The reporter or the tester can reopen a Resolved ticket, and must add evidence. Only developers or admins can reopen a ticket from a final status |

The Hub enforces these in the database (`AFH-WF-001` when refused), so no page or script can skip
them. Admins can rename statuses and change transitions on Taxonomy and Workflow (page 64).

### How does a ticket leave everyone's list?

1. A passed test moves it to **Resolved**.
2. A Resolved ticket with no activity for `AUTO_CLOSE_DAYS` (default 14) is closed automatically
   by `AFH_JOB_AUTO_CLOSE`. **This needs the job enabled.** Without it, Resolved tickets stay
   Resolved until someone closes them.
3. Closed, Rejected, Duplicate and Cannot Reproduce tickets are off every open queue.
4. `ARCHIVE_AFTER_DAYS` (default 90) after closure, the retention run can mark a ticket archived.
   An admin can also archive or unarchive a single ticket on page 66.

Closed and archived tickets can still be searched.

### What feedback types are there?

Bug, New feature, Enhancement, Usability or accessibility, Data or reporting, Performance,
Question, and General. Each type can ask its own extra questions. Bug, for example, asks for
expected result, actual result, steps and frequency. Admins maintain types, fields, categories
and classification values on page 64.

### How are tickets numbered?

`FB-` followed by a number, for example `FB-0203`. Use this number in mail, search and
conversation. Internal IDs never appear to users.

### How does a ticket find the right developer?

On submit, the Hub checks the routing rules (page 62) by application, page, type, category and
environment. If no rule matches, the ticket goes to the application owner. If there's no owner,
it goes to the `FALLBACK_OWNER_SUBJECT` user. Page 62's **Try a route** shows where a sample
ticket would land.

### How are duplicates handled?

- **While typing:** the submit form suggests similar tickets as the user types a title. The match
  scores title, description, application, page and type with weights you can configure (`DUP_*`
  settings) and includes closed and archived tickets. The user can open a suggestion, follow it,
  or press "This affects me too" instead of filing a new ticket.
- **After the fact:** a developer marks a ticket Duplicate of a master. Nothing is lost. The
  duplicate keeps its comments, attachments, captures and history, its followers and affected
  users move to the master, and searching for the duplicate's number leads to the master.

### What does "This affects me too" do?

It adds the user to the ticket's affected list and makes them a follower. It shows how widely a
problem is felt. It is not a vote and does not change official priority.

### Where do developers work?

On the **Developer Workbench** (page 30):

- a queue and a Kanban board (dragging a card makes the same checked status change as the
  buttons);
- bulk actions on selected tickets;
- a workload view across developers;
- saved views. Personal views are available to everyone; sharing a view with the team needs
  developer or above.

**Releases** (page 40) groups tickets and their tests by target release. Application owners and
admins create and complete releases.

### Where do managers look?

**Application Health** (page 3) shows the open backlog by application, environment, page, type,
status, severity, priority, release and owner. It also shows ticket aging (0-2 days to over 90),
recently resolved and reopened tickets, and pages with repeated reports. **My Work** (page 1)
shows each person their tasks, tickets they reported, assignments, tests to run, followed tickets
and recent activity.

### What does search cover?

Ticket number, title, description, public comments, application, page, environment, type,
category, status, reporter, assignee and release. Search never reads internal notes or diagnostic
context.

### Can comments be edited?

The author can edit a public comment for `COMMENT_EDIT_WINDOW_MIN` minutes (default 15). Each
earlier version is kept, and the edit is audited. Comments are never deleted. An admin can hide
one from the timeline with `afh_comment_pkg.archive_comment`, which is also audited.

---

## 7. Notifications and e-mail

### How do notifications work?

Every material change on a ticket raises an *event*: new ticket, assignment, mention, comment,
information request and response, status change, priority change, release change, ready for
testing, test request and outcome, resolution, closure, reopening, and duplicate merge. The event
goes to the user it is aimed at (the assignee, the reporter asked a question, the tester) and to
every follower except the person who caused it. Each recipient's preferences decide the channel:

- **In-app:** always available. The bell, the Notification Center (page 50) and My Work.
- **E-mail:** sent immediately, or collected into a daily or weekly digest.

### What are the notification presets?

Each user picks one on Notification Preferences (page 51), globally or per application. They can
also override single events.

| Preset | E-mail | Digest |
|---|---|---|
| Immediate | Every event | None |
| **Important** (default) | Assignment, mention, information request, test request, resolution, reopening | None |
| Daily digest | Only assignment, information request, test request and mention, sent immediately | Everything else, daily at `DIGEST_DAILY_HOUR` (default 06:00) |
| Weekly digest | Same as daily | Everything else, Mondays 06:00 |
| In-app only | None | None |

`DEFAULT_NOTIFY_PRESET` sets the preset for users who haven't chosen one.

### Can a user miss an assignment by turning e-mail off?

No. Assignments, information requests and test requests always appear as tasks in the user's
in-app inbox and on My Work, whatever their preferences.

### What does following a ticket mean?

A follower gets that ticket's notifications, filtered through their preferences. Users follow a
ticket automatically when they submit it, comment on it, are @mentioned in it, mark it "affects
me too", or are assigned to it. They can also press **Follow** on any ticket.

### What is the difference between Unfollow and Mute?

| | Unfollow | Mute |
|---|---|---|
| Effect | Removes the user from the ticket's followers | Keeps them as a follower and silences the ticket |
| Receives | Nothing more, unless directly assigned or asked something later | No e-mail and no in-app alerts, except direct tasks (assignment, question, test request), which still appear in-app |
| Refused when | The user is the assignee, or has an open assignment or information request on the ticket | The user is the assignee |
| Undo | Follow again | Unmute |

Use Mute to stay on the list quietly, for example to see the ticket again under My Work, Following.
Use Unfollow to leave the ticket.

### How does e-mail actually go out?

1. The event writes a row to `AFH_NOTIFICATIONS` with state `QUEUED`. This happens in the same
   transaction as the change, so a rolled-back change sends nothing.
2. `AFH_JOB_MAIL_WORKER` runs every two minutes. It renders each queued mail from its template
   and calls `APEX_MAIL.SEND`.
3. APEX's own mail queue delivers it to your SMTP server.

`SENT` in the Hub means the mail was handed to APEX. Whether your SMTP server accepted it shows in
`APEX_MAIL_LOG`, and the Hub checks that log and reports relay failures on Integration Health.
A temporary failure is retried up to `MAIL_MAX_RETRIES` times (default 3). After that the mail is
marked failed, and an admin can retry it from Integration Health (page 67).

### What has to be in place for e-mail?

| Requirement | Who |
|---|---|
| Instance mail configured (Manage Instance, Instance Settings, Email: SMTP host, port, TLS) | APEX instance administrator |
| A network ACL letting the **APEX engine schema** (`APEX_240200` on 24.2) connect to the SMTP host. Not the Hub schema. | DBA |
| `MAIL_FROM`: a sender address your SMTP relay accepts | Admin (page 60) |
| `BASE_URL`: the bare ORDS root, for example `https://apex.example.com/ords`, with no `/r/...` | Admin |
| `FEEDBACK_APP_ID`: the Hub's application ID | Admin |
| `MAIL_ENABLED = Y`, set last | Admin |
| `AFH_JOB_MAIL_WORKER` enabled, plus the two digest jobs if anyone uses digests | Admin or DBA |
| An e-mail address on each recipient's user record | See below |

If any other application on the instance already sends mail, the first two rows are already
done.

### Where do users' e-mail addresses come from?

From the user's row in `AFH_USERS`. When someone signs in, the Hub stores an address if it can
find one: the APEX account's e-mail, or `APP_USER` itself when it looks like an address. With
single sign-on that passes a login name, a certificate UPN or a SAML NameID, there is no address
to find. Those users stay blank and are skipped for e-mail, while in-app notifications still
work. Fill the addresses in one of two ways:

- **By hand:** an admin edits the user on Users and Roles (page 63) and enters the e-mail.
- **Automatically:** a scheduled job of your own reads your directory or user-profile table and
  calls `afh_security_pkg.update_user(p_user_id, p_display_name, p_email)` for each Hub user.

A later sign-in never blanks an address that is already stored. It only fills an empty one or
replaces it with a newer value it found.

### What is in an e-mail?

The subject reads `[<Product> <ENV>] FB-0203 - <what happened>`. The body has the ticket title,
status, who acted, the application, the environment the ticket came from, a short summary and a
link. Restricted facts (page items, internal notes, diagnostics) are never put in mail.

### Where does the link in the mail go?

To `BASE_URL/f?p=<FEEDBACK_APP_ID>:11::::11:P11_TICKET_NO:FB-0203`. Page 11 (*Open Ticket*)
requires sign-in, checks that the user may view the ticket, then redirects to the ticket page with
a properly checksummed URL. Linking straight to page 10 fails with *Session state protection
violation*, because a mail built by a job has no APEX session to compute a checksum. Releases
before 1.0.58 linked to page 10 directly.

### Can we change the wording of e-mails?

Yes, on Notification Templates (page 65), per event and channel. Placeholders include
`#TICKET_NO#`, `#TITLE#`, `#STATUS#`, `#ACTOR#`, `#APPLICATION#`, `#ENVIRONMENT#`, `#SUMMARY#`,
`#LINK#` and `#RECIPIENT#`, plus `#ITEMS#` for digests. A template an admin has edited is never
overwritten by a later install or upgrade. If no active template exists for an event, a built-in
plain template is used.

### Why do the standard templates avoid dashes and curly quotes?

Databases with a single-byte character set (for example `WE8ISO8859P1`) can't store characters
such as the em dash. They show up as `¿` in every mail. The shipped templates use plain ASCII
only, and edited templates should do the same. To check your database character set:

```sql
SELECT value FROM nls_database_parameters WHERE parameter = 'NLS_CHARACTERSET';
```

### How do I turn e-mail off?

Set `MAIL_ENABLED = N`. Nothing new is queued, the mail worker does nothing, and every
notification still appears in-app, so nothing is lost.

### A user says they got no e-mail. What do I check?

1. Their user record has an e-mail address (page 63).
2. Their preset sends that event by e-mail (page 51, or `DEFAULT_NOTIFY_PRESET`). Under
   *Important*, a plain comment or status change doesn't send mail.
3. They hadn't muted the ticket, and they weren't the person who made the change.
4. `MAIL_ENABLED = Y`, and `AFH_JOB_MAIL_WORKER` is enabled and running (page 67, Scheduler).
5. Integration Health shows no mail failure for them.
6. `APEX_MAIL_LOG` shows the relay accepted it. If it did, the problem is downstream: spam
   filtering, or the relay refusing the `MAIL_FROM` domain.

---

## 8. Data, retention and storage

### Where is the data?

All of it is in the product schema: tickets, comments, attachments (as BLOBs), captures,
notifications and audit. Back it up with the rest of the database, or on its own with
`expdp ... schemas=AFH`.

### How much space will it use?

The product was sized for a handful of applications and developers with a year of history.
Attachments dominate the space used. Attachments and Retention (page 66) shows storage by
category, and the attachment limits cap the growth per ticket.

### Does anything get deleted automatically?

Not unless you choose that. There are three retention policies:

| Policy | Action |
|---|---|
| `ARCHIVE_CLOSED` | Marks tickets archived `ARCHIVE_AFTER_DAYS` (90) after closure. Nothing is deleted |
| `PURGE_ATTACHMENTS` | Removes file contents from archived tickets older than `DEFAULT_RETENTION_DAYS` (365). The attachment record stays |
| `DELETE_TICKETS` | Permanently deletes archived tickets older than `DEFAULT_RETENTION_DAYS` |

`AFH_JOB_RETENTION` only *previews* (counts and bytes written to the run history) until you set
`RETENTION_JOB_ARMED = Y`. An admin running a policy by hand on page 66 must type the
confirmation word (`ARCHIVE` or `DELETE`). Before each deletion, an audit row is written that
survives it and names the ticket, the admin or job, and the time.

### Can a user delete a ticket?

No. Users can't delete tickets or history. An attachment can be removed only by its uploader
within the edit window, or by a developer or admin, and the removal keeps the record and audits
it.

---

## 9. Operations and troubleshooting

### Which scheduler jobs are there, and which do we enable?

The installer creates all six **disabled**.

| Job | Schedule | Enable |
|---|---|---|
| `AFH_JOB_HANDOFF_PURGE` | Hourly | Always. Removes expired launch handoffs |
| `AFH_JOB_AUTO_CLOSE` | Daily 01:00 | Always. Closes Resolved tickets after `AUTO_CLOSE_DAYS` |
| `AFH_JOB_MAIL_WORKER` | Every 2 minutes | When mail is on |
| `AFH_JOB_DAILY_DIGEST` | Daily 06:00 | When mail is on |
| `AFH_JOB_WEEKLY_DIGEST` | Monday 06:00 | When mail is on |
| `AFH_JOB_RETENTION` | Daily 02:00 | Once a retention policy is agreed. It previews until armed |

```sql
BEGIN
  DBMS_SCHEDULER.enable('AFH_JOB_HANDOFF_PURGE');
  DBMS_SCHEDULER.enable('AFH_JOB_AUTO_CLOSE');
END;
/
```

Page 60 lists the jobs and their state. Page 67 links to job management.

### Where do I look first when something is wrong?

**Integration Health** (page 67). It shows, per application, recent launches and captures, refused
launches with their reason, mail failures with a Retry action, scheduler status and the mail
configuration. Behind it:

| Table or view | Holds |
|---|---|
| `AFH_INTEGRATION_EVENTS` | Launches, captures and mail outcomes, with a safe reason code |
| `AFH_AUDIT_EVENTS` | Who changed what and when |
| `AFH_V_MAIL_FAILURES` | Mail that failed permanently |
| `APEX_MAIL_QUEUE`, `APEX_MAIL_LOG` | APEX's own view of mail delivery |
| `USER_SCHEDULER_JOB_RUN_DETAILS` | Job runs and errors |

### What do the error codes mean?

Users see a short message with a code. Stack traces and SQL never reach them.

| Code | Meaning | Usual cause |
|---|---|---|
| `AFH-AUTH-001` | No trusted identity | The Hub's authentication isn't attached, or the session cookie name differs from the host's |
| `AFH-AUTH-002` | Permission denied | Missing role. After a grant, sign out and in again |
| `AFH-CTX-001` | Launch invalid | Expired, replayed, wrong session, unregistered application or environment, URL pattern. The reason is on page 67 |
| `AFH-CTX-002` | Partial context | Some of the capture failed. The ticket is still filed |
| `AFH-CTX-003` | Unsupported contract | The host adapter is older than `MIN_ADAPTER_VERSION`, or the contract version differs |
| `AFH-UPL-001` | File type refused | Extension not in `ATTACH_ALLOWED_EXT`, or a blocked type |
| `AFH-UPL-002` | Too large | Over the per-file or per-ticket limit |
| `AFH-WF-001` | Transition refused | A required fact is missing (see section 6), or the role is too low |
| `AFH-LOCK-001` | Changed by someone else | Reload the ticket and try again |
| `AFH-VAL-001` | Input validation | The message says which field |
| `AFH-MAIL-001` | Mail delivery failed | See section 7 |
| `AFH-SRCH-001` | Search unavailable | Recorded on Integration Health. Duplicate suggestions return nothing rather than fail |
| `AFH-SYS-002` | Append-only violation | Something tried to change audit history |
| `AFH-INS-005` | Installer refused | The schema holds a different product version. Use the upgrade scripts |

### Users get "Session state protection violation" from a mail link

The mail was sent by a release before 1.0.58, which linked straight to page 10. Install 1.0.58 or
later. New mail links go through page 11. Links in mail that was already sent still point at
page 10, so open the ticket number from All Feedback instead.

### Digest mail never arrives

In bundles downloaded before 2026-11-09, the two digest jobs had a broken action and failed on
every run (`PLS-00201: identifier 'DAILY' must be declared` in
`USER_SCHEDULER_JOB_RUN_DETAILS`). Immediate mail was not affected. Re-run `install.sql` from a
current bundle: it corrects the action on the existing jobs and leaves their schedule and enabled
state alone. Digest items queued in the meantime go out on the next run.

### Mail shows `¿` characters

The templates came from a release before 1.0.58, or an admin edited a template and typed a
non-ASCII character. Re-run the 1.0.58-or-later database install to refresh the shipped
templates, and remove dashes and curly quotes from any edited ones (section 7).

### The overlay shows the Hub's own sign-in page

The Hub isn't accepting the host's session. Check that the Hub's current authentication scheme
uses the host's session cookie name. This happens after every application import until the scheme
is re-attached (section 2).

### A health check I can script

```sql
-- 1. No invalid product objects (expect 0)
SELECT COUNT(*) FROM user_objects
 WHERE status = 'INVALID' AND object_name NOT LIKE 'AFH\_TEST\_%' ESCAPE '\';

-- 2. Jobs enabled and their last run
SELECT job_name, enabled, state, last_start_date, failure_count
  FROM user_scheduler_jobs ORDER BY job_name;

-- 3. Mail waiting or failed in the Hub
SELECT channel_code, state_code, COUNT(*)
  FROM afh_notifications GROUP BY channel_code, state_code;

-- 4. Refused launches in the last 7 days, by reason
SELECT safe_detail, COUNT(*) FROM afh_integration_events
 WHERE result_code = 'FAILED' AND event_at > SYSTIMESTAMP - INTERVAL '7' DAY
 GROUP BY safe_detail;
```

---

## 10. Branding and customization

### Can we put our name and colors on it?

Yes, without touching the theme. `PRODUCT_NAME`, `BRAND_LOGO_URL`, `BRAND_PRIMARY_COLOR` and
`BRAND_ACCENT_COLOR` on page 60 drive the header, page titles, colors and mail subjects.

### What else can admins change without a developer?

| Area | Page |
|---|---|
| Feedback types, their fields, categories, severity, priority and impact values | 64 |
| Workflow status names and permitted transitions | 64 |
| Routing rules and application ownership | 62 |
| Mail templates | 65 |
| Attachment types and limits, retention periods, archiving | 66 |
| All other settings in `AFH_INSTALL_CONFIG` | 60 |

The installer and upgrades never overwrite these changes.

### Is there an "AI Recommends" panel?

A preview of one exists behind the build option `AI_PREVIEW`, which ships set to *Exclude*. Leave
it excluded. It is not part of this release and calls no AI service.

### Where do I report a problem with the product itself?

Through whoever supplied your installation. Releases, release notes and checksums are at
https://github.com/praveensehgal/apex-feedback-hub/releases.
