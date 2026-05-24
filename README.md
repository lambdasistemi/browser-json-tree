# browser-json-tree

A typed Halogen renderer + click behaviour shim for collapsible JSON
trees. Native `<details>` collapse, CAD-style array index markers,
configurable string-leaf link resolution (Cardano txid / txin /
address / policy id by default), structure-level copy chip. Self-
contained CSS themable via `--jt-*` custom properties.

📚 **Full documentation + live demo:**
**[lambdasistemi.github.io/browser-json-tree](https://lambdasistemi.github.io/browser-json-tree/)**

## Quick start

**PureScript / Halogen.** Add to your `spago.yaml`:

```yaml
package:
  dependencies:
    - browser-json-tree
workspace:
  extraPackages:
    browser-json-tree:
      git: https://github.com/lambdasistemi/browser-json-tree.git
      ref: v0.2.0
      dependencies: [argonaut-core, halogen]
```

```purescript
import JsonTree as JsonTree
import JsonTree.Behaviour as Behaviour

main = HA.runHalogenAff do
  body <- HA.awaitBody
  _ <- runUI rootComponent unit body
  H.liftEffect Behaviour.install

view someJson =
  HH.div [ HP.class_ (HH.ClassName "json-tree-wrapper") ]
    [ JsonTree.render someJson ]
```

**Vanilla JavaScript.** Drop the ES module bundle into your app:

```html
<link rel="stylesheet" href="./json-tree.css" />
<div id="tree" class="json-tree-wrapper"></div>
<script type="module">
  import { mount, install } from "./browser-json-tree.js";
  install();
  mount(document.getElementById("tree"), { hello: "world" });
</script>
```

Both `browser-json-tree.js` and `json-tree.css` ship as standalone
assets on every
[GitHub Release](https://github.com/lambdasistemi/browser-json-tree/releases/latest).

## Development

```sh
nix develop          # drops you into a shell with purs / spago / purs-tidy / esbuild / nodejs / mkdocs / just
just build           # spago build the library
just lint            # purs-tidy check
just example         # bundle the example app
just docs            # build the docs site into ./_site
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
