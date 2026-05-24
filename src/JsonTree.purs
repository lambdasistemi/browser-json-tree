-- | Typed Halogen renderer for a `Data.Argonaut.Core.Json` value.
-- |
-- | Walks the JSON tree and emits collapsed/expanded HTML using
-- | native `<details>` + `<summary>` for object keys and array
-- | indices. String leaves are passed through a configurable
-- | resolver that may upgrade them into truncated <a> links with
-- | a copy-to-clipboard button (see `JsonTree.Cardano` for the
-- | default implementation that handles txids, addresses and
-- | policy ids).
-- |
-- | The companion `JsonTree.Behaviour.install` wires up the
-- | document-level click semantics (one-level open, cascade close,
-- | double-click recursive expand). The companion stylesheet at
-- | `dist/json-tree.css` carries the layout + theming knobs.
module JsonTree
  ( render
  , renderWith
  , Config
  , defaultConfig
  , LinkSpec
  ) where

import Prelude

import Data.Argonaut.Core (Json, caseJson)
import Data.Array as Array
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..), snd)
import Foreign.Object as FO
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import JsonTree.Cardano as Cardano

-- | A resolved link for a string leaf. The renderer wraps this in
-- | a truncated `<a>` + a small copy-to-clipboard `<button>`.
type LinkSpec =
  { cls :: String
  -- ^ CSS class applied to the <a> (e.g. `"v-txid"`).
  , href :: String
  -- ^ Destination URL.
  , short :: String
  -- ^ Truncated display text shown inside the <a>.
  }

-- | Render-time knobs.
-- |
-- | * `initiallyOpen` — every compound node starts expanded
-- |   instead of collapsed. The default is closed so readers
-- |   drive the unfold; flip for inspector-style pages.
-- |
-- | * `hideEmpty` — object entries whose value is `null`, `[]`
-- |   or `{}` are skipped. The default is on so the rendered
-- |   tree stays scannable when source JSON carries inert
-- |   placeholder keys.
-- |
-- | * `resolveString` — given a raw string leaf, optionally
-- |   return a `LinkSpec`. Returning `Nothing` falls back to a
-- |   plain text leaf. The default resolves Cardano txids,
-- |   addresses and policy ids to cardanoscan links; a
-- |   non-Cardano consumer overrides with their own.
type Config =
  { initiallyOpen :: Boolean
  , hideEmpty :: Boolean
  , resolveString :: String -> Maybe LinkSpec
  }

defaultConfig :: Config
defaultConfig =
  { initiallyOpen: false
  , hideEmpty: true
  , resolveString: Cardano.resolve
  }

-- | Render with `defaultConfig`.
render :: forall w i. Json -> HH.HTML w i
render = renderWith defaultConfig

-- | Render with caller-supplied configuration.
renderWith :: forall w i. Config -> Json -> HH.HTML w i
renderWith = renderValue

openProp
  :: forall r i
   . Config
  -> Array (HH.IProp (open :: Boolean | r) i)
openProp cfg =
  if cfg.initiallyOpen then
    [ HP.prop (HH.PropName "open") true ]
  else []

renderValue :: forall w i. Config -> Json -> HH.HTML w i
renderValue cfg j =
  caseJson
    (\_ -> HH.span [ HP.classes [ HH.ClassName "v-null" ] ] [ HH.text "null" ])
    (\b -> HH.span [ HP.classes [ HH.ClassName "v-bool" ] ] [ HH.text (show b) ])
    (\n -> HH.span [ HP.classes [ HH.ClassName "v-num" ] ] [ HH.text (showNum n) ])
    (renderStringValue cfg)
    (renderArray cfg)
    (renderObject cfg)
    j

isCompound :: Json -> Boolean
isCompound j =
  caseJson
    (\_ -> false)
    (\_ -> false)
    (\_ -> false)
    (\_ -> false)
    (\xs -> not (Array.null xs))
    (\o -> not (FO.isEmpty o))
    j

renderArray
  :: forall w i. Config -> Array Json -> HH.HTML w i
renderArray cfg xs =
  HH.ol
    [ HP.classes [ HH.ClassName "v-array" ] ]
    (Array.mapWithIndex (renderArrayItem cfg) xs)

renderArrayItem
  :: forall w i. Config -> Int -> Json -> HH.HTML w i
