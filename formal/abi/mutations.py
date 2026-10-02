#!/usr/bin/env python3
"""Reject deliberate model faults in isolated temporary copies, after a clean proof run."""
import argparse
import concurrent.futures
import csv
import datetime
import hashlib
import json
from pathlib import Path
import re
import shutil
import tempfile
import time

from verify import HERE, ROOT, run, sha

CASES = [
    ('offset-includes-extra-word', 'Frames.dfy', 'then Word(tail) + Heads', 'then Word(tail + 32) + Heads', 'AbiFrames.ComponentLayout'),
    ('nonzero-padding', 'Frames.dfy', '{ seq(n, i => 0) }', '{ seq(n, i => 1) }', 'AbiFrames.Zeros'),
    ('wrong-single-value-envelope', 'Encoding.dfy', 'then Word(32) else []) + Body(t,v)', 'then Word(64) else []) + Body(t,v)', 'AbiEncoding.SingleValueEnvelope'),
    ('missing-array-count', 'Encoding.dfy', 'case Array(_) => Word(|v.values|) + Frame(Parts(t,v))', 'case Array(_) => Frame(Parts(t,v))', 'AbiEncoding.ArrayCount'),
    ('fixed-array-footprint-ignores-count', 'Encoding.dfy', 'case FixedArray(e, n) => n * HeadWords(e)', 'case FixedArray(e, n) => HeadWords(e)', 'AbiEncoding.StaticFootprint'),
    ('validator-ignores-padding', 'Validation.dfy', '!ZeroRegion(bs, 32+n, end)', 'false', 'AbiValidation.RejectDirtyPadding'),
    ('validator-allows-trailing-bytes', 'Validation.dfy', 'prefix+r.used != |bs|', 'false', 'AbiValidation.RejectTrailing'),
    ('validator-allows-loose-offset', 'Validation.dfy', 'if dynamic && ReadNat(bs[head..head+32]) != tail then BadFields else', 'if false then BadFields else', 'AbiValidation.RejectLooseOffset'),
    ('validator-ignores-word-rule', 'Validation.dfy', '!CanonicalWord(r,ReadNat(bs[..32]))', 'false', 'AbiValidation.RejectNoncanonicalScalar'),
]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dafny', required=True)
    parser.add_argument('--baseline', required=True)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    baseline_path = Path(args.baseline).resolve()
    baseline = json.loads(baseline_path.read_text())
    assert baseline['status'] == 'passed', 'Run the unmodified baseline first'
    for path in HERE.glob('*.dfy'):
        assert sha(path) == baseline['sourceSha256'][str(path.relative_to(ROOT))], 'Source drift since baseline'
    binary = Path(shutil.which(args.dafny)).resolve()
    assert sha(binary) == baseline['executableSha256']['dafnyLauncher']
    assert sha(binary.parent/'Dafny.dll') == baseline['executableSha256']['dafnyAssembly']
    pin = baseline['toolchain']
    solver = binary.parent / pin['solverRelativePath']
    assert sha(solver) == baseline['executableSha256']['solver']
    dest = Path(args.output).resolve()
    dest.mkdir(parents=True, exist_ok=False)
    shutil.copy2(baseline_path, dest/'baseline-used.json')
    shutil.copy2(Path(__file__), dest/'runner-used.py.txt')

    def check(case):
        name, filename, old, new, target = case
        assert any(r['name'] == target and r['status'] == 'passed' for r in baseline['declarationResults']), 'Mutation target was not proved in baseline'
        with tempfile.TemporaryDirectory(prefix='assertions-abi-'+name+'-') as tmp:
            scratch = Path(tmp)
            for source in HERE.glob('*.dfy'):
                shutil.copy2(source, scratch/source.name)
            path = scratch/filename
            text = path.read_text()
            assert text.count(old) == 1, (name, 'ambiguous mutation')
            path.write_text(text.replace(old, new, 1))
            command = [str(binary), 'verify', str(scratch/'Examples.dfy'), '--verify-included-files',
                       '--manual-lemma-induction', '--cores', '1', '--solver-path', str(solver),
                       '--verification-time-limit', str(pin['verificationTimeLimitSeconds']),
                       '--filter-symbol', target,
                       '--log-format', f'csv;LogFileName={dest/(name+".csv")}']
            result = run(command, dest/(name+'.log'))
            log = (dest/(name+'.log')).read_text()
            semantic_failure = bool(re.search(r'Error: (?:a postcondition could not be proved|assertion might not hold)', log))
            csv_path = dest/(name+'.csv')
            with csv_path.open(newline='') as f:
                native = list(csv.DictReader(f))
            target_failed = any(r['TestResult.DisplayName'].split(' (')[0] == target and r['TestResult.Outcome'] == 'Failed' for r in native)
            result.update(name=name, file=filename, original=old, replacement=new, target=target,
                          originalSha256=sha(HERE/filename), mutatedSha256=sha(path),
                          nativeResults=native, verificationCsvSha256=sha(csv_path),
                          rejected=result['exitCode'] not in (None, 0) and semantic_failure and target_failed,
                          containsTimeout='timed out' in log or 'time out' in log)
            print(json.dumps({'mutation': name, 'rejected': result['rejected']}), flush=True)
            return result

    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
        results = list(pool.map(check, CASES))
    report = {'schemaVersion': 1, 'baselineManifestSha256': sha(baseline_path),
              'scope': 'Faults in the independent model; not Solidity mutation testing',
              'verification': 'One explicit baseline-proved target per mutant; the unchanged baseline verifies every declaration',
              'completedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'sourceSha256': {p.name: sha(p) for p in HERE.glob('*.dfy')},
              'runnerSha256': sha(Path(__file__)), 'results': results,
              'allRejected': all(r['rejected'] for r in results)}
    (dest/'mutations.json').write_text(json.dumps(report, indent=2)+'\n')
    return 0 if report['allRejected'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
