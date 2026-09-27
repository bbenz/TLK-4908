#!/usr/bin/env bash
set -euo pipefail

OASDIFF_VERSION="v1.32.1"
OSV_SCANNER_VERSION="v2.3.3"
GRYPE_VERSION="v0.100.0"
OASDIFF_LINUX_AMD64_URL="https://github.com/oasdiff/oasdiff/releases/download/v1.32.1/oasdiff_1.32.1_linux_amd64.tar.gz"
OSV_SCANNER_LINUX_AMD64_URL="https://github.com/google/osv-scanner/releases/download/v2.3.3/osv-scanner_linux_amd64"

mkdir -p .tools/bin
if [ "$(uname -s)" = "Linux" ] && [ "$(uname -m)" = "x86_64" ]; then
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT
  curl -fsSL "$OASDIFF_LINUX_AMD64_URL" -o "$tmpdir/oasdiff.tar.gz"
  tar -xzf "$tmpdir/oasdiff.tar.gz" -C "$tmpdir"
  install "$tmpdir/oasdiff" "$PWD/.tools/bin/oasdiff"
  curl -fsSL "$OSV_SCANNER_LINUX_AMD64_URL" -o "$PWD/.tools/bin/osv-scanner"
  chmod +x "$PWD/.tools/bin/osv-scanner"
else
  GOBIN="$PWD/.tools/bin" go install "github.com/oasdiff/oasdiff@${OASDIFF_VERSION}"
  GOBIN="$PWD/.tools/bin" go install "github.com/google/osv-scanner/v2/cmd/osv-scanner@${OSV_SCANNER_VERSION}"
fi
curl -sSfL "https://raw.githubusercontent.com/anchore/grype/${GRYPE_VERSION}/install.sh" | sh -s -- -b "$PWD/.tools/bin" "$GRYPE_VERSION"

if [ -n "${GITHUB_PATH:-}" ]; then
  echo "$PWD/.tools/bin" >> "$GITHUB_PATH"
fi
