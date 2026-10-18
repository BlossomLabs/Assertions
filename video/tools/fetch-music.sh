#!/bin/sh
# Download the CC0 music track from its source (see music/CREDITS.md).
#   sh tools/fetch-music.sh
set -e
cd "$(dirname "$0")/.."
out=music/komiku-xenobiological-forest.ogg
[ -f "$out" ] && exit 0
curl -sfL -A "assertions-video (https://assertions.eth.limo)" -o "$out" \
  https://upload.wikimedia.org/wikipedia/commons/0/0f/Komiku_-_05_-_Xenobiological_Forest.ogg
echo "$out"
