#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/install/platform.sh"
MODE=--dry-run
WITH_CLAUDE=false
for arg in "$@"; do
    case "$arg" in
        --apply|--dry-run) MODE="$arg" ;;
        --with-claude) WITH_CLAUDE=true ;;
        *) printf 'Unknown argument: %s\n' "$arg" >&2; exit 2 ;;
    esac
done
PLATFORM="$(detect_platform)"
printf 'Platform: %s\n' "$PLATFORM"
if [[ "$MODE" == --apply ]]; then
    bash "$DOTFILES_DIR/install/$PLATFORM.sh"
    bash "$DOTFILES_DIR/install/plugins.sh"
else
    printf 'Package installer: %s\n' "$DOTFILES_DIR/install/$PLATFORM.sh"
    printf 'No packages or plugins will change. Use --apply to install.\n'
fi
if "$WITH_CLAUDE"; then
    bash "$DOTFILES_DIR/bootstrap.sh" "$MODE" --with-claude
else
    bash "$DOTFILES_DIR/bootstrap.sh" "$MODE"
fi
