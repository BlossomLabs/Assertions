#!/usr/bin/env python3
"""Require actual navigation source faults to fail both Dafny and real EVM tests.

A rejected AST translation, missing test or timeout does not kill a mutant.
Production Solidity is never edited; every variant is retained in its snapshot.
"""
import argparse
import datetime
import importlib.util
import json
from pathlib import Path
import re
import shutil
import sys

if not __debug__:
    raise RuntimeError('Run without Python -O: evidence gates use assertions')

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('navigation_verify', HERE / 'verify.py')
v = importlib.util.module_from_spec(spec)
spec.loader.exec_module(v)

CASES = [
    ('short-word', [('result.length - pos < 32', 'result.length - pos < 31')], 'Kernels.generated.dfy', 'NavigationKernels.ReadWord', 'testWordReadRequiresAll32Bytes'),
    ('negative-index', [('return count - uint256(-index);', 'return count - uint256(-index) + 1;')], 'Kernels.generated.dfy', 'NavigationKernels.NormalizeIndex', 'testDynamicArrayNegativeIndex'),
    ('array-head-stride', [('_navWord(result, dataStart + wanted * 32)', '_navWord(result, dataStart + wanted * 31)')], 'Cursor.generated.dfy', 'NavigationCursorSource.ArrayStep', 'testArrayOfDynamicElements'),
    ('tuple-head-stride', [('_navWord(result, c.base + acc * 32)', '_navWord(result, c.base + acc * 31)')], 'Cursor.generated.dfy', 'NavigationCursorSource.TupleStep', 'testNestedTupleField'),
    ('dynamic-child-base', [('c.base = dataStart + off;', 'c.base = dataStart + off + 1;'), ('c.base = c.base + off;', 'c.base = c.base + off + 1;')], 'Cursor.generated.dfy', 'NavigationCursorSource.DynamicMove', 'testWholeDynamicTuple'),
    ('static-array-stride', [('c.base = dataStart + wanted * elemWords * 32;', 'c.base = dataStart + wanted * elemWords * 31;')], 'Cursor.generated.dfy', 'NavigationCursorSource.StaticMove', 'testFixedArrayNegativeIndex'),
    ('static-tuple-stride', [('c.base = c.base + acc * 32;', 'c.base = c.base + acc * 31;')], 'Cursor.generated.dfy', 'NavigationCursorSource.TupleStep', 'testWholeStaticTuple'),
    ('length-array-head', [('length > available / 32 / elemWords', 'length > available / 31 / elemWords')], 'ModesSource.generated.dfy', 'NavigationModeSource.LengthAt', 'testLengthRequiresWholeElementHead'),
    ('length-rounded-bytes', [('length > available - available % 32', 'length > available')], 'ModesSource.generated.dfy', 'NavigationModeSource.LengthAt', 'testPayloadAcceptsUnpaddedBytes'),
    ('byte-padding-rounding', [('((len + 31) / 32) * 32', '(len / 32) * 32')], 'TerminalSource.generated.dfy', 'NavigationTerminalSource.BytesExtent', 'testLooseParentOffsetMayBeSelected'),
    ('payload-exact-end', [('length > result.length - pos - 32', 'length >= result.length - pos - 32')], 'ModesSource.generated.dfy', 'NavigationModeSource.PayloadAt', 'testPayloadAcceptsUnpaddedBytes'),
]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dafny', required=True)
    parser.add_argument('--solc', required=True)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    binary, solver, compiler, pin, versions, hashes = v.common.tools(args.dafny, args.solc)
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    paths = {v.ROOT / n for n in ['contracts/Assertions.sol', 'contracts/lib/AbiCodec.sol', 'contracts/lib/ERC8211.sol']}
    for entry in {HERE / case[2] for case in CASES}:
        paths.update(v.closure(entry))
    for directory in {HERE, v.ABI / 'shape', v.ABI / 'source'}:
        paths.update(p for p in directory.iterdir() if p.is_file() and
                     (p.suffix in {'.py', '.json', '.sol'} or p.name.endswith('.template.dfy')))
    manifest = {'schemaVersion': 1, 'status': 'incomplete', 'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                'versions': versions, 'toolchain': pin, 'executableSha256': hashes,
                'sourceSha256': {str(p.relative_to(v.ROOT)): v.sha(p) for p in sorted(paths)}, 'mutations': []}
    def save():
        (out / 'mutations.json').write_text(json.dumps(manifest, indent=2) + '\n')
    save()
    for name, edits, module, symbol, test in CASES:
        case = out / name
        snap = case / 'source-snapshot'
        for p in paths:
            dest = snap / p.relative_to(v.ROOT)
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(p, dest)
        source = snap / 'contracts/Assertions.sol'
        text = source.read_text()
        for old, new in edits:
            assert text.count(old) == 1, (name, old)
            text = text.replace(old, new)
        source.write_text(text)
        gen = v.run([sys.executable, '-B', snap / 'formal/navigation/generate.py', '--solc', compiler,
                     '--source', source, '--codec', snap / 'contracts/lib/AbiCodec.sol',
                     '--wire', snap / 'contracts/lib/ERC8211.sol', '--output', case / 'generated'], case / 'generate.log')
        item = {'name': name, 'edits': edits, 'mutantSourceSha256': v.sha(source), 'generation': gen,
                'targetDeclaration': symbol, 'requiredFailingEVMTest': test, 'status': 'incomplete'}
        if gen['exitCode'] == 0:
            for p in (case / 'generated').glob('*.dfy'):
                shutil.copy2(p, snap / 'formal/navigation' / p.name)
            csv = case / 'verification.csv'
            command = v.common.proof_command(binary, solver, pin, snap / 'formal/navigation' / module, csv, symbol)
            command.remove('--verify-included-files')
            proof = v.run(command, case / 'verify.log', 180)
            rows = v.common.native_results(csv)
            proof_text = (case / 'verify.log').read_text()
            proof_failed = (proof['exitCode'] == 4 and any(r['TestResult.DisplayName'].split(' (')[0] == symbol and r['TestResult.Outcome'] == 'Failed' for r in rows)
                            and re.search(r'Dafny program verifier finished with \d+ verified, [1-9]\d* errors?', proof_text)
                            and not re.search(r'time.?out|inconclusive|resource limit', proof_text, re.I))
            evm = v.evm(snap, compiler, case)
            accounted = sorted(evm['expectedTests']) == sorted(evm['passedTests'] + evm['failedTests'])
            killed = bool(proof_failed and evm['exitCode'] not in (None, 0) and test in evm['failedTests'] and accounted)
            item.update(proof=proof, nativeResults=rows, concrete=evm, allEVMTestsAccountedFor=accounted, status='killed' if killed else 'incomplete')
        manifest['mutations'].append(item)
        save()
        print(json.dumps({'mutation': name, 'status': item['status']}), flush=True)
    manifest['sourceDrift'] = any(v.sha(v.ROOT / n) != h for n, h in manifest['sourceSha256'].items())
    manifest['status'] = 'passed' if not manifest['sourceDrift'] and all(m['status'] == 'killed' for m in manifest['mutations']) else 'incomplete'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256'] = {str(p.relative_to(out)): v.sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p != out / 'mutations.json'}
    save()
    return 0 if manifest['status'] == 'passed' else 1


if __name__ == '__main__':
    sys.exit(main())
