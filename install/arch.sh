#!/usr/bin/env bash
set -euo pipefail
# A full upgrade avoids an unsupported partial Arch upgrade.
sudo pacman -Syu --needed git git-lfs curl zsh tmux neovim fzf ripgrep fd jq \
    difftastic zoxide lsd atuin nodejs npm go uv base-devel unzip wl-clipboard
