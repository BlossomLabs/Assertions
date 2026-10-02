#!/usr/bin/env python3
"""Gate window admission and ordered memory writes; lower source guards and Yul addresses."""
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
    if kind in {'YulIdentifier','Identifier'} and n['name'] in {'callData','accOffset','elemOffset','j'}:
        return {'callData':'base','accOffset':'accOffset','elemOffset':'offset','j':'j'}[n['name']]
    if kind=='MemberAccess' and n['memberName']=='length':
        return {'template':'n','elemOffsets':'|offsets|'}[n['expression']['name']]
    if kind=='IndexAccess':return 'offsets['+expr(n['indexExpression'])+']'
    if kind in {'YulLiteral','Literal'} and n['kind']=='number':return str(int(n['value'],0)) if n['value'].startswith('0x') else str(int(n['value']))
    if kind=='YulFunctionCall' and n['functionName']['name'] in {'add','mul'} and len(n['arguments'])==2:
        return 'Mem.'+{'add':'Add','mul':'Mul'}[n['functionName']['name']]+'('+','.join(expr(x) for x in n['arguments'])+')'
    if kind=='BinaryOperation' and n['operator'] in {'<','>','<=','>=','==','!=','||','&&','-','+'}:
        return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    raise ValueError('Unsupported source expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Collections.sol']['ast']['nodes'] if x.get('name')=='Collections')
    names={'_checkWindows','_checkElementWindows','_stampWindows','_stampElements'}
    functions={x['name']:form(x) for x in contract['nodes'] if x.get('nodeType')=='FunctionDefinition' and x['name'] in names}
    if set(functions)!=names:raise ValueError('Missing helper')
    slots={}
    def slot(node,key,name):
        slots[name]=expr(node[key]);node[key]={'translated-slot':name}
    acc=functions['_checkWindows']['body']['statements'];slot(acc[0],'condition','ACC_CHECK')
    elements=functions['_checkElementWindows']['body']['statements'];slot(elements[0],'condition','SHORT')
    loop=elements[1];slot(loop,'condition','CHECK_LOOP');slot(loop['body']['statements'][0],'condition','ELEMENT_CHECK')
    accstore=functions['_stampWindows']['body']['statements'][0]['AST']['statements'][0]['expression'];slots['ACC_ADDRESS']=expr(accstore['arguments'][0]);accstore['arguments'][0]={'translated-slot':'ACC_ADDRESS'}
    loop=functions['_stampElements']['body']['statements'][0];slot(loop,'condition','STAMP_LOOP')
    store=loop['body']['statements'][1]['AST']['statements'][0]['expression'];slots['ELEMENT_ADDRESS']=expr(store['arguments'][0]);store['arguments'][0]={'translated-slot':'ELEMENT_ADDRESS'}
    error=next(x for x in contract['nodes'] if x.get('nodeType')=='ErrorDefinition' and x['name']=='LambdaOffsetOutOfBounds')
    slots['ERROR']='['+','.join(str(x) for x in bytes.fromhex(error['errorSelector']))+']'
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(functions,indent=2)+'\n');return
    if functions!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported helper structure')
    code=(HERE/'Source.template.dfy').read_text()
    for key,value in slots.items():code=code.replace('$'+key,value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Source.generated.dfy').write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'slots':slots,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
