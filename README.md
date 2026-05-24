# browser-json-tree

A typed Halogen renderer for `Data.Argonaut.Core.Json` values, with native
`<details>` collapse, CAD-style array index markers, configurable
string-leaf link resolution (Cardano txid / address / policy id by
default), and a tiny document-level click behaviour shim.

Extracted from
[lambdasistemi/amaru-treasury-tx](https://github.com/lambdasistemi/amaru-treasury-tx)
where it grew up as the InspectReport renderer.

## Install

The library is published as a tagged Git source. Add to your
`spago.yaml`:

```yaml
package:
  dependencies:
    - browser-json-tree
    # ...

workspace:
  extraPackages:
    browser-json-tree:
      git: https://github.com/lambdasistemi/browser-json-tree.git
      ref: v0.1.0
      dependencies:
        - argonaut-core
        - halogen
```

Then drop the canonical stylesheet next to your app:

```html
<link rel="stylesheet" href="path/to/json-tree.css" />
```

The CSS file ships at `dist/json-tree.css` in the source tarball, and
is attached as a standalone asset on each GitHub Release.

## Usage

```purescript
module Main where

import Effect (Effect)
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)
import JsonTree as JsonTree
import JsonTree.Behaviour as Behaviour

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  _ <- runUI rootComponent unit body
  Behaviour.install   -- wire up click / dblclick / copy handlers

view someJson =
  HH.div
    [ HP.class_ (HH.ClassName "json-tree-wrapper") ]
    [ JsonTree.render someJson ]
```

`Behaviour.install` attaches three document-level listeners:

| Gesture | Effect |
| --- | --- |
| Single click on a key / index marker | Toggle just that level. When closing, cascade-close all descendants so the next reopen starts at one level deep again. |
| Double click on a key / index marker | Expand the entire subtree recursively. Never collapses (the gesture commits to "show me everything"). |
| Click on any `.v-copy` button on the page | Read `data-copy`, write it to `navigator.clipboard`, briefly flash `.v-copy--ok`. Capture phase, so the click never bubbles to a parent `<summary>` and toggles a surrounding `<details>`. |

### Structure-level copy chip

The renderer deliberately does NOT emit per-leaf copy buttons —
those clutter dense trees, and the full value already lives on the
link's `title` tooltip. Bulk copy is the consumer's job, served by
two artefacts the library ships:

1. CSS — `.v-copy` (inline / compact) and `.v-copy.v-copy--block`
   (full-row chip) are styled in `dist/json-tree.css`.
2. JS — `Behaviour.install` wires any `.v-copy` element with a
   `data-copy` attribute to the clipboard.

A typical "Copy this JSON" chip above a tree:

```purescript
HH.button
  [ HP.classes [ HH.ClassName "v-copy", HH.ClassName "v-copy--block" ]
  , HP.attr (HH.AttrName "data-copy") (stringify someJson)
  , HP.title "Copy this JSON"
  , HP.type_ HP.ButtonButton
  ]
  [ HH.text "⎘ Copy JSON" ]
```

## Configuration

```purescript
import Data.Maybe (Maybe(..))
import JsonTree (Config, LinkSpec, defaultConfig, renderWith)

myConfig :: Config
myConfig = defaultConfig
  { initiallyOpen = false      -- start collapsed (default)
  , hideEmpty     = true       -- drop null / [] / {} entries
  , resolveString = \s ->
      -- swap in your own resolver here; return `Nothing` to
      -- render a plain text leaf. Examples: an EVM hash
      -- resolver, an IPFS CID resolver, a transaction id
      -- mapper for a different chain explorer, …
      Nothing
  }

view someJson = renderWith myConfig someJson
```

A `LinkSpec` is `{ cls :: String, href :: String, short :: String }` —
the renderer wraps it in `<a class={cls} href={href} target="_blank">
{short}</a>` plus a copy-to-clipboard button.

The default resolver lives in `JsonTree.Cardano`:

```purescript
import JsonTree.Cardano as Cardano

defaultConfig = { ..., resolveString = Cardano.resolve }
-- detects four Cardano shapes and routes each to cardanoscan.io:
--   * 64-char hex            → /transaction/<txid>             (.v-txid)
--   * <64-char hex>#<digits> → /transaction/<txid>?tab=utxo    (.v-txin)
--   * addr1… bech32          → /address/<addr>                 (.v-addr)
--   * 56-char hex            → /tokenPolicy/<policy>           (.v-policy)
```

## Theming

`dist/json-tree.css` is self-contained and exposes every colour,
radius and font as a CSS custom property. Override on
`.json-tree-wrapper` (or any ancestor) to theme:

| Variable | Purpose |
| --- | --- |
| `--jt-bg` | Wrapper background |
| `--jt-fg` | Body text colour |
| `--jt-key` | Object keys |
| `--jt-line` | Index bracket hairline + gutter rule |
| `--jt-marker` | Index labels + hover accents |
| `--jt-link` / `--jt-link-hover` | Resolved-link colour + hover |
| `--jt-null` | `null` leaf colour (italic) |
| `--jt-bool-num` | Boolean + number leaves |
| `--jt-str` | Plain string leaves |
| `--jt-copy-*` | Copy button states (fg / border / hover-bg / ok-bg) |
| `--jt-radius` | Wrapper border radius |
| `--jt-font-mono` | Monospace family for the tree |
| `--jt-font-size` | Base font size |

For a dark theme:

```css
.json-tree-wrapper {
  --jt-bg: #161b22;
  --jt-fg: #e6edf3;
  --jt-key: #adbac7;
  --jt-line: #30363d;
  --jt-marker: #768390;
  --jt-link: #58a6ff;
  --jt-link-hover: #79c0ff;
  --jt-str: #e6edf3;
  --jt-copy-hover-bg: #21262d;
}
```

## Example app

A tiny Halogen demo lives under [`examples/`](./examples). Build it
with:

```sh
nix build .#example
# open ./result/index.html in a browser
```

Or in the dev shell:

```sh
nix develop
just example
# open examples/dist/index.html in a browser
```

## Class taxonomy

The renderer emits a deliberately small, stable CSS class surface so
consumers can override visuals without forking the renderer:

| Class | Element |
| --- | --- |
| `.v-object`, `.v-pair`, `.v-pair-leaf`, `.v-pair-compound` | Object + entries |
| `.v-key`, `.v-key-toggle`, `.v-val` | Object key (toggle = clickable summary) + value |
| `.v-array`, `.v-item`, `.v-item-leaf`, `.v-item-compound` | Array + rows |
| `.v-sep`, `.v-sep-toggle`, `.v-sep-line`, `.v-sep-label` | CAD-style index marker |
| `.v-children` | Indented children block |
| `.v-null`, `.v-bool`, `.v-num`, `.v-str` | Primitive leaves |
| `.v-linked` | Wrapper for resolved-link leaf |
| `.v-txid`, `.v-addr`, `.v-policy`, `.v-txin` | Default resolver link classes |
| `.v-copy`, `.v-copy--block`, `.v-copy--ok` | Copy chip (consumer-rendered) — inline, full-row, success-flash |

Custom resolvers free to define their own `cls` value — anything
returned in `LinkSpec.cls` becomes the `<a>` class.

## Development

```sh
nix develop          # drop into a shell with purs / spago / purs-tidy / esbuild / nodejs / just
just build           # spago build the library
just lint            # purs-tidy check
just example         # bundle the example app
just ci              # nix flake check (full local mirror of CI)
```

## License

[Apache-2.0](./LICENSE), matching the upstream
[`amaru-treasury-tx`](https://github.com/lambdasistemi/amaru-treasury-tx).

## Credits

Extracted from
[lambdasistemi/amaru-treasury-tx](https://github.com/lambdasistemi/amaru-treasury-tx)'s
InspectReport renderer. The recursive collapse semantics, the CAD-style
array bracket, and the cardanoscan resolution heuristics all originate
there.
