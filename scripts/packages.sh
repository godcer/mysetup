#!/usr/bin/env bash
# Central package mapping + install logic.
# Sources detect-os.sh (sets PM, ARCH) and common.sh.

set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/detect-os.sh"

LOCAL_BIN="$HOME/.local/bin"

# ---------------------------------------------------------------------------
# Native package name per family. Empty string => no native package.
# ---------------------------------------------------------------------------
pkg_native () {
  local tool="$1"
  case "$OS_FAMILY:$tool" in
    fedora:git|arch:git|debian:git)        echo git ;;
    fedora:curl|arch:curl|debian:curl)     echo curl ;;
    fedora:wget|arch:wget|debian:wget)     echo wget ;;
    fedora:unzip|arch:unzip|debian:unzip)  echo unzip ;;
    arch:which)                            echo which ;;
    fedora:zsh|arch:zsh|debian:zsh)        echo zsh ;;
    fedora:zsh-autosuggestions|arch:zsh-autosuggestions|debian:zsh-autosuggestions) echo zsh-autosuggestions ;;
    fedora:zsh-syntax-highlighting|arch:zsh-syntax-highlighting|debian:zsh-syntax-highlighting) echo zsh-syntax-highlighting ;;
    fedora:tmux|arch:tmux|debian:tmux)     echo tmux ;;
    fedora:neovim|arch:neovim|debian:neovim) echo neovim ;;
    fedora:fzf|arch:fzf|debian:fzf)        echo fzf ;;
    fedora:fd|debian:fd)                   echo fd-find ;;
    arch:fd)                               echo fd ;;
    fedora:ripgrep|arch:ripgrep|debian:ripgrep) echo ripgrep ;;
    fedora:zoxide|arch:zoxide|debian:zoxide) echo zoxide ;;
    fedora:bat|arch:bat|debian:bat)        echo bat ;;
    fedora:eza|arch:eza|debian:eza)        echo eza ;;
    arch:yazi)                             echo yazi ;;
    fedora:btop|arch:btop|debian:btop)     echo btop ;;
    fedora:jq|arch:jq|debian:jq)           echo jq ;;
    fedora:httpie|arch:httpie|debian:httpie) echo httpie ;;
    fedora:fastfetch|arch:fastfetch|debian:fastfetch) echo fastfetch ;;
    fedora:tldr|arch:tldr)                 echo tldr ;;
    debian:tldr)                           echo tealdeer ;;
    arch:tldr)                             echo tldr ;;
    fedora:starship|arch:starship|debian:starship) echo starship ;;
    arch:lazygit)                          echo lazygit ;;
    fedora:gh|arch:gh)                     echo gh ;;
    arch:procs)                            echo procs ;;
    arch:duf)                              echo duf ;;
    arch:dust)                             echo dust ;;
    arch:doggo)                            echo doggo ;;
    *)                                     echo "" ;;
  esac
}

# ---------------------------------------------------------------------------
# Binary fallback: install a GitHub release binary into ~/.local/bin.
# Returns 0 on success, non-zero if unavailable for this arch or fails.
# ---------------------------------------------------------------------------

# Latest release tag for a GitHub repo.
gh_latest_tag () {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" 2>/dev/null \
    | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4
}

# Download a tarball/zip, extract the named binary, install to ~/.local/bin.
install_release () {
  local url="$1" bin="$2"
  require curl
  local tmp; tmp="$(mktemp -d)"
  if ! curl -fsSL -o "$tmp/archive" "$url"; then
    rm -rf "$tmp"
    return 1
  fi
  ( cd "$tmp" && case "$url" in
      *.zip)  unzip -oq archive ;;                                   # noqa
      *)      tar xzf archive ;;                                     # noqa
    esac )
  if [ -f "$tmp/$bin" ]; then
    install -m755 "$tmp/$bin" "$LOCAL_BIN/$bin"
  else
    # binary may live in a subdir
    local found; found="$(find "$tmp" -type f -name "$bin" 2>/dev/null | head -1)"
    [ -n "$found" ] || { rm -rf "$tmp"; return 1; }
    install -m755 "$found" "$LOCAL_BIN/$bin"
  fi
  rm -rf "$tmp"
}

