#!/usr/bin/env bash

set -e

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/plz-search"
DATA_FILE="$DATA_DIR/german-postcodes.csv"
GIST_URL="https://gist.github.com/6ae8286a494cafce82b6ea5f6cc2362a.git"

check_dependencies() {
    local missing=()

    command -v fzf >/dev/null 2>&1 || missing+=("fzf")
    command -v git >/dev/null 2>&1 || missing+=("git")

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Error: Missing required tools: ${missing[*]}" >&2
        exit 1
    fi
}

download_data() {
    if [ ! -f "$DATA_FILE" ]; then
        echo "Downloading German postal codes..." >&2
        mkdir -p "$DATA_DIR"

        local tmp_dir=$(mktemp -d)
        trap "rm -rf $tmp_dir" EXIT

        if git clone --depth 1 "$GIST_URL" "$tmp_dir" >/dev/null 2>&1; then
            mv "$tmp_dir/german-postcodes.csv" "$DATA_FILE"
        else
            echo "Error: Failed to download postal codes" >&2
            exit 1
        fi
    fi
}

main() {
    check_dependencies
    download_data

    local selection=$(tail -n +2 "$DATA_FILE" | \
        awk -F';' '{printf "%-30s → %s (%s)\n", $1, $2, $3}' | \
        fzf --prompt="City: " \
            --height=40% \
            --layout=reverse \
            --border \
            --preview-window=hidden)

    if [ -n "$selection" ]; then
        local plz=$(echo "$selection" | awk '{print $3}')
        echo -n "$plz" | wl-copy
    fi
}

main "$@"
