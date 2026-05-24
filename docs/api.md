# API

## `JsonTree`

The renderer surface. Import as `JsonTree`.

```purescript
type LinkSpec =
  { cls   :: String   -- CSS class applied to the <a>
  , href  :: String   -- destination URL
  , short :: String   -- truncated display text
  }

type Config =
  { initiallyOpen :: Boolean
  , hideEmpty     :: Boolean
  , resolveString :: String -> Maybe LinkSpec
  }

defaultConfig :: Config
-- { initiallyOpen: false
-- , hideEmpty: true
-- , resolveString: JsonTree.Cardano.resolve
-- }

render     :: forall w i. Json -> HH.HTML w i
renderWith :: forall w i. Config -> Json -> HH.HTML w i
```

### `Config.initiallyOpen`

When `true`, every compound node renders with the HTML `open`
attribute set — the tree starts fully expanded. The reader can still
collapse on click. Default: `false`.

### `Config.hideEmpty`

When `true`, object entries whose value is `null`, `[]`, or `{}` are
dropped before rendering. Useful for payloads with optional fields
that the producer sets to `null` rather than omitting. Default: `true`.

### `Config.resolveString`

The string-leaf resolver. Given a JSON string, return `Nothing` to
render it as a plain `.v-str` text leaf, or `Just LinkSpec` to render
it as a truncated `<a>` link. Default: `JsonTree.Cardano.resolve`.

## `JsonTree.Behaviour`

```purescript
install :: Effect Unit
```

Attaches the three document-level listeners described in
[Usage → The behaviour shim](usage.md#the-behaviour-shim). Call once
from your application's `main`.

## `JsonTree.Cardano`

The default resolver, covering four Cardano string shapes routed to
`cardanoscan.io`.

```purescript
resolve :: String -> Maybe LinkSpec

-- Detection helpers (also exported for direct use).
isTxidHex     :: String -> Boolean   -- 64-char lowercase hex
isPolicyHex   :: String -> Boolean   -- 56-char lowercase hex
isBech32Addr  :: String -> Boolean   -- starts with "addr1"
parseTxin     :: String -> Maybe { txid :: String, ix :: String }

-- Truncation helpers (also exported).
shortHex      :: String -> String
shortAddr     :: String -> String
```

The four shapes the default resolver handles, in detection order:

| Input shape | Class | Destination |
| --- | --- | --- |
| 64-char lowercase hex | `v-txid` | `/transaction/<txid>` |
| `<txid>#<digits>` | `v-txin` | `/transaction/<txid>?tab=utxo` |
| `addr1…` bech32 | `v-addr` | `/address/<addr>` |
| 56-char lowercase hex | `v-policy` | `/tokenPolicy/<policy>` |

Detection order matters: `isTxidHex` first (64 hex chars with no `#`
is a txid), then `parseTxin` (anything with a `#` separator and
txid-shaped LHS), then `addr1…`, then 56-char policy.

## `JsonTree.JS` (vanilla JS surface)

Bundled to `dist/browser-json-tree.js` (also shipped as a release
asset). Use this from a `<script type="module">` or a JS bundler —
do **not** use it from PureScript (call `JsonTree.render` directly
in your Halogen tree instead).

```purescript
mount           :: HTMLElement -> Json   -> Effect Unit
mountFromString :: HTMLElement -> String -> Effect Unit
install         :: Effect Unit
```

| Export | JS signature | Notes |
| --- | --- | --- |
| `mount(el, json)` | `(Element, unknown) => void` | Takes over `el`; existing children are removed. Default `Config`. |
| `mountFromString(el, jsonText)` | `(Element, string) => void` | Throws a JS `Error` if parsing fails. |
| `install()` | `() => void` | Re-export of `JsonTree.Behaviour.install`. Call once at boot. |

`mount` cannot be reconfigured per-call — the JS surface deliberately
keeps the default `Config` (Cardano resolver, collapsed by default,
empty values hidden). If you need a custom resolver from JS, render
through PureScript instead; the JS surface is a convenience over the
Halogen surface, not a configurable framework in its own right.

## Writing a custom resolver

```purescript
import Data.Maybe (Maybe(..))
import Data.String as String
import JsonTree (Config, LinkSpec, defaultConfig)

evmHashResolver :: String -> Maybe LinkSpec
evmHashResolver s
  | String.length s == 66
  , String.take 2 s == "0x" = Just
      { cls: "v-evm-tx"
      , href: "https://etherscan.io/tx/" <> s
      , short: String.take 10 s <> "…" <> String.drop (String.length s - 6) s
      }
  | otherwise = Nothing

myConfig :: Config
myConfig = defaultConfig { resolveString = evmHashResolver }
```

The `cls` you return is used as the `<a>`'s class — add a matching
rule to your stylesheet and the link picks up your design tokens.
