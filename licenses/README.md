# Vendored browser assets

Pinned third-party libraries uploaded as **application static files** in the Hub (and, for
html2canvas, in each host application). No CDN loading anywhere (spec §7.4, DG-03).

| File | Version | License | SHA-256 | Used by |
|---|---|---|---|---|
| `html2canvas-1.4.1.min.js` | 1.4.1 | MIT (`html2canvas-1.4.1.LICENSE`) | `e87e550794322e574a1fda0c1549a3c70dae5a93d9113417a429016838eab8cb` | Host adapter: automatic screenshot (DG-03) |
| `fabric-5.3.0.min.js` | 5.3.0 | MIT (`fabric-5.3.0.LICENSE`) | `48f8f0915beb512fc7fe1b48c0eeb075dd0803c790efdfd75cd007f9c3eea2ca` | Hub Page 20: screenshot annotation (ATT-05) |

Source: npm registry tarballs, downloaded 2026-08-22. Verify before upload:
`shasum -a 256 *.min.js`.
