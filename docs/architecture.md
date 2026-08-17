# Architecture

## Overview

The setup is a git repository (`chezmoi` source) plus a small set of Bash
provision scripts. Two layers with a clear boundary:

```
usr config/orchestration  →  chezmoi            (dotfiles, apply/update/diff)
software installation     →  native package manager  (dnf / pacman / apt)
```

Bash scripts orchestrate the package layer; chezmoi owns configuration files.

## Detection flow

`scripts/detect-os.sh` reads `/etc/os-release` and sets three globals:

| Variable | Meaning | Example |
| --- | --- | --- |
| `OS_ID` | distro id | `fedora`, `arch`, `debian`, `ubuntu` |
| `OS_FAMILY` | family used for mapping | `fedora`, `arch`, `debian` |
| `PM` | package manager | `dnf`, `pacman`, `apt` |
| `ARCH` | normalized cpu arch | `x86_64`, `aarch64` |

Unknown family ⇒ `PM=unknown` and `install-packages.sh` fails safely.

`scripts/bootstrap.sh` is the single entry point; it does not duplicate logic,
it chains the focused scripts.

## Package layer

`scripts/packages.sh` is the only place that knows package names. Two lookup
paths per tool:

1. `pkg_native <tool>` → native package name for the current `OS_FAMILY`
   (empty means "not in repos").
2. `install_binary <tool>` → GitHub release fallback into `~/.local/bin`,
   arch-aware, used when there is no native package.

`scripts/install-packages.sh` loops the tool list, skips what `is_installed`
returns, installs the rest, and reports anything it could not install. It
prints a non-zero exit if failures occurred, but continues to avoid cascading
failures.

Adding a distribution or a new install method = extend the mapping functions in
`packages.sh` only. No plumbing changes elsewhere.

## Shell setup

`scripts/setup-shell.sh`:
1. Installs zsh if missing.
2. Reads the *configured* login shell (via `getent passwd`, not just `$SHELL`).
3. Adds zsh to `/etc/shells` if needed.
4. Runs `chsh -s <zsh>` (via sudo) only when zsh is not already the shell.

It never edits `/etc/passwd` directly and never runs `chsh` when unnecessary.

## Configuration layer

chezmoi maps repo files to home paths via its dot-naming convention:

| Repo | Home |
| --- | --- |
| `dot_zshrc` | `~/.zshrc` |
| `dot_tmux.conf` | `~/.tmux.conf` |
| `dot_config/` | `~/.config/...` |

`.chezmoi.toml.tmpl` derives OS/package-manager data (also used by templates)
so a single config set works across machines. Git identity is read from chezmoi
data or `GIT_USER_NAME`/`GIT_USER_EMAIL` env vars — never committed, which keeps
the repo safe to keep public.

## Idempotency

- Package install skips already-installed tools.
- `chsh` is skipped when zsh is already the login shell.
- `chezmoi apply` is idempotent by design.
- bin/scripts place files with a stable name; nothing appends repeatedly.