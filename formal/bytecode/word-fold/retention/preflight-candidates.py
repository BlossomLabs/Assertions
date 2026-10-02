#!/usr/bin/env python3
"""Check real candidate translation and physical contradictions before retention.

This diagnostic uses isolated projects. It does not verify native assertions,
freeze retained proof inputs, or assign public evidence. Native contradictions
must still pass the complete retained campaign with baseline coverage.
"""
import argparse
import datetime
import importlib.util
import json
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--candidates', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    spec = importlib.util.spec_from_file_location('fold_candidate_preflight_verifier', HERE / 'verify.py')
    v = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(v)
    configuration = json.loads((HERE / 'proof-spec.json').read_text())
    inputs = v.inputs(configuration)
    hashes = {str(p.relative_to(ROOT)): v.sha(p) for p in inputs}
    candidates = args.candidates.resolve()
    entries = json.loads((candidates / 'candidates.json').read_text())
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    results = []
    for candidate in entries:
        folder = out / candidate['name']
        work = folder / 'diagnostic-project'
        for path in inputs:
            dest = work / path.relative_to(ROOT)
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, dest)
        runtime = candidates / candidate['runtime']
        assert v.sha(runtime) == candidate['runtimeSha256']
        artifact = work / 'artifacts/contracts/Collections.sol/Collections.json'
        obj = json.loads(artifact.read_text())
        base = bytes.fromhex(obj['deployedBytecode'][2:])
        mutant = runtime.read_bytes()
        assert len(base) == len(mutant) and [(i, a, b) for i, (a, b) in enumerate(zip(base, mutant)) if a != b] == [(candidate['byteOffset'], candidate['before'], candidate['after'])]
        obj['deployedBytecode'] = '0x'+mutant.hex()
        artifact.write_text(json.dumps(obj, indent=2)+'\n')
        inventory = work / 'formal/bytecode/dispatch/inventory.json'
        obj = json.loads(inventory.read_text())
        obj['Collections']['runtimeSha256'] = candidate['runtimeSha256']
        inventory.write_text(json.dumps(obj, indent=2)+'\n')
        command = [sys.executable, '-B', work / candidate['generator'], '--output', work / candidate['package']]
        with (folder / 'generation.log').open('w') as stream:
            translation = subprocess.run(list(map(str, command)), stdout=stream, stderr=subprocess.STDOUT)
        assert translation.returncode == 0, 'Candidate parser refusal is not semantic evidence'
        physical_command = [shutil.which('node'), ROOT / configuration['physicalOwner'] / 'evm-traces.mjs',
                            '--root', ROOT, '--output', folder / 'evm-traces', '--runtime', runtime,
                            '--case', candidate['evmFixture']]
        with (folder / 'physical.log').open('w') as stream:
            physical = subprocess.run(list(map(str, physical_command)), stdout=stream, stderr=subprocess.STDOUT)
        receipts = json.loads((folder / 'evm-traces/results.json').read_text())
        assert physical.returncode != 0 and len(receipts) == 1 and receipts[0]['name'] == candidate['evmFixture'] and not receipts[0]['receiptPassed']
        assert receipts[0]['expectedFailed'] != receipts[0]['actualFailed'] or receipts[0]['expectedBytes'] != receipts[0]['actualBytes']
        results.append(dict(candidate=candidate, translationExitCode=translation.returncode,
                            translationCommand=list(map(str, command)),
                            physicalExitCode=physical.returncode, physicalCommand=list(map(str, physical_command)),
                            contradictoryReceipts=receipts,
                            scope='Parser accepted actual single-byte candidate and real EVM receipt contradicts fixed oracle. Native contradiction and full retained gates remain unproved.'))
        print(candidate['name'], 'translated, actual physical contradiction', flush=True)
    unchanged = hashes == {str(p.relative_to(ROOT)): v.sha(p) for p in v.inputs(configuration)}
    record = dict(status='candidate-translation-physical-preflight-passed-not-retained' if unchanged else 'failed-current-input-drift',
                  observedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                  currentInputsUnchanged=unchanged, sourceSha256=hashes, results=results,
                  scope='Diagnostic only. No native mutation proof, retained source snapshot or public coverage.')
    (out / 'results.json').write_text(json.dumps(record, indent=2)+'\n')
    raise SystemExit(0 if unchanged else 1)


if __name__ == '__main__':
    main()