renderArrayItem cfg i v
  | isCompound v =
      HH.li
        [ HP.classes [ HH.ClassName "v-item v-item-compound" ] ]
        [ HH.details (openProp cfg)
            [ arraySepSummary i
            , HH.div
                [ HP.classes [ HH.ClassName "v-children" ] ]
                [ renderValue cfg v ]
            ]
        ]
  | otherwise =
      HH.li
        [ HP.classes [ HH.ClassName "v-item v-item-leaf" ] ]
        [ arraySep i
        , renderValue cfg v
        ]

-- | CAD-style measurement bracket: a vertical hairline capped
-- | with 90° ticks pointing at the content, with the 1-based
-- | cardinal index centered in the middle. Used for leaf items
-- | where no collapse target exists.
arraySep :: forall w i. Int -> HH.HTML w i
arraySep i =
  HH.div
    [ HP.classes [ HH.ClassName "v-sep" ] ]
    (arraySepChildren i)

arraySepSummary :: forall w i. Int -> HH.HTML w i
arraySepSummary i =
  HH.summary
    [ HP.classes [ HH.ClassName "v-sep v-sep-toggle" ] ]
    (arraySepChildren i)

arraySepChildren :: forall w i. Int -> Array (HH.HTML w i)
arraySepChildren i =
  [ HH.span [ HP.classes [ HH.ClassName "v-sep-line" ] ] []
  , HH.span
      [ HP.classes [ HH.ClassName "v-sep-label" ] ]
      [ HH.text (show (i + 1)) ]
  , HH.span [ HP.classes [ HH.ClassName "v-sep-line" ] ] []
  ]

renderObject
  :: forall w i. Config -> FO.Object Json -> HH.HTML w i
renderObject cfg obj =
  HH.div
    [ HP.classes [ HH.ClassName "v-object" ] ]
    ( map (renderEntry cfg)
        $ (if cfg.hideEmpty then Array.filter (not <<< isEmptyValue <<< snd) else identity)
        $ FO.toUnfoldable obj
    )

-- | A JSON value that carries no inspection signal: `null`, an
-- | empty array, or an empty object. Object entries with such
-- | values are dropped when `Config.hideEmpty` is on.
isEmptyValue :: Json -> Boolean
isEmptyValue =
  caseJson
    (\_ -> true)
    (\_ -> false)
    (\_ -> false)
    (\_ -> false)
    Array.null
    FO.isEmpty

renderEntry
  :: forall w i. Config -> Tuple String Json -> HH.HTML w i
renderEntry cfg (Tuple k v)
  | isCompound v =
      HH.details
        ([ HP.classes [ HH.ClassName "v-pair v-pair-compound" ] ] <> openProp cfg)
        [ HH.summary
            [ HP.classes [ HH.ClassName "v-key v-key-toggle" ] ]
            [ HH.text (k <> ":") ]
        , HH.div
            [ HP.classes [ HH.ClassName "v-children" ] ]
            [ renderValue cfg v ]
        ]
  | otherwise =
      HH.div
        [ HP.classes [ HH.ClassName "v-pair v-pair-leaf" ] ]
        [ HH.span [ HP.classes [ HH.ClassName "v-key" ] ] [ HH.text (k <> ":") ]
        , HH.text " "
        , HH.span
            [ HP.classes [ HH.ClassName "v-val" ] ]
            [ renderValue cfg v ]
        ]

renderStringValue :: forall w i. Config -> String -> HH.HTML w i
renderStringValue cfg s =
  case cfg.resolveString s of
    Just spec -> linked spec s
    Nothing ->
      HH.span
        [ HP.classes [ HH.ClassName "v-str" ] ]
        [ HH.text s ]

-- | A truncated link to the resolver's destination. The full
-- | string is preserved on the `title` tooltip; bulk copy is
-- | a structure-level affordance (a `.v-copy.v-copy--block`
-- | chip the consumer renders above the tree) — adding a copy
-- | button to every leaf clutters the tree visually.
linked
  :: forall w i. LinkSpec -> String -> HH.HTML w i
linked spec full =
  HH.a
    [ HP.classes [ HH.ClassName spec.cls ]
    , HP.href spec.href
    , HP.target "_blank"
    , HP.rel "noopener"
    , HP.title full
    ]
    [ HH.text spec.short ]

showNum :: Number -> String
showNum n =
  case Int.fromNumber n of
    Just i -> show i
    Nothing -> show n
