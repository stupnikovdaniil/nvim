#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
check_tmp=$(mktemp -d "${TMPDIR:-/tmp}/nvim-config-check.XXXXXX")
trap 'rm -rf "$check_tmp"' EXIT HUP INT TERM
export NVIM_LOG_FILE="$check_tmp/nvim.log"
plugin_data=$(nvim --headless -u NONE -i NONE '+lua io.write(vim.fn.stdpath("data"))' '+qa!')
app_name=${NVIM_APPNAME:-nvim}
export XDG_DATA_HOME="$check_tmp/data"
export XDG_CACHE_HOME="$check_tmp/cache"
export XDG_STATE_HOME="$check_tmp/state"
mkdir -p "$XDG_DATA_HOME/$app_name"
ln -s "$plugin_data/lazy" "$XDG_DATA_HOME/$app_name/lazy"
if [ "${1:-}" = "--profile" ]; then
    for sample in 1 2 3 4 5; do
        nvim --headless -u NONE -i NONE -l tests/profile.lua
    done
else
    nvim --headless -u NONE -i NONE -l tests/run.lua
    for key in tf tt; do
        NVIM_HINT_KEY="$key" nvim --headless -u NONE -i NONE -l tests/tree.lua
    done
fi
