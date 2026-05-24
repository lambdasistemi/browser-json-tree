-- | Default Cardano-aware string-leaf resolver.
-- |
-- | Detects four shapes:
-- |
-- |   * 64-char lowercase hex — transaction id;
-- |   * `<64-char hex>#<digits>` — txin (transaction output
-- |     reference, sent to cardanoscan's UTxO tab);
-- |   * `addr1…` bech32 — mainnet address;
-- |   * 56-char lowercase hex — minting policy id.
-- |
-- | Each maps to a short-form display + cardanoscan link.
-- | Non-Cardano consumers compose their own
-- | `String -> Maybe JsonTree.LinkSpec` and pass it in via
-- | `JsonTree.defaultConfig { resolveString = ... }`.
module JsonTree.Cardano
  ( resolve
  , isTxidHex
  , isBech32Addr
  , isPolicyHex
  , parseTxin
  , shortHex
  , shortAddr
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Data.String as String
import Data.String.CodePoints as CodePoints
import Data.String.Regex (Regex, test) as Regex
import Data.String.Regex.Flags (noFlags) as Regex
import Data.String.Regex.Unsafe (unsafeRegex) as Regex

-- | The shape returned to `JsonTree.renderWith`; mirrored here
-- | rather than imported to avoid a cyclic module dependency.
type LinkSpec =
  { cls :: String
  , href :: String
  , short :: String
  }

resolve :: String -> Maybe LinkSpec
resolve s
  | isTxidHex s = Just
      { cls: "v-txid"
      , href: "https://cardanoscan.io/transaction/" <> s
      , short: shortHex s
      }
  | Just { txid, ix } <- parseTxin s = Just
      { cls: "v-txin"
      , href: "https://cardanoscan.io/transaction/" <> txid <> "?tab=utxo"
      , short: shortHex txid <> "#" <> ix
      }
  | isBech32Addr s = Just
      { cls: "v-addr"
      , href: "https://cardanoscan.io/address/" <> s
      , short: shortAddr s
      }
  | isPolicyHex s = Just
      { cls: "v-policy"
      , href: "https://cardanoscan.io/tokenPolicy/" <> s
      , short: shortHex s
      }
  | otherwise = Nothing

isTxidHex :: String -> Boolean
isTxidHex s = Regex.test reTxid s

isPolicyHex :: String -> Boolean
isPolicyHex s = Regex.test rePolicy s

isBech32Addr :: String -> Boolean
isBech32Addr s = String.take 5 s == "addr1"

-- | Recognise a Cardano transaction-output reference (a.k.a.
-- | txin) in the canonical `<txid>#<ix>` form and split it
-- | back into its components. The index is kept as a string
-- | so callers control formatting (Cardano sometimes prints
-- | leading-zero forms in JSON payloads).
parseTxin :: String -> Maybe { txid :: String, ix :: String }
parseTxin s = case String.split (String.Pattern "#") s of
  [ txid, ix ]
    | Regex.test reTxid txid
    , ix /= ""
    , Regex.test reIndex ix ->
        Just { txid, ix }
  _ -> Nothing

reTxid :: Regex.Regex
reTxid = Regex.unsafeRegex "^[0-9a-f]{64}$" Regex.noFlags

rePolicy :: Regex.Regex
rePolicy = Regex.unsafeRegex "^[0-9a-f]{56}$" Regex.noFlags

reIndex :: Regex.Regex
reIndex = Regex.unsafeRegex "^[0-9]+$" Regex.noFlags

shortHex :: String -> String
shortHex s =
  let
    head_ = CodePoints.take 8 s
    tail_ = CodePoints.drop (CodePoints.length s - 6) s
  in
    head_ <> "…" <> tail_

shortAddr :: String -> String
shortAddr s =
  let
    head_ = CodePoints.take 9 s
    tail_ = CodePoints.drop (CodePoints.length s - 6) s
  in
    head_ <> "…" <> tail_
