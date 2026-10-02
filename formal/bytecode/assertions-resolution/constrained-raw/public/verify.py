#!/usr/bin/env python3
"""Bind a retained native public RAW/non-OR class to exact runtime and mutations."""
import argparse
import csv
import datetime
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
RESOLUTION = HERE.parent.parent


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


base = load('raw_binding', RESOLUTION / 'raw/verify.py')
common, identity, sha = base.common, base.identity, base.sha


def inputs(entry):
    files = set(base.closure(entry)) | set(base.closure(RESOLUTION / 'constraints/errors/NativeSelector.dfy'))
    # The original leaf generator formats its complete original connection.
    # Keep that reproduction closure even when the public proof substitutes
    # the private, independently checked signed-range physical error kernel.
    files |= set(base.closure(RESOLUTION / 'Connection.generated.dfy'))
    files |= set(base.closure(RESOLUTION / 'constraints/errors/NativeCount.dfy'))
    files |= {HERE / 'verify.py', HERE / 'generate-prefix.py', HERE / 'Prefix.mapping.json',
              HERE.parent / 'generate-before.py', HERE.parent / 'Before.mapping.json',
              HERE.parent / 'evm-traces.mjs', RESOLUTION / 'generate.py',
              RESOLUTION / 'constraints/generate-decoder.py', RESOLUTION / 'constraints/Decoder.mapping.json',
              RESOLUTION / 'constraints/generate-loop.py', RESOLUTION / 'constraints/errors/evm-traces.mjs',
              RESOLUTION / 'constraints/leaf/generate.py'}
    files |= {RESOLUTION / 'constraints/errors' / name for name in
              ['generate-bounds.py', 'WordBounds.mapping.json', 'evm-word-bounds.mjs']}
    files |= set(RESOLUTION.glob('Kind*.mapping.json'))
    files |= {RESOLUTION / 'constraints' / (name + '.mapping.json')
              for name in ['Init', 'Prepare', 'Dispatch', 'Increment', 'Exit', 'Empty']}
    files |= {ROOT / p for p in ['formal/constraints/verify.py', 'formal/abi/toolchain.json',
              'formal/bytecode/dispatch/identity.py', 'formal/bytecode/dispatch/inventory.json',
              'formal/bytecode/format-generated.py', 'formal/bytecode/assertions-resolution/raw/verify.py',
              'hardhat.config.ts', 'package.json', 'pnpm-lock.yaml']}
    artifact = ROOT / 'artifacts/contracts/Assertions.sol/Assertions.json'
    build = ROOT / 'artifacts/build-info' / (json.loads(artifact.read_text())['buildInfoId'] + '.json')
    files |= {artifact, build}
    for key in json.loads(build.read_text())['input']['sources']:
        files.add(identity.source_path(key))
        if key.startswith('npm/'):
            package = re.fullmatch(r'npm/(@[^/]+/[^/@]+)@([^/]+)/(.+)', key)[1]
            files.add(ROOT / 'node_modules' / package / 'package.json')
    return sorted(files)


