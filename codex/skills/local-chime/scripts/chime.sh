#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 0 ]; then
    printf 'Usage: bash %s\nConfigure sound and volume with setup_codex.py --with-chime.\n' "$0" >&2
    exit 2
fi

chime_source="${XDG_DATA_HOME:-$HOME/.local/share}/setup_my_environment/peon-ping"
chime_config="${XDG_CONFIG_HOME:-$HOME/.config}/setup_my_environment/peon-ping"
if [ ! -f "$chime_source/peon.sh" ] || [ ! -f "$chime_config/config.json" ]; then
    printf 'Chime setup is missing. Run make codex-chime in setup_my_environment.\n' >&2
    exit 1
fi

case "$(uname -s)" in
    Linux) export PEON_PLATFORM=linux ;;
    Darwin) export PEON_PLATFORM=mac ;;
    *) printf 'Local chimes are supported on Linux and macOS.\n' >&2; exit 1 ;;
esac

# The sound should play on this computer, even when Codex is reached over SSH.
export CLAUDE_PEON_DIR="$chime_config"
# peon-ping supports project overrides; use the personal configuration here.
cd "$chime_config"
exec bash "$chime_source/peon.sh" preview task.complete
