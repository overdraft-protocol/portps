#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
INSTALL_DIR="$PREFIX/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/bin/portps"
# shellcheck source=scripts/shell-integration.sh
source "$SCRIPT_DIR/scripts/shell-integration.sh"

usage() {
  cat <<'EOF'
install.sh — install portps

Usage:
  ./install.sh [options]

Options:
  --prefix <dir>   Install bin to <dir>/bin (default: ~/.local)
  --zsh            Add zsh noglob alias to ~/.zshrc (unquoted globs)
  --bash           Add bash pattern tip to ~/.bashrc
  --shell          Auto-detect shell and add integration
  --uninstall      Remove binary and shell integration
  -h, --help       Show this help

Examples:
  ./install.sh --shell
  ./install.sh --zsh
  PREFIX=/usr/local ./install.sh
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
  rm -f "$INSTALL_DIR/portps"
  echo "Removed $INSTALL_DIR/portps"
  portps_remove_shell_integration
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
    portps_install_shell_integration
  elif (( do_zsh )); then
    portps_install_zsh
  elif (( do_bash )); then
    portps_install_bash_note
  fi
}

main "$@"
