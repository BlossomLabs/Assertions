#!/usr/bin/env python3
"""Gate uniqueWords and lower retention, scan, alignment and shrink controls."""
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
    if kind in {'Identifier','YulIdentifier'}:return {'i':'i','j':'j','kept':'kept','ordered':'ordered','seen':'seen','word':'word'}[n['name']]
    if kind=='MemberAccess' and n['memberName']=='length' and n['expression'].get('name')=='s':return 'length'
    if kind in {'Literal','YulLiteral'} and n['kind']=='number':return str(int(n['value']))
    if kind=='BinaryOperation' and n['operator'] in {'<','>','<=','>=','==','!=','%','/','*','+','-'}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    if kind=='UnaryOperation' and n['operator']=='!':return '!('+expr(n['subExpression'])+')'
    if kind=='YulFunctionCall' and n['functionName']['name']=='mul':return 'M.Mul('+','.join(expr(a) for a in n['arguments'])+')'
    raise ValueError('Unsupported unique expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Collections.sol']['ast']['nodes'] if x.get('name')=='Collections')
    f=form(next(x for x in contract['nodes'] if x.get('nodeType')=='FunctionDefinition' and x['name']=='uniqueWords'));slots={}
    def slot(node,key,name):slots[name]=expr(node[key]);node[key]={'translated-slot':name}
    body=f['body']['statements'];slot(body[0],'condition','ALIGNMENT');loop=body[3];slot(loop,'condition','LOOP')
    stmts=loop['body']['statements'];choice=stmts[2];slot(choice,'condition','ORDERED')
    conjunction=choice['trueBody']['statements'][0]['expression']['rightHandSide']
    if conjunction['operator']!='&&':raise ValueError('Unexpected ordered lazy condition')
    slot(conjunction,'leftExpression','NONEMPTY');equal=conjunction['rightExpression']
    # The complete _wordAt call and its index remain gated while only the
    # equality operator is lowered. Both modes must use the same comparison.
    slots['EQUAL']='(previous '+equal['operator']+' word)';equal['operator']={'translated-slot':'EQUAL_OPERATOR'}
    scan=choice['falseBody']['statements'][0];slot(scan,'condition','SCAN');other=scan['body']['statements'][0]['condition']
    if '(previous '+other['operator']+' word)'!=slots['EQUAL']:raise ValueError('Distinct unique comparisons')
    other['operator']={'translated-slot':'EQUAL_OPERATOR'};slot(stmts[3],'condition','UNSEEN')
    slot(body[4]['AST']['statements'][0]['expression']['arguments'],1,'SHRINK')
    error=next(x for x in contract['nodes'] if x.get('nodeType')=='ErrorDefinition' and x['name']=='UnalignedWords')
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(f,indent=2)+'\n');return
    if f!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported unique structure')
    code=(HERE/'Control.template.dfy').read_text()
    for key,value in slots.items():code=code.replace('$'+key+'$',value)
    code=code.replace('$UnalignedWords$',str(list(bytes.fromhex(error['errorSelector']))))
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'slots':slots,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
