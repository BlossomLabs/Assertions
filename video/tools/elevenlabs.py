"""Generate narration with ElevenLabs.

The API key is read from ELEVENLABS_API_KEY in the repository's .env and is
never printed.

  python3 -I tools/elevenlabs.py voices
  python3 -I tools/elevenlabs.py tts <voice_id> "<text>" <out.mp3> [speed]

The narration uses Eric (cjVigY5qzO86Huf0OWal) on eleven_multilingual_v2.
A pause is written inline as <break time="0.4s" />.
"""

import json
import pathlib
import re
import sys
import urllib.request

ENV = pathlib.Path(__file__).resolve().parents[2] / '.env'
ERIC = 'cjVigY5qzO86Huf0OWal'
SETTINGS = {'stability': 0.5, 'similarity_boost': 0.75, 'style': 0.05, 'use_speaker_boost': True}


def key():
    for line in ENV.read_text().splitlines():
        m = re.match(r'\s*(?:export\s+)?ELEVENLABS_API_KEY(?:\s*=\s*|\s+)(.*)', line)
        if m:
            return m.group(1).strip().strip('"\'')
    sys.exit(f'ELEVENLABS_API_KEY not found in {ENV}')


def request(path, body=None):
    r = urllib.request.Request(
        'https://api.elevenlabs.io' + path,
        method='POST' if body else 'GET',
        headers={'xi-api-key': key(), 'Content-Type': 'application/json'},
        data=json.dumps(body).encode() if body else None,
    )
    return urllib.request.urlopen(r, timeout=120).read()


def main(argv):
    if argv[1:2] == ['voices']:
        for v in json.loads(request('/v1/voices'))['voices']:
            labels = v.get('labels', {})
            print(v['voice_id'], '|', v['name'], '|', labels.get('gender'), labels.get('accent'), labels.get('use_case'))
    elif argv[1:2] == ['tts'] and len(argv) in (5, 6):
        voice, text, out = argv[2], argv[3], argv[4]
        settings = dict(SETTINGS, **({'speed': float(argv[5])} if len(argv) == 6 else {}))
        audio = request(
            f'/v1/text-to-speech/{voice}?output_format=mp3_44100_128',
            {'text': text, 'model_id': 'eleven_multilingual_v2', 'voice_settings': settings},
        )
        pathlib.Path(out).write_bytes(audio)
        print('wrote', out)
    else:
        sys.exit(__doc__)


if __name__ == '__main__':
    main(sys.argv)
