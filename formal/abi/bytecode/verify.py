#!/usr/bin/env python3
"""Verify finite ABI geometries against exact Hardhat Collections runtime bytes."""
import argparse
import copy
import datetime
import gzip
import hashlib
import json
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(HERE.parent/'source'))
from verify import run, sha, canonical_sources

MUTATIONS = [
    ('array-count-guard', 'requireValue(x.count <= (v.length - x.base) / 32 / x.words, x.base, context);',
     'requireValue(true, x.base, context);', 'check_nestedHostileCount'),
    ('tuple-head-guard', 'requireValue(w <= (v.length - p - x.tail) / 32, p, context);',
     'requireValue(true, p, context);', 'check_tupleHeadTruncated'),
    ('array-offset', 'requireValue(word(v, position, context) == x.tail, position, context);',
     'requireValue(true, position, context);', 'check_dynamicFixedOffsets'),
    ('tuple-offset', 'requireValue(word(v, p + x.base, context) == x.tail, p + x.base, context);',
     'requireValue(true, p + x.base, context);', 'check_tupleCanonical'),
    ('tuple-head-width', 'x.tail += w * 32;', 'x.tail += 32;', 'check_tupleCanonical'),
]


def compile_runtime(request, solc, dest):
    (dest/'solc-input.json').write_text(json.dumps(request, indent=2)+'\n')
    proc = subprocess.run([str(solc), '--standard-json'], input=json.dumps(request), capture_output=True, text=True, timeout=120)
    (dest/'solc-stderr.log').write_text(proc.stderr)
    output = json.loads(proc.stdout)
    (dest/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(), mtime=0))
    if proc.returncode or any(e['severity'] == 'error' for e in output.get('errors', [])):
        raise ValueError('Compiler failed; this is not a detected semantic mutation')
    return output['contracts']['project/contracts/Collections.sol']['Collections']['evm']['deployedBytecode']['object']


