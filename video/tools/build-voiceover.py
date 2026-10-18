"""Assemble voiceover/01.mp3 ... 10.mp3 into one track.

The lead-in and the silence after each beat come from src/timing.ts, which
the animation also reads, so the audio and the picture cannot drift apart.
Each clip's measured length is checked against CLIPS there.

  python3 -I tools/build-voiceover.py

Writes voiceover/voiceover-full.{mp3,wav} and public/voiceover-full.wav.
"""

import pathlib
import re
import shutil
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
VO = ROOT / 'voiceover'


def array(src, name):
    m = re.search(rf'const {name} = \[([^\]]*)\]', src)
    return [float(x) for x in m.group(1).split(',')]


def duration(path):
    out = subprocess.check_output(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', str(path)])
    return float(out)


def main():
    timing = (ROOT / 'src' / 'timing.ts').read_text()
    lead = float(re.search(r'const LEAD = ([\d.]+)', timing).group(1))
    clips, gaps = array(timing, 'CLIPS'), array(timing, 'GAPS')

    inputs = ['-f', 'lavfi', '-t', str(lead), '-i', 'anullsrc=r=44100:cl=mono']
    for n, (clip, gap) in enumerate(zip(clips, gaps), start=1):
        path = VO / f'{n:02d}.mp3'
        measured = duration(path)
        if abs(measured - clip) > 0.02:
            sys.exit(f'{path.name} is {measured:.2f} s but CLIPS in src/timing.ts says {clip}; update it and the phrase offsets')
        inputs += ['-i', str(path), '-f', 'lavfi', '-t', str(gap), '-i', 'anullsrc=r=44100:cl=mono']

    count = 1 + 2 * len(clips)
    graph = ''.join(f'[{i}:a]' for i in range(count)) + f'concat=n={count}:v=0:a=1,aformat=sample_rates=44100:channel_layouts=mono[out]'
    mp3, wav = VO / 'voiceover-full.mp3', VO / 'voiceover-full.wav'
    subprocess.check_call(['ffmpeg', '-y', '-loglevel', 'error', *inputs, '-filter_complex', graph, '-map', '[out]', '-c:a', 'libmp3lame', '-b:a', '192k', str(mp3)])
    subprocess.check_call(['ffmpeg', '-y', '-loglevel', 'error', '-i', str(mp3), str(wav)])
    shutil.copy(wav, ROOT / 'public' / 'voiceover-full.wav')
    print(f'voiceover {duration(wav):.2f} s')


if __name__ == '__main__':
    main()
