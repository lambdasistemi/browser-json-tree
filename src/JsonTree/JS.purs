-- | Vanilla-JS adaptor over `JsonTree.render` +
-- | `JsonTree.Behaviour.install`. PureScript consumers should
-- | reach for `JsonTree.render` / `renderWith` directly inside
-- | their own Halogen components; this module exists so that
-- | a plain JavaScript application can drop in the bundled
-- | `dist/browser-json-tree.js` and call:
-- |
-- | ```js
-- | import { mount, mountFromString, install }
-- |   from "./browser-json-tree.js";
-- |
-- | install();
-- | mount(document.getElementById("tree"), someJsonValue);
-- | // or:
-- | mountFromString(
-- |   document.getElementById("tree"),
-- |   '{"hello":"world"}'
-- | );
-- | ```
-- |
-- | The mounted element is taken over by a Halogen instance —
-- | any existing children are removed.
module JsonTree.JS
  ( mount
  , mountFromString
  , install
  ) where

import Prelude

import Data.Argonaut.Core (Json)
import Data.Argonaut.Parser (jsonParser)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Exception (throw) as Exception
import Halogen as H
import Halogen.Aff (runHalogenAff)
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)
import JsonTree as JsonTree
import JsonTree.Behaviour as Behaviour
import Web.HTML.HTMLElement (HTMLElement)

-- | Mount the typed renderer under `target`. Default `Config`
-- | applies — Cardano-aware string resolution, empty values
-- | hidden, compound nodes collapsed.
mount :: HTMLElement -> Json -> Effect Unit
mount target j = runHalogenAff do
  _ <- runUI (treeComponent j) unit target
  pure unit

-- | Same as `mount` but takes an unparsed JSON string. Throws
-- | a JavaScript `Error` if parsing fails — catch it on the JS
-- | side if your input is untrusted.
mountFromString :: HTMLElement -> String -> Effect Unit
mountFromString target s = case jsonParser s of
  Right j -> mount target j
  Left e ->
    Exception.throw $ "JsonTree: failed to parse JSON: " <> e

-- | Re-export of `JsonTree.Behaviour.install`. Idempotent
-- | enough per page load to call once at boot.
install :: Effect Unit
install = Behaviour.install

treeComponent :: forall q i o. Json -> H.Component q i o Aff
treeComponent j =
  H.mkComponent
    { initialState: const unit
    , render: const view
    , eval: H.mkEval H.defaultEval
    }
  where
  view =
    HH.div
      [ HP.class_ (HH.ClassName "json-tree-wrapper") ]
      [ JsonTree.render j ]
