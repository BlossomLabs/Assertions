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
    # Bind the proof's explicit error bytes to solc's selector computation.
    error_selectors={n['name']:n['errorSelector'] for n in contract['nodes'] if n.get('nodeType')=='ErrorDefinition'}
    def byte_constant(path,name):
        pattern=r'function '+name+r'\(\): seq<Byte> \{ \[([^\]]+)\] \}'
        match=re.search(pattern,path.read_text())
        if not match:raise ValueError('Unsupported selector definition '+name)
        return bytes(int(x.strip(),0) for x in match[1].split(',')).hex()
    for error,path,name in [('InvalidNode',HERE/'Model.dfy','NodeSelector'),('InvalidReference',HERE/'Model.dfy','ReferenceSelector'),('SubcallOutOfGas',root/'formal/resolution/Model.dfy','Signal')]:
        if byte_constant(path,name)!=error_selectors[error]:raise ValueError('Error selector projection drift '+error)
    functions={n['name']:nav.normalized_form(n) for n in contract['nodes'] if n.get('name') in {'_evaluate','_address','_rejectOutOfGas'}}
    for n in nav.shape.walk(functions):
        if 'overloadedDeclarations' in n:n['overloadedDeclarations']=['declaration']*len(n['overloadedDeclarations'])
    slots={}
    def op(function,predicate,key,allowed):
        nodes=[n for n in nav.shape.walk(functions[function]) if n.get('nodeType')=='BinaryOperation' and predicate(n)]
        if len(nodes)!=1 or nodes[0]['operator'] not in allowed:raise ValueError('Unsupported slot '+key)
        slots[key]=nodes[0]['operator'];nodes[0]['operator']={'slot':key}
    op('_evaluate',lambda n:n['leftExpression'].get('name')=='parameter' and n['rightExpression'].get('memberName')=='length','PARAMETER_BOUND',{'>=','>'})
    op('_address',lambda n:n['leftExpression'].get('nodeType')=='FunctionCall','ADDRESS_BOUND',{'>','>='})
    op('_evaluate',lambda n:n['leftExpression'].get('nodeType')=='FunctionCall' and n['leftExpression'].get('expression',{}).get('memberName')=='word','TRUTH_OPERATOR',{'!=','=='})
    op('_rejectOutOfGas',lambda n:n['operator'] in {'||','&&'},'GUARD_OPERATOR',{'||','&&'})
    structure={'functions':functions,'typesAndErrors':[nav.normalized_form(n) for n in contract['nodes'] if n.get('nodeType') in {'StructDefinition','EnumDefinition','ErrorDefinition'}]}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported scalar source drift')
    out.mkdir(parents=True,exist_ok=True)
    text=(HERE/'Source.template.dfy').read_text().replace('$HASH',hashlib.sha256(sources['contracts/Expressions.sol'].encode()).hexdigest())
    for key,value in slots.items():text=text.replace('$'+key,value)
    if '$' in text:raise ValueError('Template expansion failed')
    (out/'Source.generated.dfy').write_text(text)
    (out/'mapping.json').write_text(json.dumps({'scope':'Selected scalar leaf/address/truth/Boolean/guard paths; complete _evaluate AST gated but recursion is covered separately','translatedSlots':slots,'errorSelectors':error_selectors,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
