# Installation

`browser-json-tree` ships in two flavours. Pick the one that matches
your stack:

=== "PureScript / Halogen"

    Add as a spago `extraPackage`; use `JsonTree.render` directly
    inside your own Halogen components.

=== "Vanilla JavaScript"

    Pull the ES-module bundle from the GitHub Release; call
    `mount(element, json)` from a `<script type="module">`. Skip
    [§ PureScript install](#purescript-halogen) and jump to
    [§ JavaScript install](#javascript) below.

## PureScript / Halogen

`browser-json-tree` ships as a tagged Git source. Two pieces land in
your project: the PureScript module set (consumed via spago) and the
canonical stylesheet (a single `.css` file).

## 1. Add the library to your `spago.yaml`

```yaml
package:
  dependencies:
    - browser-json-tree
    # ... your existing deps

workspace:
  extraPackages:
    browser-json-tree:
      git: https://github.com/lambdasistemi/browser-json-tree.git
      ref: v0.1.0           # or the latest tag from /releases
      dependencies:
        - argonaut-core
        - halogen
```

Then re-run `spago install` to update your `spago.lock`.

## 2. Drop the stylesheet next to your app

Two equivalent options.

=== "Vendored copy"

    Download `json-tree-<version>.css` from the GitHub Release page
    and commit it. Reference from your HTML shell:

    ```html
    <link rel="stylesheet" href="/assets/json-tree.css" />
    ```

=== "Bundled with your build"

    Add the project as an npm dependency too (it exposes the CSS
    via `"main": "dist/json-tree.css"`):

    ```json
    {
      "dependencies": {
        "browser-json-tree": "github:lambdasistemi/browser-json-tree#v0.1.0"
      }
    }
    ```

    Then import it from your CSS entry point or bundler config:

    ```css
    @import "browser-json-tree/dist/json-tree.css";
    ```

## 3. Wire the behaviour shim

In your application's `main`:

```purescript
import JsonTree.Behaviour as Behaviour
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  _ <- runUI rootComponent unit body
  H.liftEffect Behaviour.install   -- single + dblclick + copy
```

`Behaviour.install` is idempotent within a page load — call it once.

## 4. Render a tree

```purescript
import JsonTree as JsonTree

view someJson =
  HH.div [ HP.class_ (HH.ClassName "json-tree-wrapper") ]
    [ JsonTree.render someJson ]
```

That's it.
[Usage →](usage.md){ .md-button .md-button--primary }

---

## JavaScript

For consumers who don't run a PureScript toolchain. Pull the ES
module bundle from the GitHub Release and `import` it from your
HTML or your JS bundler.

### 1. Grab the bundle and the stylesheet

Every GitHub Release ships two standalone assets:

| Asset | What |
| --- | --- |
| `browser-json-tree-<version>.js` | ES module exporting `mount`, `mountFromString`, `install`. ~180 KB unminified (Halogen runtime is included). |
| `json-tree-<version>.css` | The canonical stylesheet. Theme via `--jt-*` custom properties. |

Drop both next to your app, or fetch via a CDN that proxies the
release assets (e.g. `https://github.com/lambdasistemi/browser-json-tree/releases/download/v<version>/browser-json-tree-<version>.js`).

### 2. Wire it up

```html
<link rel="stylesheet" href="./json-tree.css" />

<div id="tree" class="json-tree-wrapper"></div>

<script type="module">
  import {
    mount, mountFromString, install
  } from "./browser-json-tree.js";

  // Call once at boot. Wires single-click toggle, dblclick
  // recursive expand, and the .v-copy clipboard handler.
  install();

  // Mount under an existing element. Either pass an already-parsed
  // value (`mount`) or a raw JSON string (`mountFromString`).
  const data = await fetch("/api/some-payload").then(r => r.json());
  mount(document.getElementById("tree"), data);
</script>
```

`mount` takes over the element — any existing children are removed.
`mountFromString` throws a JavaScript `Error` on parse failure, so
catch it if your input is untrusted:

```js
try {
  mountFromString(el, untrustedString);
} catch (e) {
  console.error("Invalid JSON:", e.message);
}
```

### 3. (Optional) Vendor it into a bundler

If you already build with esbuild / Vite / webpack, drop the
`browser-json-tree.js` file into your assets directory and import it
the same way — the bundle is plain ESM with no external runtime
dependencies.

The bundle is **the** entire library: it includes the renderer, the
default Cardano resolver, and the behaviour shim. The CSS stays
separate (`json-tree.css`) so consumers can theme without rebuilding.

### What you trade

The JS bundle is convenient but bigger than a hand-rolled tree
renderer. ~180 KB unminified, ~50 KB gzipped — most of that is the
Halogen virtual DOM driver. If bundle size matters more than
ergonomics, render the tree yourself (the renderer's source is ~300
lines of PureScript; the algorithm is simpler when you don't need
Halogen's reconciliation guarantees).

[Usage →](usage.md){ .md-button .md-button--primary }
