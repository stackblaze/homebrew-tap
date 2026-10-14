#!/usr/bin/env bash
# Print the latest STABLE StackBlaze CLI version (e.g. 1.0.0), anonymously.
#
# The CLI repo is private, so its GitHub Releases are not readable from here
# (api.github.com returns 404 without a cross-repo token). Instead read the
# public GHCR OCI artifact: the stable release job pushes `latest` (dev
# prereleases only push `dev`, `sha-*` and `vX.Y.Z-dev.N`), and the manifest
# carries the version in org.opencontainers.image.version.
#
# Exits non-zero unless the version is plain X.Y.Z, so a prerelease
# (-dev.N, -rc.N, ...) can never reach the stable formula, even if `latest`
# were ever moved to one by hand.
#
# Requires: bash, curl, python3.
set -euo pipefail

REGISTRY="ghcr.io"
REPOSITORY="${STACKBLAZE_GHCR_REPOSITORY:-stackblaze/stackblaze-cli}"

token="$(curl -fsSL "https://${REGISTRY}/token?scope=repository:${REPOSITORY}:pull" |
  python3 -c 'import json,sys; print(json.load(sys.stdin)["token"])')"

version="$(curl -fsSL \
  -H "Authorization: Bearer ${token}" \
  -H "Accept: application/vnd.oci.image.manifest.v1+json" \
  "https://${REGISTRY}/v2/${REPOSITORY}/manifests/latest" |
  python3 -c 'import json,sys; m=json.load(sys.stdin); print((m.get("annotations") or {}).get("org.opencontainers.image.version","").lstrip("v"))')"

if ! printf '%s' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "::error::GHCR ${REPOSITORY}:latest has version '${version}', not a stable X.Y.Z release; refusing" >&2
  exit 1
fi
printf '%s\n' "$version"
