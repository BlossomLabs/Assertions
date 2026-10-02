#!/usr/bin/env python3
"""Gate complete predicate search bodies; lower source controls and compiler-bound selectors."""
import argparse,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:(['compiler-node-id']*len(v) if k=='overloadedDeclarations' else form(v)) for k,v in n.items() if k not in ignored}
predicate_calls=[]
def expr(n):
    kind=n['nodeType']
    if kind=='Identifier':return {'i':'i','wanted':'wanted'}[n['name']]
    if kind=='Literal':return n['value'] if n['kind']=='bool' else str(int(n['value']))
    if kind=='MemberAccess':
        if n['expression'].get('name')=='values' and n['memberName']=='length':return 'length'
        if n['memberName']=='max' and n['expression'].get('expression',{}).get('name')=='type' and n['expression']['arguments'][0]['typeName']['name']=='uint256':return 'S.Missing()'
    if kind=='FunctionCall' and n['expression'].get('name')=='_predicate':
        predicate_calls.append(form(n));return 'truth'
    if kind=='UnaryOperation' and n['operator']=='!':return '!('+expr(n['subExpression'])+')'
    if kind=='BinaryOperation' and n['operator'] in {'==','!=','<','<=','+','-'}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    raise ValueError('Unsupported value search expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast'],'Collections':['evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Collections.sol']['ast']['nodes'] if x.get('name')=='Collections')
    funcs={n['name']:form(n) for n in contract['nodes'] if n.get('nodeType')=='FunctionDefinition' and n.get('name') in {'indexOfValues','anyValues','allValues','findValues','_findValue'}}
    slots={}
    def slot(node,key,name):slots[name]=expr(node[key]);node[key]={'translated-slot':name}
    for name,prefix in [('indexOfValues','INDEX'),('_findValue','FIND')]:
        body=funcs[name]['body']['statements'];loop=body[2];slot(loop,'condition',prefix+'_LOOP')
        a=loop['body']['statements'];slot(a[0]['expression']['arguments'][1],'indexExpression',prefix+'_VALIDATE')
        slot(a[1],'condition',prefix+'_MATCH');slot(a[1]['trueBody'],'expression',prefix+'_RESULT');slot(body[-1],'expression',prefix+'_MISSING')
    for name,prefix in [('anyValues','ANY'),('allValues','ALL')]:
        expression=funcs[name]['body']['statements'][0]['expression'];call=expression['leftExpression']
        slot(call['arguments'],3,prefix+'_WANTED');slots[prefix+'_RESULT']='(index '+expression['operator']+' S.Missing())';expression['operator']={'translated-slot':prefix+'_RESULT_OPERATOR'}
    slot(funcs['findValues']['body']['statements'][0]['expression']['arguments'],3,'FIND_WANTED')
    # Calls consumed by scalar condition lowering keep every original argument
    # in this structural projection. Predicate helper mode/operands/metadata
    # cannot disappear behind a truth-symbol substitution.
    funcs['predicateProjections']=predicate_calls
    identifiers=data['contracts']['contracts/Collections.sol']['Collections']['evm']['methodIdentifiers']
    entries={}
    for name in ['indexOfValues','anyValues','allValues','findValues']:
        matches=[(sig,value) for sig,value in identifiers.items() if sig.startswith(name+'(')]
        if len(matches)!=1:raise ValueError('Missing public selector')
        entries[name]={'signature':matches[0][0],'selector':matches[0][1]}
        slots[name+'Selector']=str(list(bytes.fromhex(matches[0][1])))
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(funcs,indent=2)+'\n');return
    if funcs!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported value search structure')
    code=(HERE/'Control.template.dfy').read_text()
    for key,value in slots.items():code=code.replace('$'+key+'$',value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code)
    (out/'selectors.json').write_text(json.dumps(entries,indent=2)+'\n')
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'slots':slots,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
