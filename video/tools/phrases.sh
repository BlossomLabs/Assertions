#!/bin/sh
# Print the silences inside a voice clip. The spans between them are the
# phrases whose offsets go into PHRASES in src/timing.ts (captions and cues).
#   sh tools/phrases.sh voiceover/05.mp3
set -e
printf 'duration %s\n' "$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$1")"
ffmpeg -hide_banner -i "$1" -af silencedetect=noise=-35dB:d=0.12 -f null - 2>&1 |
  grep -oE 'silence_(start|end): [0-9.]+'
