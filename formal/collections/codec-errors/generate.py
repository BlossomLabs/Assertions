#!/usr/bin/env python3
"""Bind codec error selectors and field kinds to fresh solc output."""
import argparse,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
EXPECTED={'InvalidValue':['uint256'],'InvalidComponentValue':['uint256','uint256'],'InvalidComponentLength':['uint256','uint256','uint256'],'InvalidComponentEnvelope':['uint256','uint256','bytes32'],'ComponentCountMismatch':['uint256','uint256'],'InvalidCallbackResult':['bytes4','uint256','uint256','address'],'InvalidTypeDescriptor':['uint256']}
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
    contracts=ast['contracts']['contracts/Collections.sol'];abi=ast['contracts']['contracts/lib/AbiCodec.sol']['AbiCodec']['abi']+contracts['Collections']['abi']
    actual={}
    for e in abi:
        if e['type']=='error' and e['name'] in EXPECTED:
            fields=[a['type'] for a in e['inputs']]
            if e['name'] in actual and actual[e['name']]!=fields:raise ValueError('Inconsistent ABI error')
            actual[e['name']]=fields
    if actual!=EXPECTED:raise ValueError('Codec error signature drift: '+repr(actual))
    selectors={n['name']:n['errorSelector'] for n in walk(ast['sources']) if n.get('nodeType')=='ErrorDefinition' and n['name'] in EXPECTED}
    if set(selectors)!=set(EXPECTED):raise ValueError('Missing AST error selector')
    expression=contracts['IExpressions']['evm']['methodIdentifiers'];signature='evaluateEncoded(bytes,bytes[])'
    if set(expression)!={signature}:raise ValueError('Callback interface drift')
    def seq(h):return '['+','.join('0x'+h[i:i+2] for i in range(0,len(h),2))+']'
    code='// SPDX-License-Identifier: MIT\n// Generated from fresh solc AST and interface method identifiers.\ninclude "../../abi/Frames.dfy"\n\nmodule CollectionsCodecErrorSignatures {\n  import opened AbiFrames\n'
    tags={'uint256':'U','address':'Address','bytes4':'Four','bytes32':'Word'}
    code+='  datatype Tag = U | Address | Four | Word\n'
    for n in sorted(EXPECTED):
        code+='  function '+n+'(): seq<Byte>\n    ensures |'+n+'()| == 4\n  { '+seq(selectors[n])+' }\n'
        code+='  function '+n+'Types(): seq<Tag> { ['+','.join(tags[t] for t in EXPECTED[n])+'] }\n'
    code+='  function Panic(): seq<Byte>\n    ensures |Panic()| == 4\n  { [0x4e,0x48,0x7b,0x71] }\n  function PanicTypes(): seq<Tag> { [U] }\n}\n'
    out.mkdir(parents=True,exist_ok=True);(out/'Signatures.generated.dfy').write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'errors':EXPECTED,'selectors':selectors,'expression':expression,'sourceSha256':{n:hashlib.sha256(t.encode()).hexdigest() for n,t in texts.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.solc,a.root,a.output)
