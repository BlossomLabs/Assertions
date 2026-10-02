#!/usr/bin/env python3
"""Gate four complete public bodies and lower word allocation/control/address expressions."""
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
    if kind in {'Identifier','YulIdentifier'}:return {'n':'n','i':'i','count':'count','out':'base','which':'lane','laneCount':'laneCount'}[n['name']]
    if kind=='MemberAccess' and n['memberName']=='length':return {'s':'length','a':'aLength','b':'bLength'}[n['expression']['name']]
    if kind in {'Literal','YulLiteral'} and n['kind']=='number':return str(int(n['value']))
    if kind=='BinaryOperation' and n['operator'] in {'<','>','<=','>=','==','!=','%','/','*','+','-'}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    if kind=='TupleExpression' and len(n['components'])==1:return '('+expr(n['components'][0])+')'
    if kind=='Conditional':return '(if '+expr(n['condition'])+' then '+expr(n['trueExpression'])+' else '+expr(n['falseExpression'])+')'
    if kind=='YulFunctionCall':
        op=n['functionName']['name'];fn={'add':'Mem.Add','mul':'Mem.Mul','sub':'Sub'}[op]
        return fn+'('+','.join(expr(a) for a in n['arguments'])+')'
    raise ValueError('Unsupported layout expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Collections.sol']['ast']['nodes'] if x.get('name')=='Collections')
    names={'iotaWords','reverseWords','zipWords','unzipWords'}
    fs={x['name']:form(x) for x in contract['nodes'] if x.get('nodeType')=='FunctionDefinition' and x['name'] in names}
    if set(fs)!=names:raise ValueError('Missing public layout')
    slots={}
    def slot(node,key,name):slots[name]=expr(node[key]);node[key]={'translated-slot':name}
    def alloc(statement,name):slot(statement['expression']['rightHandSide']['arguments'],0,name)
    def address(statement,name,index=0):slot(statement['AST']['statements'][index]['expression']['arguments'],0,name)
    body=fs['iotaWords']['body']['statements'];alloc(body[0],'IOTA_BYTES');slot(body[1],'condition','IOTA_LOOP');slot(body[1]['body']['statements'][0]['expression']['arguments'],2,'IOTA_VALUE')
    body=fs['reverseWords']['body']['statements'];slot(body[0],'condition','R_ALIGNMENT');slot(body[1],'initialValue','R_COUNT');slot(body[3],'condition','R_LOOP');address(body[3]['body']['statements'][1],'R_ADDRESS')
    body=fs['zipWords']['body']['statements'];slot(body[0],'condition','Z_A_ALIGNMENT');slot(body[1],'condition','Z_B_ALIGNMENT');slot(body[2],'condition','Z_MISMATCH');slot(body[3],'initialValue','Z_COUNT');alloc(body[4],'Z_BYTES');slot(body[5],'condition','Z_LOOP');address(body[5]['body']['statements'][2],'Z_LEFT_ADDRESS');address(body[5]['body']['statements'][2],'Z_RIGHT_ADDRESS',1)
    body=fs['unzipWords']['body']['statements'];slot(body[0],'condition','U_ALIGNMENT');slot(body[1],'condition','U_INVALID');slot(body[2],'initialValue','U_COUNT');slot(body[3],'initialValue','U_LANE_COUNT');alloc(body[4],'U_BYTES');slot(body[5],'condition','U_LOOP');address(body[5]['body']['statements'][1],'U_ADDRESS')
    selectors={}
    for name in ['UnalignedWords','WordCountMismatch','InvalidLane']:
        error=next(x for x in contract['nodes'] if x.get('nodeType')=='ErrorDefinition' and x['name']==name);selectors[name]=error['errorSelector']
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(fs,indent=2)+'\n');return
    if fs!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported layout structure')
    code=(HERE/'Control.template.dfy').read_text()
    for key,value in slots.items():code=code.replace('$'+key+'$',value)
    for key,value in selectors.items():code=code.replace('$'+key+'$',str(list(bytes.fromhex(value))))
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'slots':slots,'selectors':selectors,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
