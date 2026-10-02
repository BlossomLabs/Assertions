#!/usr/bin/env python3
"""Gate complete Math.invMod and compiler target of its reached ternary helper."""
import argparse,copy,gzip,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('muldiv',HERE.parent/'full-mul-div/generate.py');dep=importlib.util.module_from_spec(spec);spec.loader.exec_module(dep)
SOURCES=dep.SOURCES
def expr(node):
    if node.get("nodeType")=="BinaryOperation" and node["operator"]=="%":return "("+dep.expr(node["leftExpression"])+"%"+dep.expr(node["rightExpression"])+")"
    return dep.expr(node)

def generate(solc,root,out,bootstrap=False):
    out.mkdir(parents=True,exist_ok=True);helper=out/'muldiv-regenerated';dep.generate(solc,root,helper)
    for name in ['Control.generated.dfy','Helpers.generated.dfy']:
        if (helper/name).read_bytes()!=(HERE.parent/'full-mul-div'/name).read_bytes():raise ValueError('Reached ternary/helper source drift '+name)
    data=json.loads(gzip.decompress((helper/'solc-output.json.gz').read_bytes()))
    math=next(x for x in data['sources']['@openzeppelin/contracts/utils/math/Math.sol']['ast']['nodes'] if x.get('name')=='Math')
    f=copy.deepcopy(next(x for x in math['nodes'] if x.get('nodeType')=='FunctionDefinition' and x.get('name')=='invMod'))
    ternary=next(x for x in math['nodes'] if x.get('nodeType')=='FunctionDefinition' and x.get('name')=='ternary')
    body=f['body']['statements'][0]['statements'];loop=body[5]['body']['statements'];call=body[7]['expression']
    if call['expression'].get('name')!='ternary' or call['expression'].get('referencedDeclaration')!=ternary['id']:raise ValueError('Unbound reached ternary call')
    slots={}
    for name,node in [('ZERO',body[0]['condition']),('REMAINDER',body[1]['initialValue']),('GCD',body[2]['initialValue']),('X',body[3]['initialValue']),('Y',body[4]['initialValue']),('LOOP',body[5]['condition']),('QUOTIENT',loop[0]['initialValue']),('NO_INVERSE',body[6]['condition'])]:slots[name]=expr(node)
    for index,key in [(1,'NEXT_GCD'),(2,'NEXT_X')]:
        pair=loop[index]['expression']['rightHandSide']['components'];slots[key]=dep.expr(pair[0]);slots['NEXT_REMAINDER' if index==1 else 'NEXT_Y']=dep.expr(pair[1])
    loop[2]['expression']['rightHandSide']['components'][1]={'translated-slot':'NEXT_Y'}
    slots['RETURN_ARGUMENTS']=','.join(dep.expr(a) for a in call['arguments'])
    shape=dep.form(f)
    if bootstrap:(HERE/'inverse-structure.json').write_text(json.dumps(shape,indent=2)+'\n');return
    if shape!=json.loads((HERE/'inverse-structure.json').read_text()):raise ValueError('Complete invMod AST drift')
    code=(HERE/'Inverse.template.dfy').read_text()
    for name,value in slots.items():code=code.replace('$'+name+'$',value)
    if '$' in code:raise ValueError('Unexpanded slot')
    (out/'Inverse.generated.dfy').write_text(code);(out/'inverse-mapping.json').write_text(json.dumps({'slots':slots,'helperBinding':{'callee':'Math.ternary','compilerDeclaration':ternary['id']}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
