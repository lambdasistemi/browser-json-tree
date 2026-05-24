-- | Document-level interaction wiring for `JsonTree`-rendered
-- | trees. Native `<details>` already gives single-click toggle
-- | for free, but it doesn't:
-- |
-- |   * cascade close to descendants (so a re-opened subtree
-- |     would re-expand fully because the descendant `open`
-- |     attributes never got cleared);
-- |   * offer a recursive-expand gesture for "show me
-- |     everything";
-- |   * wire structure-level copy chips (`.v-copy` /
-- |     `.v-copy.v-copy--block`) — the consumer renders the
-- |     chip above the tree with a `data-copy` attribute and
-- |     the install handler writes its value to
-- |     `navigator.clipboard` on click.
-- |
-- | All three behaviours are installed with a single document
-- | listener triple. Summary handlers filter on the
-- | `v-key-toggle` and `v-sep-toggle` classes, so other native
-- | `<details>` on the host page keep stock behaviour. The
-- | copy handler fires in the capture phase so clicking the
-- | chip never bubbles up and toggles a surrounding
-- | `<details>`.
module JsonTree.Behaviour
  ( install
  ) where

import Prelude

import Effect (Effect)

-- | Install the click + dblclick listeners. Call once from the
-- | application's `main`. Calling twice attaches twice, so
-- | guard at the call site if you need idempotence.
foreign import install :: Effect Unit
