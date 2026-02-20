# dotfiles

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/mullakhmetov/dotfiles/master/install.sh | bash
```

Detects OS (Ubuntu or macOS) and prompts for optional component groups:

- **shell tools** — zsh, oh-my-zsh, fzf, zoxide, lsd, atuin
- **neovim**

Core tools (git, tmux, curl) are always installed.

## Manual re-link

To re-symlink configs without reinstalling tools:

```sh
bash ~/dotfiles/bootstrap.sh
```
