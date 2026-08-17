# Installation

## Prerequisites

- A supported OS: **Fedora, Arch, Debian, Ubuntu** (x86_64 or aarch64).
- An unprivileged user with `sudo` (the scripts use `sudo` only for package/shell
  changes, and run chezmoi as your own user).
- `curl` available (present on essentially all these systems).

## Fresh machine

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <REPOSITORY_URL>
```

Then run provisioning:

```bash
~/.local/share/chezmoi/scripts/bootstrap.sh
```

That single command chain:

```
detect OS/PM/arch
  → install missing terminal tools
  → install/check zsh + set login shell
  → chezmoi apply (deploy dotfiles)
  → verify
```

## What gets configured

| Component | File |
| --- | --- |
| Shell | `~/.zshrc` |
| Terminal multiplexer | `~/.tmux.conf` |
| Git | `~/.gitconfig`, `~/.gitignore_global` |
| Prompt | `~/.config/starship/starship.toml` |
| Editor | `~/.config/nvim/...` |
| File manager | `~/.config/yazi/...` |
| Monitor | `~/.config/btop/...` |
| History | `~/.config/atuin/...` |
| Git TUI | `~/.config/lazygit/...` |
| GitHub CLI | `~/.config/gh/...` |
| Fetch | `~/.config/fastfetch/...` |

## Git identity

The repo never stores your name/email. Set them once (any of):

```bash
chezmoi -D git_user_name="You" -D git_user_email="you@example.com" apply
# or
GIT_USER_NAME="You" GIT_USER_EMAIL="you@example.com" chezmoi apply
# or just let git prompt on first commit
```

## After install

Log out and back in (or start a new shell) if the default shell was changed.
Run `chezmoi status`/`chezmoi diff` at any time to review state.

## Updating

```bash
chezmoi update          # pulls repo + applies
```