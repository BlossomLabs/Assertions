#!/usr/bin/env python3
"""Bind callback selectors and ABI argument types to fresh solc output."""
import argparse,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
EXPECTED={'InvalidCallback':[],'InvalidCallbackTarget':['address'],'SubcallOutOfGas':[],'CallbackFailed':['bytes4','uint256','uint256','address','bytes','bytes'],'InvalidCallbackResult':['bytes4','uint256','uint256','address']}
def walk(v):
    if isinstance(v,dict):
        yield v
        for x in v.values():yield from walk(x)
    elif isinstance(v,list):
        for x in v:yield from walk(x)
def generate(solc,root,out):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
    texts={n:(root/n).read_text() for n in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{n:{'content':t} for n,t in texts.items()},'settings':{'outputSelection':{'*':{'':['ast'],'*':['abi','evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),text=True,capture_output=True,check=True);ast=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in ast.get('errors',[])):raise ValueError(ast['errors'])
    contracts=ast['contracts']['contracts/Collections.sol'];abi=contracts['Collections']['abi']
    actual={e['name']:[a['type'] for a in e['inputs']] for e in abi if e['type']=='error' and e['name'] in EXPECTED}
    if actual!=EXPECTED:raise ValueError('Callback error signature drift')
    selectors={n['name']:n['errorSelector'] for n in walk(ast['sources']) if n.get('nodeType')=='ErrorDefinition' and n['name'] in EXPECTED}
    expression=contracts['IExpressions']['evm']['methodIdentifiers'];signature='evaluateEncoded(bytes,bytes[])'
    if set(expression)!={signature}:raise ValueError('Callback interface drift')
    def seq(h):return '['+','.join('0x'+h[i:i+2] for i in range(0,len(h),2))+']'
    code='// SPDX-License-Identifier: MIT\n// Generated from fresh solc AST and interface method identifiers.\ninclude "../../abi/Frames.dfy"\n\nmodule CollectionsWireSignatures {\n  import opened AbiFrames\n'
    for n in sorted(EXPECTED):code+='  function '+n+'(): seq<Byte>\n    ensures |'+n+'()| == 4\n  { '+seq(selectors[n])+' }\n'
    code+='  function Evaluate(): seq<Byte>\n    ensures |Evaluate()| == 4\n  { '+seq(expression[signature])+' }\n}\n'
    out.mkdir(parents=True,exist_ok=True);(out/'Signatures.generated.dfy').write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'errors':EXPECTED,'selectors':selectors,'expression':expression,'sourceSha256':{n:hashlib.sha256(t.encode()).hexdigest() for n,t in texts.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.solc,a.root,a.output)
