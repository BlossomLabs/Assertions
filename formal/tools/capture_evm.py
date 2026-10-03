"""Compile the frozen current Assertions source closure into fresh evidence."""
import argparse
import json
import re
from declarations import declarations
import subprocess
from pathlib import Path
from check import ROOT, LIBRARY, digest

BINDING = LIBRARY/'bytecode/dafnyevm/runtime-binding.json'


def capture(output):
    binding = json.loads(BINDING.read_text())
    assert not output.exists(), 'Runtime capture must be fresh'
    for relative, expected in binding['sources'].items():
        assert digest(ROOT/relative) == expected, 'Runtime source drift: '+relative
    compiler = ROOT/'proof-tools/assertions/solc-0.8.36'
    assert digest(compiler) == binding['compilerSha256'], 'Compiler drift'
    request = {'language':'Solidity','sources':{
        'project/'+relative:{'content':(ROOT/relative).read_text()}
        for relative in binding['sources']},'settings':binding['settings']}
    output.mkdir(parents=True)
    (output/'solc-input.json').write_text(json.dumps(request,indent=2)+'\n')
    with (output/'solc-input.json').open() as stdin, (output/'solc-output.json').open('w') as stdout:
        subprocess.run([str(compiler),'--standard-json'],stdin=stdin,stdout=stdout,check=True,cwd=ROOT)
    compiled = json.loads((output/'solc-output.json').read_text())
    assert not any(e.get('severity') == 'error' for e in compiled.get('errors',[])), 'Compiler errors'
    runtime = bytes.fromhex(compiled['contracts']['project/contracts/Assertions.sol']['Assertions']['evm']['deployedBytecode']['object'])
    import hashlib
    assert hashlib.sha256(runtime).hexdigest() == binding['runtimeSha256'], 'Exact runtime drift'
    proof = declarations(LIBRARY/'bytecode/dafnyevm/Helpers.dfy')['Window']['body']
    assert re.fullmatch(r'[\s{}\[\],+0-9]+',proof), 'Unsupported instruction window syntax'
    proof_bytes = bytes(int(n) for n in re.findall(r'\d+',proof))
    assert proof_bytes.hex() == binding['windows'][0]['hex'], 'Proof/runtime window mismatch'
    for window in binding['windows']:
        assert runtime[window['start']:window['end']].hex() == window['hex'], 'Instruction window drift'
    (output/'runtime.hex').write_text(runtime.hex()+'\n')
    result = dict(binding, inputsSha256=digest(output/'solc-input.json'), outputSha256=digest(output/'solc-output.json'))
    (output/'manifest.json').write_text(json.dumps(result,indent=2)+'\n')
    assert digest(compiler) == binding['compilerSha256'], 'Compiler changed during capture'
    assert all(digest(ROOT/p) == h for p,h in binding['sources'].items()), 'Source changed during capture'
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args()
    capture(args.output.resolve())
    print('PASS current compiler/source binding and exact helper runtime.')
