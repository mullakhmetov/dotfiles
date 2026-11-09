#!/usr/bin/env bash
set -euo pipefail

clone_plugin() {
    local repository="$1" target="$2"
    if [[ -e "$target" || -L "$target" ]]; then
        printf 'Preserve existing plugin: %s\n' "$target"
        return
    fi
    mkdir -p "$(dirname "$target")"
    git clone --depth 1 "$repository" "$target"
}
clone_plugin https://github.com/ohmyzsh/ohmyzsh.git "${ZSH:-$HOME/.oh-my-zsh}"
CUSTOM="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}"
clone_plugin https://github.com/zsh-users/zsh-autosuggestions "$CUSTOM/plugins/zsh-autosuggestions"
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting "$CUSTOM/plugins/zsh-syntax-highlighting"
clone_plugin https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
