#!/bin/bash
set -e

echo '==> Installing apt packages'
sudo apt-get update -qq
sudo apt-get install -y zsh git tmux curl unzip

echo '==> Installing neovim'
sudo snap install neovim --classic

echo '==> Installing fzf'
if [[ ! -d "$HOME/.fzf" ]]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-bash --no-fish
fi

echo '==> Installing zoxide'
if ! command -v zoxide &>/dev/null; then
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

echo '==> Installing lsd'
if [[ ! -x /usr/local/bin/lsd ]]; then
  LSD_VERSION="1.1.5"
  LSD_URL="https://github.com/lsd-rs/lsd/releases/download/v${LSD_VERSION}/lsd-v${LSD_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
  curl -fsSL "$LSD_URL" | tar xz -C /tmp
  sudo mv "/tmp/lsd-v${LSD_VERSION}-x86_64-unknown-linux-gnu/lsd" /usr/local/bin/lsd
  rm -rf "/tmp/lsd-v${LSD_VERSION}-x86_64-unknown-linux-gnu"
fi

echo '==> Installing atuin'
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

echo '==> Installing oh-my-zsh'
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo '==> Installing zsh plugins'
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

echo '==> Setting zsh as default shell'
chsh -s "$(which zsh)"

echo '==> Ubuntu setup complete'
