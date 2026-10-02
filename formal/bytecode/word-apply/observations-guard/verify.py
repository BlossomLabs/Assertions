#!/usr/bin/env python3
"""Snapshot and check fresh local EVM guard fixtures; development evidence only."""
import argparse, hashlib, json, shutil, subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
p = argparse.ArgumentParser()
p.add_argument('--output',type=Path,required=True)
p.add_argument('--toolchain-reference',type=Path,required=True)
a = p.parse_args()
out = a.output.resolve()
out.mkdir(parents=True,exist_ok=False)
reference = json.loads(a.toolchain_reference.read_text())
inputs = {f for f in HERE.iterdir() if f.is_file()}
inputs |= {ROOT/'contracts/Collections.sol',ROOT/'artifacts/contracts/Collections.sol/Collections.json',
           ROOT/'formal/bytecode/dispatch/inventory.json',ROOT/'hardhat.config.ts',
           ROOT/'package.json',ROOT/'pnpm-lock.yaml',a.toolchain_reference.resolve()}
for key in ['nodeExecutable','hardhatEntry','edrEntry','nativeBinding']:
    inputs.add(Path(reference[key]))
hashes = {str(f):sha(f) for f in sorted(inputs)}
snapshot = out/'source-snapshot'
for f in sorted(inputs):
    if f.is_relative_to(ROOT):
        dest = snapshot/f.relative_to(ROOT)
        dest.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(f,dest)
manifest = dict(status='development-evm-running-not-retained',inputSha256=hashes,
                scope='Fresh PCzero guard fixtures, explicit faithful local EVM/interpreter and adequate outer reached resources. No gas-cost/deployment/performance or public proof claim.')
save = lambda: (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
save()
command = [reference['nodeExecutable'],str(snapshot/HERE.relative_to(ROOT)/'evm-traces.mjs'),
           '--root',str(snapshot),'--output',str(out/'fixtures'),'--suite','guard']
with (out/'evm.log').open('w') as log:
    result = subprocess.run(command,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,timeout=7200)
manifest['exitCode'] = result.returncode
if result.returncode == 0:
    rows = json.loads((out/'fixtures/results.json').read_text())
    manifest['cases'] = rows
    assert len(rows) == 12 and len({x['name'] for x in rows}) == 12
    assert all(x['passed'] and x['callbacks'] == 1 for x in rows)
    actual = json.loads((out/'fixtures/toolchain.json').read_text())
    for key in ['nodeExecutable','hardhatEntry','edrEntry','nativeBinding']:
        assert actual[key] == reference[key]
        hashkey = 'nodeSha256' if key == 'nodeExecutable' else key+'Sha256'
        assert actual[hashkey] == hashes[reference[key]]
    manifest['fixtureSha256'] = {str(f.relative_to(out)):sha(f) for f in sorted((out/'fixtures').iterdir()) if f.is_file()}
manifest['inputsUnchanged'] = all(sha(Path(f)) == h for f,h in hashes.items())
passed = result.returncode == 0 and manifest['inputsUnchanged']
manifest['status'] = 'development-evm-passed-not-retained' if passed else 'development-evm-failed'
save()
print('PASS twelve fresh compiled guard fixtures, unchanged inputs' if passed else 'FAIL fresh guard fixtures')
raise SystemExit(0 if passed else 1)
