#!/usr/bin/env python3
"""Require actual Solidity faults to fail both semantics and the EVM oracle."""
import argparse
import datetime
import json
from pathlib import Path
import re
import shutil
import sys
import verify

FAULTS = [
    ('equality', 'return actual == bound;', 'return actual != bound;', 'Check', 'testInclusiveBoundaries'),
    ('signed-order', 'return int256(uint256(actual)) >= int256(uint256(bound));', 'return int256(uint256(actual)) <= int256(uint256(bound));', 'Check', 'testSignedExtremesAndRanges'),
    ('inclusive-range', 'if (lower > upper)', 'if (lower >= upper)', 'Check', 'testInclusiveBoundaries'),
    ('word-bounds', 'if (words < length)', 'if (words <= length)', 'ValidateConstraints', 'testBoundsBeforePredicatesAndSkip'),
]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dafny', type=Path, required=True)
    parser.add_argument('--solc', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    manifest = {'status':'incomplete', 'startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(), 'faults':[],
                'sourceSha256':{str(p.relative_to(verify.ROOT)):verify.sha(p) for p in verify.inputs()},
                'executableSha256':{'dafny':verify.sha(args.dafny), 'Dafny.dll':verify.sha(args.dafny.parent/'Dafny.dll'), 'solc':verify.sha(args.solc), 'z3':verify.sha(args.dafny.parent/'z3/bin/z3-4.12.1')}}
    def save():
        (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    save()
    for name, before, after, theorem, test in FAULTS:
        directory = out/name
        scratch = directory/'source-snapshot'
        for p in verify.inputs():
            dest = scratch/p.relative_to(verify.ROOT)
            dest.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(p,dest)
        solidity = scratch/'contracts/Assertions.sol'
        text = solidity.read_text()
        if text.count(before) != 1:
            raise ValueError('Ambiguous mutation: '+name)
        solidity.write_text(text.replace(before,after))
        source = scratch/'formal/constraints'
        gate = verify.run([sys.executable,'-B',source/'generate.py','--solc',args.solc,'--root',scratch,'--output',directory/'generated'],directory/'gate.log')
        result = {'name':name,'before':before,'after':after,'expectedTheorem':theorem,'expectedTest':test,'sourceGate':gate,'passed':False}
        if gate['exitCode'] == 0:
            shutil.copy2(directory/'generated/Engine.generated.dfy',source/'Engine.generated.dfy')
            command = verify.proof_command(args.dafny,source/'Engine.generated.dfy',directory/'proof.csv')
            command += ['--filter-symbol', 'ConstraintEngine.'+theorem]
            proof = verify.run(command,directory/'proof.log',180)
            log = (directory/'proof.log').read_text()
            # A parser/type error, source rejection or timeout is never a kill.
            proof['killed'] = bool(proof['exitCode'] == 4 and re.search(r'with \d+ verified, [1-9]\d* errors?',log)
                and re.search(r'postcondition could not be proved|invariant could not be proved|assertion might not hold',log)
                and not re.search(r'time.?out|inconclusive|resolution/type errors|parse errors',log,re.I))
            result['proof'] = proof
            (scratch/'foundry.toml').write_text('[profile.default]\nsrc="contracts"\ntest="formal/constraints"\nsolc='+json.dumps(str(args.solc))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[fuzz]\nruns=256\nseed="0x8211"\n[lint]\nlint_on_build=false\n')
            evm = verify.run(['forge','test','--root',scratch,'--match-contract','ConstraintOracleTest','-vv'],directory/'concrete.log',180)
            text = (directory/'concrete.log').read_text()
            expected = re.findall(r'function (test\w+)\(', (source/'ConstraintOracle.t.sol').read_text())
            observed = re.findall(r'^\[(?:PASS|FAIL:.*)\] (test\w+)\(',text,re.M)
            failed = re.findall(r'^\[FAIL:.*\] (test\w+)\(',text,re.M)
            # Forge repeats failing names after its summary; compare sets and
            # require every current test accounted for, with the named kill.
            evm.update(expectedTests=expected,observedTests=sorted(set(observed)),failedTests=sorted(set(failed)))
            evm['killed'] = evm['exitCode'] == 1 and set(observed) == set(expected) and test in failed
            result['concrete'] = evm
            result['passed'] = proof['killed'] and evm['killed']
            shutil.rmtree(scratch/'out',ignore_errors=True)
            shutil.rmtree(scratch/'cache',ignore_errors=True)
        manifest['faults'].append(result)
        save()
    manifest['inputsUnchanged'] = manifest['sourceSha256'] == {str(p.relative_to(verify.ROOT)):verify.sha(p) for p in verify.inputs()}
    manifest['status'] = 'passed' if manifest['inputsUnchanged'] and all(f['passed'] for f in manifest['faults']) else 'incomplete'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256'] = {str(p.relative_to(out)):verify.sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name != 'manifest.json'}
    save()
    print(manifest['status'])
    raise SystemExit(0 if manifest['status']=='passed' else 1)


if __name__ == '__main__':
    main()
