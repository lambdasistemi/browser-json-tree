{
  description = "browser-json-tree — typed Halogen JSON tree renderer + click behaviour";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    purescript-overlay = {
      url = "github:paolino/purescript-overlay/fix/remove-nodePackages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mkSpagoDerivation = {
      url = "github:jeslie0/mkSpagoDerivation";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      purescript-overlay,
      mkSpagoDerivation,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [
          purescript-overlay.overlays.default
          mkSpagoDerivation.overlays.default
        ];
      };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          project = import ./nix/project.nix { inherit pkgs; src = ./.; };
        in
        {
          default = project.library;
          library = project.library;
          example = project.example;
        });

      checks = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          project = import ./nix/project.nix { inherit pkgs; src = ./.; };
          apps = import ./nix/apps.nix { inherit pkgs project; src = ./.; };
        in
        {
          library = project.library;
          example = project.example;
          lint = apps.runCheck "lint" apps.lint;
        });

      apps = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          project = import ./nix/project.nix { inherit pkgs; src = ./.; };
          apps' = import ./nix/apps.nix { inherit pkgs project; src = ./.; };
        in
        {
          lint = {
            type = "app";
            program = "${apps'.lint}/bin/lint";
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.purs
              pkgs.spago-unstable
              pkgs.purs-tidy-bin.purs-tidy-0_10_0
              pkgs.purescript-language-server
              pkgs.esbuild
              pkgs.nodejs_22
              pkgs.just
              pkgs.git
              pkgs.gh
            ];
          };
        });
    };
}