def results(path):
    if not path.exists():
        return []
    data = json.loads(path.read_text())
    return [r for entries in data.get('test_results', {}).values() for r in entries]


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--solc', required=True, type=Path)
    p.add_argument('--yices', required=True, type=Path)
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    solc = args.solc.resolve()
    solver = args.yices.resolve()
    solver_version = subprocess.check_output([solver, '--version'], text=True).strip()
    assert solver_version.startswith('Yices 2.6.4\n')
    solver_command = shlex.join([str(solver), '--smt2-model-format', '--bvconst-in-decimal'])
    halmos_path = Path(shutil.which('halmos')).resolve()
    interpreter = halmos_path.read_text().splitlines()[0].removeprefix('#!')
    z3_version = subprocess.check_output([interpreter, '-c', 'import z3; print(z3.get_version_string())'], text=True).strip()
    artifact_path = ROOT/'artifacts/contracts/Collections.sol/Collections.json'
    artifact = json.loads(artifact_path.read_text())
    build_path = ROOT/'artifacts/build-info'/(artifact['buildInfoId']+'.json')
    build = json.loads(build_path.read_text())
    assert build['solcLongVersion'] == '0.8.36+commit.8a079791'
    assert build['solcLongVersion'] in subprocess.check_output([solc, '--version'], text=True)
    assert subprocess.check_output(['halmos', '--version'], text=True).strip() == 'halmos 0.3.3'
    request = build['input']
    sources, dependencies = canonical_sources(request)
    sources += [HERE/'RuntimeSpec.t.sol', HERE/'properties.json', Path(__file__), HERE.parent/'source/verify.py']
    manifest = {'schemaVersion': 1, 'status': 'incomplete',
                'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                'revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                'scope': 'Exact canonical Collections runtime; listed finite ABI geometries with symbolic contents, not unbounded bytecode induction',
                'sourceSha256': {str(path.relative_to(ROOT)): sha(path) for path in sources},
                'artifactSha256': sha(artifact_path), 'buildInfoSha256': sha(build_path),
                'compiler': build['solcLongVersion'], 'compilerSettings': request['settings'], 'solcSha256': sha(solc),
                'compilerDependencies': dependencies,
                'versions': {name: subprocess.check_output([name, '--version'], text=True).strip() for name in ('forge', 'halmos')},
                'solver': {'assertions': solver_version, 'branchingZ3': z3_version,
                           'command': solver_command, 'sha256': sha(solver), 'halmosLauncherSha256': sha(halmos_path)},
                'bounds': {'loop': 70, 'solverAssertionTimeoutMs': 30000, 'outerSecondsPerInvocation': 300,
                           'geometries': 'See each check_* function in RuntimeSpec.t.sol; no symbolic dynamic input lengths',
                           'hostileCount': 'All uint256 count > 2 with a two-word input body'},
                'assumptions': ['Halmos EVM/cheatcode semantics and its solver toolchain are trusted',
                                'Cancun and sufficient gas; Halmos does not model gas exhaustion',
                                'Only listed ABI geometries; no compiler-correctness or deployment claim',
                                'Oracle is independent solc ABI decode/re-encode; exact byte comparison, no hash equality'],
                'checks': [], 'properties': [], 'mutations': []}
    def save():
        (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    snap = out/'source-snapshot'
    for path in sources:
        target = snap/path.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)
    shutil.copy2(artifact_path, out/'Collections.artifact.json')
    save()
    runtime = compile_runtime(request, solc, out)
    assert runtime == artifact['deployedBytecode'].removeprefix('0x'), 'Recompiled bytecode differs from canonical artifact'
    (out/'runtime.hex').write_text('0x'+runtime+'\n')
    manifest['runtimeSha256'] = hashlib.sha256(bytes.fromhex(runtime)).hexdigest()
    manifest['runtimeBytes'] = len(runtime)//2
    manifest['canonicalRecompileMatched'] = True
    harness = (HERE/'RuntimeSpec.t.sol').read_text()
    properties = re.findall(r'function (check_\w+)\(', harness)
    assert len(properties) == 12 and len(set(properties)) == 12
    property_scopes = json.loads((HERE/'properties.json').read_text())
    assert set(properties) == set(property_scopes)
    with tempfile.TemporaryDirectory(prefix='abi-bytecode-') as tmp:
        work = Path(tmp)
        (work/'test').mkdir()
        (work/'test/RuntimeSpec.t.sol').write_text(harness)
        config = ('[profile.default]\nsrc="src"\ntest="test"\nsolc='+json.dumps(str(solc))+
                  '\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\nast=true\nextra_output=["storageLayout","metadata"]\n[lint]\nlint_on_build=false\n')
        (work/'foundry.toml').write_text(config)
        (out/'foundry.toml').write_text(config)
        def install(code):
            (work/'test/PinnedRuntime.sol').write_text('// SPDX-License-Identifier: MIT\npragma solidity 0.8.36;\n'
                'library PinnedRuntime { function code() internal pure returns(bytes memory) { return hex"'+code+'"; }}\n')
        def symbolic(dest, target=None):
            command = ['halmos', '--root', work, '--contract', 'AbiRuntimeSpec', '--loop', '70',
                       '--solver-command', solver_command,
                       '--solver-timeout-assertion', '30000', '--panic-error-codes', '*',
                       '--json-output', dest/'halmos.json', '--dump-smt-queries', '--dump-smt-directory', dest/'queries']
            if target:
                command += ['--match-test', '^'+target+'\\(']
            result = run(command, dest/'halmos.log', 300)
            result['nativeResults'] = results(dest/'halmos.json')
            return result
        install(runtime)
        concrete = run(['forge', 'test', '--root', work, '-vv'], out/'concrete.log', 120)
        concrete['passed'] = concrete['exitCode'] == 0 and '1 tests passed, 0 failed, 0 skipped (1 total tests)' in (out/'concrete.log').read_text()
        manifest['checks'].append(concrete)
        symbolic_result = symbolic(out)
        rows = symbolic_result['nativeResults']
        observed = [r['name'].split('(')[0] for r in rows]
        symbolic_result['passed'] = symbolic_result['exitCode'] == 0 and sorted(observed) == sorted(properties) and all(
            r['exitcode'] == 0 and r['num_models'] == 0 and r['num_bounded_loops'] == 0 and r['num_paths'][1] > 0 and r['num_paths'][2] == 0 for r in rows)
        # Native JSON is authoritative, but unsupported-path diagnostics must
        # not disappear behind a successful overall exit status.
        bad = re.search(r'loop.bound|NotConcrete|unsupported|timeout|incomplete', (out/'halmos.log').read_text(), re.I)
        symbolic_result['passed'] = symbolic_result['passed'] and not bad
        manifest['checks'].append(symbolic_result)
        for name in properties:
            found = [r for r in rows if r['name'].split('(')[0] == name]
            status = 'passed' if len(found) == 1 and found[0]['exitcode'] == 0 and found[0]['num_models'] == 0 and not found[0]['num_bounded_loops'] and found[0]['num_paths'][1] > 0 and found[0]['num_paths'][2] == 0 else 'incomplete'
            manifest['properties'].append({'name': name, 'status': status, 'scope': property_scopes[name], 'nativeResults': found})
        save()
        if symbolic_result['passed'] and concrete['passed']:
            for name, before, after, target in MUTATIONS:
                dest = out/name
                dest.mkdir()
                changed = copy.deepcopy(request)
                code = changed['sources']['project/contracts/lib/AbiCodec.sol']['content']
                assert code.count(before) == 1
                changed['sources']['project/contracts/lib/AbiCodec.sol']['content'] = code.replace(before, after)
                mutant = compile_runtime(changed, solc, dest)
                assert mutant != runtime
                install(mutant)
                result = symbolic(dest, target)
                rows = result['nativeResults']
                caught = result['exitCode'] not in (0, None) and len(rows) == 1 and rows[0]['name'].split('(')[0] == target and rows[0]['num_models'] > 0 and any(
                    model.get('is_valid') is True for model in rows[0]['models']) and rows[0]['num_bounded_loops'] == 0
                real = run(['forge', 'test', '--root', work, '-vv'], dest/'concrete.log', 120)
                real['detected'] = real['exitCode'] not in (0, None) and '0 tests passed, 1 failed, 0 skipped (1 total tests)' in (dest/'concrete.log').read_text()
                manifest['mutations'].append({'name': name, 'before': before, 'after': after, 'target': target,
                    'runtimeSha256': hashlib.sha256(bytes.fromhex(mutant)).hexdigest(), 'proof': result,
                    'evm': real, 'detected': caught and real['detected']})
                save()
    fmt = run(['forge', 'fmt', '--check', HERE/'RuntimeSpec.t.sol'], out/'format.log')
    fmt['passed'] = fmt['exitCode'] == 0
    manifest['checks'].append(fmt)
    manifest['sourceDrift'] = any(sha(ROOT/n) != h for n,h in manifest['sourceSha256'].items()) or sha(artifact_path) != manifest['artifactSha256']
    manifest['status'] = 'passed' if all(c['passed'] for c in manifest['checks']) and len(manifest['mutations']) == len(MUTATIONS) and all(
        m['detected'] for m in manifest['mutations']) and not manifest['sourceDrift'] else 'incomplete'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256'] = {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name != 'manifest.json'}
    save()
    print(json.dumps({'status': manifest['status'], 'properties': len(manifest['properties']),
                      'mutationsDetected': sum(m['detected'] for m in manifest['mutations'])}))
    return 0 if manifest['status'] == 'passed' else 1


if __name__ == '__main__':
    sys.exit(main())
