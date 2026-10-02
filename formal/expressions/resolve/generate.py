#!/usr/bin/env python3
"""Gate literal/parameter/address/truth/Boolean/guard source paths."""
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
    vocabulary={n.get('name'):n for n in ast['sources']['contracts/lib/ERC8211.sol']['ast']['nodes']}
    for name,members in {'InputParamType':['TARGET','VALUE','CALL_DATA'],'InputParamFetcherType':['RAW_BYTES','STATIC_CALL','BALANCE'],'ConstraintType':['EQ','GTE','LTE','IN','GTE_SIGNED','LTE_SIGNED','OR','SKIP','IN_SIGNED']}.items():
        if [m['name'] for m in vocabulary[name]['members']]!=members:raise ValueError('Enum wire drift '+name)
    for name,members in {'InputParam':['paramType','fetcherType','paramData','constraints'],'Constraint':['constraintType','referenceData']}.items():
        if [m['name'] for m in vocabulary[name]['members']]!=members:raise ValueError('Struct wire drift '+name)
    interface=next(n for n in ast['sources']['contracts/Expressions.sol']['ast']['nodes'] if n.get('name')=='ICore')
    resolve=next(n for n in interface['nodes'] if n.get('name')=='resolve')
    if len(resolve['parameters']['parameters'])!=1 or resolve['parameters']['parameters'][0]['typeDescriptions']['typeString']!='struct InputParam':raise ValueError('Resolve signature drift')
    functions={n['name']:nav.normalized_form(n) for n in contract['nodes'] if n.get('name') in {'_evaluate'}}
    for n in nav.shape.walk(functions):
        if 'overloadedDeclarations' in n:n['overloadedDeclarations']=['declaration']*len(n['overloadedDeclarations'])
    slots={}
    nodes=[n for n in nav.shape.walk(functions['_evaluate']) if n.get('nodeType')=='FunctionCall' and n.get('expression',{}).get('name')=='_call' and n.get('arguments',[{}])[0].get('memberName')=='core']
    if len(nodes)!=1:raise ValueError('Resolve dispatch ambiguity')
    value=nodes[0]['arguments'][2]
    if value.get('nodeType')=='Identifier' and value.get('name')=='index':slots['NODE_INDEX']='index'
    elif value.get('nodeType')=='Literal' and value.get('value')=='0':slots['NODE_INDEX']='0'
    else:raise ValueError('Unsupported Resolve node index')
    nodes[0]['arguments'][2]={'slot':'NODE_INDEX'}
    structure={'functions':functions,'typesAndErrors':[nav.normalized_form(n) for n in contract['nodes'] if n.get('nodeType') in {'StructDefinition','EnumDefinition','ErrorDefinition'}]}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported call source drift')
    out.mkdir(parents=True,exist_ok=True)
    text=(HERE/'Source.template.dfy').read_text().replace('$HASH',hashlib.sha256(sources['contracts/Expressions.sol'].encode()).hexdigest())
    for key,value in slots.items():text=text.replace('$'+key,value)
    if '$' in text:raise ValueError('Template expansion failed')
    (out/'Source.generated.dfy').write_text(text)
    (out/'mapping.json').write_text(json.dumps({'scope':'Resolve branch and explicit decoder/standard ABI projection; full _evaluate AST gated but recursion remains separate','translatedSlots':slots,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
