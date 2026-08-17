#!/usr/bin/env bash
# One-command bootstrap: detect OS -> install packages -> configure shell -> apply config.
# Safe to run repeatedly (idempotent).
#
# Usage:
#   cheezmoi init --apply <REPO> && scripts/bootstrap.sh
#   # or directly:
#   DOTFILES_REPO=<REPO> ./scripts/bootstrap.sh
#
# When run inside a fresh chezmoi checkout, it runs install-packages.sh,
# then setup-shell.sh, then `chezmoi apply`, then verify.sh.

set -u
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
. ./scripts/lib/common.sh
. ./scripts/detect-os.sh

main () {
  info "OS: $OS_ID ($OS_FAMILY) | pm: $PM | arch: $ARCH"

  [ -x "$(command -v chezmoi 2>/dev/null)" ] || die "chezmoi is not installed. Install it first (see https://www.chezmoi.io/install)."

  say "Installing packages..."
  ./scripts/install-packages.sh || warn "some packages could not be installed (see above)"

  say "Configuring shell..."
  ./scripts/setup-shell.sh || warn "shell setup had issues"

  say "Applying configuration..."
  chezmoi apply || die "chezmoi apply failed"

  say "Verifying..."
  ./scripts/verify.sh || warn "verification reported missing tools"

  printf '\n%s\n' "------------------------------------------"
  ok "Bootstrap complete. Log out/in to switch shells if changed."
}

main "$@"