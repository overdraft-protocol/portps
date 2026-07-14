#!/usr/bin/env bash
set -euo pipefail

# Only add shell integration after global npm install.
if [[ "${npm_config_global:-}" != "true" ]]; then
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=shell-integration.sh
source "$SCRIPT_DIR/shell-integration.sh"

portps_install_shell_integration
