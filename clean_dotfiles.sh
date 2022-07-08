read -p "Deleting all dotfiles. Are you sure? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	rm ~/.gitconfig
	rm ~/.gitignore_global
	rm ~/.zshrc
	rm ~/.zprofile
	rm ~/.zshrc.pre-oh-my-zsh
	rm ~/.tmux.conf

	rm -rf ~/.zsh
	rm -rf ~/.oh-my-zsh
fi

