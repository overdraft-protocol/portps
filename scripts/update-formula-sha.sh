#!/usr/bin/env bash
# Compatibility wrapper — prefer sync-homebrew-tap.sh.
# Usage: ./scripts/update-formula-sha.sh 1.1.0
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$ROOT/scripts/sync-homebrew-tap.sh" "${1:?usage: $0 <version>}" --local-only
