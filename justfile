# Terminal dotfiles
# Usage: just <recipe> (see `just --list`)

set shell := ["bash", "-c"]

# Initial bootstrap on a fresh machine (installs deps, packages, shell, config)
bootstrap:
    bash scripts/bootstrap.sh

# Install/repair the software tools (idempotent)
packages:
    bash scripts/install-packages.sh

# Apply chezmoi config to restore dotfiles
apply:
    chezmoi apply

# Verify that tools + shell + config are all in place
verify:
    bash scripts/verify.sh

# Confirm the OS is supported by the scripts
detect:
    bash scripts/detect-os.sh

# Show current git remote / status helpers
status:
    git status
    git remote -v

# Push the source repo to the configured public remote
push:
    git push