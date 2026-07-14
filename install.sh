#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
INSTALL_DIR="$PREFIX/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/bin/portps"

usage() {
  cat <<'EOF'
install.sh — install portps

Usage:
  ./install.sh [options]

Options:
  --prefix <dir>   Install bin to <dir>/bin (default: ~/.local)
  --shell          Run: portps --setup-shell (zsh noglob or bash tip)
  --zsh            Run: portps --setup-shell zsh
  --bash           Run: portps --setup-shell bash
  --uninstall      Remove binary and shell integration
  -h, --help       Show this help

Examples:
  ./install.sh
  ./install.sh --shell
  PREFIX=/usr/local ./install.sh

Patterns work without setup using shell-safe % / _ :
  portps 91%
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

uninstall() {
  if [[ -x $INSTALL_DIR/portps ]]; then
    "$INSTALL_DIR/portps" --remove-shell || true
  fi
  rm -f "$INSTALL_DIR/portps"
  echo "Removed $INSTALL_DIR/portps"
}

main() {
  local do_zsh=0 do_bash=0 do_shell=0 do_uninstall=0

  while [[ $# -gt 0 ]]; do
    case $1 in
      --prefix)
        PREFIX="$2"
        INSTALL_DIR="$PREFIX/bin"
        shift 2
        ;;
      --zsh) do_zsh=1; shift ;;
      --bash) do_bash=1; shift ;;
      --shell) do_shell=1; shift ;;
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
  if (( do_shell )); then
    "$INSTALL_DIR/portps" --setup-shell
  elif (( do_zsh )); then
    "$INSTALL_DIR/portps" --setup-shell zsh
  elif (( do_bash )); then
    "$INSTALL_DIR/portps" --setup-shell bash
  else
    echo "portps: tip — shell-safe patterns need no setup: portps 91%"
    echo "portps: optional classic * globs: $INSTALL_DIR/portps --setup-shell"
  fi
}

main "$@"
