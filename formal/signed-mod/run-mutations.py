#!/usr/bin/env python3
"""Check proof and EVM-test sensitivity in disposable copies, never the shared tree."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parents[2]

def sha(data):
    return hashlib.sha256(data).hexdigest()

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dafny', required=True)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    output = Path(args.output).resolve()
    output.mkdir(parents=True, exist_ok=True)
    results = []
    source = (ROOT / 'contracts/Operations.sol').read_text()
    model = (ROOT / 'formal/signed-mod/SignedMod.dfy').read_text()
    # Each replacement is deliberately unique and changes an intended obligation.
    model_cases = [
        ('model-magnitude', 'Unsigned(Unsigned(Signed(-Signed(v + 1))) + 1)', 'Unsigned(Unsigned(Signed(-Signed(v + 1))) + 0)'),
        ('model-add-sign', 'SignedMagnitudeImpl((x + y) % d, a < 0)', 'SignedMagnitudeImpl((x + y) % d, a >= 0)'),
        ('model-wrapped-product', 'SignedMagnitudeImpl((x * y) % d, (a < 0) != (b < 0))', 'SignedMagnitudeImpl(((x * y) % Word) % d, (a < 0) != (b < 0))'),
    ]
    evm_cases = [
        ('evm-magnitude', 'uint256(-(value + 1)) + 1', 'uint256(-(value + 1)) + 0'),
        ('evm-opposite-sign', '_signedMagnitude((y - x) % modulus, b < 0)', '_signedMagnitude((y - x) % modulus, a < 0)'),
        ('evm-product-sign', 'mulmod(_magnitude(a), _magnitude(b), _magnitude(m)), (a < 0) != (b < 0)', 'mulmod(_magnitude(a), _magnitude(b), _magnitude(m)), (a < 0) == (b < 0)'),
        ('evm-wrapped-product',
         'return _signedMagnitude(mulmod(_magnitude(a), _magnitude(b), _magnitude(m)), (a < 0) != (b < 0));',
         'unchecked { return _signedMagnitude((_magnitude(a) * _magnitude(b)) % _magnitude(m), (a < 0) != (b < 0)); }'),
        ('evm-zero-modulus',
         'function mulMod(int256 a, int256 b, int256 m) external pure returns (int256) {',
         'function mulMod(int256 a, int256 b, int256 m) external pure returns (int256) { if (m == 0) return 0;'),
    ]
    def run(name, command, cwd, kind, original, mutated, before, after):
        start = time.monotonic()
        log_path = output / (name + '.log')
        with log_path.open('w') as log:
            try:
                proc = subprocess.run(command, cwd=cwd, stdout=log, stderr=subprocess.STDOUT, timeout=240)
                code = proc.returncode
            except subprocess.TimeoutExpired:
                code = None
        text = log_path.read_text()
        # A timeout, build failure or zero-test run is never a killed mutant.
        if kind == 'model':
            killed = code == 4 and 'could not be proved' in text and not re.search(r'time[ -]?out|timed out', text, re.I)
        elif kind == 'baseline':
            killed = code == 0 and bool(re.search(r'\b2 passing\b', text))
        else:
            killed = code not in (0, None) and 'AssertionError' in text and bool(re.search(r'\b[12] failing\b', text))
        result = dict(name=name, kind=kind, command=command, exitCode=code,
                      status=('passed' if kind == 'baseline' else 'killed') if killed else 'incomplete',
                      seconds=round(time.monotonic() - start, 3), log=log_path.name,
                      logSha256=sha(log_path.read_bytes()), runnerSha256=sha(Path(__file__).read_bytes()), testSha256=sha((ROOT / 'test/signed-mod.test.ts').read_bytes()), originalSha256=sha(original.encode()),
                      mutatedSha256=sha(mutated.encode()), before=before, after=after)
        results.append(result)
        (output / 'mutations.json').write_text(json.dumps(results, indent=2) + '\n')
        print(name, result['status'], flush=True)
        return killed

    with tempfile.TemporaryDirectory(prefix='assertions-signed-mod-') as tmp:
        scratch = Path(tmp)
        for name, before, after in model_cases:
            assert model.count(before) == 1, name
            mutated = model.replace(before, after)
            path = scratch / (name + '.dfy')
            path.write_text(mutated)
            # Verify all lemmas for helper/sign mutations. For wrapped product,
            # use a ground obligation with NO lemma calls or assumed helper
            # postconditions, avoiding an expensive universal counterexample.
            filters = ['--filter-symbol', 'ProductDoesNotWrap'] if name == 'model-wrapped-product' else []
            solver = str(Path(args.dafny).resolve().parent / 'z3/bin/z3-4.12.1')
            run(name, [args.dafny, 'verify', str(path), '--cores', '2', '--verification-time-limit', '30', '--solver-path', solver] + filters,
                scratch, 'model', model, mutated, before, after)
        for name, before, after in [('evm-baseline', '', '')] + evm_cases:
            project = scratch / name
            project.mkdir()
            shutil.copy2(ROOT / 'package.json', project / 'package.json')
            shutil.copy2(ROOT / 'hardhat.config.ts', project / 'hardhat.config.ts')
            (project / 'node_modules').symlink_to(ROOT / 'node_modules', target_is_directory=True)
            (project / 'contracts').mkdir()
            for contract in (ROOT / 'contracts').glob('*.sol'):
                shutil.copy2(contract, project / 'contracts' / contract.name)
            shutil.copytree(ROOT / 'contracts/lib', project / 'contracts/lib')
            (project / 'test').mkdir()
            shutil.copy2(ROOT / 'test/signed-mod.test.ts', project / 'test/signed-mod.test.ts')
            if before:
                assert source.count(before) == 1, name
                mutated = source.replace(before, after)
            else:
                mutated = source
            (project / 'contracts/Operations.sol').write_text(mutated)
            ok = run(name, ['pnpm', 'exec', 'hardhat', 'test', 'nodejs', 'test/signed-mod.test.ts', '--grep', 'boundary Cartesian'],
                     project, 'baseline' if not before else 'evm', source, mutated, before, after)
            if not before and not ok:
                raise SystemExit('Isolated EVM baseline did not pass; refusing mutation results')
    if any(r['status'] == 'incomplete' for r in results):
        raise SystemExit('Some mutation checks did not complete')

if __name__ == '__main__':
    main()
