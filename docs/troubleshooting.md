# Troubleshooting

## `Package manager not supported`

`install-packages.sh` prints `unsupported OS`. The distro's `ID`/`ID_LIKE` in
`/etc/os-release` is not mapped. Add it to `scripts/detect-os.sh` (and, if it
uses an existing package manager, the mapping flows automatically).

## A tool shows as failed

`✓/x` in the checklist. Either:
- The native package name differs — check `pkg_native` in `scripts/packages.sh`.
- The tool needs a GitHub binary fallback — add a spec to `bin_spec` in
  `scripts/packages.sh` for the correct asset names (match the upstream
  release assets).

## Shell did not change to zsh

- Confirm zsh is in `/etc/shells` (the script adds it).
- Check `chsh` reported success; some systems use `useradd`/LDAP and need the
  change upstream.
- Log out completely — `$SHELL` in an existing session stays until restart.

## `chezmoi apply` conflict

If an existing file is not managed, chezmoi shows a conflict by default.
Inspect with `chezmoi diff`, then decide: `chezmoi apply` (overwrite) or back it
up first. On a fresh machine there is normally no conflict.

## Settings not picked up

Dotfiles load once per shell. Start a new shell, or `exec zsh`. Starship,
fzf, zoxide, and atuin are `command -v`-guarded in `.zshrc`, so a missing tool
never prevents zsh from starting.

## Public repo, no leaked secrets

The repo contains no private keys/tokens. Git identity is templated in from
chezmoi data or `GIT_USER_NAME`/`GIT_USER_EMAIL`. Keep other credentials in
ignored machine files and reference them via templates.