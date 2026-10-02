#!/usr/bin/env python3
"""Gate complete pairing bodies; lower checked controls, source indices and error selectors."""
import argparse,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:(['compiler-node-id']*len(v) if k=='overloadedDeclarations' else form(v)) for k,v in n.items() if k not in ignored}
def expr(n):
    kind=n['nodeType']
    if kind=='TupleExpression' and len(n['components'])==1:return expr(n['components'][0])
    if kind=='Identifier':return {'i':'i','lane':'lane','aw':'aw','bw':'bw','a':'a','b':'b','tail':'tail','end':'end','base':'base'}[n['name']]
    if kind=='Literal':return n['value'] if n['kind']=='bool' else str(int(n['value']))
    if kind=='MemberAccess' and n['memberName']=='length':return {'left':'left','right':'right','pair':'length'}[n['expression']['name']]
    if kind=='IndexAccess' and n['baseExpression']['nodeType']=='MemberAccess' and n['baseExpression']['memberName']=='dynamic':return ['a','b'][int(n['indexExpression']['value'])]
    if kind=='FunctionCall' and n['expression']['nodeType']=='MemberAccess' and n['expression']['memberName']=='word':return 'first' if n['arguments'][1].get('value')=='0' else 'offset'
    if kind=='BinaryOperation' and n['operator'] in {'==','!=','<','>','<=','>=','+','-','*','||','&&'}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    if kind=='Conditional':return '(if '+expr(n['condition'])+' then '+expr(n['trueExpression'])+' else '+expr(n['falseExpression'])+')'
    raise ValueError('Unsupported pair expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast'],'Collections':['evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Collections.sol']['ast']['nodes'] if x.get('name')=='Collections')
    funcs={n['name']:form(n) for n in contract['nodes'] if n.get('nodeType')=='FunctionDefinition' and n.get('name') in {'zipValues','unzipValues','_zipPlan','_unzipPair'}}
    slots={}
    def slot(node,key,name):slots[name]=expr(node[key]);node[key]={'translated-slot':name}
    body=funcs['zipValues']['body']['statements'];slot(body[0],'condition','ZIP_LENGTH')
    loop=body[-1]['body']['statements']
    slot(loop[0]['expression']['arguments'][1],'indexExpression','ZIP_LEFT');slot(loop[1]['expression']['arguments'][1],'indexExpression','ZIP_RIGHT')
    slot(loop[2]['expression']['leftHandSide'],'indexExpression','LEFT_SLOT');slot(loop[3]['expression']['leftHandSide'],'indexExpression','RIGHT_SLOT')
    slot(loop[4]['initialValue']['arguments'],3,'ARRAY_MODE');slot(loop[5]['expression']['rightHandSide'],'condition','ENVELOPE')
    body=funcs['unzipValues']['body']['statements'];slot(body[0],'condition','LANE_BAD')
    loop=body[-1]['body']['statements'];slot(loop[1]['expression']['arguments'][1],'indexExpression','UNZIP_LEFT');slot(loop[2]['expression']['arguments'][1],'indexExpression','UNZIP_RIGHT');slot(loop[3]['expression']['rightHandSide'],'indexExpression','SELECTED')
    body=funcs['_zipPlan']['body']['statements'];slot(body[5]['expression'],'rightHandSide','HEAD')
    body=funcs['_unzipPair']['body']['statements'];slot(body[0],'initialValue','BASE');slot(body[1]['condition'],'rightExpression','ENVELOPE_WRONG')
    loop=body[5];slot(loop,'condition','LOOP');branch=loop['body']['statements'][0]['trueBody']['statements']
    slot(branch[0],'condition','OFFSET_WRONG');slot(branch[1]['initialValue'],'condition','NEXT_BOUNDARY');slot(branch[2],'condition','BOUNDARY_WRONG')
    slot(branch[3]['expression']['rightHandSide']['arguments'][1]['arguments'],2,'SPAN');slot(body[-1],'condition','TAIL_WRONG')
    errors=[n for n in contract['nodes'] if n.get('nodeType')=='ErrorDefinition' and n['name'] in {'LengthMismatch','InvalidLane'}]
    for error in errors:
        slots[error['name']+'Selector']=str(list(bytes.fromhex(error['errorSelector'])))
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(funcs,indent=2)+'\n');return
    if funcs!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported value pairing structure')
    code=(HERE/'Control.template.dfy').read_text()
    for key,value in slots.items():code=code.replace('$'+key+'$',value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'slots':slots,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
