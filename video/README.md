# Assertions 2.0 (Byakko) launch video

A 92-second motion-design video for YouTube and X, built with
[Remotion](https://www.remotion.dev) and narrated with an ElevenLabs voice.

## What is here

| Path | What it holds |
|---|---|
| `SCRIPT.md` | The script: promise, beats (visual, action, narration), chapters, cut plan, timing sheet, recording brief, YouTube description |
| `src/` | The video. `timing.ts` holds every time in it (clip lengths, gaps, caption phrases); `scenes/` one file per scene; `theme.ts` the website's dark palette and fonts |
| `public/byakko-tiger.svg` | The release figure on the title card |
| `voiceover/CID`, `voiceover/SHA256SUMS` | Where the narration lives: ten clips, one per beat (ElevenLabs, voice Eric), pinned on IPFS through Pinata as one folder, and their hashes. A regenerated take sounds and lasts differently, so the build fetches these exact clips instead of making new ones |
| `music/CREDITS.md` | The CC0 track used and the candidates considered |
| `tools/` | `elevenlabs.py` (generate a line), `phrases.sh` (find the phrase spans in a clip), `pin-voiceover.py` and `fetch-voiceover.sh` (pin the clips, fetch and verify them), `build-voiceover.py` (assemble the track), `fetch-music.sh` (download the track), `mix-music.sh` (mix it under the voice) |

No audio or video is committed. Everything the build fetches or produces is
ignored by git: the clips, the assembled voiceover, the music, and `out/`
(renders, mixes, stills). The audio stays out of the repository's MIT license:
the narration is ElevenLabs output and the music is CC0.

## Building it

```sh
pnpm install
pnpm build          # fetch the clips, voiceover, render, then music: out/assertions-2-byakko-music.mp4
pnpm studio         # live preview
pnpm render:clean   # the same video without burned-in captions, for YouTube
pnpm x             # an X-ready copy: faststart, 5 Mbps, AAC 44.1 kHz (out/assertions-2-byakko-x.mp4)
```

## Changing a line

1. Generate the new take; the API key is read from `ELEVENLABS_API_KEY` in the
   repository's `.env`:
   `python3 -I tools/elevenlabs.py tts cjVigY5qzO86Huf0OWal "<text>" out/NN-new.mp3`
2. Listen, then copy it over `voiceover/NN.mp3`.
3. `sh tools/phrases.sh voiceover/NN.mp3`, then update that beat's length in
   `CLIPS` and its phrase offsets in `PHRASES` (`src/timing.ts`), and any cue in
   the scene that fires on a phrase.
4. `pnpm build`, and update the beat and the timing sheet in `SCRIPT.md`.
5. `pnpm pin` (reads `PINATA_JWT` from `website/.env`) to pin the new set of
   clips; it rewrites `voiceover/CID` and `voiceover/SHA256SUMS`. Commit those.

Lines read best at normal speed with only the punctuation's pauses: forced
breaks and a slowed voice sounded artificial.

## Licenses

The code here can follow the repository's MIT license, but rendering it is
subject to Remotion's own license (free for individuals and companies of up to
three people). The narration is ElevenLabs output, used commercially under a
paid plan; it is not openly licensed and is not in the repository. The music
is CC0. The clips stay fetchable only while the Pinata pin (or another pin of
the same CID) is kept.
