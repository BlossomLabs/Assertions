#!/bin/sh
# Mix the music under the voiceover and put the result on the rendered video.
#   sh tools/mix-music.sh
# Reads out/assertions-2-byakko.mp4 (from `pnpm render`) and
# public/voiceover-full.wav, writes out/mix.wav and
# out/assertions-2-byakko-music.mp4.
#
# The music sits at -17 dB, fades in over 1.5 s and out over the last 3 s,
# and ducks under the voice (sidechain); the whole mix is raised 8 dB and
# limited, which lands at about -15 LUFS.
set -e
cd "$(dirname "$0")/.."
voice=public/voiceover-full.wav
music=music/komiku-xenobiological-forest.ogg
length=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$voice")
fade=$(python3 -c "print(round($length - 3, 2))")

sh tools/fetch-music.sh >/dev/null
ffmpeg -y -loglevel error -i "$voice" -i "$music" -filter_complex "\
[1:a]atrim=0:$length,asetpts=PTS-STARTPTS,aresample=44100,aformat=channel_layouts=stereo,volume=-17dB,afade=t=in:d=1.5,afade=t=out:st=$fade:d=3[m];\
[0:a]aresample=44100,aformat=channel_layouts=stereo,asplit[v1][v2];\
[m][v1]sidechaincompress=threshold=0.02:ratio=5:attack=30:release=500[md];\
[v2][md]amix=inputs=2:normalize=0,volume=8dB,alimiter=limit=0.84[out]" -map "[out]" -ar 48000 out/mix.wav

ffmpeg -y -loglevel error -i out/assertions-2-byakko.mp4 -i out/mix.wav -map 0:v -map 1:a \
  -c:v copy -c:a aac -b:a 192k -shortest -movflags +faststart out/assertions-2-byakko-music.mp4
echo "out/assertions-2-byakko-music.mp4"
