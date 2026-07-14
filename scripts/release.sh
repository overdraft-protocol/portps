#!/usr/bin/env bash
# Full release: npm publish → git tag → push → gh release create
# (GitHub Release triggers the Homebrew tap sync workflow.)
#
# Usage:
#   ./scripts/release.sh              # publish current package.json version
#   ./scripts/release.sh patch        # bump patch, commit, then release
#   ./scripts/release.sh minor
#   ./scripts/release.sh major
#   ./scripts/release.sh 1.2.0        # set exact version, commit, then release
#   ./scripts/release.sh --dry-run    # print plan only
#
# Prerequisites: clean git tree (except for version bump we make), npm login,
# gh auth, push access to origin.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DRY_RUN=0
BUMP=""

usage() {
  sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help) usage; exit 0 ;;
    --dry-run) DRY_RUN=1; shift ;;
    patch|minor|major) BUMP=$1; shift ;;
    [0-9]*) BUMP=$1; shift ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

run() {
  if (( DRY_RUN )); then
    echo "dry-run: $*"
  else
    echo "+ $*"
    "$@"
  fi
}

require_cmd() {
  command -v "$1" >/dev/null || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

require_cmd npm
require_cmd git
require_cmd gh
require_cmd node

if [[ -n $(git status --porcelain) && -z $BUMP ]]; then
  echo "Working tree is dirty. Commit/stash first, or pass patch|minor|major|x.y.z to bump." >&2
  git status --short
  exit 1
fi

if [[ -n $(git status --porcelain) && -n $BUMP ]]; then
  echo "Working tree must be clean before a version bump." >&2
  git status --short
  exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ $BRANCH != main && $BRANCH != master ]]; then
  echo "Warning: on branch '$BRANCH' (expected main/master)." >&2
fi

if [[ -n $BUMP ]]; then
  case $BUMP in
    patch|minor|major)
      run npm version "$BUMP" --no-git-tag-version
      ;;
    *)
      run npm version "$BUMP" --no-git-tag-version --allow-same-version
      ;;
  esac
  VERSION=$(node -p "require('./package.json').version")
  run git add package.json package-lock.json 2>/dev/null || run git add package.json
  run git commit -m "release: v${VERSION}"
else
  VERSION=$(node -p "require('./package.json').version")
fi

TAG="v${VERSION}"

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag $TAG already exists locally." >&2
  exit 1
fi

if git ls-remote --exit-code --tags origin "refs/tags/${TAG}" >/dev/null 2>&1; then
  echo "Tag $TAG already exists on origin." >&2
  exit 1
fi

echo "Releasing @overdraft-protocol/portps@${VERSION} (tag ${TAG})"

run npm publish --access=public
run git tag -a "$TAG" -m "portps ${TAG}"
run git push origin HEAD
run git push origin "$TAG"
run gh release create "$TAG" --title "$TAG" --generate-notes --verify-tag

echo
echo "Done: npm @${VERSION} + GitHub ${TAG}"
echo "Homebrew tap sync should run via the release workflow."
echo "Check: gh run list --workflow=sync-homebrew-tap.yml -L 3"
