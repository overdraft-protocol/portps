#!/usr/bin/env bash
# Update Formula/portps.rb with a stable GitHub release tarball url + sha256,
# then push it to overdraft-protocol/homebrew-portps over SSH.
#
# Usage:
#   ./scripts/sync-homebrew-tap.sh 1.1.0
#   ./scripts/sync-homebrew-tap.sh v1.1.0 --local-only
#
# Env:
#   HOMEBREW_TAP_REPO  Override tap repo (default: overdraft-protocol/homebrew-portps)
#   SSH agent must be loaded with a write deploy key for the tap (CI sets this up).
set -euo pipefail

VERSION_RAW="${1:?usage: $0 <version> [--local-only]}"
LOCAL_ONLY=0
if [[ ${2:-} == --local-only ]]; then
  LOCAL_ONLY=1
fi

VERSION="${VERSION_RAW#v}"
TAG="v${VERSION}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORMULA_SRC="$ROOT/Formula/portps.rb"
TAP_REPO="${HOMEBREW_TAP_REPO:-overdraft-protocol/homebrew-portps}"
URL="https://github.com/overdraft-protocol/portps/archive/refs/tags/${TAG}.tar.gz"

if [[ ! -f $FORMULA_SRC ]]; then
  echo "Missing $FORMULA_SRC" >&2
  exit 1
fi

echo "Fetching $URL"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

# Retries help when the tag/release exists but the archive is briefly unavailable.
ok=0
for attempt in 1 2 3 4 5 6; do
  if curl -fsSL "$URL" -o "$TMP"; then
    ok=1
    break
  fi
  echo "Attempt $attempt failed; waiting 10s…"
  sleep 10
done
if (( !ok )); then
  echo "Could not download release archive for $TAG" >&2
  echo "Create a GitHub release/tag first, then re-run." >&2
  exit 1
fi

SHA=$(shasum -a 256 "$TMP" | awk '{print $1}')
echo "sha256: $SHA"

apply_formula() {
  local dest=$1
  python3 - "$FORMULA_SRC" "$dest" "$URL" "$SHA" <<'PY'
import re
import sys
from pathlib import Path

src, dest, url, sha = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3], sys.argv[4]
text = src.read_text()
block = f'  url "{url}"\n  sha256 "{sha}"\n'
if re.search(r'  url ".*?"\n  sha256 ".*?"\n', text):
    text = re.sub(r'  url ".*?"\n  sha256 ".*?"\n', block, text, count=1)
else:
    needle = '  head "'
    idx = text.find(needle)
    if idx == -1:
        m = re.search(r'  license ".*?"\n', text)
        if not m:
            raise SystemExit("Could not find insertion point in Formula")
        idx = m.end()
        text = text[:idx] + "\n" + block + text[idx:]
    else:
        text = text[:idx] + block + "\n" + text[idx:]
text = re.sub(
    r"\n  # After publishing to npm,.*?head\.\n",
    "\n",
    text,
    count=1,
    flags=re.S,
)
dest.parent.mkdir(parents=True, exist_ok=True)
dest.write_text(text)
print(f"Wrote {dest}")
PY
}

apply_formula "$FORMULA_SRC"
echo "Updated local $FORMULA_SRC"

if (( LOCAL_ONLY )); then
  exit 0
fi

WORK="$(mktemp -d)"
trap 'rm -f "$TMP"; rm -rf "$WORK"' EXIT

git clone --depth 1 "git@github.com:${TAP_REPO}.git" "$WORK/tap"
apply_formula "$WORK/tap/Formula/portps.rb"

if [[ ! -f $WORK/tap/README.md ]]; then
  cat >"$WORK/tap/README.md" <<EOF
# homebrew-portps

Homebrew tap for [portps](https://github.com/overdraft-protocol/portps).

\`\`\`bash
brew tap overdraft-protocol/portps
brew install portps
\`\`\`

This formula is updated automatically from the portps repo on each GitHub Release.
EOF
fi

git -C "$WORK/tap" config user.name "github-actions[bot]"
git -C "$WORK/tap" config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git -C "$WORK/tap" add Formula/portps.rb README.md
if git -C "$WORK/tap" diff --staged --quiet; then
  echo "Tap already up to date for $TAG"
  exit 0
fi

git -C "$WORK/tap" commit -m "portps ${TAG}"
git -C "$WORK/tap" push origin HEAD
echo "Pushed portps ${TAG} to ${TAP_REPO}"
