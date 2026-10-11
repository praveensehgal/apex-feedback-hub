# Upgrade and rollback

## Versions

Two numbers travel together in every bundle:

| | Where | Example | Changes when |
|---|---|---|---|
| Product version | `database/install/install.sql` → `DEFINE afh_product_version`; stored in `AFH_INSTALL_CONFIG.PRODUCT_VERSION` | `0.1.0` | the database layer changes |
| Application release | `apex/application/application/create_application.sql` → `p_flow_version`; shown in `APEX_APPLICATIONS.VERSION` | `Release 1.0.56` | anything in the APEX application changes |

The pre-flight check refuses to run `install.sql` on a schema whose `PRODUCT_VERSION` differs from
the bundle (`AFH-INS-005`). Same-version re-runs are safe and are the normal way to repair a
partial install.

## Upgrading the database layer

Each product version after the first ships `database/upgrades/v<to>/upgrade.sql`, which:

1. reads `PRODUCT_VERSION` and refuses unless it equals the version it upgrades **from**;
2. applies schema changes as guarded, re-runnable DDL;
3. re-runs the package specifications, views, bodies and seed from the main tree, so code is
   always the bundle's version and seed rows you changed are left alone;
4. sets `PRODUCT_VERSION` last, in the same run, and finishes with the verification block.

Run it as the product schema from inside its directory, exactly like `install.sql`. Chain the
directories in order when skipping versions; each one checks the version it starts from.

## Upgrading the application

Import the bundle's `apex/application/install.sql` **over the existing application ID**: on the
import screen choose *Replace application* with the same ID. Everything that is configuration in
the Hub lives in the database, not in the application, so a replace loses nothing:

- registered applications, environments, routing rules, users and roles, tickets: database;
- the authentication scheme you attached in INSTALL.md §5: **this one is in the application** and
  will be replaced by the bundle's Oracle APEX Accounts scheme. Re-create or re-subscribe your
  scheme and make it current again after every application import, before users return. Export
  the scheme first (Shared Components → Authentication Schemes → export) so it is a two-minute step.
- `FEEDBACK_APP_ID` stays valid because the ID did not change.

A full application import ends every APEX session of that application; schedule it when users are
off. Static files are versioned (`files_version`), so browsers pick up new CSS and JavaScript on
the next page load without clearing caches.

## Order

Database first, application second. A new application release may call packages the previous
database version does not have; the reverse is never true within one bundle.

## Rollback

| What went wrong | Do |
|---|---|
| `upgrade.sql` failed part-way | It runs with `WHENEVER SQLERROR EXIT FAILURE ROLLBACK`, but DDL commits implicitly. Re-run it: every step is guarded and resumes where it stopped. If it cannot complete, restore the previous bundle's package and view scripts (`06_packages.sql`, `05_views.sql`, `07_package_bodies.sql`) and set `PRODUCT_VERSION` back by SQL. Ticket data is never dropped by an upgrade. |
| Application import failed | APEX rolls the import back; the previous application is untouched. |
| Application imported but misbehaves | Re-import the previous bundle's `apex/application/install.sql` over the same ID and re-attach your authentication scheme. |
| Everything must go | INSTALL.md §8: delete the application, then `database/uninstall/uninstall.sql` with `afh_confirm_uninstall = 'YES'`. Take `expdp … schemas=AFH` first if the tickets matter. |

Keep the previous bundle until the new one has been in production for a full digest cycle.
