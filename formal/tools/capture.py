"""Capture the exact Hardhat production artifact and the public ABI inventory."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACTS = ('Assertions', 'Operations', 'Collections', 'Expressions')

def digest(data):
    return hashlib.sha256(data).hexdigest()

def canonical(data):
    return json.dumps(data, sort_keys=True, separators=(',', ':')).encode()

def abi_type(parameter):
    value = parameter['type']
    if value.startswith('tuple'):
        return '(' + ','.join(abi_type(c) for c in parameter['components']) + ')' + value[5:]
    return value

def runtime_source(code):
    runtime = 'include "../../proof-tools/dafnyevm/src/dafny/core/code.dfy"\nmodule OperationsRuntime {\n  import opened Int\n'
    for value in range(256):
        runtime += f'  const Byte{value:02x}: u8 := 0x{value:02x}\n'
    names=[]
    for i in range(0,len(code),256):
        name=f'Chunk{i//256:03d}'
        names.append(name+'()')
        chunk=code[i:i+256]
        def literal(parts):
            if len(parts)==1: return parts[0]
            n=len(parts)//2
            return '('+literal(parts[:n])+' + '+literal(parts[n:])+')'
        pieces=['[ '+','.join(f'Byte{x:02x}' for x in chunk[j:j+16])+' ]'
                for j in range(0,len(chunk),16)]
        runtime += f'  opaque function {name}(): (data: seq<u8>)\n    ensures |data| == {len(chunk)}\n  {{ '+literal(pieces)+' }\n'
    paths = {}
    nodes = []
    def balanced(parts, indices):
        if len(parts)==1:
            paths[indices[0]] = []
            return parts[0], min(256,len(code)-indices[0]*256), [indices[0]]
        n=len(parts)//2
        left,left_size,left_indices=balanced(parts[:n],indices[:n])
        right,right_size,right_indices=balanced(parts[n:],indices[n:])
        name=f'Node{len(nodes):03d}'
        size=left_size+right_size
        nodes.append(f'  opaque function {name}(): (data: seq<u8>)\n    ensures |data| == {size}\n  {{ {left} + {right} }}\n')
        for index in left_indices+right_indices: paths[index].append(name)
        return name+'()',size,left_indices+right_indices
    top,_,_=balanced(names,list(range(len(names))))
    runtime += ''.join(nodes)
    runtime += f'  opaque function Code(): (code: seq<u8>)\n    ensures |code| == {len(code)}\n  {{ {top} }}\n'
    for i in range(len(names)):
        start=i*256;end=min(start+256,len(code))
        runtime += f'  lemma Window{i:03d}()\n    ensures Code()[{start}..{end}] == Chunk{i:03d}()\n  {{\n    reveal Code();\n'
        for name in reversed(paths[i]): runtime += f'    reveal {name}();\n'
        runtime += '  }\n'
    runtime += '}\n'
    return runtime

def capture(update=False):
    artifacts = {name: json.loads((ROOT/f'artifacts/contracts/{name}.sol/{name}.json').read_text())
                 for name in CONTRACTS}
    candidates = []
    for path in (ROOT/'artifacts/build-info').glob('*.json'):
        data = json.loads(path.read_text())
        if 'input' in data and 'project/contracts/Operations.sol' in data['input']['sources']:
            output = json.loads(path.with_name(path.stem+'.output.json').read_text())['output']
            contract = output['contracts']['project/contracts/Operations.sol']['Operations']
            if contract['evm']['deployedBytecode']['object'] == artifacts['Operations']['deployedBytecode'][2:]:
                candidates.append((data, output))
    assert len(candidates) == 1, 'Missing or ambiguous production build info'
    build, output = candidates[0]
    settings = build['input']['settings']
    assert build['solcVersion'] == '0.8.36'
    assert settings['evmVersion'] == 'cancun' and settings['optimizer'] == {'enabled': True, 'runs': 200}
    code = bytes.fromhex(artifacts['Operations']['deployedBytecode'][2:])
    assert len(code) <= 24576
    binding = {'schemaVersion': 1, 'contract': 'Operations', 'compiler': build['solcLongVersion'],
               'settings': settings, 'inputSha256': digest(canonical(build['input'])),
               'runtimeSha256': digest(code), 'runtimeBytes': len(code),
               'metadataBytes': int.from_bytes(code[-2:], 'big')+2,
               'sources': {p: digest(s['content'].encode()) for p,s in build['input']['sources'].items()},
               'localSources': {str(p.relative_to(ROOT)): digest(p.read_bytes())
                                for p in sorted((ROOT/'contracts').rglob('*.sol'))
                                if '/tests/' not in str(p)},
               'generatedRuntime': 'formal/.generated/OperationsRuntime.dfy',
               'artifact': 'artifacts/contracts/Operations.sol/Operations.json'}
    generated = ROOT/'formal/.generated'
    generated.mkdir(parents=True, exist_ok=True)
    (generated/'Operations.runtime.hex').write_text(code.hex()+'\n')
    (generated/'solc-input.json').write_text(json.dumps(build['input'])+'\n')
    runtime = runtime_source(code)
    (generated/'OperationsRuntime.dfy').write_text(runtime)
    catalog = []
    for name in CONTRACTS:
        identifiers = output['contracts'][f'project/contracts/{name}.sol'][name]['evm']['methodIdentifiers']
        for fn in artifacts[name]['abi']:
            if fn['type'] != 'function': continue
            signature = fn['name']+'('+','.join(abi_type(p) for p in fn['inputs'])+')'
            active = name == 'Operations' and signature in ('add(uint256,uint256)', 'add(int256,int256)')
            entry = {'id': name+'.'+signature, 'contract': name, 'signature': signature,
                     'selector': '0x'+identifiers[signature], 'status': 'pending', 'theorems': [], 'evidence': []}
            if active:
                sign = 'Unsigned' if signature.startswith('add(uint') else 'Signed'
                entry.update(status='implemented-unverified', proofHome='formal/contracts/Operations/add',
                             theorems=[{'file': f'formal/contracts/Operations/add/{sign}.dfy',
                                        'entrypoint': f'Operations{sign}Add.VerifyAdd'}],
                             runtimeBinding='formal/contracts/Operations/runtime.json',
                             premises=['PC 0','complete runtime','empty stack and memory','canonical 68-byte calldata',
                                       'zero call value','sufficient execution gas'],
                             claims=[{'id':'O1','coverage':'partial; addition overload only'}])
            catalog.append(entry)
    assert len(catalog) == 141, f'Public ABI changed: {len(catalog)} signatures'
    catalog = {'schemaVersion':1, 'functions':sorted(catalog,key=lambda x:x['id']), 'sharedTheorems':[]}
    for relative, data in [('formal/contracts/Operations/runtime.json',binding),('formal/catalog.json',catalog)]:
        path = ROOT/relative
        if update:
            path.parent.mkdir(parents=True,exist_ok=True)
            path.write_text(json.dumps(data,indent=2)+'\n')
        else:
            stored = json.loads(path.read_text())
            if relative == 'formal/catalog.json':
                identity = lambda f: (f['id'], f['contract'], f['signature'], f['selector'])
                assert sorted(map(identity, stored['functions'])) == sorted(map(identity, data['functions'])), 'Stale public ABI inventory'
            else:
                assert stored == data, 'Stale binding: '+relative
    return binding

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--update', action='store_true')
    args = parser.parse_args()
    print(json.dumps(capture(args.update),indent=2))
