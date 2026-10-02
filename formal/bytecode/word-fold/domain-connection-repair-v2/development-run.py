#!/usr/bin/env python3
"""Freeze and verify selected fold count/domain control composition; no public credit."""
import argparse
import datetime
import importlib.util
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

if not __debug__:
    raise RuntimeError('Run without Python -O')
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    verifier = load('fold_getter_common', ROOT / 'formal/bytecode/getters/verify.py')
    common, sha = verifier.common, verifier.sha
    spec = json.loads((HERE / 'scope.json').read_text())
    selected = [HERE / 'Connection.dfy']
    closed = set()

    def visit(path):
        path = path.resolve()
        assert path.is_relative_to(ROOT) and path.is_file()
        if path in closed:
            return
        closed.add(path)
        for include in re.findall(r'^include "([^"]+)"', path.read_text(), re.M):
            visit(path.parent / include)

    for source in selected:
        visit(source)
    owners = {source.parent for source in closed} | {HERE}
    paths = set(verifier.inputs()) | closed | {f for owner in owners for f in owner.iterdir() if f.is_file()}
    paths = sorted(paths)
    hashes = {str(path.relative_to(ROOT)): sha(path) for path in paths}
    dafny = Path('/tmp/assertions-dafny-4.11.0/dafny/dafny')
    tools = {'dafny': dafny, 'Dafny.dll': dafny.parent / 'Dafny.dll',
             'z3': dafny.parent / 'z3/bin/z3-4.12.1'}
    tool_hashes = {name: sha(path) for name, path in tools.items()}
    versions = {name: subprocess.check_output([str(tools[name]), '--version'], text=True).strip()
                for name in ['dafny', 'z3']}
    assert versions['dafny'] == json.loads((ROOT / 'formal/abi/toolchain.json').read_text())['dafnyVersion']
    assert '4.12.1' in versions['z3']
    snapshot = output / 'source-snapshot'
    for source in paths:
        destination = snapshot / source.relative_to(ROOT)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)
    manifest = {'status': 'development-running-not-retained',
                'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                'scope': 'Complete selected full-word loop count branch/domain helper composition and observation-preserving external lift; imported contracts assumed. Physical index/byte SHR/word load result. Byte representation bridge/raw iteration/stamping/callback/guards/early-exit/scalar output/full fresh retention remain open.',
                'assumptions': spec['assumptions'], 'sourceSha256': hashes,
                'executableSha256': tool_hashes, 'versions': versions,
                'dependencyGraph': {str(p.relative_to(ROOT)): sha(p) for p in sorted(closed)},
                'selectedSources': [str(p.relative_to(ROOT)) for p in selected], 'checks': []}

    def save():
        (output / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')

    def run(name, command, timeout=7200):
        job = common.run(command, output / (name + '.log'), timeout)
        job.update(name=name, passed=job['exitCode'] == 0)
        manifest['checks'].append(job)
        save()
        return job

    save()
    run('format', [dafny, 'format', '--check', *[snapshot / p.relative_to(ROOT) for p in selected]], 300)
    for item in spec['prefixCandidates']:
        folder = snapshot / item['owner']
        generated = output / 'generated' / Path(item['owner']).name
        job = run('generation-' + item['name'], [sys.executable, '-B', folder / 'generate.py', '--output', generated], 300)
        expected = {name + suffix for name in ['RangeAccepted', 'SourceAccepted'] for suffix in ['.generated.dfy', '.mapping.json']}
        job['passed'] = job['passed'] and expected == {p.name for p in generated.iterdir()} and all((folder / name).read_bytes() == (generated / name).read_bytes() for name in expected)
        save()
    proofs = []
    if all(job['passed'] for job in manifest['checks']):
        for path in selected:
            source = snapshot / path.relative_to(ROOT)
            module = re.search(r'^module (\w+)', source.read_text(), re.M)[1]
            name = 'proof-' + module
            csv_path = output / (name + '.csv')
            job = run(name, common.proof_command(dafny, source, csv_path) + ['--filter-symbol', module, '--filter-position', str(source), '--progress', 'Symbol'])
            common.check_proof(job, output / (name + '.log'), csv_path, verifier.inventory(path))
            proofs.append(job)
            save()
            audit = run('audit-' + module, [dafny, 'audit', source], 300)
            audit['passed'] = audit['passed'] and 'auditor completed with 0 findings' in (output / ('audit-' + module + '.log')).read_text()
            save()
            print(module, 'passed' if job['passed'] else 'FAILED', len(job.get('nativeResults', [])), flush=True)
    manifest['nativeResults'] = [row for job in proofs for row in job.get('nativeResults', [])]
    manifest['declarationResults'] = [decl for job in proofs for decl in job.get('declarations', [])]
    manifest['nativeObligations'] = len(manifest['nativeResults'])
    current_paths = set(verifier.inputs()) | closed | {f for owner in owners for f in owner.iterdir() if f.is_file()}
    manifest['inputsUnchanged'] = hashes == {str(path.relative_to(ROOT)): sha(path) for path in sorted(current_paths)}
    manifest['toolsUnchanged'] = tool_hashes == {name: sha(path) for name, path in tools.items()}
    passed = len(proofs) == len(selected) and manifest['inputsUnchanged'] and manifest['toolsUnchanged'] and all(job['passed'] for job in manifest['checks'])
    manifest['status'] = 'development-native-passed-not-retained' if passed else 'development-native-failed'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256'] = {str(path.relative_to(output)): sha(path) for path in sorted(output.rglob('*')) if path.is_file() and path.name != 'manifest.json'}
    save()
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
