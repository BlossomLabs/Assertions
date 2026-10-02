#!/usr/bin/env python3
"""Gate complete public wordIndexOf/sumWords and translate arithmetic/control slots."""
import argparse,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:(['compiler-node-id']*len(v) if k=='overloadedDeclarations' else form(v)) for k,v in n.items() if k not in ignored}
projections=[]
def expr(n):
    kind=n['nodeType']
    if kind=='Identifier':return {'i':'i','count':'count','w':'needle','total':'total'}[n['name']]
    if kind=='MemberAccess' and n['memberName']=='length' and n['expression'].get('name')=='s':return 'length'
    if kind=='FunctionCall' and n['kind']=='typeConversion' and n['expression']['typeName'].get('name') in {'bytes32','uint256'}:
        arg=n['arguments'][0]
        if arg['nodeType']=='IndexRangeAccess':
            projections.append(form(arg));return 'element'
        return expr(arg)
    if kind=='Literal' and n['kind']=='number':return str(int(n['value']))
    if kind=='BinaryOperation' and n['operator'] in {'<','>','<=','>=','==','!=','%','/','*','+','-'}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    raise ValueError('Unsupported scan expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Collections.sol']['ast']['nodes'] if x.get('name')=='Collections')
    functions={x['name']:form(x) for x in contract['nodes'] if x.get('nodeType')=='FunctionDefinition' and x['name'] in {'wordIndexOf','sumWords'}}
    if len(functions)!=2:raise ValueError('Missing public scan')
    slots={}
    def slot(node,key,name):
        value=expr(node[key])
        if name in slots and slots[name]!=value:raise ValueError('Inconsistent shared slot '+name)
        slots[name]=value;node[key]={'translated-slot':name}
    for name,f in functions.items():
        body=f['body']['statements'];slot(body[0],'condition','ALIGNMENT');slot(body[1],'initialValue','COUNT');slot(body[2],'condition','LOOP')
        inner=body[2]['body']['statements'][0]
        if name=='wordIndexOf':slot(inner,'condition','EQUAL')
        else:
            add=inner['expression']
            if add['nodeType']!='Assignment' or add['operator']!='+=':raise ValueError('Unsupported sum assignment')
            slots['SUM']='(total + '+expr(add['rightHandSide'])+')';add['operator']={'translated-slot':'SUM_OPERATOR'};add['rightHandSide']={'translated-slot':'SUM_OPERAND'}
    functions['sliceProjections']=projections
    error=next(x for x in contract['nodes'] if x.get('nodeType')=='ErrorDefinition' and x['name']=='UnalignedWords')
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(functions,indent=2)+'\n');return
    if functions!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported scan structure')
    code=(HERE/'Control.template.dfy').read_text()
    for key,value in slots.items():code=code.replace('$'+key+'$',value)
    code=code.replace('$UnalignedWords$',str(list(bytes.fromhex(error['errorSelector']))))
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'slots':slots,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
