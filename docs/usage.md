# Usage

## Default rendering

```purescript
import JsonTree as JsonTree

view someJson =
  HH.div [ HP.class_ (HH.ClassName "json-tree-wrapper") ]
    [ JsonTree.render someJson ]
```

`render` uses `JsonTree.defaultConfig`: collapsed by default, empty
values (`null`, `[]`, `{}`) hidden from the rendered tree, Cardano
string-leaf resolution on.

## Configuring

`renderWith` takes a `Config`:

```purescript
import Data.Maybe (Maybe(..))
import JsonTree (Config, LinkSpec, defaultConfig, renderWith)

myConfig :: Config
myConfig = defaultConfig
  { initiallyOpen = false   -- start collapsed (default)
  , hideEmpty     = true    -- drop null / [] / {} entries
  , resolveString = \s ->
      -- return Nothing → render as a plain text leaf;
      -- return Just LinkSpec → render as <a>.
      Nothing
  }

view someJson = renderWith myConfig someJson
```

`LinkSpec` is `{ cls :: String, href :: String, short :: String }`. The
renderer wraps it as `<a class={cls} href={href} target="_blank">{short}</a>`
with the full underlying string preserved on the `title` tooltip.

## The behaviour shim

`JsonTree.Behaviour.install` attaches three document-level listeners:

| Gesture | Effect |
| --- | --- |
| Single click on a `.v-key-toggle` / `.v-sep-toggle` summary | Toggle just that one level. When closing, cascade-close all descendants so the next reopen starts at one level deep again. |
| Double click on the same summaries | Expand the entire subtree recursively. Never collapses — the gesture commits to "show me everything". |
| Click on any `.v-copy` element on the page | Read `data-copy`, write it to `navigator.clipboard`, briefly flash `.v-copy--ok`. Capture phase, so the click never bubbles to a parent `<summary>` and toggles a surrounding `<details>`. |

Call it once from `main`:

```purescript
main = HA.runHalogenAff do
  body <- HA.awaitBody
  _ <- runUI rootComponent unit body
  H.liftEffect Behaviour.install
```

## Structure-level copy chip

The renderer deliberately does **not** emit per-leaf copy buttons —
they clutter dense trees, and the full value already lives on the
link's `title` tooltip. Bulk copy is the consumer's job, served by two
artefacts the library ships:

1. **CSS** — `.v-copy` (inline / compact) and `.v-copy.v-copy--block`
   (full-row chip) are styled in `dist/json-tree.css`.
2. **JS** — `Behaviour.install` wires any `.v-copy` element with a
   `data-copy` attribute to the clipboard.

A typical chip above a tree:

```purescript
import Data.Argonaut.Core (stringify)

HH.div_
  [ HH.button
      [ HP.classes
          [ HH.ClassName "v-copy"
          , HH.ClassName "v-copy--block"
          ]
      , HP.attr (HH.AttrName "data-copy") (stringify someJson)
      , HP.title "Copy this JSON"
      , HP.type_ HP.ButtonButton
      ]
      [ HH.text "⎘ Copy JSON" ]
  , HH.div [ HP.class_ (HH.ClassName "json-tree-wrapper") ]
      [ JsonTree.render someJson ]
  ]
```

The chip briefly flashes green (`.v-copy--ok`) on a successful
clipboard write. No state machine in your component — the library's
DOM-level handler does it.

## Class taxonomy

| Class | Element |
| --- | --- |
| `.v-object`, `.v-pair`, `.v-pair-leaf`, `.v-pair-compound` | Object + entries |
| `.v-key`, `.v-key-toggle`, `.v-val` | Object key (toggle = clickable summary) + value |
| `.v-array`, `.v-item`, `.v-item-leaf`, `.v-item-compound` | Array + rows |
| `.v-sep`, `.v-sep-toggle`, `.v-sep-line`, `.v-sep-label` | CAD-style index marker |
| `.v-children` | Indented children block |
| `.v-null`, `.v-bool`, `.v-num`, `.v-str` | Primitive leaves |
| `.v-txid`, `.v-addr`, `.v-policy`, `.v-txin` | Default resolver link classes |
| `.v-copy`, `.v-copy--block`, `.v-copy--ok` | Copy chip (consumer-rendered) — inline, full-row, success-flash |

Custom resolvers are free to define their own `cls` — anything returned
in `LinkSpec.cls` becomes the `<a>` class.
