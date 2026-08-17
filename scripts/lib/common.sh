#!/usr/bin/env bash
# Shared helpers for all setup scripts.

set -u

# Color helpers
color () { tput setaf "$1" 2>/dev/null; }
NC=$(tput sgr0 2>/dev/null || true)

say ()  { printf '%s==>%s %s\n' "$(color 2)" "$NC" "$*"; }
info () { printf '%s    %s\n' "$(color 4)" "$*"; }
ok ()   { printf '%s\xe2\x9c\x93%s %s\n' "$(color 2)" "$NC" "$*"; }
warn () { printf '%s ! %s %s\n' "$(color 3)" "$NC" "$*"; }
err ()  { printf '%sx%s %s\n' "$(color 1)" "$NC" "$*" >&2; }

die () {
  err "$*"
  exit 1
}

# SUDO env: use sudo when not root, empty otherwise.
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  SUDO="sudo"
fi

# require: die if command is missing
require () {
  local bin="$1"
  command -v "$bin" >/dev/null 2>&1 || die "required command not found: $bin"
}

# LINK_ARG determines whether sudo is prepended to commands that need root.
run_root () {
  $SUDO "$@"
}