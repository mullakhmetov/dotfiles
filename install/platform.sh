#!/usr/bin/env bash
detect_platform() {
    local kernel="${1:-$(uname -s)}" release="${2:-/etc/os-release}"
    local ID="" ID_LIKE=""
    case "$kernel" in
        Darwin) printf '%s\n' macos ;;
        Linux)
            [[ -r "$release" ]] || { printf 'Cannot read OS release.\n' >&2; return 1; }
            source "$release"
            case " $ID $ID_LIKE " in
                *" arch "*|*" archarm "*) printf '%s\n' arch ;;
                *" ubuntu "*|*" debian "*) printf '%s\n' ubuntu ;;
                *) printf 'Unsupported Linux distribution: %s\n' "$ID" >&2; return 1 ;;
            esac
            ;;
        *) printf 'Unsupported OS: %s\n' "$kernel" >&2; return 1 ;;
    esac
}
