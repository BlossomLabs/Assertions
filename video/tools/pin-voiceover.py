"""Pin voiceover/01.mp3 ... 10.mp3 to IPFS through Pinata, as one folder.

The JWT is read from PINATA_JWT in website/.env and is never printed. Writes
the folder's CID to voiceover/CID and each clip's SHA-256 to
voiceover/SHA256SUMS, which tools/fetch-voiceover.sh checks after download.

  python3 -I tools/pin-voiceover.py
"""

import hashlib
import json
import pathlib
import re
import sys
import urllib.request
import uuid

ROOT = pathlib.Path(__file__).resolve().parents[1]
VO = ROOT / 'voiceover'
ENV = ROOT.parent / 'website' / '.env'


def jwt():
    for line in ENV.read_text().splitlines():
        m = re.match(r'\s*(?:export\s+)?PINATA_JWT(?:\s*=\s*|\s+)(.*)', line)
        if m:
            return m.group(1).strip().strip('"\'')
    sys.exit(f'PINATA_JWT not found in {ENV}')


def main():
    clips = [VO / f'{n:02d}.mp3' for n in range(1, 11)]
    boundary = uuid.uuid4().hex
    body = b''
    for clip in clips:
        body += (
            f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="voiceover/{clip.name}"\r\n'
            'Content-Type: audio/mpeg\r\n\r\n'
        ).encode() + clip.read_bytes() + b'\r\n'
    meta = json.dumps({'name': 'assertions-2-byakko-voiceover'})
    body += f'--{boundary}\r\nContent-Disposition: form-data; name="pinataMetadata"\r\n\r\n{meta}\r\n--{boundary}--\r\n'.encode()

    request = urllib.request.Request(
        'https://api.pinata.cloud/pinning/pinFileToIPFS',
        method='POST',
        data=body,
        headers={'Authorization': f'Bearer {jwt()}', 'Content-Type': f'multipart/form-data; boundary={boundary}'},
    )
    cid = json.loads(urllib.request.urlopen(request, timeout=300).read())['IpfsHash']

    (VO / 'CID').write_text(cid + '\n')
    sums = ''.join(f'{hashlib.sha256(c.read_bytes()).hexdigest()}  {c.name}\n' for c in clips)
    (VO / 'SHA256SUMS').write_text(sums)
    print(cid)


if __name__ == '__main__':
    main()