# Case pattern: "<repo>|<asset-glob-for-x86_64>|<asset-glob-for-aarch64>|<bin>"
# asset pattern may contain <VER> placeholder replaced with latest tag (v-stripped).
bin_spec () {
  local tool="$1"
  case "$tool" in
    yazi)      echo "sxyazi/yazi|yazi-x86_64-unknown-linux-gnu.zip|yazi-aarch64-unknown-linux-gnu.zip|yazi" ;;
    eza)       echo "eza-community/eza|eza_x86_64-unknown-linux-gnu.tar.gz|eza_aarch64-unknown-linux-gnu.tar.gz|eza" ;;
    atuin)     echo "atuinsh/atuin|atuin-x86_64-unknown-linux-gnu.tar.gz|atuin-aarch64-unknown-linux-gnu.tar.gz|atuin" ;;
    doggo)     echo "mr-karan/doggo|doggo-linux-x86_64.tar.gz|doggo-linux-aarch64.tar.gz|doggo" ;;
    starship)  echo "starship/starship|starship-x86_64-unknown-linux-gnu.tar.gz|starship-aarch64-unknown-linux-gnu.tar.gz|starship" ;;
    duf)       echo "muesli/duf|duf_<VER>_linux_x86_64.tar.gz|duf_<VER>_linux_arm64.tar.gz|duf" ;;
    dust)      echo "bootandy/dust|dust-<VER>-x86_64-unknown-linux-gnu.tar.gz|dust-<VER>-aarch64-unknown-linux-gnu.tar.gz|dust" ;;
    curlie)    echo "rs/curlie|curlie_<VER>_linux_amd64.tar.gz|curlie_<VER>_linux_arm64.tar.gz|curlie" ;;
    procs)     echo "dalance/procs|procs-v<VER>-x86_64-linux.zip|procs-v<VER>-aarch64-linux.zip|procs" ;;
    gh)        echo "cli/cli|gh_<VER>_linux_amd64.tar.gz|gh_<VER>_linux_arm64.tar.gz|gh" ;;
    lazygit)   echo "jesseduffield/lazygit|lazygit_<VER>_Linux_x86_64.tar.gz|lazygit_<VER>_Linux_arm64.tar.gz|lazygit" ;;
    fastfetch) echo "fastfetch-cli/fastfetch|fastfetch-linux-x86_64.tar.gz|fastfetch-linux-aarch64.tar.gz|fastfetch" ;;
    tldr)      echo "tealdeer-rs/tealdeer|tealdeer-<VER>-x86_64-unknown-linux-gnu.tar.gz|tealdeer-<VER>-aarch64-unknown-linux-gnu.tar.gz|tldr" ;;
    *)         echo "" ;;
  esac
}

install_binary () {
  local tool="$1"
  local spec bin url base tag stripped
  spec="$(bin_spec "$tool")"
  [ -n "$spec" ] || return 1
  base="${spec%%|*}"; spec="${spec#*|}"
  local x64="${spec%%|*}"; spec="${spec#*|}"
  local a64="${spec%%|*}"; bin="${spec#*|}"
  local asset
  if [ "$ARCH" = "x86_64" ]; then asset="$x64"; elif [ "$ARCH" = "aarch64" ]; then asset="$a64"; else return 1; fi

  url="https://github.com/$base/releases/download/latest/$asset"
  if printf '%s' "$asset" | grep -q '<VER>'; then
    tag="$(gh_latest_tag "$base")"
    [ -n "$tag" ] || return 1
    stripped="${tag#v}"
    url="https://github.com/$base/releases/download/$tag/${asset//<VER>/$stripped}"
  fi

  mkdir -p "$LOCAL_BIN"
  if install_release "$url" "$bin"; then
    ok "$tool (binary build)"
    return 0
  fi
  return 1
}

# ---------------------------------------------------------------------------
# is_installed: 0 if tool present on PATH (with fd/debian special case).
# ---------------------------------------------------------------------------
is_installed () {
  local tool="$1"
  if command -v "$tool" >/dev/null 2>&1; then
    return 0
  fi
  # debian fd-find installs binary as fdfind; user expects `fd`.
  if [ "$tool" = "fd" ] && command -v fdfind >/dev/null 2>&1; then
    return 0
  fi
  return 1
}