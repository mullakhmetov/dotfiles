#!/bin/bash
set -e

REPO_URL="https://github.com/mullakhmetov/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# Detect OS
OS="$(uname -s)"
case "$OS" in
  Linux*)   PLATFORM="ubuntu" ;;
  Darwin*)  PLATFORM="macos" ;;
  *)        echo "Unsupported OS: $OS" && exit 1 ;;
esac

echo "==> Detected platform: $PLATFORM"

# Ensure git is available
if ! command -v git &>/dev/null; then
  if [[ "$PLATFORM" == "ubuntu" ]]; then
    sudo apt-get update -qq && sudo apt-get install -y git
  else
    echo "git not found. Install Xcode Command Line Tools: xcode-select --install"
    exit 1
  fi
fi

# Clone dotfiles
if [[ -d "$DOTFILES_DIR" ]]; then
  echo "==> Dotfiles already cloned at $DOTFILES_DIR, pulling latest"
  git -C "$DOTFILES_DIR" pull --ff-only
else
  echo "==> Cloning dotfiles to $DOTFILES_DIR"
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# Run platform-specific installer
echo "==> Running $PLATFORM installer"
bash "$DOTFILES_DIR/install/$PLATFORM.sh"

# Symlink dotfiles
echo "==> Running bootstrap"
bash "$DOTFILES_DIR/bootstrap.sh"

echo ""
echo "==> All done! Start a new zsh session."
