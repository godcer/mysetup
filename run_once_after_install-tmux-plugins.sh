#!/usr/bin/env bash
set -eu

TPM="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM/.git" ]; then
  mkdir -p "$(dirname "$TPM")"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM"
fi

# TPM expects a running tmux server when installing plugins.
if ! tmux start-server 2>/dev/null; then
  tmux new-session -d -s chezmoi-bootstrap 'sleep 1' 2>/dev/null || true
fi

if [ -x "$TPM/bin/install_plugins" ]; then
  "$TPM/bin/install_plugins"
fi

tmux kill-session -t chezmoi-bootstrap 2>/dev/null || true
