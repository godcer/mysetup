#!/usr/bin/env bash
# Ensure zsh is installed and is the login shell. Safe / idempotent.

set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/detect-os.sh"
. "$(dirname "${BASH_SOURCE[0]}")/packages.sh"

ensure_zsh_installed () {
  if command -v zsh >/dev/null 2>&1; then
    return 0
  fi
  say "Zsh is not installed. Installing..."
  local pkg; pkg="$(pkg_native zsh)"
  case "$PM" in
    dnf)    $SUDO dnf install -y "$pkg" ;;
    pacman) $SUDO pacman -S --needed --noconfirm "$pkg" ;;
    apt)    $SUDO apt-get install -y "$pkg" ;;
  esac
  command -v zsh >/dev/null 2>&1
}

main () {
  local zsh_path current_shell
  zsh_path="$(command -v zsh)" || zsh_path=""
  current_shell="${SHELL:-}"

  if [ -z "$zsh_path" ]; then
    ensure_zsh_installed || die "failed to install zsh"
    zsh_path="$(command -v zsh)"
  fi

  # Re-read for the *configured* login shell (not just this session's $SHELL).
  local login_shell
  if command -v getent >/dev/null 2>&1; then
    login_shell="$(getent passwd "$(id -un)" | cut -d: -f7 2>/dev/null)"
  else
    login_shell="$current_shell"
  fi
  login_shell="${login_shell:-}"

  if [ "$login_shell" = "$zsh_path" ]; then
    ok "Zsh already configured as login shell ($zsh_path)"
    return 0
  fi

  say "Changing default shell -> $zsh_path"
  # Ensure zsh is a valid login shell in /etc/shells before chsh.
  if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
    $SUDO sh -c "echo '$zsh_path' >> /etc/shells"
  fi
  $SUDO chsh -s "$zsh_path" "$(id -un)" || die "chsh failed"
  ok "Zsh set as login shell ($zsh_path)"
  info "Run: start a new terminal (or re-exec zsh) to apply."
  return 0
}

main "$@"