# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## Unreleased

## [0.2.0](https://github.com/lambdasistemi/browser-json-tree/compare/v0.1.0...v0.2.0) (2026-05-24)

### Features

* add JsonTree.JS — vanilla JS adapter (mount / install) ([d9bfd20](https://github.com/lambdasistemi/browser-json-tree/commit/d9bfd208d09c8512a44d14406c53f8aba7d9ac42))
* **example:** multi-sample picker with real-world JSON ([173ff64](https://github.com/lambdasistemi/browser-json-tree/commit/173ff64f35fd8dda99a5f66051563d1b65709a3c))
* **docs:** MkDocs Material site with embedded live demo ([81575b6](https://github.com/lambdasistemi/browser-json-tree/commit/81575b6af3fecd37385ac7bcb866138d26bdf222))

### Bug Fixes

* **demo:** ride Material design tokens; surface dblclick hint ([5b3539d](https://github.com/lambdasistemi/browser-json-tree/commit/5b3539dc0959ca93b1ae1917d3ae708fb026ac56))

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
