#!/usr/bin/env bash
set -eu

TPM="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM/.git" ]; then
  mkdir -p "$(dirname "$TPM")"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM"
fi

# TPM reads the tmux configuration from a running server when installing plugins.
tmux new-session -d -s chezmoi-bootstrap 'sleep 1' 2>/dev/null || true

if [ -x "$TPM/bin/install_plugins" ]; then
  "$TPM/bin/install_plugins"
fi

tmux kill-session -t chezmoi-bootstrap 2>/dev/null || true
