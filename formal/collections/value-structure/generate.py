#!/usr/bin/env python3
"""Gate complete pure-value bodies; lower signed clamps, counts and source indices."""
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
    if kind=='Identifier':return {'i':'i','j':'j','k':'k','count':'count','a':'a','b':'b','index':'index','length':'length'}[n['name']]
    if kind=='MemberAccess' and n['memberName']=='length':
        v=n['expression']
        if v.get('name')=='values':return 'length'
        if v.get('name')=='out':return 'size'
        if v['nodeType']=='IndexAccess' and v['baseExpression'].get('name')=='values' and v['indexExpression'].get('name')=='i':return 'rowLength'
    if kind=='Literal' and n['kind']=='number':return str(int(n['value']))
    if kind=='BinaryOperation' and n['operator'] in {'<','>','<=','>=','==','!=','%','/','*','+','-'}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    if kind=='UnaryOperation' and n['operator']=='-':return '-('+expr(n['subExpression'])+')'
    if kind=='Conditional':return '(if '+expr(n['condition'])+' then '+expr(n['trueExpression'])+' else '+expr(n['falseExpression'])+')'
    if kind=='FunctionCall' and n['kind']=='typeConversion':
        name=n['expression']['typeName']['name'];args=n['arguments']
        if len(args)==1 and name in {'uint256','int256'}:return ('ToUnsigned' if name=='uint256' else 'ToSigned')+'('+expr(args[0])+')'
    raise ValueError('Unsupported pure value expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Collections.sol']['ast']['nodes'] if x.get('name')=='Collections')
    funcs={n['name']:form(n) for n in contract['nodes'] if n.get('nodeType')=='FunctionDefinition' and n.get('name') in {'reverseValues','sliceValues','flattenValues','_sliceIndex'}};slots={}
    def slot(node,key,name):slots[name]=expr(node[key]);node[key]={'translated-slot':name}
    r=funcs['reverseValues']['body']['statements'];loop=r[2];slot(loop,'condition','REVERSE_LOOP')
    a=loop['body']['statements'];slot(a[0]['expression']['arguments'][1],'indexExpression','REVERSE_VALIDATE')
    slot(a[1]['expression']['leftHandSide'],'indexExpression','REVERSE_DEST');slot(a[1]['expression']['rightHandSide'],'indexExpression','REVERSE_VALUE')
    s=funcs['sliceValues']['body']['statements'];slot(s[3]['expression']['rightHandSide']['arguments'],0,'SLICE_SIZE');loop=s[4];slot(loop,'condition','SLICE_LOOP')
    a=loop['body']['statements'];slot(a[0]['expression']['arguments'][1],'indexExpression','SLICE_VALIDATE');slot(a[1]['expression']['rightHandSide'],'indexExpression','SLICE_VALUE');slot(a[1]['expression']['leftHandSide'],'indexExpression','SLICE_DEST')
    f=funcs['flattenValues']['body']['statements'];slot(f[2],'condition','COUNT_LOOP')
    update=f[2]['body']['statements'][0]['expression']
    if update['operator']!='+=':raise ValueError('Unexpected count assignment')
    slot(update,'rightHandSide','COUNT_ADD');slot(f[5],'condition','FLAT_LOOP')
    inner=f[5]['body']['statements'][0];slot(inner,'condition','ROW_LOOP');a=inner['body']['statements']
    slot(a[0]['expression']['arguments'][1]['baseExpression'],'indexExpression','FLAT_VALIDATE_ROW');slot(a[0]['expression']['arguments'][1],'indexExpression','FLAT_VALIDATE_COL')
    slot(a[1]['expression']['rightHandSide']['baseExpression'],'indexExpression','FLAT_VALUE_ROW');slot(a[1]['expression']['rightHandSide'],'indexExpression','FLAT_VALUE_COL')
    # The actual k++ destination, both loop increments, raw shape calls,
    # validation/copy order and allocation arguments remain structurally gated.
    h=funcs['_sliceIndex']['body']['statements'];slot(h[0],'condition','INDEX_NEGATIVE');slot(h[0]['trueBody'],'expression','NEGATIVE_RESULT');slot(h[1],'expression','POSITIVE_RESULT')
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(funcs,indent=2)+'\n');return
    if funcs!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported pure value structure')
    code=(HERE/'Control.template.dfy').read_text()
    for key,value in slots.items():code=code.replace('$'+key+'$',value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'slots':slots,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
