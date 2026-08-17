# dotfiles

Portable terminal environment managed by [chezmoi](https://www.chezmoi.io/).

Deploys a matching Zsh, Starship, tmux, Neovim, Git, and terminal-tool setup on
any of: **Fedora, Arch, Debian, Ubuntu** (x86_64 and aarch64). One command to
bootstrap a fresh machine; safe to run repeatedly.

## Scope

Terminal environment only. Desktop/DE, Niri/Noctalia, services, dev/pen-testing
environments, and Nix are out of scope for now.

## Quick start (fresh machine)

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <REPOSITORY_URL>
~/.local/share/chezmoi/scripts/bootstrap.sh
```

`bootstrap.sh` will:
1. Detect OS / package manager / architecture.
2. Ensure required terminal tools are installed (native package manager with a
   GitHub-binary fallback for tools not in the repos).
3. Ensure **zsh** is installed and set as your login shell.
4. Run `chezmoi apply` to deploy all configuration.
5. Verify the result and print a summary.

Re-running the same commands is safe and makes only the necessary changes.

## Daily use

```bash
chezmoi apply     # push local changes into place
chezmoi diff      # show what would change
chezmoi update    # pull repo changes and apply
```

## Repository layout

| Path | Purpose |
| --- | --- |
| `.chezmoi.toml.tmpl` | chezmoi config; computes OS/package manager/arch data |
| `dot_zshrc` | `~/.zshrc` |
| `dot_tmux.conf` | `~/.tmux.conf` |
| `dot_gitconfig.tmpl` | `~/.gitconfig` (identity templated, never committed) |
| `dot_gitignore_global` | `~/.gitignore_global` |
| `dot_config/` | per-tool configs → `~/.config/...` |
| `scripts/` | small, focused, idempotent provision scripts |
| `docs/` | installation, architecture, troubleshooting |

## Design

- **Chezmoi** = configuration and orchestration layer.
- **Native package manager** = installs software (dnf / pacman / apt).
- **Git + Bash** glue the pieces together. No Nix, no Home Manager, no Stow.
- Package mapping is centralized in `scripts/packages.sh`, so adding a new
  distribution or an extra install method is a small change in one place.