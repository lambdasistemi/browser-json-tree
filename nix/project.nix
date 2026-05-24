{ pkgs, src }:

let
  # `spago build --offline` of the library. Verifies the library
  # compiles cleanly against the pinned registry. We copy the
  # resulting `output/` to $out so consumers can introspect, but
  # the library is distributed as source — this derivation is a
  # compile-check, not a binary artifact.
  library = pkgs.mkSpagoDerivation {
    pname = "browser-json-tree";
    version = "0.1.0";
    inherit src;
    spagoYaml = ../spago.yaml;
    spagoLock = ../spago.lock;
    nativeBuildInputs = [
      pkgs.purs
      pkgs.spago-unstable
    ];
    buildPhase = ''
      spago build --offline
    '';
    installPhase = ''
      mkdir -p $out
      cp -r output $out/output
      cp -r src $out/src
      cp -r dist $out/dist
    '';
  };

  # JS-facing ES module bundle. Built from `JsonTree.JS`; ships
  # `mount`, `mountFromString`, and `install` for vanilla JS
  # consumers. Output: `dist/browser-json-tree.js` (~180KB,
  # Halogen runtime included).
  jsBundle = pkgs.mkSpagoDerivation {
    pname = "browser-json-tree-js";
    version = "0.1.0";
    inherit src;
    spagoYaml = ../spago.yaml;
    spagoLock = ../spago.lock;
    nativeBuildInputs = [
      pkgs.purs
      pkgs.spago-unstable
      pkgs.esbuild
      pkgs.nodejs_22
    ];
    buildPhase = ''
      spago bundle --offline \
        --module JsonTree.JS \
        --outfile dist/browser-json-tree.js
    '';
    installPhase = ''
      mkdir -p $out
      cp dist/browser-json-tree.js $out/
      cp dist/json-tree.css $out/
    '';
  };

  # End-to-end smoke: build + bundle the example app. Confirms
  # the public surface (`JsonTree.render`, `JsonTree.Behaviour.install`)
  # is reachable and a downstream Halogen app builds against it.
  example = pkgs.mkSpagoDerivation {
    pname = "browser-json-tree-example";
    version = "0.1.0";
    inherit src;
    spagoYaml = ../examples/spago.yaml;
    spagoLock = ../examples/spago.lock;
    nativeBuildInputs = [
      pkgs.purs
      pkgs.spago-unstable
      pkgs.esbuild
      pkgs.nodejs_22
    ];
    buildPhase = ''
      # mkSpagoDerivation populates `.spago/` at the source root,
      # but `spago bundle` resolves the cache relative to its
      # working directory. The example's spago.yaml lives under
      # `examples/`, so symlink the populated cache into place
      # before switching directory, then return to the root so
      # the install phase finds `dist/json-tree.css` at the
      # expected path.
      ln -s ../.spago examples/.spago
      ( cd examples
        spago bundle --offline \
          --module Main \
          --outfile dist/index.js
      )
    '';
    installPhase = ''
      mkdir -p $out
      cp examples/dist/index.html $out/
      cp examples/dist/index.js $out/
      cp examples/dist/demo.css $out/
      cp dist/json-tree.css $out/json-tree.css
    '';
  };

  # MkDocs site, ready to serve from a static host. Bundles the
  # example app's JS + CSS into `assets/` so `docs/demo.md` can
  # mount a live tree under `<div id="json-tree-demo">`. Also
  # ships the JS library bundle at `assets/browser-json-tree.js`
  # for any docs page that wants to demo the JS API.
  docsSite = pkgs.stdenv.mkDerivation {
    pname = "browser-json-tree-docs";
    version = "0.1.0";
    inherit src;
    nativeBuildInputs = [
      pkgs.python3
      pkgs.python3Packages.mkdocs-material
      pkgs.python3Packages.pymdown-extensions
    ];
    buildPhase = ''
      runHook preBuild
      mkdir -p docs/assets
      # Drop the canonical library stylesheet into the docs
      # assets directory so the demo page can `<link>` it.
      cp dist/json-tree.css                       docs/assets/json-tree.css
      cp ${example}/index.js                      docs/assets/demo.js
      cp ${example}/demo.css                      docs/assets/demo.css
      cp ${jsBundle}/browser-json-tree.js         docs/assets/browser-json-tree.js
      # MkDocs honours the working dir; the site is rendered
      # from this repo root against mkdocs.yml at the root.
      mkdocs build --strict --site-dir _site
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r _site/* $out/
      runHook postInstall
    '';
  };
in
{
  inherit library jsBundle example docsSite;
}
