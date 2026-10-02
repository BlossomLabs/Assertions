#!/usr/bin/env python3
"""Gate complete rpow body/selector and freshly regenerate its full mulDiv helper source graph."""
import argparse,copy,gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('muldiv',HERE.parent/'full-mul-div/generate.py');dep=importlib.util.module_from_spec(spec);spec.loader.exec_module(dep)
SOURCES=dep.SOURCES

def expr(node):
    if node.get('nodeType')=='BinaryOperation' and node['operator']=='>>':return '('+expr(node['leftExpression'])+'/B.Power('+str(dep.literal(node['rightExpression']))+'))'
    if node.get('nodeType')=='BinaryOperation':
        a,b=expr(node['leftExpression']),expr(node['rightExpression']);op=node['operator']
        if op=='&':return 'I.And('+a+','+b+')'
        if op in {'==','!=','>','<','>=','<='}:return '('+a+' '+op+' '+b+')'
    if node.get('nodeType')=='Conditional':return '(if '+expr(node['condition'])+' then '+expr(node['trueExpression'])+' else '+expr(node['falseExpression'])+')'
    return dep.expr(node)

def generate(solc,root,out,bootstrap=False):
    out.mkdir(parents=True,exist_ok=True);helper=out/'muldiv-regenerated';dep.generate(solc,root,helper)
    for name in ['Control.generated.dfy','Helpers.generated.dfy']:
        if (helper/name).read_bytes()!=(HERE.parent/'full-mul-div'/name).read_bytes():raise ValueError('Reached helper source regeneration drift '+name)
    data=json.loads(gzip.decompress((helper/'solc-output.json.gz').read_bytes()))
    ops=next(x for x in data['sources']['contracts/Operations.sol']['ast']['nodes'] if x.get('name')=='Operations')
    math=next(x for x in data['sources']['@openzeppelin/contracts/utils/math/Math.sol']['ast']['nodes'] if x.get('name')=='Math')
    f=copy.deepcopy(next(x for x in ops['nodes'] if x.get('nodeType')=='FunctionDefinition' and x.get('name')=='rpow'))
    helperid=next(x['id'] for x in math['nodes'] if x.get('nodeType')=='FunctionDefinition' and x.get('name')=='mulDiv' and len(x['parameters']['parameters'])==3)
    panicid=next(x['id'] for x in ops['nodes'] if x.get('name')=='_panic')
    bindings=[]
    def bind(node):
        if isinstance(node,list):
            for x in node:bind(x)
        elif isinstance(node,dict):
            if node.get('nodeType')=='FunctionCall' and node.get('kind')=='functionCall':
                c=node['expression'];name=c.get('name') or c.get('memberName')
                if name=='_panic':expected=panicid
                elif name=='mulDiv' and c.get('expression',{}).get('name')=='Math':expected=helperid
                else:raise ValueError('Unbound reached call '+str(c))
                if c.get('referencedDeclaration')!=expected:raise ValueError('Reached helper target mismatch')
                bindings.append({'callee':name,'compilerDeclaration':expected})
            for v in node.values():bind(v)
    bind(f)
    signature='rpow(uint256,uint256,uint256)';selector=data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][signature]
    if selector!=f['functionSelector']:raise ValueError('Compiler selector disagreement')
    slots={};body=f['body']['statements'];loop=body[3]['body']['statements']
    for name,value in [('BASE_ZERO',body[0]['condition']),('X_ZERO',body[1]['condition']),('ZERO_RESULT',body[1]['trueBody']['expression']),('INITIAL',body[2]['initialValue']),('LOOP',body[3]['condition']),('SELECTED',loop[0]['condition']),('REMAINING',loop[2]['condition']),('RETURN',body[4]['expression'])]:slots[name]=expr(value)
    for name,node in [('SELECT_ARGUMENTS',loop[0]['trueBody']['statements'][0]['expression']['rightHandSide']),('SQUARE_ARGUMENTS',loop[2]['trueBody']['statements'][0]['expression']['rightHandSide'])]:
        slots[name]=','.join(expr(a) for a in node['arguments']);node['arguments']={'translated-slot':name}
    shift=loop[1]['expression'];slots['SHIFT']='('+expr(shift['leftHandSide'])+'/B.Power('+str(dep.literal(shift['rightHandSide']))+'))';shift['rightHandSide']={'translated-slot':'SHIFT'}
    shape=dep.form(f);entries=[{'signature':signature,'selector':selector,'symbol':'Run'}]
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(shape,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if shape!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete rpow AST/selector drift')
    code=(HERE/'Control.template.dfy').read_text()
    for name,value in slots.items():code=code.replace('$'+name+'$',value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    (out/'Control.generated.dfy').write_text(code);(out/'mapping.json').write_text(json.dumps({'entries':entries,'slots':slots,'helperBindings':bindings,'sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
