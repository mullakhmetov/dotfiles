#!/bin/sh

# git
echo 'copying git dotfiles'
mv ~/.gitconfig ~/gitconfig.copy 2> /dev/null
mv ~/.gitignore_global ~/gitignore_global.copy 2> /dev/null

ln $PWD/git/config $HOME/.gitconfig
ln $PWD/git/ignore $HOME/gitignore_global


# zsh
echo 'installing oh-my-zsh'
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo 'copying zsh dotfiles'
mv ~/.zsh ~/zsh_copy 2> /dev/null
mv ~/.zshrc ~/zshrc_copy 2> /dev/null

ln -s $PWD/zsh/zshrc $HOME/.zshrc
mkdir ~/.zsh

ln -s $PWD/zsh/config $HOME/.zsh/config
ln -s $PWD/zsh/plugins $HOME/.zsh/plugins
ln -s $PWD/zsh/aliases $HOME/.zsh/aliases
ln -s $PWD/zsh/functions $HOME/.zsh/functions
ln -s $PWD/zsh/path_updates $HOME/.zsh/path_updates

echo 'installing some zsh plugins'
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# tmux
echo 'copying tmux dotfiles'
mv ~/.tmux.conf ~/tmux.conf.copy 2> /dev/null
ln -s $PWD/tmux/conf $HOME/.tmux.conf


# scripts
# echo 'running scripts'
# source runscripts.sh

chmod a+x clean_dotfiles.sh

