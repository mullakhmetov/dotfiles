#!/bin/sh
SESSION_NAME="$1"

if [ "$SESSION_NAME" = "prod" ]; then
  tmux set status-style bg=colour1
elif [ -n "$SSH_CONNECTION" ]; then
  tmux set status-style bg=colour30,fg=colour137,dim
else
  tmux set status-style bg=colour234,fg=colour137,dim
fi
