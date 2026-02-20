#!/bin/bash
set -eo pipefail

echo '==> Ensuring Homebrew is installed'
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo '==> Installing brew packages'
brew install \
  coreutils moreutils findutils gnu-sed \
  vim git wget grep httpie jq difftastic \
  nmap zoxide tmux openssh openssl \
  redis sqlite lsd docker-compose \
  postgres pgcli kubectl \
  nodejs pnpm typescript \
  atuin \
  golang

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

echo '==> macOS setup complete'
