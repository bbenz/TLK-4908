#!/usr/bin/env bash
# Install pinned versions of the gate's tools in .tools/bin, so every run uses the same tools.
# Pass the tools you need, or nothing for all of them: scripts/install-tools.sh oasdiff
set -euo pipefail

OASDIFF_VERSION="1.34.1"
OSV_SCANNER_VERSION="2.7.0"
GRYPE_VERSION="0.121.0"

# SHA-256 checksums from each project's release page, for Linux x86-64
OASDIFF_SHA256="75775f65b0adebd26a8e013af51a799342dfdc6262d89efa9e3b7bdf89657d90"
OSV_SCANNER_SHA256="160c6253e2922e9e0a6a9771c5c4c40a4b3c6090b34a3cdd5e80c96cc2e4218b"
GRYPE_SHA256="64e07133d3486115de647a66581461dccf5c732748a0a3119077395565f15519"

tools=("$@")
if [ ${#tools[@]} -eq 0 ]; then
  tools=(oasdiff osv-scanner grype)
fi

bin="$PWD/.tools/bin"
mkdir -p "$bin"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

download() { # url, file, sha256
  curl -fsSL "$1" -o "$tmp/$2"
  echo "$3  $tmp/$2" | sha256sum --check --quiet
}

linux_x64=false
if [ "$(uname -s)" = "Linux" ] && [ "$(uname -m)" = "x86_64" ]; then
  linux_x64=true
fi

for tool in "${tools[@]}"; do
  case "$tool" in
    oasdiff)
      if $linux_x64; then
        download "https://github.com/oasdiff/oasdiff/releases/download/v${OASDIFF_VERSION}/oasdiff_${OASDIFF_VERSION}_linux_amd64.tar.gz" \
          oasdiff.tar.gz "$OASDIFF_SHA256"
        tar -xzf "$tmp/oasdiff.tar.gz" -C "$tmp" oasdiff
        install "$tmp/oasdiff" "$bin/oasdiff"
      else
        GOBIN="$bin" go install "github.com/oasdiff/oasdiff@v${OASDIFF_VERSION}"
      fi
      ;;
    osv-scanner)
      if $linux_x64; then
        download "https://github.com/google/osv-scanner/releases/download/v${OSV_SCANNER_VERSION}/osv-scanner_linux_amd64" \
          osv-scanner "$OSV_SCANNER_SHA256"
        install "$tmp/osv-scanner" "$bin/osv-scanner"
      else
        GOBIN="$bin" go install "github.com/google/osv-scanner/v2/cmd/osv-scanner@v${OSV_SCANNER_VERSION}"
      fi
      ;;
    grype)
      if $linux_x64; then
        download "https://github.com/anchore/grype/releases/download/v${GRYPE_VERSION}/grype_${GRYPE_VERSION}_linux_amd64.tar.gz" \
          grype.tar.gz "$GRYPE_SHA256"
        tar -xzf "$tmp/grype.tar.gz" -C "$tmp" grype
        install "$tmp/grype" "$bin/grype"
      else
        curl -sSfL "https://raw.githubusercontent.com/anchore/grype/v${GRYPE_VERSION}/install.sh" \
          | sh -s -- -b "$bin" "v${GRYPE_VERSION}"
      fi
      ;;
    *)
      echo "Unknown tool: $tool"
      exit 1
      ;;
  esac
  echo "Installed $tool"
done

if [ -n "${GITHUB_PATH:-}" ]; then
  echo "$bin" >> "$GITHUB_PATH"
fi
