# StackBlaze Homebrew tap

Homebrew tap for the [StackBlaze CLI](https://www.stackblaze.com/docs/reference/cli) (macOS and Linux, arm64 and x86_64).

## Install

```sh
brew install stackblaze/tap/stackblaze
```

Homebrew 7+ refuses to load formulae from third-party taps until you trust them. If the install
stops with `Refusing to load formula ... from untrusted tap`, trust the tap once and re-run:

```sh
brew tap stackblaze/tap
brew trust --tap stackblaze/tap
brew install stackblaze
```

Upgrade with `brew upgrade stackblaze`; remove with `brew uninstall stackblaze && brew untap stackblaze/tap`.

## How it works

The CLI binaries are published anonymously to the public GHCR OCI artifact
`ghcr.io/stackblaze/stackblaze-cli` (tags `latest`, `dev`, `vX.Y.Z`; one layer per platform).
`Formula/stackblaze.rb` points directly at the per-platform blob digests and downloads them with
Homebrew's `CurlGitHubPackagesDownloadStrategy`, the same anonymous GHCR access Homebrew uses for bottles.

The formula is **generated**, never edited by hand:

```sh
scripts/update-formula.sh v1.2.3   # or latest / dev / any GHCR tag
```

The [`Update formula`](.github/workflows/update.yml) workflow runs the script, installs and tests the
formula on macOS and Linux, then commits it. It runs on:

- `schedule` (every 30 minutes): [`scripts/latest-stable-version.sh`](scripts/latest-stable-version.sh) reads the
  version annotation of the public GHCR `latest` tag anonymously (the CLI repo is private, so its GitHub Releases
  are not readable from here). Only a plain `X.Y.Z` is accepted, so `-dev.N` prereleases never reach the formula.
  If it matches the formula's `version` the run stops there; otherwise it regenerates from `vX.Y.Z`, tests and
  commits with this repo's own `GITHUB_TOKEN`. No cross-repo token is needed;
- manual `workflow_dispatch`: leave `tag` empty for the same latest-stable check, or pass any GHCR tag to force a
  regeneration from it;
- `repository_dispatch` (`cli-release`, payload `{"tag": "vX.Y.Z"}`), sent by the CLI's stable release job when it
  has a `HOMEBREW_TAP_TOKEN` (optional; the schedule covers it otherwise).

GitHub disables scheduled workflows in a public repo after 60 days without activity; re-enable it from the
Actions tab if that happens.

## License

MIT
