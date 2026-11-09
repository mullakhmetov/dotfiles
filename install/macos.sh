#!/usr/bin/env bash
set -euo pipefail
command -v brew >/dev/null || {
    printf 'Install Homebrew before running this script.\n' >&2
    exit 1
}
brew install git git-lfs curl zsh tmux neovim fzf ripgrep fd jq \
    difftastic zoxide lsd atuin node go uv
