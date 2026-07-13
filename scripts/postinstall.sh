#!/usr/bin/env bash
set -euo pipefail

# Only add shell integration after global npm install.
if [[ "${npm_config_global:-}" != "true" ]]; then
  exit 0
fi

ZSHRC="${ZSHRC:-$HOME/.zshrc}"
MARKER="# portps shell integration"

if [[ ! -f $ZSHRC ]]; then
  touch "$ZSHRC"
fi

if grep -qF "$MARKER" "$ZSHRC" 2>/dev/null; then
  echo "portps: zsh integration already present in $ZSHRC"
  exit 0
fi

cat >>"$ZSHRC" <<EOF

$MARKER
alias portps='noglob command portps'
EOF

echo "portps: added noglob alias to $ZSHRC"
echo "portps: run: source $ZSHRC"
