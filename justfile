default:
    @just --list

# Build the library (compile only — no bundle, this is a library).
build:
    spago build

# Watch the library compilation for development.
dev:
    spago build --watch

# Lint formatting with purs-tidy.
lint:
    purs-tidy check 'src/**/*.purs'

# Apply purs-tidy formatting in place.
format:
    purs-tidy format-in-place 'src/**/*.purs' 'examples/src/**/*.purs'

# Build the JS-facing ES module bundle. Output: dist/browser-json-tree.js
js-bundle:
    spago bundle --module JsonTree.JS --outfile dist/browser-json-tree.js

# Build the example app via spago bundle (run inside examples/).
example-bundle:
    cd examples && spago bundle --module Main --outfile dist/index.js

# Build the example app the same way nix does, end-to-end.
example: example-bundle

# Build the full docs site (mkdocs + bundled demo + JS lib + CSS).
docs:
    just js-bundle
    just example-bundle
    mkdir -p docs/assets
    cp dist/json-tree.css                 docs/assets/json-tree.css
    cp dist/browser-json-tree.js          docs/assets/browser-json-tree.js
    cp examples/dist/index.js             docs/assets/demo.js
    cp examples/dist/demo.css             docs/assets/demo.css
    mkdocs build --strict --site-dir _site
    @echo "Docs built into ./_site"

# Serve the docs locally with live reload. Run `just docs` once first.
docs-serve:
    mkdocs serve

# Local mirror of CI: runs every check in the sandbox.
ci:
    nix flake check --no-eval-cache

# Generate / refresh spago.lock + package-lock.json. Run inside `nix develop`.
install:
    spago install
    cd examples && spago install
