###############################################################################
# Path to oh-my-zsh
ZSH=~/.dotfiles/zsh/oh-my-zsh
#ZSH=~/.oh-my-zsh
# Enable oh-my-zsh plugins here.
plugins=(git, python, history-substring-search)

# Use a theme from a seperate repository.
POWERLINE_HIDE_HOST_NAME="true"
#POWERLINE_HIDE_GIT_PROMPT_STATUS="true"
#POWERLINE_RIGHT_A="mixed"
#POWERLINE_DETECT_SSH="true"
#ZSH_THEME="../../oh-my-zsh-powerline-theme/powerline"
ZSH_THEME="miloshadzic"

export PATH=/usr/local/bin:/usr/local/sbin:~/bin:$PATH

# Source oh-my-zsh.
source $ZSH/oh-my-zsh.sh
#source /usr/local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh
# Enable vi keybindings.
bindkey -v
bindkey -M vicmd v edit-command-line

# Source the zsh syntax highlighter. For some reason this is not included in
# oh-my-zsh. Works more reliable if done after sourcing oh-my-zsh.
source ~/.dotfiles/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Add zsh-completions.
fpath=(~/.dotfiles/zsh/zsh-completions/src $fpath)

# Make 'z' work like autojump.
#alias j="z"
# Slash after directories, colorize, KB,MB,... when appropriate
alias ls='ls -GFh'

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

# Disable auto-update prompt
DISABLE_AUTO_UPDATE="true"

# Disable setting of terminal titles.
DISABLE_AUTO_TITLE="true"

# Show red dots while waiting for completion
COMPLETION_WAITING_DOTS="true"
###############################################################################


###############################################################################
# Enable history substring search with vi and emacs keys. Much more intuitive!
# From https://github.com/zsh-users/zsh-history-substring-search/issues/12
bindkey -M emacs "^P" history-substring-search-up
bindkey -M emacs "^N" history-substring-search-down
bindkey -M vicmd "k" history-substring-search-up
bindkey -M vicmd "j" history-substring-search-down

for keymap in 'emacs' 'viins'; do
    bindkey -M "$keymap" '\e[A' history-substring-search-up
    bindkey -M "$keymap" '\e[B' history-substring-search-down
done
unset keymap

# Remove the ugly pink default color!
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=white,bold'
###############################################################################


############################################################
# ALIASES

# Some aliases should only be set while using OSX.
if [[ "$OSTYPE" == darwin* ]]; then
    # Propert 256 color tmux. Also OSX needs special care for copy/paste to
    # work inside tmux. This will source the basic tmux.conf and execute one
    # special command for copy/paste to work.
        # alias tmux="TERM=screen-256-color-bce tmux attach --source-file ~/.tmux.conf || TERM=screen-256color-bce tmux -2 -f ~/.tmux.conf"

    # Alias Quicklook for some filetypes. Simply typing the filename should
    # open Quicklook with the file. The quicklook command require the osx module
    # from oh-my-zsh or at least the ql command.
    # Websites
    alias -s html=ql
    alias -s htm=ql
    # Markdown
    alias -s md=ql
    alias -s markdown=ql
    # Image files
    alias -s png=ql
    alias -s jpg=ql
    alias -s jpeg=ql
    alias -s gif=ql
    alias -s bmp=ql
    # Misc
    alias -s pdf=ql
    alias -s txt=ql
    # Open files in Quick Look.
    function ql {
        (( $# > 0 )) && qlmanage -p "$@" &> /dev/null
    }
else
    # On non-OSX the simple tmux.conf is sufficient.
    alias tmux="term=screen-256color-bce tmux attach --source-file ~/.tmux.conf || term=screen-256color-bce tmux -2 -f ~/.tmux.conf"
    # Alias xdg-open to open on linux.
    alias open="xdg-open"
fi
############################################################


############################################################
# RANDOM THINGS
# Locale exports are necessary for some programs...
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
############################################################


############################################################
# PATHS. Currently adds homebrew and TeX related binaries.
export PATH=/usr/local/bin:$PATH:/usr/texbin
############################################################



# Enable autojump...
#[[ -s ~/.autojump/etc/profile.d/autojump.zsh ]] && source ~/.autojump/etc/profile.d/autojump.zsh
#[[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh


# Setup zsh-autosuggestions
#source /Users/qr/.zsh-autosuggestions/autosuggestions.zsh

# Enable autosuggestions automatically
#zle-line-init() {
#    zle autosuggest-start
#}

#zle -N zle-line-init

# use ctrl+t to toggle autosuggestions(hopefully this wont be needed as
# zsh-autosuggestions is designed to be unobtrusive)
bindkey '^T' autosuggest-toggle
#alias j="autojump"

eval "$(rbenv init -)"
eval "$(fasd --init auto)"
alias v='f -e vim' # quick opening files with vim
alias m='f -e mplayer' # quick opening files with mplayer
alias o='a -e xdg-open' # quick opening files with xdg-open
alias c='fasd_cd -d'
#################
# sencha
export PATH=/Users/qr/bin/Sencha/Cmd/6.0.0.202:$PATH
export SENCHA_CMD_6_0_0="/Users/qr/bin/Sencha/Cmd/6.0.0.202"
###############
#postgresql
# export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin
# set PATH /Applications/Postgres.app/Contents/Versions/latest/bin $PATH
export DYLD_LIBRARY_PATH=/usr/local/Cellar/openssl/1.0.2h_1/lib
######
#export http_proxy=http://a.mullakhmetov:edFy92a8@proxy:8080/
#export https_proxy=http://a.mullakhmetov:edFy92a8@proxy:8080/
#export ftp_proxy=http://a.mullakhmetov:edFy92a8@proxy:8080/
#export ALL_PROXY=http://a.mullakhmetov:edFy92a8@proxy:8080/
##### virtualenv
export WORKON_HOME=~/Workspace/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
export WEB_EDU_CONFIG_PATH=~/Workspace/bars-open/configs/web_edu/conf/
export SSUZ_CONFIG_PATH=~/Workspace/bars-open/configs/ssuz/conf/
# export DJANGO_SETTINGS_MODULE=web_edu.settings
###### FLASK
# export PGDATA=~/Workspace/Python/db/
######
alias web_edu='workon web_edu_dev && cd /Users/qr/Workspace/bars-open/eduschl/src/web_edu/' # activate web_edu virtualenv and navigate to web_edu project folder

bindkey '^[[1;9D' backward-word
bindkey '^[[1;9C' forward-word
bindkey '^[[1;10D' beginning-of-line
bindkey '^[[1;10C' end-of-line

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
source ~/.iterm2_shell_integration.`basename $SHELL`
