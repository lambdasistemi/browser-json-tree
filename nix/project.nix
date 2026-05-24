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
      cp dist/json-tree.css $out/json-tree.css
    '';
  };
in
{
  inherit library example;
}
