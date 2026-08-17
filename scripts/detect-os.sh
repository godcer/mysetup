#!/usr/bin/env bash
# Detect Linux distribution, package manager and architecture.
# Can be sourced (sets OS_ID, OS_FAMILY, PM, ARCH) or run directly.

. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

detect_os () {
  OS_ID=""
  OS_FAMILY=""
  PM=""
  ARCH="$(uname -m)"

  if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-}"
    case "$OS_ID" in
      fedora)          OS_FAMILY=fedora; PM=dnf ;;
      arch|endeavouros|manjaro|garuda|cachyos) OS_FAMILY=arch; PM=pacman ;;
      ubuntu|debian|kali|linuxmint|pop) OS_FAMILY=debian; PM=apt ;;
      *)
        # fall back to ID_LIKE
        case "$ID_LIKE" in
          *fedora*|*rhel*)  OS_FAMILY=fedora; PM=dnf ;;
          *arch*)           OS_FAMILY=arch;   PM=pacman ;;
          *debian*|*ubuntu*)OS_FAMILY=debian; PM=apt ;;
          *)                OS_FAMILY=unknown; PM=unknown ;;
        esac
        ;;
    esac
  else
    OS_ID=unknown
    OS_FAMILY=unknown
    PM=unknown
  fi

  case "$ARCH" in
    x86_64|amd64) ARCH=x86_64 ;;
    aarch64|arm64) ARCH=aarch64 ;;
  esac
}

detect_os

# When run directly, print the results.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  printf 'OS_ID=%s\nOS_FAMILY=%s\nPM=%s\nARCH=%s\n' "$OS_ID" "$OS_FAMILY" "$PM" "$ARCH"
fi