def main():
    parser = argparse.ArgumentParser()
    for name in ['dafny', 'solc', 'node', 'native-evidence', 'output']:
        parser.add_argument('--' + name, type=Path, required=True)
    parser.add_argument('--class', dest='case', choices=['success', 'first-error', 'word-bounds'], required=True)
    args = parser.parse_args()
    entry = HERE / {'success': 'Connection.dfy', 'first-error': 'Error.dfy', 'word-bounds': 'WordBounds.dfy'}[args.case]
    native = args.native_evidence.resolve()
    nm = json.loads((native / 'manifest.json').read_text())
    assert nm['status'] == 'passed' and nm['inputsUnchanged'] and nm['toolsUnchanged']
    proof_files = base.closure(entry)
    expected_closure = {str(p.relative_to(ROOT)) for p in proof_files}
    if nm.get('verificationMode') == 'modular-complete-closure':
        assert nm['coverageComplete']
        assert set(nm['entryIncludeClosures'][str(entry.relative_to(ROOT))]) == expected_closure
        assert expected_closure <= set(nm['includeClosure'])
        assert {m['file'] for m in nm['moduleProofs']} == set(nm['includeClosure'])
        assert all(m['proof']['passed'] and m['audit']['passed'] for m in nm['moduleProofs'])
    else:
        assert set(nm['includeClosure']) == expected_closure
    assert all(nm['sourceSha256'][str(p.relative_to(ROOT))] == sha(p) for p in proof_files)
    assert nm['nativeResults'] and all(r['TestResult.Outcome'] == 'Passed' for r in nm['nativeResults'])
    assert all(job['passed'] for job in nm['checks'])
    assert all(sha(native / name) == digest for name, digest in nm['evidenceSha256'].items())
    dafny, solc, node = args.dafny.resolve(), args.solc.resolve(), args.node.resolve()
    z3 = dafny.parent / 'z3/bin/z3-4.12.1'
    tools = {'dafny': dafny, 'Dafny.dll': dafny.parent / 'Dafny.dll', 'z3': z3, 'solc': solc, 'node': node}
    versions = {k: subprocess.check_output([str(v), '--version'], text=True).strip()
                for k, v in tools.items() if k != 'Dafny.dll'}
    assert versions['dafny'] == json.loads((ROOT / 'formal/abi/toolchain.json').read_text())['dafnyVersion']
    assert '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc']
    assert all(nm['executableSha256'][k] == sha(v) for k, v in tools.items() if k in nm['executableSha256'])
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    files = inputs(entry)
    hashes = {str(p.relative_to(ROOT)): sha(p) for p in files}
    snapshot = out / 'source-snapshot'
    for p in files:
        dest = snapshot / p.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(p, dest)
    retained = out / 'retained-native'
    shutil.copytree(native, retained)
    source = snapshot / HERE.relative_to(ROOT)
    scope = {'success': 'physical RETURN of the original arbitrary RAW payload after arbitrarily many successful non-OR constraints',
             'first-error': 'physical InvalidConstraintData/InvalidConstraintRange REVERT at the first bad constraint after arbitrarily many successful non-OR constraints',
             'word-bounds': 'physical ReturnDataOutOfBounds REVERT when the constraint count exceeds complete RAW words, before reading any constraint record'}[args.case]
    manifest = {
        'schemaVersion': 1, 'status': 'incomplete',
        'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'scope': 'Exact Assertions public resolve class from PC0 with empty stack/memory to ' + scope +
                 ('. No constraint record is read in this class; record contents may be malformed.' if args.case == 'word-bounds' else '. Enum kinds 0..8 except OR.') +
                 ' Complete structural ABI admission and explicit representable allocation bounds. Other fetchers and resolver classes remain open. No whole-entry completion claim.',
        'entryPc': 0, 'publicEntries': [],
        'publicEntryClasses': ['resolve((uint8,uint8,bytes,(uint8,bytes)[])): RAW_BYTES/' + args.case],
        'nativeEvidence': {'manifestSha256': sha(native / 'manifest.json'),
                           'nativeCheckCount': len(nm['nativeResults']), 'source': 'retained-native/manifest.json'},
        'sourceSha256': hashes, 'versions': versions, 'executableSha256': {k: sha(v) for k, v in tools.items()}, 'checks': [],
        'assumptions': [
            'Reviewed EVM opcode/memory/frame semantics, pinned Dafny/Boogie/Z3 and native EVM runtime are trusted boundaries. Compilation and EVM fixtures corroborate the arbitrary-input native proof.',
            'The independent calldata admission fixes the actual selector, legal RAW fetcher, ABI spans, constraint table and original payload. All internal physical memory and stack premises are discharged from the empty public frame. Constraint-record contents are admitted only when this class reads them.',
            'The measured bytecode is reproduced from pinned compilation inputs. Actual destinations and continuations are certified by a complete PUSH-aware scan. Sufficient reached execution resources are assumed; no gas theorem.',
            ('The independent count error encodes the number of complete resolved words and the original byte length. No constraint record or verdict is read.'
             if args.case == 'word-bounds' else
             'Independent mathematical non-OR verdicts fix unsigned/signed order, exact reference widths and exact physical error bytes. Loop induction handles an arbitrary count and first-error position under allocation bounds.')
        ]}

    def save():
        (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')

    def record(name, command, timeout=600):
        job = common.run(command, out / (name + '.log'), timeout)
        job.update(name=name, passed=job['exitCode'] == 0)
        manifest['checks'].append(job)
        save()
        print(name, 'passed' if job['passed'] else 'failed', flush=True)
        return job

    save()
    record('runtime-identity', [sys.executable, '-B', snapshot / 'formal/bytecode/dispatch/identity.py',
                              '--solc', solc, '--output', out / 'identity', '--contract', 'Assertions'], 240)
    code = bytes.fromhex(json.loads((snapshot / 'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
    destinations = set()
    pc = 0
    while pc < len(code):
        op = code[pc]
        if op == 0x5b:
            destinations.add(pc)
        pc += 1 + (op - 95 if 96 <= op <= 127 else 0)
    guard_count = 0
    for p in proof_files:
        for match in re.finditer(r'code\[(\d+)\]\s*==\s*(0x[0-9a-fA-F]+|[0-9]+)', p.read_text()):
            address, expected = int(match[1]), int(match[2], 0)
            assert code[address] == expected, (p, address)
            guard_count += 1
    before = json.loads((HERE.parent / 'Before.mapping.json').read_text())
    assert before['fullRuntimeDestinations'] == sorted(destinations)
    assert all(ret in destinations for ret in [1017, 3967, 7723, 8035])
    manifest['runtimeBinding'] = {'runtimeSha256': hashlib.sha256(code).hexdigest(),
                                  'runtimeBytes': len(code), 'constantGuardCount': guard_count,
                                  'certifiedContinuations': [1017, 3967, 7723, 8035],
                                  'pushAwareDestinationCount': len(destinations)}
    save()
    generations = [
        ('before', source.parent / 'generate-before.py', HERE.parent, ['Before.generated.dfy', 'Before.mapping.json']),
        ('prefix', source / 'generate-prefix.py', HERE, ['Prefix.generated.dfy', 'Prefix.mapping.json']),
        ('decoder', snapshot / RESOLUTION.relative_to(ROOT) / 'constraints/generate-decoder.py',
         RESOLUTION / 'constraints', ['Decoder.generated.dfy', 'Decoder.mapping.json']),
        ('loop', snapshot / RESOLUTION.relative_to(ROOT) / 'constraints/generate-loop.py',
         RESOLUTION / 'constraints', [name + suffix for name in ['Init', 'Prepare', 'Dispatch', 'Increment', 'Exit', 'Empty']
                                   for suffix in ['.generated.dfy', '.mapping.json']]),
        ('leaf', snapshot / RESOLUTION.relative_to(ROOT) / 'generate.py', RESOLUTION,
         [p.name for p in RESOLUTION.glob('Kind*.mapping.json')] +
         [p.name for p in RESOLUTION.glob('Kind*.dfy')] + ['Connection.generated.dfy'])]
    if args.case == 'word-bounds':
        generations = generations[:2] + [('word-bounds', snapshot / RESOLUTION.relative_to(ROOT) / 'constraints/errors/generate-bounds.py',
                                           RESOLUTION / 'constraints/errors', ['WordBounds.generated.dfy', 'WordBounds.mapping.json'])]
    else:
        generations.append(('leaf-private', snapshot / RESOLUTION.relative_to(ROOT) / 'constraints/leaf/generate.py',
                            RESOLUTION / 'constraints/leaf', ['Kind8BadRange.generated.dfy', 'Connection.generated.dfy']))
    for name, generator, original, names in generations:
        generated = out / ('generated-' + name)
        job = record('generation-' + name, [sys.executable, '-B', generator, '--output', generated, '--dafny', dafny])
        job['passed'] = job['passed'] and all((original / n).read_bytes() == (generated / n).read_bytes() for n in names)
        save()
    evm_script = {'success': HERE.parent / 'evm-traces.mjs',
                  'first-error': RESOLUTION / 'constraints/errors/evm-traces.mjs',
                  'word-bounds': RESOLUTION / 'constraints/errors/evm-word-bounds.mjs'}[args.case]
    expected_count = {'success': 18, 'first-error': 22, 'word-bounds': 16}[args.case]
    concrete = record('concrete', [node, evm_script, out / 'evm-traces'], 240)
    traces = json.loads((out / 'evm-traces/results.json').read_text())
    concrete['passed'] = concrete['passed'] and len(traces) == expected_count and len({r['name'] for r in traces}) == expected_count and all(r['passed'] for r in traces)
    save()
    witness = {'success': source / 'Return.dfy',
               'first-error': snapshot / RESOLUTION.relative_to(ROOT) / 'constraints/errors/NativeSelector.dfy',
               'word-bounds': snapshot / RESOLUTION.relative_to(ROOT) / 'constraints/errors/NativeCount.dfy'}[args.case]
    symbol = {'success': 'AssertionsConstrainedPublicReturn.Step', 'first-error': 'AssertionsConstraintErrorSelector',
              'word-bounds': 'AssertionsConstraintCountWitness'}[args.case]
    baseline = record('witness-baseline', [dafny, 'verify', witness, '--manual-lemma-induction', '--cores', '1',
                      '--verification-time-limit', '30', '--solver-path', z3, '--filter-symbol', symbol,
                      '--log-format', 'csv;LogFileName=' + str(out / 'witness-baseline.csv')], 300)
    rows = list(csv.DictReader((out / 'witness-baseline.csv').open()))
    baseline['passed'] = baseline['passed'] and bool(rows) and all(r['TestResult.Outcome'] == 'Passed' for r in rows)
    audit = record('witness-audit', [dafny, 'audit', witness])
    audit['passed'] = audit['passed'] and 'auditor completed with 0 findings' in (out / 'witness-audit.log').read_text()
    save()
    mutant = out / 'mutant-source'
    shutil.copytree(snapshot, mutant)
    mutable = bytearray(code)
    if args.case == 'success':
        assert mutable[1026] == 0xf3
        mutable[1026] = 0xfd
        candidate_witness = mutant / witness.relative_to(snapshot)
        candidate_witness.write_text(candidate_witness.read_text().replace('code[1026] == 243', 'code[1026] == 253'))
        mutation_name = 'return-to-revert'
    elif args.case == 'first-error':
        assert mutable[11083:11088] == bytes.fromhex('63738673b3')
        mutable[11087] = 0xb2
        candidate_witness = mutant / witness.relative_to(snapshot)
        candidate_witness.write_text(candidate_witness.read_text().replace('code[11087] == 0xb3', 'code[11087] == 0xb2'))
        mutation_name = 'bad-data-selector'
    else:
        assert mutable[7615] == 0x10
        mutable[7615] = 0x11
        candidate_witness = mutant / witness.relative_to(snapshot)
        candidate_witness.write_text(candidate_witness.read_text().replace('code[7615] == 0x10', 'code[7615] == 0x11'))
        mutation_name = 'word-count-lt-to-gt'
    binary = out / (mutation_name + '.bin')
    binary.write_bytes(mutable)
    negative = record('mutant-native', [dafny, 'verify', candidate_witness, '--manual-lemma-induction', '--cores', '1',
                      '--verification-time-limit', '30', '--solver-path', z3, '--filter-symbol', symbol,
                      '--log-format', 'csv;LogFileName=' + str(out / 'mutant-native.csv')], 300)
    rows = list(csv.DictReader((out / 'mutant-native.csv').open()))
    log = (out / 'mutant-native.log').read_text()
    negative['passed'] = negative['exitCode'] not in [0, None] and bool(rows) and any(r['TestResult.Outcome'] == 'Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed', 'Failed'} for r in rows) and bool(re.search(r'postcondition could not be proved|assertion might not hold', log)) and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error', log, re.I)
    negative['nativeResults'] = rows
    mutant_evm = record('mutant-concrete', [node, evm_script, out / 'mutant-traces', binary], 240)
    mutant_traces = json.loads((out / 'mutant-traces/results.json').read_text())
    receipt_failure = {'success': 'Independent exact public receipt differs', 'first-error': 'Independent exact first-error receipt differs',
                       'word-bounds': 'Independent exact word-count error differs'}[args.case]
    mutant_evm['passed'] = mutant_evm['exitCode'] not in [0, None] and len(mutant_traces) == expected_count and any(receipt_failure in r['errors'] for r in mutant_traces)
    manifest['mutation'] = {'name': mutation_name, 'runtimeSha256': sha(binary),
                            'failedNativeCount': sum(r['TestResult.Outcome'] == 'Failed' for r in rows),
                            'semanticConcreteFailures': sum(receipt_failure in r['errors'] for r in mutant_traces)}
    ct = json.loads((out / 'evm-traces/toolchain.json').read_text())
    manifest['concreteToolchain'] = ct
    manifest['inputsUnchanged'] = hashes == {str(p.relative_to(ROOT)): sha(p) for p in inputs(entry)}
    manifest['toolsUnchanged'] = manifest['executableSha256'] == {k: sha(v) for k, v in tools.items()}
    manifest['retainedNativeUnchanged'] = sha(retained / 'manifest.json') == manifest['nativeEvidence']['manifestSha256'] and all(sha(retained / name) == digest for name, digest in nm['evidenceSha256'].items())
    manifest['concreteToolsUnchanged'] = all(sha(Path(ct[k])) == ct[k + 'Sha256'] for k in ['hardhatEntry', 'edrEntry', 'nativeBinding']) and sha(Path(ct['nodeExecutable'])) == ct['nodeSha256'] and sha(ROOT / 'pnpm-lock.yaml') == ct['lockfileSha256']
    manifest['status'] = 'passed' if all(manifest[k] for k in ['inputsUnchanged', 'toolsUnchanged', 'retainedNativeUnchanged', 'concreteToolsUnchanged']) and all(job['passed'] for job in manifest['checks']) else 'failed'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256'] = {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name != 'manifest.json'}
    save()
    print(manifest['status'])
    raise SystemExit(0 if manifest['status'] == 'passed' else 1)


if __name__ == '__main__':
    main()
