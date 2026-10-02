"""Load the pinned image's precompiled KONTROL-BASE semantics, without changes.

Kontrol 1.0.255's build.py chooses KONTROL-FULL for --no-keccak-lemmas
without --auxiliary-lemmas. Copying its bundled base avoids that option bug
and an unnecessary recompilation. No project rules are added.
"""
import hashlib
import json
from pathlib import Path
import shutil

from kontrol import VERSION
from kontrol.foundry import Foundry
from pyk.kdist import kdist

assert VERSION == '1.0.255'
source = kdist.get('kontrol.base')
assert (source / 'mainModule.txt').read_text().strip() == 'KONTROL-BASE'
target = Path('out/kompiled')
assert not target.exists(), 'Use a fresh proof directory'
shutil.copytree(source, target)
files = {str(p.relative_to(source)): hashlib.sha256(p.read_bytes()).hexdigest()
         for p in source.rglob('*') if p.is_file()}
assert all(hashlib.sha256((target / p).read_bytes()).hexdigest() == sha
           for p, sha in files.items())
Path('backend.json').write_text(json.dumps(dict(module='KONTROL-BASE',
    source=str(source), kontrolVersion=VERSION, filesSha256=files), indent=2) + '\n')
foundry = Foundry(Path.cwd())
foundry.update_digest()
digest_path = Path('out/digest')
digest = json.loads(digest_path.read_text())
digest['kontrol'] = VERSION
digest_path.write_text(json.dumps(digest, indent=2) + '\n')
print('Loaded unmodified bundled KONTROL-BASE; recorded all backend file hashes')
