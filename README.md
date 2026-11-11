# APEX Feedback Hub

Version **0.1.1** (application Release 1.0.60), built 2026-11-11T10:14:34Z
from commit 9722dc2.

In-application feedback capture and ticket management for Oracle APEX. Users press a Feedback
button on any integrated APEX page; the Hub opens in an overlay, captures the page context and a
screenshot, and creates a ticket that developers triage, discuss, test, resolve and audit in the
same application.

By Praveen Sehgal · https://sehgalp.ai

## Requirements

Oracle Database 19c or later, Oracle APEX 24.2 or later, HTTPS in front of ORDS.

## Install

Start with [docs/INSTALL.md](docs/INSTALL.md). In order:

1. `database/install/install.sql` connected as the product schema (DBA prerequisites in INSTALL.md §2)
2. Import `apex/application/install.sql` into the workspace of the host application
3. Attach the host application's authentication scheme (INSTALL.md §5)
4. Configure ([docs/CONFIGURATION.md](docs/CONFIGURATION.md))
5. Wire the host application ([integration/host-adapter/README.md](integration/host-adapter/README.md))

Upgrades and rollback: [docs/UPGRADE-AND-ROLLBACK.md](docs/UPGRADE-AND-ROLLBACK.md).
How the parts fit together, for IT: [docs/FAQ.md](docs/FAQ.md).
Verify a download with `shasum -a 256 -c MANIFEST.sha256`.

## Layout

```
database/                   ordered installer, uninstall, upgrades
apex/application/           the Hub application export (split, install.sql at the top)
integration/host-adapter/   files the host application installs
docs/                       INSTALL.md, CONFIGURATION.md, UPGRADE-AND-ROLLBACK.md, FAQ.md
licenses/                   third-party browser libraries and their licenses
MANIFEST.sha256             checksums of every file in the release
```

## License

[MIT](LICENSE) © 2026 Praveen Sehgal. Bundled browser libraries (html2canvas 1.4.1, fabric 5.3.0)
are MIT as well; see [licenses/README.md](licenses/README.md).
