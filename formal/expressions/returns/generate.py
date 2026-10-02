#!/usr/bin/env python3
"""Gate both public evaluation raw-return tails and translate their pointer offsets."""
import argparse,gzip,hashlib,importlib.util,json,re,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('nav',ROOT/'formal/navigation/generate.py')
nav=importlib.util.module_from_spec(spec);spec.loader.exec_module(nav)

def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Unpinned solc')
    sources={p:(root/p).read_text() for p in ['contracts/Expressions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);ast=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in ast.get('errors',[])):raise ValueError('Compiler error')
    contract=next(n for n in ast['sources']['contracts/Expressions.sol']['ast']['nodes'] if n.get('name')=='Expressions')
    functions={n['name']:nav.normalized_form(n) for n in contract['nodes'] if n.get('name') in {'evaluate','evaluateEncoded'}}
    for n in nav.shape.walk(functions):
        if 'overloadedDeclarations' in n:n['overloadedDeclarations']=['declaration']*len(n['overloadedDeclarations'])
    slots={}
    for function,slot in [('evaluate','EVALUATE_OFFSET'),('evaluateEncoded','ENCODED_OFFSET')]:
        returns=[n for n in nav.shape.walk(functions[function]) if n.get('nodeType')=='YulFunctionCall' and n.get('functionName',{}).get('name')=='return']
        if len(returns)!=1:raise ValueError('Ambiguous raw return '+function)
        node=returns[0];args=node['arguments']
        if len(args)!=2 or args[0].get('functionName',{}).get('name')!='add' or args[1].get('functionName',{}).get('name')!='mload':raise ValueError('Unsupported return geometry')
        addition=args[0]['arguments'];load=args[1]['arguments']
        if len(addition)!=2 or addition[0].get('name')!='result' or len(load)!=1 or load[0].get('name')!='result':raise ValueError('Unsupported return base')
        offset=addition[1]
        if offset.get('nodeType')!='YulLiteral' or offset.get('value') not in {'0','32'}:raise ValueError('Unsupported return offset')
        slots[slot]=offset['value'];addition[1]={'slot':slot}
    structure={'functions':functions,'typesAndErrors':[nav.normalized_form(n) for n in contract['nodes'] if n.get('nodeType') in {'StructDefinition','EnumDefinition','ErrorDefinition'}]}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported call source drift')
    out.mkdir(parents=True,exist_ok=True)
    text=(HERE/'Source.template.dfy').read_text().replace('$HASH',hashlib.sha256(sources['contracts/Expressions.sol'].encode()).hexdigest())
    for key,value in slots.items():text=text.replace('$'+key,value)
    if '$' in text:raise ValueError('Template expansion failed')
    (out/'Source.generated.dfy').write_text(text)
    (out/'mapping.json').write_text(json.dumps({'scope':'evaluate/evaluateEncoded full AST gate; only final memory return tails lowered here; compiler memory-object and nonwrapping-pointer projections explicit','translatedSlots':slots,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
