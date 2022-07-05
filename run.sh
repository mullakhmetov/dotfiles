# git
rm ~/.gitconfig > /dev/null
rm ~/gitignore_global > /dev/null

ln ~/.gitconfig git/config
ln ~/.gitignore_global git/ignore


# zsh
source zsh/install-oh-my-zsh.sh

mv ~/.zsh ~/.zsh_copy
mv ~/.zshrc ~/.zshrc_copy

ln ~/.zshrc zsh/zshrc
mkdir ~/.zsh

ln ~/.zsh/config zsh/config
ln ~/.zsh/plugins zsh/plugins
ln ~/.zsh/aliases zsh/aliases
ln ~/.zsh/functions zsh/functions


# tmux
mv ~/.tmux.conf ~/.tmux.conf.copy
ln ~/.tmux.conf tmux/conf


# scripts
source runscripts.sh



