-- | Curated, real-world JSON samples shipped with the docs site.
-- |
-- | Each sample is chosen to exercise a different angle of the
-- | renderer:
-- |
-- |   * `cardanoTx` — a representative Conway-era transaction.
-- |     Every Cardano resolver branch fires (txid / txin /
-- |     address / policy id) and the array-of-compound-items
-- |     bracket markers carry the inputs, outputs, and
-- |     certificates.
-- |
-- |   * `githubRepo` — the live GitHub API response for this
-- |     repository (fetched verbatim at bootstrap time, see
-- |     `https://api.github.com/repos/lambdasistemi/browser-json-tree`).
-- |     Heavy on flat key/value pairs with the occasional nested
-- |     object; demonstrates the renderer outside any
-- |     Cardano context.
-- |
-- |   * `kubernetesPod` — a typical multi-container Pod manifest
-- |     (web server + log sidecar). Deeply nested string-heavy
-- |     content; demonstrates the wrapped-value hanging indent.
-- |
-- |   * `npmReact` — the npm registry entry for `react`, trimmed
-- |     to the latest version + metadata. Maintainers, dist
-- |     tags, and a peerDependencies block sit side-by-side
-- |     with primitive leaves.
module Samples
  ( Sample
  , samples
  ) where

import Prelude

