#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Keep the legacy entry point, with the same safe default as the main installer.
exec python3 -B "$ROOT/install/packages.py" --platform macos --group all "$@"
