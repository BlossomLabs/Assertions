#!/usr/bin/env python3
"""Exercise the proof harness and zero-modulus negative controls on a real EVM."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--solc', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    assert not (output / 'manifest.json').exists(), 'Refusing to overwrite evidence'
    artifact = json.loads((ROOT / 'artifacts/contracts/Operations.sol/Operations.json').read_text())
    build = json.loads((ROOT / 'artifacts/build-info' / (artifact['buildInfoId'] + '.json')).read_text())
    compiler_input = build['input']
    source_name = next(k for k in compiler_input['sources'] if k.endswith('/contracts/Operations.sol'))
    original = compiler_input['sources'][source_name]['content']
    assert original == (ROOT / 'contracts/Operations.sol').read_text()
    work = Path(tempfile.mkdtemp(prefix='signed-mod-harness-'))
    (work / 'spec').mkdir()
    for name in ['SignedModSpec.t.sol', 'Concrete.t.sol']:
        shutil.copy(HERE / name, work / 'spec' / name)
        shutil.copy(HERE / name, output / (name + '.txt'))
    shutil.copy(HERE / 'foundry.toml', work / 'foundry.toml')
    shutil.copy(args.solc, work / 'solc')
    shutil.copy(Path(__file__), output / 'runner-used.py.txt')
    manifest = dict(workDirectory=str(work), sourceSha256=sha(original.encode()),
                    compiler=build['solcLongVersion'], solcSha256=sha(args.solc.read_bytes()),
                    forgeVersion=subprocess.check_output(['forge', '--version'], text=True).strip(),
                    status='incomplete', checks=[])

    def compile_runtime():
        result = subprocess.run([str(args.solc), '--standard-json'], input=json.dumps(compiler_input),
                                capture_output=True, text=True, timeout=60, check=True)
        compiled = json.loads(result.stdout)
        errors = [e for e in compiled.get('errors', []) if e['severity'] == 'error']
        assert not errors, errors
        return '0x' + compiled['contracts'][source_name]['Operations']['evm']['deployedBytecode']['object']

    def exercise(name, runtime):
        (work / 'spec/OperationsRuntime.sol').write_text(
            '// SPDX-License-Identifier: MIT\npragma solidity 0.8.36;\n'
            'library OperationsRuntime { function code() internal pure returns(bytes memory) '
            '{ return hex"' + runtime[2:] + '"; } }\n')
        (output / (name + '-runtime.hex')).write_text(runtime + '\n')
        command = ['forge', 'test', '--match-contract', 'Concrete', '--fuzz-runs', '256',
                   '--fuzz-seed', '0x1352a31', '-vv']
        result = subprocess.run(command, cwd=work, capture_output=True, text=True, timeout=60)
        log = result.stdout + result.stderr
        (output / (name + '.log')).write_text(log)
        manifest['checks'].append(dict(name=name, command=command, exitCode=result.returncode,
            runtimeSha256=sha(bytes.fromhex(runtime[2:])), logSha256=sha(log.encode())))
        return result.returncode, log

    baseline = compile_runtime()
    assert baseline == artifact['deployedBytecode'], 'Independent compiler invocation changed the canonical runtime'
    code, log = exercise('baseline', baseline)
    assert code == 0 and '5 tests passed, 0 failed, 0 skipped' in log
    mutations = []
    mutant = original
    for operation in ['addMod', 'mulMod']:
        signature = f'function {operation}(int256 a, int256 b, int256 m) external pure returns (int256) {{'
        assert mutant.count(signature) == 1
        replacement = signature + '\n        if (m == 0) return 0;'
        mutant = mutant.replace(signature, replacement)
        mutations.append(dict(before=signature, after=replacement))
    compiler_input['sources'][source_name]['content'] = mutant
    (output / 'mutant-Operations.sol.txt').write_text(mutant)
    mutant_runtime = compile_runtime()
    code, log = exercise('accept-zero-mutant', mutant_runtime)
    assert code != 0 and '3 tests passed, 2 failed, 0 skipped' in log
    assert '[FAIL:' in log and 'testFuzz_addZeroModulus' in log and 'testFuzz_mulZeroModulus' in log
    manifest.update(status='passed', baselineTests=5, fuzzCases=1024, fixedWitnesses=4,
                    mutantFailedTests=2, mutations=mutations, mutantSourceSha256=sha(mutant.encode()))
    (output / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(manifest, indent=2))


if __name__ == '__main__':
    main()