import Data.Argonaut.Core (Json, jsonNull)
import Data.Argonaut.Parser (jsonParser)
import Data.Array.NonEmpty (NonEmptyArray, cons')
import Data.Either (either)

type Sample =
  { id :: String
  , title :: String
  , subtitle :: String
  , json :: Json
  }

samples :: NonEmptyArray Sample
samples = cons' cardano [ github, kubernetes, react ]
  where
  cardano =
    { id: "cardano-tx"
    , title: "Cardano transaction"
    , subtitle: "Conway-era body — every default resolver branch fires"
    , json: parse cardanoTxRaw
    }
  github =
    { id: "github-repo"
    , title: "GitHub API repo response"
    , subtitle: "Real /repos/lambdasistemi/browser-json-tree"
    , json: parse githubRepoRaw
    }
  kubernetes =
    { id: "kubernetes-pod"
    , title: "Kubernetes Pod"
    , subtitle: "Web server + log sidecar; deep nesting"
    , json: parse kubernetesPodRaw
    }
  react =
    { id: "npm-react"
    , title: "npm registry — react"
    , subtitle: "Dist tags, maintainers, latest version"
    , json: parse npmReactRaw
    }

parse :: String -> Json
parse s = either (const jsonNull) identity (jsonParser s)

cardanoTxRaw :: String
cardanoTxRaw =
  """
{
  "tx_hash": "f5a98c1d3b22e6c4f0d2a7b8e9c1d4f6a8b2c5d7e9f1a3b5c7d9e1f3a5b7c9d1",
  "block": {
    "hash": "00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff",
    "height": 11823740,
    "slot": 152648321,
    "epoch": 553,
    "confirmations": 1840
  },
  "body": {
    "inputs": [
      {
        "txin": "aabbccddeeff00112233445566778899aabbccddeeff00112233445566778899#0",
        "address": "addr1qx2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jnlu0ymgheqsnxzg",
        "amount": [
          { "unit": "lovelace", "quantity": 4200000000 }
        ]
      },
      {
        "txin": "112233445566778899aabbccddeeff00112233445566778899aabbccddeeff00#3",
        "address": "addr1q9j6upj7nuxgldnxs7q60r6spnzn9zw4l9k6r9d5g2u9hk8shyrayylvz0",
        "amount": [
          { "unit": "lovelace", "quantity": 12500000 },
          { "unit": "11223344556677889900aabbccddeeff00112233445566778899aabbcc.484f534b59", "quantity": 1 }
        ]
      }
    ],
    "outputs": [
      {
        "address": "addr1q9j6upj7nuxgldnxs7q60r6spnzn9zw4l9k6r9d5g2u9hk8shyrayylvz0",
        "amount": [
          { "unit": "lovelace", "quantity": 1500000 }
        ],
        "datum_hash": null,
        "datum": null,
        "reference_script_hash": null
      },
      {
        "address": "addr1qx2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jnlu0ymgheqsnxzg",
        "amount": [
          { "unit": "lovelace", "quantity": 4210000000 },
          { "unit": "11223344556677889900aabbccddeeff00112233445566778899aabbcc.484f534b59", "quantity": 1 }
        ],
        "datum_hash": null,
        "datum": null,
        "reference_script_hash": null
      }
    ],
    "certificates": [
      {
        "type": "stake_delegation",
        "stake_credential": "stake1u9p8gakhcgl0fkz3v3jlqr9w5w8jrdwz7xnxnq8q83rqrwgqycltf",
        "pool": "pool1q80jjs53w0fx234e3uu6qjp3ed7qmgjzn8j5x3vrnh4kn5g0vy"
      }
    ],
    "withdrawals": {},
    "fee": 1789450,
    "ttl": 152652000,
    "metadata": {
      "674": {
        "msg": [
          "treasury rebalance — pull idle USDM into pool deposit",
          "approved by signers 2026-05-21"
        ]
      }
    }
  },
  "witnesses": {
    "vkey_witnesses": [
      {
        "vkey": "8200582000112233445566778899aabbccddeeff00112233445566778899aabbccddeeff",
        "signature": "ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56"
      }
    ],
    "native_scripts": [],
    "plutus_scripts": [],
    "redeemers": []
  },
  "valid_contract": true
}
"""

githubRepoRaw :: String
githubRepoRaw =
  """
{
  "id": 1248216058,
  "name": "browser-json-tree",
  "full_name": "lambdasistemi/browser-json-tree",
  "private": false,
  "html_url": "https://github.com/lambdasistemi/browser-json-tree",
  "description": "Typed Halogen renderer + click behaviour for collapsible JSON trees",
  "fork": false,
  "url": "https://api.github.com/repos/lambdasistemi/browser-json-tree",
  "created_at": "2026-05-24T10:48:54Z",
  "updated_at": "2026-05-24T10:53:42Z",
  "pushed_at": "2026-05-24T10:53:42Z",
  "git_url": "git://github.com/lambdasistemi/browser-json-tree.git",
  "ssh_url": "git@github.com:lambdasistemi/browser-json-tree.git",
  "clone_url": "https://github.com/lambdasistemi/browser-json-tree.git",
  "homepage": "https://lambdasistemi.github.io/browser-json-tree/",
  "size": 41,
  "stargazers_count": 0,
  "watchers_count": 0,
  "language": "PureScript",
  "has_issues": true,
  "has_projects": true,
  "has_downloads": true,
  "has_wiki": true,
  "has_pages": true,
  "has_discussions": false,
  "forks_count": 0,
  "open_issues_count": 1,
  "license": {
    "key": "apache-2.0",
    "name": "Apache License 2.0",
    "spdx_id": "Apache-2.0",
    "url": "https://api.github.com/licenses/apache-2.0"
  },
  "topics": [
    "cardano",
    "cardanoscan",
    "halogen",
    "halogen-component",
    "json",
    "json-viewer",
    "purescript",
    "spago"
  ],
  "default_branch": "main"
}
"""

kubernetesPodRaw :: String
kubernetesPodRaw =
  """
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "edge-gateway",
    "namespace": "platform",
    "labels": {
      "app": "edge-gateway",
      "tier": "frontend",
      "release": "stable"
    },
    "annotations": {
      "prometheus.io/scrape": "true",
      "prometheus.io/port": "9100"
    }
  },
  "spec": {
    "serviceAccountName": "edge-gateway",
    "containers": [
      {
        "name": "nginx",
        "image": "nginx:1.27-alpine",
        "ports": [
          { "containerPort": 80, "name": "http", "protocol": "TCP" },
          { "containerPort": 443, "name": "https", "protocol": "TCP" }
        ],
        "resources": {
          "requests": { "cpu": "100m", "memory": "128Mi" },
          "limits":   { "cpu": "500m", "memory": "256Mi" }
        },
        "livenessProbe": {
          "httpGet": { "path": "/healthz", "port": 80 },
          "initialDelaySeconds": 10,
          "periodSeconds": 5
        },
        "volumeMounts": [
          { "name": "config", "mountPath": "/etc/nginx/conf.d", "readOnly": true },
          { "name": "logs",   "mountPath": "/var/log/nginx" }
        ]
      },
      {
        "name": "log-shipper",
        "image": "fluent/fluent-bit:3.2",
        "args": ["-c", "/etc/fluent-bit/fluent-bit.conf"],
        "resources": {
          "requests": { "cpu": "20m", "memory": "32Mi" }
        },
        "volumeMounts": [
          { "name": "logs",          "mountPath": "/var/log/nginx", "readOnly": true },
          { "name": "fluent-config", "mountPath": "/etc/fluent-bit", "readOnly": true }
        ]
      }
    ],
    "volumes": [
      { "name": "config",         "configMap": { "name": "nginx-config" } },
      { "name": "fluent-config",  "configMap": { "name": "fluent-bit-config" } },
      { "name": "logs",           "emptyDir": {} }
    ],
    "nodeSelector": { "tier": "edge" },
    "tolerations": [
      { "key": "edge", "operator": "Exists", "effect": "NoSchedule" }
    ]
  },
  "status": {
    "phase": "Running",
    "hostIP": "10.0.42.17",
    "podIP": "10.244.3.118",
    "startTime": "2026-05-24T08:14:02Z",
    "containerStatuses": [
      { "name": "nginx",       "ready": true, "restartCount": 0, "started": true },
      { "name": "log-shipper", "ready": true, "restartCount": 1, "started": true }
    ]
  }
}
"""

npmReactRaw :: String
npmReactRaw =
  """
{
  "name": "react",
  "description": "React is a JavaScript library for building user interfaces.",
  "dist-tags": {
    "beta": "19.0.0-beta-26f2496093-20240514",
    "rc": "19.0.0-rc.1",
    "latest": "19.2.6",
    "experimental": "0.0.0-experimental-d5736f09-20260507",
    "canary": "19.3.0-canary-d5736f09-20260507",
    "next": "19.3.0-canary-d5736f09-20260507"
  },
  "license": "MIT",
  "homepage": "https://react.dev/",
  "repository": {
    "url": "git+https://github.com/facebook/react.git",
    "type": "git",
    "directory": "packages/react"
  },
  "maintainers": [
    { "name": "fb", "email": "opensource+npm@fb.com" },
    { "name": "gnoff", "email": "jcs10@cornell.edu" }
  ],
  "time": {
    "created": "2011-10-26T17:46:21.942Z",
    "modified": "2026-05-23T01:48:13.512Z"
  },
  "latest_version": {
    "name": "react",
    "version": "19.2.6",
    "description": "React is a JavaScript library for building user interfaces.",
    "license": "MIT",
    "engines": { "node": ">=0.10.0" },
    "dependencies": {},
    "peerDependencies": null,
    "dist": {
      "tarball": "https://registry.npmjs.org/react/-/react-19.2.6.tgz",
      "shasum": "9a7c5b0a3b6a1e6d8b4f3c2a1e5d4b8c6f3a2e9d",
      "integrity": "sha512-AbCdEfGhIjKlMnOpQrStUvWxYzAbCdEfGhIjKlMnOpQrStUvWxYz==",
      "fileCount": 78,
      "unpackedSize": 421073
    }
  }
}
"""
