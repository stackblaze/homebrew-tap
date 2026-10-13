# StackBlaze Homebrew tap

Homebrew tap for the [StackBlaze CLI](https://docs.stackblaze.com/cli) (macOS and Linux, arm64 and x86_64).

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

- `repository_dispatch` (`cli-release`, payload `{"tag": "vX.Y.Z"}`), sent by the CLI's stable release job;
- manual `workflow_dispatch` with a `tag` input.

> The initial formula was generated from a dev prerelease (`v1.0.0-dev.66`) so the tap could be tested
> before the first stable CLI release; that release overwrites it.

## License

MIT
