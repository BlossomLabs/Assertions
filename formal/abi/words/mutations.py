#!/usr/bin/env python3
"""Plant word-classification/checking faults in isolated repaired source copies."""
import argparse
import copy
import datetime
import gzip
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from repair import AFTER, BEFORE, candidate

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
spec = importlib.util.spec_from_file_location('abi_common', HERE.parent/'source/verify.py')
common = importlib.util.module_from_spec(spec)
spec.loader.exec_module(common)
run, sha = common.run, common.sha

MUTATIONS = [
    ('remove-boundary-repair', AFTER, BEFORE, 'name-length-6'),
    ('drop-largest-width', 'gt(bits, 248)', 'gt(bits, 240)', 'name-length-7'),
    ('allow-leading-zero', 'iszero(or(bits, c))', '0', 'name-length-6'),
    ('ignore-name-continuation', 'if or(lt(sub(c, 0x30), 10), lt(sub(c, 0x61), 26)) { end := s }',
     'if or(lt(sub(c, 0x30), 10), lt(sub(c, 0x61), 26)) { end := end }', 'name-length-6'),
    ('unsigned-wrong-direction', 'ok := iszero(shr(bits, x))', 'ok := iszero(shl(bits, x))', 'canonical-uint8'),
    ('signed-wrong-extension', 'signextend(sub(shr(3, bits), 1), x)', 'signextend(sub(shr(3, bits), 0), x)', 'canonical-int8'),
    ('bytes-wrong-direction', 'ok := iszero(shl(bits, x))', 'ok := iszero(shr(bits, x))', 'canonical-bytes1'),
    ('exclude-letter-a', 'gt(c, 0x60)', 'gt(c, 0x61)', 'scan-name-character'),
]


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--solc', required=True, type=Path)
    p.add_argument('--solver', required=True, type=Path)
    p.add_argument('--smt-python', required=True, type=Path)
    p.add_argument('--candidate-evidence', required=True, type=Path)
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    baseline = json.loads(args.candidate_evidence.read_text())
    assert baseline['candidateOnly'] and baseline['status'] == 'passed', 'A fully passed repaired baseline is required'
    assert all(sha(args.candidate_evidence.parent/n) == h for n,h in baseline['evidenceSha256'].items())
    source_path = ROOT/'contracts/lib/AbiCodec.sol'
    assert sha(source_path) == baseline['workingTreeSha256']['contracts/lib/AbiCodec.sol']
    repaired = candidate(source_path.read_text())
    request = json.loads((args.candidate_evidence.parent/'solc-input.json').read_text())
    assert request['sources']['project/contracts/lib/AbiCodec.sol']['content'] == repaired
    paths = [source_path, *HERE.glob('*.py'), HERE/'WordOracle.t.sol', HERE.parent/'source/verify.py']
    for path in paths:
        dest = out/'source-snapshot'/path.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, dest)
    versions = {'solc': subprocess.check_output([args.solc, '--version'], text=True).strip(),
                'solver': subprocess.check_output([args.solver, '--version'], text=True).strip(),
                'expressionLibrary': subprocess.check_output([args.smt_python, '-c', 'import z3; print(z3.get_version_string())'], text=True).strip(),
                'forge': subprocess.check_output(['forge', '--version'], text=True).strip()}
    assert '0.8.36+commit.8a079791' in versions['solc'] and '4.12.1' in versions['solver'] and versions['expressionLibrary'] == '4.12.6'
    manifest = {'schemaVersion': 1, 'status': 'incomplete', 'candidateOnly': True,
                'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                'revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                'baselineManifestSha256': sha(args.candidate_evidence), 'baselineEvidence': str(args.candidate_evidence),
                'sourceSha256': {str(path.relative_to(ROOT)): sha(path) for path in paths},
                'versions': versions, 'executableSha256': {'solc': sha(args.solc), 'solver': sha(args.solver)},
                'scope': 'Named universal SMT obligation must have a SAT countermodel, and an actual EVM assertion must fail; parser/timeout failures do not count',
                'mutations': []}
    def save():
        (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    save()
    for name, before, after, target in MUTATIONS:
        dest = out/name
        dest.mkdir()
        assert repaired.count(before) == 1, name
        source = repaired.replace(before, after)
        (dest/'AbiCodec.sol').write_text(source)
        generated = dest/'generated'
        gen = run([args.smt_python, '-B', out/'source-snapshot/formal/abi/words/generate.py', '--solc', args.solc,
                   '--source', dest/'AbiCodec.sol', '--output', generated], dest/'generate.log', 120)
        assert gen['exitCode'] == 0, 'Translator rejection is not semantic mutation detection'
        query = generated/(target+'.smt2')
        proof = run([args.solver, '-smt2', query], dest/'proof.log', 45)
        detected = proof['exitCode'] == 0 and (dest/'proof.log').read_text().splitlines() == ['sat']
        if detected:
            witness = dest/'counterexample.smt2'
            witness.write_text(query.read_text()+'\n(get-model)\n')
            proof['counterexample'] = run([args.solver, '-smt2', witness], dest/'counterexample.log', 45)
        changed = copy.deepcopy(request)
        changed['sources']['project/contracts/lib/AbiCodec.sol']['content'] = source
        (dest/'solc-input.json').write_text(json.dumps(changed, indent=2)+'\n')
        proc = subprocess.run([args.solc, '--standard-json'], input=json.dumps(changed), capture_output=True, text=True, timeout=120)
        (dest/'solc-stderr.log').write_text(proc.stderr)
        (dest/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(), mtime=0))
        compiled = json.loads(proc.stdout)
        assert proc.returncode == 0 and not any(e['severity'] == 'error' for e in compiled.get('errors', [])), 'Compiler failure is not mutation detection'
        runtime = compiled['contracts']['project/contracts/Collections.sol']['Collections']['evm']['deployedBytecode']['object']
        (dest/'runtime.hex').write_text('0x'+runtime+'\n')
        with tempfile.TemporaryDirectory(prefix='abi-word-mutant-') as tmp:
            work = Path(tmp)
            (work/'src').mkdir()
            (work/'test').mkdir()
            shutil.copy2(out/'source-snapshot/formal/abi/words/WordOracle.t.sol', work/'test/WordOracle.t.sol')
            (work/'test/PinnedRuntime.sol').write_text('pragma solidity 0.8.36; library PinnedRuntime {function code() internal pure returns(bytes memory){return hex"'+runtime+'";}}')
            config = '[profile.default]\nsrc="src"\ntest="test"\nsolc='+json.dumps(str(args.solc))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[lint]\nlint_on_build=false\n'
            (work/'foundry.toml').write_text(config)
            (dest/'foundry.toml').write_text(config)
            concrete = run(['forge', 'test', '--root', work, '-vv'], dest/'concrete.log', 120)
        log = (dest/'concrete.log').read_text()
        concrete['detected'] = concrete['exitCode'] not in (0, None) and '[FAIL: panic: assertion failed (0x01)] test' in log
        manifest['mutations'].append({'name': name, 'before': before, 'after': after, 'target': target,
                                      'generation': gen, 'proof': proof, 'concrete': concrete, 'detected': detected and concrete['detected']})
        save()
        print(name+': '+('detected' if detected and concrete['detected'] else 'incomplete'), flush=True)
    manifest['sourceDrift'] = any(sha(ROOT/n) != h for n,h in manifest['sourceSha256'].items())
    manifest['status'] = 'passed' if len(manifest['mutations']) == 8 and all(m['detected'] for m in manifest['mutations']) and not manifest['sourceDrift'] else 'incomplete'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256'] = {str(path.relative_to(out)): sha(path) for path in sorted(out.rglob('*')) if path.is_file() and path.name != 'manifest.json'}
    save()
    return 0 if manifest['status'] == 'passed' else 1


if __name__ == '__main__':
    sys.exit(main())
