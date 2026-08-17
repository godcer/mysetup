#!/usr/bin/env bash
# Verify the terminal setup. Prints a human-readable checklist.
# Exits non-zero if any core tool is missing.

set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

CORE=(zsh starship git tmux neovim fzf fd ripgrep bat eza yazi zoxide atuin btop jq lazygit gh)

main () {
  local missing=() tool
  printf '%s\n' "=========================================="
  printf '%s\n' "  Terminal Setup Verification"
  printf '%s\n' "=========================================="
  for tool in "${CORE[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
      ok "$tool"
    elif [ "$tool" = "fd" ] && command -v fdfind >/dev/null 2>&1; then
      printf '%s\xe2\x9c\x93%s %s\n' "$(color 2)" "$NC" "fd (fdfind)"
    else
      err "$tool"
      missing+=("$tool")
    fi
  done

  local zsh_path login_shell
  zsh_path="$(command -v zsh 2>/dev/null || true)"
  login_shell="$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7)"
  printf '%s\n' "------------------------------------------"
  if [ -n "$zsh_path" ] && [ "$login_shell" = "$zsh_path" ]; then
    ok "Default shell: $zsh_path"
  else
    warn "Default shell: ${login_shell:-unknown} (zsh: ${zsh_path:-missing})"
  fi

  if [ "${#missing[@]}" -gt 0 ]; then
    err "Missing: ${missing[*]}"
    return 1
  fi
  ok "Terminal setup complete."
  return 0
}

main "$@"