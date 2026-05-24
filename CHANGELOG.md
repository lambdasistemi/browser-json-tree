# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## Unreleased

### Features

- Ship a MkDocs Material documentation site at
  https://lambdasistemi.github.io/browser-json-tree/ with a live,
  interactive demo rendering four real-world JSON samples (a
  Conway-era Cardano transaction exercising every default resolver
  branch, the live GitHub API response for this repo, a Kubernetes
  Pod manifest with a sidecar, and the npm registry entry for
  `react`). Light/dark Material palette toggle drives both site
  chrome and the tree colours via a `--jt-*` ⇄ `--md-*` tie-in.
- Add `JsonTree.JS` — vanilla-JS adapter over the renderer +
  behaviour shim. Exposes `mount`, `mountFromString`, and `install`;
  bundled as `dist/browser-json-tree.js` (ES module). Lets a plain
  JS app render a tree under any DOM element without writing
  Halogen. Shipped as a standalone GitHub Release asset.
- Refactor the example app into a four-sample picker, mounting on
  `#json-tree-demo` if present (docs site) and falling back to
  `<body>` for the standalone smoke. The bundle is reused by the
  docs site as the live demo.
- `nix build .#docsSite` builds the documentation site reproducibly
  in the sandbox; CI Build Gate now includes it, and a localhost
  smoke check verifies the rendered HTML + the JS/CSS assets are
  reachable. `nix build .#jsBundle` builds the JS library bundle.
- `.github/workflows/deploy-docs.yml` publishes to GitHub Pages on
  push to `main`.

## [0.1.0]

### Features

- Initial extraction from
  [lambdasistemi/amaru-treasury-tx](https://github.com/lambdasistemi/amaru-treasury-tx).
- `JsonTree.render` / `JsonTree.renderWith` typed Halogen renderer for
  `Data.Argonaut.Core.Json` values.
- `JsonTree.Config` record with `initiallyOpen`, `hideEmpty`, and a
  pluggable `resolveString :: String -> Maybe LinkSpec`.
- `JsonTree.Cardano.resolve` default resolver covering four shapes,
  all routed through `cardanoscan.io`:
  * 64-char lowercase hex — txid;
  * `<txid>#<ix>` — txin (`?tab=utxo`);
  * `addr1…` bech32 — mainnet address;
  * 56-char lowercase hex — minting policy id.
  Also exports `parseTxin` for direct use.
- `JsonTree.Behaviour.install` document-level click wiring: single
  click toggles one level with cascade close, double click expands
  recursively, and a capture-phase `.v-copy` handler drives any copy
  chip with a `data-copy` attribute (clipboard write + brief
  `.v-copy--ok` flash). The renderer does NOT emit per-leaf copy
  buttons; structure-level copy is the consumer's affordance, but
  the library ships the matching CSS (`.v-copy`, `.v-copy--block`,
  `.v-copy--ok`) and JS handler.
- Canonical, self-contained `dist/json-tree.css` stylesheet themable
  via `--jt-*` custom properties. Resolver links use a single dotted
  underline mechanism (`text-decoration` + explicit
  `border-bottom: none`) to stay robust against host stylesheets
  that ship their own link underlines. Leaf pairs use a hanging
  indent so wrapped long values can't be misread as new keys.
- Standalone Halogen example app under `examples/`.
- `nix flake check` builds the library, bundles the example, and runs
  `purs-tidy` against the source tree.
- Conventional-commits release planner script + tag-driven release
  workflow.
