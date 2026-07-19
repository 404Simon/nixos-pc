#!/usr/bin/env bash

playlist_dir="$HOME/Music/mpd/playlists"
playlists=$(find "$playlist_dir" -name "*.m3u" -type f -printf "%f\n" | sed 's/\.m3u$//')

choice=$(echo "$playlists" | wofi --dmenu -i -p "Choose playlist:")

[ -z "$choice" ] && exit 0

playlist_file="$playlist_dir/$choice.m3u"
[ ! -f "$playlist_file" ] && exit 0

music_root="$HOME/Music"

rmpc clear

mapfile -t tracks < <(grep -v -e '^#' -e '^$' "$playlist_file")

while IFS= read -r track; do
    track="${track#../../}"
    rmpc add "$track"
done < <(printf '%s\n' "${tracks[@]}" | shuf)

rmpc play
