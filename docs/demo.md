# Live demo

A real Halogen app, bundled from `examples/`, mounted below against
four real-world JSON payloads. Pick a sample to render it. Try:

- **Single click** on a key or an index marker — toggles that one
  level. When closing, cascades all descendants closed too.
- **Double click** on a key or an index marker — expands the whole
  subtree recursively.
- **⎘ Copy JSON** — the structure-level chip the library ships the
  CSS and behaviour for. Click it to copy the displayed sample to
  the clipboard.
- **Click a resolved link** (`v-txid` / `v-txin` / `v-addr` /
  `v-policy` on the Cardano sample) — opens cardanoscan in a new tab
  with the full underlying value preserved on the `title` tooltip.

<div id="json-tree-demo" class="jt-demo-host"></div>

!!! tip "The renderer's surface is tiny"
    Everything you see here comes from `JsonTree.render` + the
    bundled stylesheet + `JsonTree.Behaviour.install`. The
    consumer-side picker chrome (the round chips above the tree, the
    "Copy JSON" affordance, the subtitle line) is consumer code in
    `examples/src/Main.purs` — the library does not impose any of it.

!!! info "Want the JSON?"
    Each sample's source literal lives in
    [`examples/src/Samples.purs`](https://github.com/lambdasistemi/browser-json-tree/blob/main/examples/src/Samples.purs).
    The Cardano sample uses real-shape hex strings (64-char txid,
    `<txid>#<ix>` txin, 56-char policy id, `addr1…` bech32). The
    GitHub sample is the live API response for this repo, fetched at
    bootstrap time and shipped verbatim.
