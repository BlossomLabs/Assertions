"""Capture owned generation, resolution and audits without claiming native proof."""
import datetime
import hashlib
import json
import subprocess
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
DAFNY = Path('/tmp/assertions-dafny-4.11.0/dafny/dafny')
out = HERE / 'development/static-v1'
out.mkdir(parents=True, exist_ok=False)
selected = [ROOT / p for p in json.loads((HERE / 'scope.json').read_text())['selectedSources']]
owners = [HERE, HERE.parent, *(p.parent for p in selected)]
inputs = sorted({p for owner in owners for p in owner.iterdir() if p.is_file()})
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
hashes = {str(p.relative_to(ROOT)): sha(p) for p in inputs}
checks = []

def run(name, command):
    with (out / (name + '.log')).open('w') as log:
        process = subprocess.Popen(list(map(str, command)), stdout=log, stderr=subprocess.STDOUT)
        code = process.wait()
    checks.append(dict(name=name, command=list(map(str, command)), exitCode=code,
                       log=name + '.log', passed=code == 0))
    return code

for owner in ['prefix-pack', 'prefix-unpack', 'decoder-unpack']:
    source = HERE.parent / owner
    with tempfile.TemporaryDirectory(prefix='array-codec-regeneration-') as temp:
        target = Path(temp)
        assert run('generate-' + owner, ['python3', '-B', source / 'generate.py', '--output', target]) == 0
        expected = {p.name for p in source.iterdir() if p.name.endswith(('.generated.dfy', '.mapping.json'))}
        assert expected == {p.name for p in target.iterdir()}
        assert all((source / p).read_bytes() == (target / p).read_bytes() for p in expected)
assert run('format', [DAFNY, 'format', '--check', *selected]) == 0
assert run('resolve', [DAFNY, 'resolve', *selected]) == 0
assert run('audit', [DAFNY, 'audit', *selected]) == 0
assert 'auditor completed with 0 findings' in (out / 'audit.log').read_text()
assert hashes == {str(p.relative_to(ROOT)): sha(p) for p in inputs}
record = dict(status='static-passed-native-open-not-retained',
              completedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),
              selectedSources=[str(p.relative_to(ROOT)) for p in selected],
              sourceSha256=hashes, dafnySha256=sha(DAFNY),
              ownedGenerationByteIdentical=True, auditFindings=0, checks=checks,
              nativeProofCredit=0, publicEntryCredit=0)
record['evidenceSha256'] = {p.name: sha(p) for p in out.iterdir() if p.is_file()}
(out / 'results.json').write_text(json.dumps(record, indent=2) + '\n')
print(record['status'])
