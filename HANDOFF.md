# Handoff — first push

This document is meant for the maintainer doing the initial push. It
will be removed once the repository is bootstrapped on GitHub.

## What's in this branch

Everything needed for the first release of `browser-json-tree v0.1.0`,
sitting on a clean `feat/initial-extraction` branch off an empty
`chore: bootstrap repository` commit on `main`.

```
.
├── .github/workflows/
│   ├── ci.yml              # build-gate + library + example + lint
│   ├── release-plan.yml    # conventional-commits release planner
│   └── release.yml         # v* tag → GitHub Release + artifacts
├── flake.nix, flake.lock   # purescript-overlay + mkSpagoDerivation
├── nix/
│   ├── project.nix         # library + example mkSpagoDerivation
│   └── apps.nix            # writeShellApplication apps + runCheck wrapper
├── scripts/release/
│   ├── plan                # SemVer planner (3-part, adapted from upstream Cabal planner)
│   ├── get-spago-version
│   ├── check-version-consistency
│   └── extract-notes
├── src/
│   ├── JsonTree.purs       # PUBLIC: render, renderWith, Config, defaultConfig, LinkSpec
│   ├── JsonTree/
│   │   ├── Behaviour.purs  # PUBLIC: install
│   │   ├── Behaviour.js    # FFI
│   │   └── Cardano.purs    # default Cardano txid/address/policy resolver
├── dist/json-tree.css      # canonical stylesheet, themable via --jt-* vars
├── examples/               # standalone Halogen demo
├── spago.yaml + spago.lock
├── package.json (no npm deps; placeholder for tooling)
├── justfile, .gitignore, LICENSE (Apache-2.0)
├── README.md, CHANGELOG.md
└── HANDOFF.md (this file)
```

`nix flake check --no-eval-cache` is green on every commit.

## Post-push steps

The repository does NOT yet exist on GitHub. Run these once after the
first push:

### 1. Create the GitHub repository

```bash
gh repo create lambdasistemi/browser-json-tree --public \
  --description "Typed Halogen renderer + click behaviour for collapsible JSON trees" \
  --source . --remote origin --push
```

(`--source .` + `--push` uploads the current `main` branch. The
`feat/initial-extraction` branch can then be pushed with
`git push -u origin feat/initial-extraction` and opened as the first
PR via `gh pr create`.)

### 2. Enable GitHub Actions PR write permissions

Required so the release planner can open PRs:

```bash
gh api repos/lambdasistemi/browser-json-tree/actions/permissions/workflow -X PUT \
  -f default_workflow_permissions=write \
  -F can_approve_pull_request_reviews=true
```

### 3. Add the standard labels

```bash
for label in \
  "feat:a2eeef:New feature" \
  "fix:d73a4a:Bug fix" \
  "docs:0075ca:Documentation" \
  "chore:ededed:Maintenance" \
  "refactor:e8d44d:Code refactoring" \
  "test:bfd4f2:Tests" \
  "ci:c5def5:CI/CD changes" \
  "experiment:c2ca58:Experimental"; do
  IFS=: read -r name color desc <<<"$label"
  gh label create "$name" --repo lambdasistemi/browser-json-tree \
    --color "$color" --description "$desc" --force
done
```

### 4. Add secrets

```bash
gh secret set CACHIX_AUTH_TOKEN --repo lambdasistemi/browser-json-tree \
  --body "$(pass cachix/paolino)"   # or however you fetch the token

# Deploy key for the release planner. Generate with:
#   ssh-keygen -t ed25519 -f /tmp/browser-json-tree-release -N ""
# Add the public half as a deploy key with write access, the private
# half as the RELEASE_BOT_SSH_KEY secret.
gh repo deploy-key add /tmp/browser-json-tree-release.pub \
  --repo lambdasistemi/browser-json-tree \
  --title "release-bot" --allow-write
gh secret set RELEASE_BOT_SSH_KEY --repo lambdasistemi/browser-json-tree \
  < /tmp/browser-json-tree-release
```

### 5. Branch protection ruleset

```bash
cat <<'JSON' | gh api repos/lambdasistemi/browser-json-tree/rulesets -X POST --input -
{
  "name": "main",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["refs/heads/main"], "exclude": [] } },
  "bypass_actors": [
    { "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always" }
  ],
  "rules": [
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": false,
        "required_status_checks": [
          { "context": "Build Gate" }
        ]
      }
    }
  ]
}
JSON
```

### 6. Repo metadata

```bash
gh api repos/lambdasistemi/browser-json-tree -X PATCH \
  -f homepage="https://github.com/lambdasistemi/browser-json-tree" \
  -f description="Typed Halogen renderer + click behaviour for collapsible JSON trees"

echo '{"names":["purescript","halogen","json","cardano","cardanoscan","spago"]}' | \
  gh api repos/lambdasistemi/browser-json-tree/topics -X PUT --input -
```

### 7. Cutting the first release

`v0.1.0` is already prepared in `spago.yaml` + `CHANGELOG.md`. Once
this branch is merged into `main`, the release planner detects that
the current `spago.yaml` version (`0.1.0`) has a CHANGELOG entry and
no matching tag, and tags `v0.1.0` automatically. The tag push then
fires `release.yml` which builds the source tarball + CSS asset and
opens the GitHub Release.

If you prefer to bootstrap the tag manually:

```bash
git tag -a v0.1.0 -m "browser-json-tree v0.1.0"
git push origin v0.1.0
```

### 8. Optional — publish to the PureScript Registry

The `spago.yaml` already declares `package.publish` so the library is
ready for `spago publish`. The first publish must be done from a
developer machine after the GitHub Release exists:

```bash
nix develop -c spago publish
```

Spago will open the Registry PR. From the second release on,
`spago publish` can run in the `release.yml` job; until then, leave
it as a manual step.

### 9. Remove this file

```bash
git rm HANDOFF.md
git commit -m "chore: remove handoff notes"
```
