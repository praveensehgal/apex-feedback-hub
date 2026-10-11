# Upgrades

One directory per target version, each with an ordered `upgrade.sql` that:

1. Reads `PRODUCT_VERSION` from `AFH_INSTALL_CONFIG` and refuses to run unless it equals the
   version the script upgrades **from** (`AFH-INS-005` otherwise).
2. Applies schema changes as guarded, re-runnable DDL (the same `user_tables` / `user_constraints`
   guards the installer uses), then re-runs the package specs, views, bodies, and seed from the
   main tree (`@@../../install/06_packages.sql` …) so code is always the current version.
3. Updates `PRODUCT_VERSION` last, in the same run, and finishes with `@@../../install/99_verify.sql`.

Rollback: restore the previous application export and re-run the previous version's package and
view scripts; ticket data is never dropped by an upgrade.

```
upgrades/
  README.md
  v0.2.0/upgrade.sql      -- from 0.1.0
```
