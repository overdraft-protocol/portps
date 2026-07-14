#!/usr/bin/env bash
# Shared shell integration for install.sh and npm postinstall.
set -euo pipefail

MARKER="# portps shell integration"
ZSHRC="${ZSHRC:-$HOME/.zshrc}"
BASHRC="${BASHRC:-$HOME/.bashrc}"

portps_install_zsh() {
  if [[ ! -f $ZSHRC ]]; then
    touch "$ZSHRC"
  fi
  if grep -qF "$MARKER" "$ZSHRC" 2>/dev/null; then
    echo "portps: zsh integration already present in $ZSHRC"
    return 0
  fi
  cat >>"$ZSHRC" <<EOF

$MARKER
alias portps='noglob command portps'
EOF
  echo "portps: added noglob alias to $ZSHRC"
  echo "portps: run: source $ZSHRC"
}

portps_install_bash_note() {
  if [[ ! -f $BASHRC ]]; then
    touch "$BASHRC"
  fi
  if grep -qF "$MARKER" "$BASHRC" 2>/dev/null; then
    echo "portps: bash note already present in $BASHRC"
    return 0
  fi
  cat >>"$BASHRC" <<EOF

$MARKER
# Quote glob patterns: portps '91*' — or use %/_ : portps 91%
EOF
  echo "portps: added bash pattern tip to $BASHRC"
  echo "portps: run: source $BASHRC"
}

portps_remove_shell_integration() {
  local rc
  for rc in "$ZSHRC" "$BASHRC"; do
    [[ -f $rc ]] || continue
    if grep -qF "$MARKER" "$rc" 2>/dev/null; then
      # Drop marker and following comment/alias lines.
      awk -v m="$MARKER" '
        $0 == m { skip=1; next }
        skip {
          if ($0 ~ /^#/ || $0 ~ /^alias /) next
          skip=0
        }
        { print }
      ' "$rc" >"$rc.tmp" && mv "$rc.tmp" "$rc"
      echo "portps: removed shell integration from $rc"
    fi
  done
}

portps_install_shell_integration() {
  local shell_name
  shell_name=$(basename "${SHELL:-}")

  case $shell_name in
    zsh)
      portps_install_zsh
      ;;
    bash)
      portps_install_bash_note
      echo "portps: in bash, quote patterns: portps '91*' (or use 91%)"
      ;;
    *)
      if [[ -f $HOME/.zshrc ]] || [[ $shell_name == zsh ]]; then
        portps_install_zsh
      elif [[ -f $HOME/.bashrc ]] || [[ $shell_name == bash ]]; then
        portps_install_bash_note
      else
        echo "portps: tip — quote patterns: portps '91*'"
        echo "portps: for zsh, add: alias portps='noglob command portps'"
      fi
      ;;
  esac
}
