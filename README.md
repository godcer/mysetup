# mysetup

My personal terminal environment managed by [chezmoi](https://www.chezmoi.io/).

The repository keeps the terminal configuration itself and lets chezmoi handle the machine setup around it. The current terminal configuration is based on the latest configuration from `ank_config`; Nix/Flake files are intentionally excluded.

## Fresh machine

Install and apply everything with one command:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply https://github.com/godcer/mysetup
```

During initialization, chezmoi asks for the local Git identity:

```text
Git name (optional):
Git email (optional):
```

Both can be left empty. The values are stored in the local chezmoi configuration and are never committed to this repository.

The setup automatically:

- detects Fedora, Arch, Debian, Ubuntu, and common derivatives;
- installs the terminal tools used by the configuration;
- installs required base utilities such as `awk` for tmux/CLI tooling;
- installs optional configured tools such as Helix when available;
- uses the native package manager first and upstream installers/releases when a package is unavailable;
- normalizes Debian's `fd`/`fdfind` and `bat`/`batcat` names;
- installs Zsh and makes it the login shell;
- applies the terminal dotfiles;
- installs TPM and the tmux plugins declared by `.tmux.conf`.

## Included configuration

- Zsh + Starship
- Bash fallback configuration
- tmux + TPM plugins
- Neovim / NvChad
- Helix
- Fastfetch
- Yazi
- Atuin
- Git
- fzf / fd / ripgrep
- eza / bat / zoxide
- btop / jq
- lazygit / GitHub CLI

## Daily use

```bash
chezmoi apply
chezmoi diff
chezmoi update
```

`chezmoi apply` is intentionally quiet after the initial setup. Package provisioning runs again when the provisioning definition changes.

## Scope

This repository currently covers the terminal only. Desktop configuration, Niri, Noctalia, Nix/Flakes, pentesting environments, services, and other system configuration are intentionally kept separate for now.

## Repository rule

The files that define the terminal experience are kept as normal chezmoi source files. Setup logic is implemented through chezmoi's `run_onchange_` / `run_once_` scripts so a fresh machine needs no second bootstrap command.
