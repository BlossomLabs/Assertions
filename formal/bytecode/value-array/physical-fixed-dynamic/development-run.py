#!/usr/bin/env python3
"""Retain finite array-codec EVM receipts as development evidence only."""
import argparse
import datetime
import importlib.util
import json
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    specification = importlib.util.spec_from_file_location('array_physical_common', ROOT / 'formal/bytecode/getters/verify.py')
    verifier = importlib.util.module_from_spec(specification)
    specification.loader.exec_module(verifier)
    sha = verifier.sha

    def inputs():
        return sorted(set(verifier.inputs()) | {f for owner in [HERE, HERE.parent, HERE.parent/'prefix-pack', HERE.parent/'prefix-unpack', HERE.parent/'decoder-unpack', HERE.parent/'decoder-pack', HERE.parent/'raw-pack'] for f in owner.iterdir() if f.is_file()})

    paths = inputs()
    hashes = {str(path.relative_to(ROOT)): sha(path) for path in paths}
    snapshot = output / 'source-snapshot'
    for path in paths:
        target = snapshot / path.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)
    manifest = {'status': 'development-physical-running-not-retained',
                'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                'scope': 'Finite complete packArray/unpackArray PC-zero physical receipts only, for fixed arrays of dynamic bytes/string elements, exact mapped routing/accepted decoders, independent canonical ABI encoder and actual empty/padding boundaries. Native inventories, all geometries and retained public evidence remain open.',
                'sourceSha256': hashes, 'checks': []}

    def save():
        (output / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')

    save()
    node = shutil.which('node')
    job = verifier.common.run([node, HERE / 'evm-traces.mjs', '--root', snapshot,
                               '--output', output / 'evm-traces'], output / 'evm-traces.log', 900)
    results_path = output / 'evm-traces/results.json'
    rows = json.loads(results_path.read_text()) if results_path.is_file() else []
    fixtures = json.loads((snapshot / HERE.relative_to(ROOT) / 'fixtures.inventory.json').read_text())
    expected_names = {f['name'] for f in fixtures}
    job['passed'] = job['exitCode'] == 0 and len(fixtures) == len(expected_names) == len(rows) and {r['name'] for r in rows} == expected_names and all(r['passed'] and r['receiptPassed'] for r in rows)
    manifest['checks'].append(job)
    toolchain_path = output / 'evm-traces/toolchain.json'
    tools = json.loads(toolchain_path.read_text()) if toolchain_path.is_file() else {}
    manifest['concreteToolchain'] = tools
    manifest['concreteToolsUnchanged'] = bool(tools) and all(sha(Path(tools[name])) == tools[name + 'Sha256'] for name in ['hardhatEntry', 'edrEntry', 'nativeBinding']) and sha(Path(tools['nodeExecutable'])) == tools['nodeSha256'] and sha(ROOT / 'pnpm-lock.yaml') == tools['lockfileSha256']
    manifest['inputsUnchanged'] = hashes == {str(path.relative_to(ROOT)): sha(path) for path in inputs()}
    manifest['concreteFixtures'] = len(rows)
    manifest['fixtureNames'] = [r['name'] for r in rows]
    passed = job['passed'] and manifest['inputsUnchanged'] and manifest['concreteToolsUnchanged']
    manifest['status'] = 'development-physical-passed-not-retained' if passed else 'development-physical-failed'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256'] = {str(path.relative_to(output)): sha(path) for path in sorted(output.rglob('*')) if path.is_file() and path.name != 'manifest.json'}
    save()
    print(manifest['status'], len(rows), 'complete finite fixtures')
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
