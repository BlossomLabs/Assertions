#!/usr/bin/env python3
"""Gate encoded graph entrypoint, wire types and selectors."""
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
    vocabulary={n.get('name'):n for n in contract['nodes']}
    for name,members in {'Kind':['Literal','Parameter','Resolve','Call','Select','Wrap','Array','Tuple','TryOrElse','IsValid','ProbeCall']}.items():
        if [m['name'] for m in vocabulary[name]['members']]!=members:raise ValueError('Enum wire drift '+name)
    for name,members in {'Expression':['core','nodes','result'],'Node':['kind','valueType','data','refs','selector','arguments']}.items():
        if [m['name'] for m in vocabulary[name]['members']]!=members:raise ValueError('Struct wire drift '+name)
    for name,fn in [('evaluate','EvaluateSelector'),('evaluateGuarded','GuardSelector')]:
        m=re.search(r'function '+fn+r'\(\): seq<Byte> \{ \[([^\]]+)\] \}',(root/'formal/expressions/encoded/Model.dfy').read_text())
        if not m or bytes(int(x.strip(),0) for x in m[1].split(',')).hex()!=vocabulary[name]['functionSelector']:raise ValueError('Selector drift '+name)
    functions={n['name']:nav.normalized_form(n) for n in contract['nodes'] if n.get('name') in {'evaluateEncoded'}}
    for n in nav.shape.walk(functions):
        if 'overloadedDeclarations' in n:n['overloadedDeclarations']=['declaration']*len(n['overloadedDeclarations'])
    slots={}
    nodes=[n for n in nav.shape.walk(functions['evaluateEncoded']) if n.get('nodeType')=='FunctionCall' and n.get('expression',{}).get('name')=='_call']
    if len(nodes)!=1:raise ValueError('Encoded dispatch ambiguity')
    value=nodes[0]['arguments'][2]
    if value.get('nodeType')!='Literal' or value.get('value') not in {'0','1'}:raise ValueError('Unsupported wrapper index')
    slots['NODE_INDEX']=value['value'];nodes[0]['arguments'][2]={'slot':'NODE_INDEX'}
    structure={'functions':functions,'typesAndErrors':[nav.normalized_form(n) for n in contract['nodes'] if n.get('nodeType') in {'StructDefinition','EnumDefinition','ErrorDefinition'}]}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported call source drift')
    out.mkdir(parents=True,exist_ok=True)
    text=(HERE/'Source.template.dfy').read_text().replace('$HASH',hashlib.sha256(sources['contracts/Expressions.sol'].encode()).hexdigest())
    for key,value in slots.items():text=text.replace('$'+key,value)
    if '$' in text:raise ValueError('Template expansion failed')
    (out/'Source.generated.dfy').write_text(text)
    (out/'mapping.json').write_text(json.dumps({'scope':'evaluateEncoded full AST gate; explicit decoder, canonical outgoing ABI projection and exact self-call error routing; raw-return memory is composed separately','translatedSlots':slots,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
