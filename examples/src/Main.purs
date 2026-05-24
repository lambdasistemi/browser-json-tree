module Main (main) where

import Prelude

import Data.Argonaut.Core (Json, jsonNull, stringify)
import Data.Argonaut.Parser (jsonParser)
import Data.Either (either)
import Effect (Effect)
import Effect.Aff (Aff)
import Halogen as H
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
  H.liftEffect Behaviour.install

rootComponent :: forall q i o. H.Component q i o Aff
rootComponent =
  H.mkComponent
    { initialState: const unit
    , render: const view
    , eval: H.mkEval H.defaultEval
    }
  where
  view =
    HH.div [ HP.class_ (HH.ClassName "panel") ]
      [ HH.h1_ [ HH.text "browser-json-tree — example" ]
      , HH.div [ HP.class_ (HH.ClassName "json-tree-wrapper") ]
          -- Structure-level "Copy JSON" chip. The library
          -- ships the CSS (`.v-copy.v-copy--block`) and the
          -- behaviour (`Behaviour.install` reads `data-copy`
          -- and writes to navigator.clipboard, then flashes
          -- `.v-copy--ok`). Consumers render the chip; the
          -- library wires the rest.
          [ HH.button
              [ HP.classes
                  [ HH.ClassName "v-copy"
                  , HH.ClassName "v-copy--block"
                  ]
              , HP.attr (HH.AttrName "data-copy") (stringify sample)
              , HP.attr (HH.AttrName "aria-label") "Copy JSON"
              , HP.title "Copy the whole sample as JSON"
              , HP.type_ HP.ButtonButton
              ]
              [ HH.text "⎘ Copy JSON" ]
          , JsonTree.render sample
          ]
      ]

-- | Sample chosen to exercise every renderer branch: nested
-- | objects, arrays of leaves, arrays of compound items, the
-- | four default Cardano shapes the resolver knows about
-- | (txid, txin `<txid>#<ix>`, policy id, addr1 bech32), an
-- | empty object (hidden by `Config.hideEmpty`), a null, a
-- | bool, a number, a plain string. `jsonNull` is the safe
-- | fallback if the literal ever stops parsing during
-- | refactoring.
sample :: Json
sample = either (const jsonNull) identity (jsonParser raw)
  where
  raw =
    """
    {
      "tx_hash": "00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff",
      "txin":    "aabbccddeeff00112233445566778899aabbccddeeff00112233445566778899#1",
      "policy":  "11223344556677889900aabbccddeeff00112233445566778899aabbcc",
      "address": "addr1qx2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jnlu0ymgheqsnxzg",
      "amount":  1500000,
      "valid":   true,
      "missing": null,
      "label":   "treasury rebalance",
      "tags":    [ "draft", "reviewed", "shipped" ],
      "deltas":  [
        { "kind": "withdraw", "amount": 1000, "memo": "fees" },
        { "kind": "deposit",  "amount": 2500, "memo": "" }
      ],
      "metadata": {}
    }
    """
