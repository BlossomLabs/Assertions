#!/usr/bin/env python3
"""Gate the complete word map/filter engine and public wrappers."""
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
    if kind in {'Identifier','YulIdentifier'}:return {'i':'i','count':'count','word':'word','elem':'elem','kept':'kept','filterMode':'mode'}[n['name']]
    if kind=='MemberAccess' and n['memberName']=='length' and n['expression'].get('name')=='s':return 'length'
    if kind=='FunctionCall' and n['kind']=='typeConversion' and n['expression']['typeName']['name'] in {'bytes32','uint256'}:return expr(n['arguments'][0])
    if kind in {'Literal','YulLiteral'} and n['kind']=='number':return str(int(n['value']))
    if kind=='Literal' and n['kind']=='bool':return n['value']
    if kind=='BinaryOperation' and n['operator'] in {'<','>','<=','>=','==','!=','%','/','*','+'}:
        return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    if kind=='YulFunctionCall' and n['functionName']['name']=='mul':return 'Mem.Mul('+','.join(expr(x) for x in n['arguments'])+')'
    raise ValueError('Unsupported apply expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Collections.sol']['ast']['nodes'] if x.get('name')=='Collections')
    names={'_applyWords','mapWords','filterWords'}
    functions={x['name']:form(x) for x in contract['nodes'] if x.get('nodeType')=='FunctionDefinition' and x['name'] in names}
    if set(functions)!=names:raise ValueError('Missing helper')
    slots={}
    def slot(node,key,name):slots[name]=expr(node[key]);node[key]={'translated-slot':name}
    body=functions['_applyWords']['body']['statements']
    slot(body[0],'condition','ALIGNMENT');slot(body[2],'initialValue','COUNT');slot(body[5],'condition','NONEMPTY')
    loop=body[5]['trueBody']['statements'][2];slot(loop,'condition','LOOP')
    choose=loop['body']['statements'][3];slot(choose,'condition','FILTER')
    filtered=choose['trueBody']['statements'];slot(filtered[0],'condition','INVALID');slot(filtered[1],'condition','KEEP')
    filterargs=filtered[1]['trueBody']['statements'][0]['expression']['arguments']
    for index,key in [(1,'FILTER_INDEX'),(2,'FILTER_VALUE')]:
        slots[key]=expr(filterargs[index]);filterargs[index]={'translated-slot':key}
    mapargs=choose['falseBody']['statements'][0]['expression']['arguments']
    for index,key in [(1,'MAP_INDEX'),(2,'MAP_VALUE')]:
        slots[key]=expr(mapargs[index]);mapargs[index]={'translated-slot':key}
    slot(body[6],'condition','SHRINK_MODE')
    args=body[6]['trueBody']['statements'][0]['AST']['statements'][0]['expression']['arguments']
    slots['SHRINK_BYTES']=expr(args[1]);args[1]={'translated-slot':'SHRINK_BYTES'}
    selectors={}
    for name,key in [('mapWords','MAP_MODE'),('filterWords','FILTER_MODE')]:
        selectors[name]=functions[name]['functionSelector']
        args=functions[name]['body']['statements'][0]['expression']['arguments']
        slots[key]=expr(args[-1]);args[-1]={'translated-slot':key}
    error=next(x for x in contract['nodes'] if x.get('nodeType')=='ErrorDefinition' and x['name']=='UnalignedWords')
    selectors['UnalignedWords']=error['errorSelector']
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(functions,indent=2)+'\n');return
    if functions!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported apply structure')
    code=(HERE/'Control.template.dfy').read_text()
    for key,value in slots.items():code=code.replace('$'+key+'$',value)
    for key,value in selectors.items():code=code.replace('$'+key+'$',str(list(bytes.fromhex(value))))
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'slots':slots,'selectors':selectors,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
