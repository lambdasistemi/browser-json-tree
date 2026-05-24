# browser-json-tree

A typed Halogen renderer for `Data.Argonaut.Core.Json` values, with
native `<details>` collapse, CAD-style array index markers, configurable
string-leaf link resolution (Cardano txid / txin / address / policy id
by default), and a tiny document-level click behaviour shim.

[**:material-play-circle: Open the live demo →**](demo.md){ .md-button .md-button--primary }
[Install](installation.md){ .md-button }

## In one paragraph

You hand it a `Json`. It hands you back a `Halogen.HTML.HTML` that
renders as a foldable, hyperlink-resolving, copy-friendly tree. The
companion CSS is themable via `--jt-*` custom properties. The companion
JS shim wires single-click toggle (with cascade-close), double-click
recursive expand, and any consumer-rendered "Copy JSON" chip — no
per-leaf copy buttons cluttering the tree.

## Why use it

- :material-toggle-switch-outline: **Native `<details>`** for fold state.
  Survives a page refresh on its own, no Halogen state machine for
  open/closed bookkeeping.
- :material-link-variant: **Pluggable string-leaf resolution.** Default
  resolver upgrades Cardano txids, txins, addresses, and policy ids
  into truncated `cardanoscan.io` links. Non-Cardano consumers swap
  the resolver and keep the tree.
- :material-palette: **Self-contained, themable CSS.** All colours and
  typography drive off `--jt-*` custom properties — drop the
  stylesheet in and override per page if you like.
- :material-content-copy: **Structure-level copy chip.** The library
  ships the styles and the click handler; you render the button where
  it makes sense. The tree itself stays clean.

## What it looks like

The live demo on the next page renders four real-world JSON payloads:

| Sample | Why |
| --- | --- |
| **Cardano transaction** | Exercises every Cardano resolver branch (`v-txid` / `v-txin` / `v-addr` / `v-policy`). Real-shape hex strings, nested inputs/outputs/witnesses. |
| **GitHub API repo response** | Live `/repos/lambdasistemi/browser-json-tree`. Flat key/value heavy, occasional nested object. Demonstrates "this is also useful outside Cardano". |
| **Kubernetes Pod manifest** | Web server + log sidecar. Deeply nested string-heavy content; demonstrates the wrapped-value hanging indent. |
| **npm registry — react** | Dist tags, maintainers, latest version. Arrays + nested objects, side-by-side with primitive leaves. |

## Source + release

- Source: [github.com/lambdasistemi/browser-json-tree](https://github.com/lambdasistemi/browser-json-tree)
- Latest release: [releases/latest](https://github.com/lambdasistemi/browser-json-tree/releases/latest)
- Standalone CSS asset: shipped on every GitHub Release as `json-tree-<version>.css`.
