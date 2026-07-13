#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
INSTALL_DIR="$PREFIX/bin"
ZSHRC="${ZSHRC:-$HOME/.zshrc}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/bin/portps"
MARKER="# portps shell integration"

usage() {
  cat <<'EOF'
install.sh — install portps

Usage:
  ./install.sh [options]

Options:
  --prefix <dir>   Install bin to <dir>/bin (default: ~/.local)
  --zsh            Add noglob alias to ~/.zshrc (recommended for zsh users)
  --uninstall      Remove binary and zsh integration
  -h, --help       Show this help

Examples:
  ./install.sh --zsh
  PREFIX=/usr/local ./install.sh
  npm install -g .
EOF
}

install_bin() {
  mkdir -p "$INSTALL_DIR"
  cp "$SOURCE" "$INSTALL_DIR/portps"
  chmod +x "$INSTALL_DIR/portps"
  echo "Installed $INSTALL_DIR/portps"
  if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Add to PATH: export PATH=\"$INSTALL_DIR:\$PATH\""
  fi
}

install_zsh() {
  if ! grep -qF "$MARKER" "$ZSHRC" 2>/dev/null; then
    cat >>"$ZSHRC" <<EOF

$MARKER
alias portps='noglob command portps'
EOF
    echo "Added noglob alias to $ZSHRC"
  else
    echo "Zsh integration already present in $ZSHRC"
  fi
}

uninstall() {
  rm -f "$INSTALL_DIR/portps"
  echo "Removed $INSTALL_DIR/portps"
  if [[ -f $ZSHRC ]]; then
    sed -i.bak "/$MARKER/,+1d" "$ZSHRC"
    rm -f "$ZSHRC.bak"
    echo "Removed zsh integration from $ZSHRC"
  fi
}

main() {
  local do_zsh=0
  local do_uninstall=0

  while [[ $# -gt 0 ]]; do
    case $1 in
      --prefix)
        PREFIX="$2"
        INSTALL_DIR="$PREFIX/bin"
        shift 2
        ;;
      --zsh) do_zsh=1; shift ;;
      --uninstall) do_uninstall=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
  done

  if (( do_uninstall )); then
    uninstall
    exit 0
  fi

  if [[ ! -x $SOURCE ]] && [[ -f $SOURCE ]]; then
    chmod +x "$SOURCE"
  fi
  if [[ ! -f $SOURCE ]]; then
    echo "Missing $SOURCE" >&2
    exit 1
  fi

  install_bin
  if (( do_zsh )); then
    install_zsh
  fi
}

main "$@"
