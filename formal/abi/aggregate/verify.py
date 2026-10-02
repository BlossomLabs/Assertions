#!/usr/bin/env python3
"""Verify all ABI models, source kernels and recursive composition together."""
import argparse
import datetime
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ABI = HERE.parent
ROOT = HERE.parents[2]
spec = importlib.util.spec_from_file_location('abi_common', ABI/'source/verify.py')
common = importlib.util.module_from_spec(spec)
spec.loader.exec_module(common)
run, sha = common.run, common.sha


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--dafny', required=True)
    p.add_argument('--solc', required=True)
    p.add_argument('--bytecode-evidence', required=True, type=Path)
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    binary, solver, compiler, pin, versions, hashes = common.tools(args.dafny, args.solc)
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    sources = sorted([*ABI.glob('*.dfy'), *(ABI/'source').glob('*.dfy'), *HERE.glob('*.dfy')])
    seen = set()
    def includes(path):
        seen.add(path)
        for name in re.findall(r'^include "([^"]+)"', path.read_text(), re.M):
            child = (path.parent/name).resolve()
            if child not in seen:
                includes(child)
    includes(HERE/'Refinement.dfy')
    assert seen == set(sources)
    inventory = []
    for path in sources:
        module = re.search(r'^module (\w+)', path.read_text(), re.M)[1]
        for m in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate)(?: \{:[^}]+\})? (\w+)\(', path.read_text(), re.M):
            inventory.append({'name': module+'.'+m[2], 'kind': m[1], 'file': str(path.relative_to(ROOT))})
    artifacts = sorted(set(sources + list(HERE.glob('*.py')) + list((ABI/'source').glob('*.py')) +
                    [ROOT/'contracts/lib/AbiCodec.sol', ABI/'toolchain.json', ABI/'check-fixtures.mjs', ABI/'fixtures.json']))
    snapshot = out/'source-snapshot'
    for path in artifacts:
        dest = snapshot/path.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, dest)
    entry = snapshot/'formal/abi/aggregate/Refinement.dfy'
    manifest = {'schemaVersion': 1, 'status': 'incomplete',
                'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                'revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                'scope': 'Typed recursive composition plus selected source-derived checked aggregate cursor kernels; not full-source/bytecode refinement',
                'sourceSha256': {str(path.relative_to(ROOT)): sha(path) for path in artifacts},
                'versions': versions, 'executableSha256': hashes, 'toolchain': pin, 'sourceSnapshot': 'source-snapshot',
                'bounds': {'unrolling': None, 'inputLength': '<2^256', 'shapes': 'WellFormed plus recursive uint256 HeadWords fit',
                           'solverSecondsPerBatch': 30, 'ArrayHead': 'isolate_assertions; all obligations retained'},
                'assumptions': ['The prior bytes/string source proof and its trusted memory/AST boundary',
                                'Descriptor parsing/enumeration agrees with algebraic types and ShapesFit; not proved here',
                                'Static checkWords classification agrees with model scalar rules; not proved here',
                                'Loop-control normalization in ComposedWalk/Scan is hand-written composition, not a full AST translation',
                                'Sufficient resources; no gas/allocation/compiler-correctness theorem',
                                'Dafny/Boogie/Z3 and restricted AST translator are trusted'],
                'inventory': inventory, 'checks': []}
    def save():
        (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    def add(item, passed):
        item['passed'] = bool(passed)
        manifest['checks'].append(item)
        save()
    save()
    generated = out/'generated'
    gen = run([sys.executable, snapshot/'formal/abi/aggregate/generate.py', '--solc', compiler,
               '--source', snapshot/'contracts/lib/AbiCodec.sol', '--output', generated], out/'generate.log')
    gen['freshness'] = gen['exitCode'] == 0 and all((generated/name).read_bytes() == path.read_bytes() for name,path in [
        ('Cursors.generated.dfy', entry.parent/'Cursors.generated.dfy'),
        ('BytesBody.generated.dfy', entry.parent.parent/'source/BytesBody.generated.dfy')])
    add(gen, gen['exitCode'] == 0 and gen['freshness'])
    if not gen['passed']:
        return 1
    mask = run([solver, '-smt2', generated/'mask.smt2'], out/'mask.log', 120)
    mask['outcomes'] = (out/'mask.log').read_text().splitlines()
    add(mask, mask['exitCode'] == 0 and mask['outcomes'] == ['unsat']*32)
    proof = run(common.proof_command(binary, solver, pin, entry, out/'verification.csv'), out/'verify.log')
    native = common.native_results(out/'verification.csv')
    manifest['nativeResults'] = native
    declarations = []
    for d in inventory:
        rows = [r for r in native if r['TestResult.DisplayName'].split(' (')[0] == d['name']]
        status = ('failed' if any(r['TestResult.Outcome'] == 'Failed' for r in rows) else
                  'incomplete' if any(r['TestResult.Outcome'] != 'Passed' for r in rows) else 'passed') if rows else 'definition-no-separate-batch'
        declarations.append(dict(d, status=status, batches=len(rows)))
    manifest['declarationResults'] = declarations
    manifest['lemmaCount'] = sum(d['kind'] == 'lemma' for d in inventory)
    manifest['methodCount'] = sum(d['kind'] == 'method' for d in inventory)
    summary = re.search(r'Dafny program verifier finished with (\d+) verified, (\d+) errors', (out/'verify.log').read_text())
    proof['verifiedBatches'] = int(summary[1]) if summary else 0
    add(proof, proof['exitCode'] == 0 and summary and summary[2] == '0' and len(native) == proof['verifiedBatches'] > 0 and
        all(r['TestResult.Outcome'] == 'Passed' for r in native) and
        all(d['status'] == 'passed' for d in declarations if d['kind'] in ('lemma', 'method')))
    audit = run([binary, 'audit', entry], out/'audit.log')
    add(audit, audit['exitCode'] == 0 and 'auditor completed with 0 findings' in (out/'audit.log').read_text())
    fixture = run(['node', ABI/'check-fixtures.mjs'], out/'fixtures.log')
    add(fixture, fixture['exitCode'] == 0 and 'PASS: 1 ' in (out/'fixtures.log').read_text())
    fmt = run([binary, 'format', '--check', *[snapshot/p.relative_to(ROOT) for p in sources]], out/'format.log')
    add(fmt, fmt['exitCode'] == 0)
    bytecode = json.loads(args.bytecode_evidence.read_text())
    shutil.copy2(args.bytecode_evidence, out/'bytecode-baseline.json')
    integrity = all(sha(args.bytecode_evidence.parent/n) == h for n,h in bytecode['evidenceSha256'].items())
    add({'name': 'concrete-and-bytecode-evidence', 'exitCode': 0, 'manifestSha256': sha(args.bytecode_evidence)},
        bytecode['status'] == 'passed' and integrity and bytecode['sourceSha256']['contracts/lib/AbiCodec.sol'] == sha(ROOT/'contracts/lib/AbiCodec.sol'))
    manifest['sourceDrift'] = any(sha(ROOT/n) != h for n,h in manifest['sourceSha256'].items())
    manifest['status'] = 'passed' if all(c['passed'] for c in manifest['checks']) and not manifest['sourceDrift'] else 'incomplete'
    if any(r['TestResult.Outcome'] == 'Failed' for r in native):
        manifest['status'] = 'failed'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256'] = {str(path.relative_to(out)): sha(path) for path in sorted(out.rglob('*')) if path.is_file() and path.name != 'manifest.json'}
    save()
    print(json.dumps({'status': manifest['status'], 'lemmas': manifest['lemmaCount'], 'methods': manifest['methodCount'], 'batches': proof['verifiedBatches']}))
    return 0 if manifest['status'] == 'passed' else 1


if __name__ == '__main__':
    sys.exit(main())
