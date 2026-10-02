#!/usr/bin/env python3
"""Account for source word proofs and concrete exact-runtime checks, including failures."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import copy
import datetime
import difflib
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

from repair import candidate

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
    p.add_argument('--smt-python', required=True, type=Path, help='Python with z3-solver 4.12.6 installed')
    p.add_argument('--candidate-fix', action='store_true', help='Check the isolated proposal; never modify production files')
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    binary, solver, compiler, pin, versions, hashes = common.tools(args.dafny, args.solc)
    versions['expressionLibrary'] = subprocess.check_output([args.smt_python, '-c', 'import z3; print(z3.get_version_string())'], text=True).strip()
    assert versions['expressionLibrary'] == '4.12.6'
    versions['forge'] = subprocess.check_output(['forge', '--version'], text=True).strip()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    sources = sorted([*ABI.glob('*.dfy'), *(ABI/'source').glob('*.dfy'), *(ABI/'aggregate').glob('*.dfy'), *HERE.glob('*.dfy')])
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
    artifact_path = ROOT/'artifacts/contracts/Collections.sol/Collections.json'
    artifact = json.loads(artifact_path.read_text())
    build_path = ROOT/'artifacts/build-info'/(artifact['buildInfoId']+'.json')
    build = json.loads(build_path.read_text())
    assert build['solcLongVersion'] == '0.8.36+commit.8a079791'
    request = copy.deepcopy(build['input'])
    project_inputs, dependencies = common.canonical_sources(request)
    paths = sorted(set(sources + project_inputs +
                       list(HERE.glob('*.py')) + list(HERE.glob('*.sol')) + list((ABI/'source').glob('*.py')) +
                       list((ABI/'aggregate').glob('*.py')) + [ABI/'toolchain.json']))
    snap = out/'source-snapshot'
    for path in paths:
        dest = snap/path.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, dest)
    contract = snap/'contracts/lib/AbiCodec.sol'
    if args.candidate_fix:
        original = contract.read_text()
        repaired = candidate(original)
        contract.write_text(repaired)
        (out/'candidate.patch').write_text(''.join(difflib.unified_diff(original.splitlines(True), repaired.splitlines(True),
                                                fromfile='a/contracts/lib/AbiCodec.sol', tofile='b/contracts/lib/AbiCodec.sol')))
        request['sources']['project/contracts/lib/AbiCodec.sol']['content'] = repaired
    manifest = {
        'schemaVersion': 1, 'status': 'incomplete', 'candidateOnly': args.candidate_fix,
        'scope': 'Source name classification, word predicates and AST-checked loop certificates; exact-runtime finite EVM regressions. Not full descriptor/validator or unbounded bytecode proof.',
        'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
        'workingTreeSha256': {str(path.relative_to(ROOT)): sha(path) for path in paths},
        'analysisSourceSha256': sha(contract),
        'canonicalArtifactSha256': sha(artifact_path), 'canonicalBuildInfoSha256': sha(build_path),
        'compilerDependencies': dependencies,
        'versions': versions, 'executableSha256': hashes, 'toolchain': pin,
        'bounds': {'nameLengths': '1..8 plus arbitrary >=9', 'wordBits': 256,
                   'widthLoopVisits': 4, 'widthLoopCompletion': 'separate universal UNSAT obligation',
                   'scanNameAndWordScanIterations': 'unbounded induction; lengths <2^256', 'solverTimeoutMs': 30000},
        'assumptions': ['Pinned solc AST, restricted Python Yul interpreter and loop-certificate normalization are trusted, not verified',
                        'The finite 96-name whitelist maps to Dafny ClassifiedRule constructors; full-width/unknown names map to Opaque',
                        'Calldata pointer relocation to descriptor-relative origin and in-bounds big-endian memory representation are trusted',
                        'Bytes outside the descriptor limit are unconstrained; zero padding is NOT assumed',
                        'Sufficient gas, memory and recursion resources; no compiler-correctness theorem',
                        'Static tuple/suffix traversal, full typeShape grammar and complete function connection remain open'],
        'inventory': inventory, 'checks': [], 'smtResults': []}
    def save():
        (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    def add(check, passed):
        check['passed'] = bool(passed)
        manifest['checks'].append(check)
        save()
    save()
    generated = out/'generated'
    gen = run([args.smt_python, '-B', snap/'formal/abi/words/generate.py', '--solc', compiler, '--source', contract, '--output', generated], out/'generate.log', 120)
    assert gen['exitCode'] == 0, 'Generation failed; incomplete proof'
    checked = snap/'formal/abi/words/Scanners.generated.dfy'
    # Candidate changes only the classifier, but hashes must identify its source.
    if args.candidate_fix:
        checked.write_text(checked.read_text().replace(manifest['workingTreeSha256']['contracts/lib/AbiCodec.sol'], sha(contract)))
    gen['freshness'] = (generated/'Scanners.generated.dfy').read_bytes() == checked.read_bytes()
    add(gen, gen['freshness'])
    queries = json.loads((generated/'queries.json').read_text())
    assert len(queries) == 107 and len({q['name'] for q in queries}) == 107
    def prove(q):
        name = q['name']
        result = run([solver, '-smt2', generated/(name+'.smt2')], out/(name+'.log'), 45)
        lines = (out/(name+'.log')).read_text().splitlines()
        status = 'passed' if result['exitCode'] == 0 and lines == ['unsat'] else 'failed' if result['exitCode'] == 0 and lines == ['sat'] else 'incomplete'
        if status == 'failed':
            model_query = generated/(name+'-counterexample.smt2')
            model_query.write_text((generated/(name+'.smt2')).read_text()+'\n(get-model)\n')
            result['counterexample'] = run([solver, '-smt2', model_query], out/(name+'-counterexample.log'), 45)
        return dict(q, status=status, execution=result)
    with ThreadPoolExecutor(max_workers=2) as pool:
        manifest['smtResults'] = list(pool.map(prove, queries))
    save()
    add({'name': 'all-source-SMT-obligations', 'exitCode': 0, 'expectedCount': 107,
         'counts': {s: sum(q['status'] == s for q in manifest['smtResults']) for s in ('passed', 'failed', 'incomplete')}},
        all(q['status'] == 'passed' for q in manifest['smtResults']))
    # Retain prior source-kernel obligations too: the entry includes them all.
    previous = out/'aggregate-generated'
    agg = run([sys.executable, '-B', snap/'formal/abi/aggregate/generate.py', '--solc', compiler, '--source', contract, '--output', previous], out/'aggregate-generate.log')
    # A classifier edit shifts solc ids/spans and the source hash in comments.
    # The candidate must leave every non-comment line of these kernels intact;
    # use its freshly generated files for the actual proof and snapshot hashes.
    agg['freshness'] = agg['exitCode'] == 0
    for name, path in [('Cursors.generated.dfy', 'formal/abi/aggregate/Cursors.generated.dfy'),
                       ('BytesBody.generated.dfy', 'formal/abi/source/BytesBody.generated.dfy')]:
        actual, expected = (previous/name).read_text(), (snap/path).read_text()
        if args.candidate_fix:
            code = lambda text: '\n'.join(line for line in text.splitlines() if not line.lstrip().startswith('//'))
            agg['freshness'] = agg['freshness'] and code(actual) == code(expected)
            (snap/path).write_text(actual)
        else:
            agg['freshness'] = agg['freshness'] and actual == expected
    add(agg, agg['freshness'])
    mask = run([solver, '-smt2', previous/'mask.smt2'], out/'mask.log', 120)
    add(mask, mask['exitCode'] == 0 and (out/'mask.log').read_text().splitlines() == ['unsat']*32)
    entry = snap/'formal/abi/words/Refinement.dfy'
    proof = run(common.proof_command(binary, solver, pin, entry, out/'verification.csv'), out/'verify.log')
    native = common.native_results(out/'verification.csv')
    text = (out/'verify.log').read_text()
    # Dafny's CSV uses Failed for timeouts too; retain them as incomplete,
    # rather than misreporting a solver limit as a semantic counterexample.
    timed_out = set(re.findall(r"Verification of '([^']+)' timed out", text))
    proof['timedOutDeclarations'] = sorted(timed_out)
    manifest['nativeResults'] = native
    declarations = []
    for d in inventory:
        rows = [r for r in native if r['TestResult.DisplayName'].split(' (')[0] == d['name']]
        status = ('incomplete' if d['name'] in timed_out else
                  'failed' if any(r['TestResult.Outcome'] == 'Failed' for r in rows) else
                  'incomplete' if any(r['TestResult.Outcome'] != 'Passed' for r in rows) else 'passed') if rows else 'definition-no-separate-batch'
        declarations.append(dict(d, status=status, batches=len(rows)))
    manifest['declarationResults'] = declarations
    manifest['lemmaCount'] = sum(d['kind'] == 'lemma' for d in inventory)
    manifest['methodCount'] = sum(d['kind'] == 'method' for d in inventory)
    summary = re.search(r'Dafny program verifier finished with (\d+) verified, (\d+) errors', text)
    proof['verifiedBatches'] = int(summary[1]) if summary else 0
    add(proof, proof['exitCode'] == 0 and summary and summary[2] == '0' and len(native) == proof['verifiedBatches'] > 0 and
        all(r['TestResult.Outcome'] == 'Passed' for r in native) and
        all(d['status'] == 'passed' for d in declarations if d['kind'] in ('lemma', 'method')) and
        not re.search(r'time.?out|inconclusive|resource limit', text, re.I))
    audit = run([binary, 'audit', entry], out/'audit.log')
    add(audit, audit['exitCode'] == 0 and 'auditor completed with 0 findings' in (out/'audit.log').read_text())
    # Canonical compiler settings; baseline must reproduce the exact artifact.
    (out/'solc-input.json').write_text(json.dumps(request, indent=2)+'\n')
    proc = subprocess.run([compiler, '--standard-json'], input=json.dumps(request), capture_output=True, text=True, timeout=120)
    (out/'solc-stderr.log').write_text(proc.stderr)
    (out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(), mtime=0))
    compiled = json.loads(proc.stdout)
    assert proc.returncode == 0 and not any(e['severity'] == 'error' for e in compiled.get('errors', []))
    runtime = compiled['contracts']['project/contracts/Collections.sol']['Collections']['evm']['deployedBytecode']['object']
    manifest['runtimeBytes'] = len(runtime)//2
    manifest['runtimeSha256'] = hashlib.sha256(bytes.fromhex(runtime)).hexdigest()
    manifest['canonicalRuntimeMatched'] = runtime == artifact['deployedBytecode'].removeprefix('0x')
    add({'name': 'runtime-origin', 'exitCode': 0}, args.candidate_fix or manifest['canonicalRuntimeMatched'])
    add({'name': 'EIP-170', 'exitCode': 0, 'runtimeBytes': len(runtime)//2}, len(runtime)//2 <= 24576)
    (out/'runtime.hex').write_text('0x'+runtime+'\n')
    with tempfile.TemporaryDirectory(prefix='abi-word-oracle-') as tmp:
        scratch = Path(tmp)
        (scratch/'src').mkdir()
        (scratch/'test').mkdir()
        shutil.copy2(snap/'formal/abi/words/WordOracle.t.sol', scratch/'test/WordOracle.t.sol')
        (scratch/'test/PinnedRuntime.sol').write_text('// SPDX-License-Identifier: MIT\npragma solidity 0.8.36;\nlibrary PinnedRuntime {function code() internal pure returns(bytes memory) {return hex"'+runtime+'";}}\n')
        config = '[profile.default]\nsrc="src"\ntest="test"\nsolc='+json.dumps(str(compiler))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[lint]\nlint_on_build=false\n'
        (scratch/'foundry.toml').write_text(config)
        (out/'foundry.toml').write_text(config)
        concrete = run(['forge', 'test', '--root', scratch, '-vv'], out/'concrete.log', 120)
        log = (out/'concrete.log').read_text()
        tests = re.findall(r'function (test\w+)\(', (scratch/'test/WordOracle.t.sol').read_text())
        observed = re.findall(r'^\[PASS\] (test\w+)\(', log, re.M)
        concrete['expectedTests'] = tests
        concrete['passedTests'] = observed
        concrete['failedTests'] = re.findall(r'^\[FAIL:.*?\] (test\w+)\(', log, re.M)
        assert len(tests) == 4 and len(set(tests)) == 4
        add(concrete, concrete['exitCode'] == 0 and sorted(observed) == sorted(tests))
    fmt = run([binary, 'format', '--check', *[snap/path.relative_to(ROOT) for path in sources]], out/'format.log')
    add(fmt, fmt['exitCode'] == 0)
    sfmt = run(['forge', 'fmt', '--check', snap/'formal/abi/words/WordOracle.t.sol'], out/'solidity-format.log')
    add(sfmt, sfmt['exitCode'] == 0)
    manifest['sourceDrift'] = any(sha(ROOT/n) != h for n,h in manifest['workingTreeSha256'].items()) or sha(artifact_path) != manifest['canonicalArtifactSha256']
    failure = any(q['status'] == 'failed' for q in manifest['smtResults']) or any(d['status'] == 'failed' for d in declarations) or bool(concrete['failedTests'])
    manifest['status'] = 'passed' if all(c['passed'] for c in manifest['checks']) and not manifest['sourceDrift'] else 'failed' if failure else 'incomplete'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['sourceSnapshotSha256'] = {str(path.relative_to(snap)): sha(path) for path in sorted(snap.rglob('*')) if path.is_file()}
    manifest['evidenceSha256'] = {str(path.relative_to(out)): sha(path) for path in sorted(out.rglob('*')) if path.is_file() and path.name != 'manifest.json'}
    save()
    print(json.dumps({'status': manifest['status'], 'candidateOnly': args.candidate_fix, 'lemmas': manifest['lemmaCount'],
                      'methods': manifest['methodCount'], 'batches': proof['verifiedBatches'], 'runtimeBytes': manifest['runtimeBytes'],
                      'SMT': {s: sum(q['status'] == s for q in manifest['smtResults']) for s in ('passed', 'failed', 'incomplete')}}))
    return 0 if manifest['status'] == 'passed' else 1


if __name__ == '__main__':
    sys.exit(main())
