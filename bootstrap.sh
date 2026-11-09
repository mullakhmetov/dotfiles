#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
MODE=dry-run
WITH_CLAUDE=false
for arg in "$@"; do
    case "$arg" in
        --apply) MODE=apply ;;
        --dry-run) MODE=dry-run ;;
        --with-claude) WITH_CLAUDE=true ;;
        *) printf 'Unknown argument: %s\n' "$arg" >&2; exit 2 ;;
    esac
done
BACKUP_DIR=""
umask 077

link_config() {
    local source="$DOTFILES_DIR/$1" target="$2" backup
    if [[ ! -e "$source" ]]; then
        printf 'Missing source: %s\n' "$source" >&2
        return 1
    fi
    if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
        return
    fi
    printf '%s: %s -> %s\n' "$MODE" "$target" "$source"
    [[ "$MODE" == apply ]] || return 0
    mkdir -p "$(dirname "$target")"
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ -z "$BACKUP_DIR" ]]; then
            mkdir -p "$STATE_DIR/dotfiles/backups"
            BACKUP_DIR="$(mktemp -d "$STATE_DIR/dotfiles/backups/$(date +%Y%m%d-%H%M%S).XXXXXX")"
            printf 'Backup directory: %s\n' "$BACKUP_DIR"
        fi
        backup="$BACKUP_DIR/${target#/}"
        mkdir -p "$(dirname "$backup")"
        mv "$target" "$backup"
        printf '%s\t%s\n' "$target" "$backup" >> "$BACKUP_DIR/manifest.tsv"
    fi
    ln -s "$source" "$target"
}

link_config git/config "$HOME/.gitconfig"
link_config git/ignore "$HOME/.gitignore_global"
link_config zsh/zshrc "$HOME/.zshrc"
link_config zsh/zshenv "$HOME/.zshenv"
link_config zsh/zprofile "$HOME/.zprofile"
for file in config plugins aliases functions path_updates shell_scripts; do
    link_config "zsh/$file" "$HOME/.zsh/$file"
done
link_config tmux/conf "$HOME/.tmux.conf"
link_config tmux/session-style.sh "$HOME/.tmux/session-style.sh"
link_config tmux/copy.sh "$HOME/.tmux/copy.sh"
link_config nvim "$CONFIG_DIR/nvim"
link_config atuin/config.toml "$CONFIG_DIR/atuin/config.toml"
if "$WITH_CLAUDE"; then
    for file in settings.json statusline.sh CLAUDE.md; do
        link_config "claude/$file" "$HOME/.claude/$file"
    done
fi
printf 'Configuration %s complete.\n' "$MODE"
