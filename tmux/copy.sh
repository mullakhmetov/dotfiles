#!/bin/sh
set -eu
if [ -n "${SSH_CONNECTION:-}" ]; then
    exec tmux load-buffer -w -
elif [ "$(uname -s)" = Darwin ] && command -v pbcopy >/dev/null 2>&1; then
    exec pbcopy
elif [ -n "${WAYLAND_DISPLAY:-}" ] && command -v wl-copy >/dev/null 2>&1; then
    exec wl-copy
elif [ -n "${DISPLAY:-}" ] && command -v xclip >/dev/null 2>&1; then
    exec xclip -selection clipboard
else
    exec tmux load-buffer -w -
fi
