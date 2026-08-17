#!/usr/bin/env bash
# Install missing packages using the native package manager, with a
# GitHub-binary fallback for tools not available natively.
# Idempotent: only installs what is missing.

set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/detect-os.sh"
. "$(dirname "${BASH_SOURCE[0]}")/packages.sh"

# The core set we install (terminal-only, per project scope).
TOOLS=(
  git curl wget unzip
  just
  zsh zsh-autosuggestions zsh-syntax-highlighting
  starship tmux neovim
  fzf fd ripgrep zoxide
  bat eza yazi
  btop jq
  lazygit gh
  atuin
)

# Optional "nice-to-have" tools from earlier discussion.
EXTRA_TOOLS=(tldr procs dust duf curlie httpie doggo fastfetch)

pm_update () {
  case "$PM" in
    apt)   $SUDO apt-get update -qq ;;
    *)     : ;;
  esac
}

install_one () {
  local tool="$1"
  local pkg
  pkg="$(pkg_native "$tool")"

  # 1) native package
  if [ -n "$pkg" ]; then
    case "$PM" in
      dnf)    $SUDO dnf install -y --skip-unavailable "$pkg" ;;
      pacman) $SUDO pacman -S --needed --noconfirm "$pkg" ;;
      apt)    $SUDO apt-get install -y "$pkg" ;;
    esac
    return 0
  fi

  # 2) binary fallback
  if install_binary "$tool" >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

main () {
  [ "$PM" = "unknown" ] && die "unsupported OS: $OS_ID (pm=unknown)"
  say "Distro: $OS_ID ($OS_FAMILY) | pm: $PM | arch: $ARCH"
  pm_update

  local missing=() tool failed=()
  for tool in "${TOOLS[@]}" "${EXTRA_TOOLS[@]}"; do
    if is_installed "$tool"; then
      ok "$tool"
    else
      missing+=("$tool")
    fi
  done

  if [ "${#missing[@]}" -eq 0 ]; then
    say "All tools already installed."
    return 0
  fi

  say "Installing: ${missing[*]}"
  for tool in "${missing[@]}"; do
    if install_one "$tool"; then
      ok "$tool"
    else
      err "$tool could not be installed"
      failed+=("$tool")
    fi
  done

  if [ "${#failed[@]}" -gt 0 ]; then
    err "Failed to install: ${failed[*]}"
    return 1
  fi
  return 0
}

main "$@"