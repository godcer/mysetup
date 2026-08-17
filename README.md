# mysetup

My personal terminal environment managed by [chezmoi](https://www.chezmoi.io/).

The repository keeps the terminal configuration and the small amount of bootstrap logic needed to reproduce it on a fresh Linux system.

## Fresh machine

Install and apply everything with one command:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply https://github.com/godcer/mysetup
```

During initialization, chezmoi asks for the local Git identity. Both values are optional and remain local to the machine.

The setup automatically:

- detects Fedora, Arch, Debian, Ubuntu, and common derivatives;
- installs the terminal tools used by the configuration;
- installs required base utilities such as `awk`;
- installs Zsh and makes it the login shell;
- installs TPM and the configured tmux plugins;
- installs Nix in daemon mode when it is missing;
- enables `nix-command` and Flakes through the user Nix configuration;
- applies the terminal dotfiles.

Nix installation is intentionally separate from the terminal package list: the terminal tools remain native to the distribution where possible, while Nix provides reproducible development environments.

## Nix environments

The portable Flake lives at:

```text
~/.config/ank/nix/flake.nix
```

Use it with:

```bash
cd ~/.config/ank/nix
nix develop
nix develop .#recon
nix develop .#web
nix develop .#osint
```

These are temporary development shells. Packages disappear from the shell when you exit the environment; they are not installed globally by the Flake.

## Included terminal configuration

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

`chezmoi apply` is idempotent. Package provisioning runs only when its chezmoi provisioning definition changes, and Nix installation runs only when Nix is missing.

## Scope

Current scope is the terminal and reproducible Nix development environments. Desktop configuration, Niri, Noctalia, and other system configuration will be added separately later.
