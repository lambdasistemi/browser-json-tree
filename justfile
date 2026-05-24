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
    purs-tidy format-in-place 'src/**/*.purs'

# Build the example app via spago bundle (run inside examples/).
example-bundle:
    cd examples && spago bundle --module Main --outfile dist/index.js

# Build the example app the same way nix does, end-to-end.
example: example-bundle

# Local mirror of CI: runs every check in the sandbox.
ci:
    nix flake check --no-eval-cache

# Generate / refresh spago.lock + package-lock.json. Run inside `nix develop`.
install:
    spago install
    cd examples && spago install
