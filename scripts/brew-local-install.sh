#!/usr/bin/env bash
# Create/update a local Homebrew tap and install from this working tree.
# Usage: ./scripts/brew-local-install.sh [user/tap]
set -euo pipefail

TAP="${1:-overdraft/portps}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! brew tap-new "$TAP" 2>/dev/null; then
  echo "Tap $TAP already exists (ok)"
fi

TAP_PATH="$(brew --repo "$TAP")"
mkdir -p "$TAP_PATH/Formula"

STAGE="$(mktemp -d)"
cp "$ROOT/bin/portps" "$STAGE/portps"
TARBALL="$TAP_PATH/portps-local.tar.gz"
tar -C "$STAGE" -czf "$TARBALL" portps
rm -rf "$STAGE"
SHA=$(shasum -a 256 "$TARBALL" | awk '{print $1}')
VERSION="1.1.0-local.$(date +%Y%m%d%H%M%S)"

cat >"$TAP_PATH/Formula/portps.rb" <<EOF
class Portps < Formula
  desc "Find or kill processes listening on TCP ports"
  homepage "https://github.com/overdraft-protocol/portps"
  url "file://${TARBALL}"
  sha256 "${SHA}"
  version "${VERSION}"
  license "MIT"

  def install
    bin.install "portps"
  end

  def caveats
    <<~EOS
      On zsh: alias portps='noglob command portps'  # then: portps 91*
      In bash: quote patterns (portps '91*') or use %/_ (portps 91%)
    EOS
  end

  test do
    assert_match "usage: portps", shell_output("#{bin}/portps 2>&1", 1)
  end
end
EOF

echo "Installed local formula into $TAP_PATH/Formula/portps.rb"

# Clear prior npm/global symlink conflicts.
brew uninstall --force portps 2>/dev/null || true
if [[ -L /opt/homebrew/bin/portps || -e /opt/homebrew/bin/portps ]]; then
  echo "Removing existing /opt/homebrew/bin/portps so Homebrew can link"
  rm -f /opt/homebrew/bin/portps
fi

brew install --force "$TAP/portps"
brew link --overwrite --force portps
brew test "$TAP/portps"

PORTPS_BIN="$(brew --prefix portps)/bin/portps"
echo "Done. Binary: $PORTPS_BIN"
head -1 "$PORTPS_BIN"
"$PORTPS_BIN" 2>&1 | head -2 || true
