#!/bin/sh
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

symlink() { rm -f "$2"; ln -s "$1" "$2"; }

echo '==> Linking git config'
symlink "$DOTFILES_DIR/git/config" "$HOME/.gitconfig"
symlink "$DOTFILES_DIR/git/ignore" "$HOME/.gitignore_global"

echo '==> Linking zsh config'
symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
mkdir -p "$HOME/.zsh"
symlink "$DOTFILES_DIR/zsh/config"        "$HOME/.zsh/config"
symlink "$DOTFILES_DIR/zsh/plugins"       "$HOME/.zsh/plugins"
symlink "$DOTFILES_DIR/zsh/aliases"       "$HOME/.zsh/aliases"
symlink "$DOTFILES_DIR/zsh/functions"     "$HOME/.zsh/functions"
symlink "$DOTFILES_DIR/zsh/shell_scripts" "$HOME/.zsh/shell_scripts"
symlink "$DOTFILES_DIR/zsh/path_updates"  "$HOME/.zsh/path_updates"

echo '==> Linking tmux config'
symlink "$DOTFILES_DIR/tmux/conf" "$HOME/.tmux.conf"

echo '==> Done. Reload your shell.'
