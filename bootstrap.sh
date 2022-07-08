# git
mv ~/.gitconfig ~/gitconfig.copy 2> /dev/null
mv ~/.gitignore_global ~/gitignore_global.copy 2> /dev/null

ln git/config ~/.gitconfig
ln git/ignore ~/.gitignore_global


# zsh
source zsh/install-oh-my-zsh.sh

mv ~/.zsh ~/zsh_copy 2> /dev/null
mv ~/.zshrc ~/zshrc_copy 2> /dev/null

ln -s zsh/zshrc ~/.zshrc
mkdir ~/.zsh

ln -s zsh/config ~/.zsh/config
ln -s zsh/plugins ~/.zsh/plugins
ln -s zsh/aliases ~/.zsh/aliases
ln -s zsh/functions ~/.zsh/functions

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# tmux
mv ~/.tmux.conf ~/tmux.conf.copy 2> /dev/null
ln -s tmux/conf ~/.tmux.conf


# scripts
# source runscripts.sh



