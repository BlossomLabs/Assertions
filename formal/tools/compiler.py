"""Reproduce the complete runtime with the pinned native Solidity compiler."""
import hashlib
import json
import subprocess

import evidence


def reproduce(root, solc, output):
    lock = json.loads((root / 'formal/dependencies/dafnyevm/tools.json').read_text())
    assert evidence.sha(solc) == lock['solcSha256'], 'Modified Solidity compiler'
    version = subprocess.check_output([str(solc), '--version'], text=True)
    assert '0.8.36+commit.8a079791' in version, 'Wrong Solidity compiler'
    binding = json.loads((root / 'formal/contracts/Operations/runtime.json').read_text())
    data = json.loads((root / 'formal/.generated/solc-input.json').read_text())
    canonical = json.dumps(data, sort_keys=True, separators=(',', ':')).encode()
    assert hashlib.sha256(canonical).hexdigest() == binding['inputSha256'], 'Stale compiler input'
    assert {p: hashlib.sha256(s['content'].encode()).hexdigest() for p, s in data['sources'].items()} == binding['sources'], 'Stale compiler source binding'
    assert data['settings']['optimizer'] == {'enabled': True, 'runs': 200} and data['settings']['evmVersion'] == 'cancun'
    command = [str(solc), '--standard-json']
    with (output / 'compiler-input.json').open('w') as input:
        json.dump(data, input)
    with (output / 'compiler-input.json').open() as input, (output / 'compiler-output.json').open('w') as log:
        process = subprocess.run(command, stdin=input, stdout=log, stderr=subprocess.PIPE, text=True)
    (output / 'compiler-stderr.log').write_text(process.stderr)
    result = json.loads((output / 'compiler-output.json').read_text())
    errors = [x for x in result.get('errors', []) if x['severity'] == 'error']
    assert process.returncode == 0 and not errors, 'Solidity reproduction failed'
    code = bytes.fromhex(result['contracts']['project/contracts/Operations.sol']['Operations']['evm']['deployedBytecode']['object'])
    assert hashlib.sha256(code).hexdigest() == binding['runtimeSha256'], 'Reproduced runtime differs, including metadata'
    assert code.hex() == (root / 'formal/.generated/Operations.runtime.hex').read_text().strip(), 'Stale runtime literal bytes'
    return {'gate': 'compiler', 'command': command, 'exitCode': process.returncode, 'passed': True,
            'compilerSha256': evidence.sha(solc), 'runtimeSha256': binding['runtimeSha256']}
