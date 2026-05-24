{ pkgs, project, src }:

let
  # Single shared definition of every verification step. Each entry
  # becomes (a) a `writeShellApplication` exposed as `apps.<name>`
  # so `nix run .#<name>` is usable, and (b) a sandboxed
  # `runCommand` that *invokes* the same app, exposed under
  # `checks.<name>` so `nix flake check` actually exercises it.
  scripts = {
    lint = {
      runtimeInputs = [
        pkgs.purs-tidy-bin.purs-tidy-0_10_0
        pkgs.findutils
      ];
      text = ''
        cd "''${LINT_ROOT:-.}"
        find src examples/src -type f -name '*.purs' -print0 \
          | xargs -0 purs-tidy check
      '';
    };
  };

  mkApp = name: { runtimeInputs, text }:
    pkgs.writeShellApplication {
      inherit name text runtimeInputs;
    };

  # Wrap the app in a runCommand so `nix flake check` runs it
  # inside the sandbox with the writeShellApplication's strict
  # PATH — i.e. exactly what `nix run .#<name>` will see in CI.
  runCheck = name: app:
    pkgs.runCommand name {
      nativeBuildInputs = [ pkgs.glibcLocales ];
      LANG = "C.UTF-8";
      LC_ALL = "C.UTF-8";
      LINT_ROOT = src;
    } ''
      ${pkgs.lib.getExe app}
      touch $out
    '';

  lint = mkApp "lint" scripts.lint;
in
{
  inherit lint runCheck;
}
