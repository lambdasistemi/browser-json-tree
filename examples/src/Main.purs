module Main (main) where

import Prelude

import Data.Argonaut.Core (stringify)
import Data.Array (mapWithIndex)
import Data.Array.NonEmpty as NEA
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)
import JsonTree as JsonTree
import JsonTree.Behaviour as Behaviour
import Samples (Sample, samples)
import Web.DOM.ParentNode (QuerySelector(..))

-- | Entry point. Mount to `#json-tree-demo` if the host page
-- | provides one (the docs site does); otherwise mount to the
-- | document body so the standalone `examples/dist/index.html`
-- | bundle keeps working as an end-to-end smoke artefact.
main :: Effect Unit
main = HA.runHalogenAff do
  HA.awaitLoad
  mTarget <- HA.selectElement (QuerySelector "#json-tree-demo")
  target <- case mTarget of
    Just el -> pure el
    Nothing -> HA.awaitBody
  _ <- runUI rootComponent unit target
  H.liftEffect Behaviour.install

type State = { current :: Sample }

data Action = Pick Sample

rootComponent :: forall q i o. H.Component q i o Aff
rootComponent =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction }
    }
  where
  initialState :: i -> State
  initialState _ = { current: NEA.head samples }

  handleAction :: Action -> H.HalogenM State Action () o Aff Unit
  handleAction = case _ of
    Pick s -> H.modify_ \st -> st { current = s }

  render :: State -> H.ComponentHTML Action () Aff
  render st =
    HH.div [ HP.class_ (HH.ClassName "jt-demo") ]
      [ HH.div [ HP.class_ (HH.ClassName "jt-demo__picker") ]
          (mapWithIndex (sampleButton st.current) (NEA.toArray samples))
      , HH.p [ HP.class_ (HH.ClassName "jt-demo__subtitle") ]
          [ HH.text st.current.subtitle ]
      , HH.div [ HP.class_ (HH.ClassName "jt-demo__chrome") ]
          [ HH.div [ HP.class_ (HH.ClassName "jt-demo__bar") ]
              [ HH.button
                  [ HP.classes
                      [ HH.ClassName "v-copy"
                      , HH.ClassName "v-copy--block"
                      ]
                  , HP.attr (HH.AttrName "data-copy") (stringify st.current.json)
                  , HP.attr (HH.AttrName "aria-label") "Copy JSON"
                  , HP.title "Copy the displayed JSON to the clipboard"
                  , HP.type_ HP.ButtonButton
                  ]
                  [ HH.text "⎘ Copy JSON" ]
              ]
          , HH.div [ HP.class_ (HH.ClassName "json-tree-wrapper") ]
              [ JsonTree.render st.current.json ]
          , HH.p [ HP.class_ (HH.ClassName "jt-demo__hint") ]
              [ HH.text "Single click → toggle one level (closing cascades) · Double click → expand recursively · Links open cardanoscan in a new tab" ]
          ]
      ]

  sampleButton :: Sample -> Int -> Sample -> H.ComponentHTML Action () Aff
  sampleButton current _ s =
    HH.button
      [ HP.classes
          -- `md-button` makes the chip ride Material for MkDocs'
          -- own button design tokens inside the docs site; the
          -- `jt-demo__pick` fallback class keeps the standalone
          -- `examples/dist/index.html` smoke looking presentable
          -- when Material isn't on the page.
          ( [ HH.ClassName "md-button"
            , HH.ClassName "jt-demo__pick"
            ]
              <>
                ( if s.id == current.id then
                    [ HH.ClassName "md-button--primary"
                    , HH.ClassName "jt-demo__pick--active"
                    ]
                  else []
                )
          )
      , HP.type_ HP.ButtonButton
      , HE.onClick (\_ -> Pick s)
      ]
      [ HH.text s.title ]
