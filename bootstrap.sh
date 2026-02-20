#!/bin/sh
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo '==> Linking git config'
ln -sf "$DOTFILES_DIR/git/config" "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/git/ignore" "$HOME/.gitignore_global"

echo '==> Linking zsh config'
ln -sf "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
mkdir -p "$HOME/.zsh"
ln -sf "$DOTFILES_DIR/zsh/config"        "$HOME/.zsh/config"
ln -sf "$DOTFILES_DIR/zsh/plugins"       "$HOME/.zsh/plugins"
ln -sf "$DOTFILES_DIR/zsh/aliases"       "$HOME/.zsh/aliases"
ln -sf "$DOTFILES_DIR/zsh/functions"     "$HOME/.zsh/functions"
ln -sf "$DOTFILES_DIR/zsh/shell_scripts" "$HOME/.zsh/shell_scripts"
ln -sf "$DOTFILES_DIR/zsh/path_updates"  "$HOME/.zsh/path_updates"

echo '==> Linking tmux config'
ln -sf "$DOTFILES_DIR/tmux/conf" "$HOME/.tmux.conf"

echo '==> Done. Reload your shell.'
