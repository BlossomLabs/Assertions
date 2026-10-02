#!/usr/bin/env python3
"""Source gate for the production guarded dispatch boundary."""
import argparse, gzip, hashlib, importlib.util, json, subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('navigation', ROOT/'formal/navigation/generate.py')
nav=importlib.util.module_from_spec(spec);spec.loader.exec_module(nav)

def generate(solc,root,out,bootstrap=False):
    sources={p:(root/p).read_text() for p in ['contracts/Expressions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True)
    ast=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in ast.get('errors',[])):raise ValueError('Compiler error')
    contract=next(n for n in ast['sources']['contracts/Expressions.sol']['ast']['nodes'] if n.get('name')=='Expressions')
    identities={n['id']:[path,n.get('nodeType'),n.get('name')] for path,s in ast['sources'].items() for n in nav.shape.walk(s['ast']) if 'id' in n}
    for key in ['linearizedBaseContracts','usedErrors','usedEvents']:
        if key in contract:contract[key]=[identities[i] for i in contract[key]]
    contract=nav.normalized_form(contract)
    # Compiler allocated overload identifiers are not semantic source values.
    for n in nav.shape.walk(contract):
        if 'overloadedDeclarations' in n:n['overloadedDeclarations']=['declaration']*len(n['overloadedDeclarations'])
    slots={}
    for name,key,arg in [('_call','CALL_CHECK','data'),('_probe','PROBE_CHECK','callData')]:
        f=next(n for n in contract['nodes'] if n.get('name')==name)
        statements=f['body']['statements']; first=statements[0]
        checks=[n for n in nav.shape.walk(f) if n.get('nodeType')=='FunctionCall' and n.get('expression',{}).get('name')=='_checkPublicCall']
        slots[key]='true'
        if checks:
            if len(checks)!=1 or first.get('nodeType')!='ExpressionStatement' or first.get('expression')!=checks[0]:raise ValueError('Check must be first')
            call=checks[0]
            if [n.get('name') for n in call['arguments']]!=['target',arg]:raise ValueError('Check arguments drift')
            slots[key]='CheckPublicCall(r.selfTarget, r.data, selector)'
            statements.pop(0)
    structure=HERE/'structure.json'
    if bootstrap:
        structure.write_text(json.dumps(contract,indent=2)+'\n');return
    if contract!=json.loads(structure.read_text()):raise ValueError('Unsupported candidate AST drift')
    out.mkdir(parents=True,exist_ok=True)
    text=(HERE/'Source.template.dfy').read_text().replace('$HASH',hashlib.sha256(sources['contracts/Expressions.sol'].encode()).hexdigest())
    for key,value in slots.items():text=text.replace('$'+key,value)
    if '$' in text:raise ValueError('Template expansion failed')
    (out/'Source.generated.dfy').write_text(text)
    (out/'Model.dfy').write_bytes((HERE/'Model.dfy').read_bytes())
    (out/'mapping.json').write_text(json.dumps({'scope':'Candidate dispatch boundary only','translatedSlots':slots,'sourceSha256':{p:hashlib.sha256(s.encode()).hexdigest() for p,s in sources.items()}},indent=2)+'\n')
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
