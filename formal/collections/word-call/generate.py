#!/usr/bin/env python3
"""Gate domain-element selection, target code check and word callback invocation."""
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
    if kind=='Identifier':return {'i':'index','index':'index','domain':'domain','success':'observed.success'}[n['name']]
    if kind=='Literal' and n['kind']=='number':return str(int(n['value'],0)) if n['value'].startswith('0x') else str(int(n['value']))
    if kind=='MemberAccess':
        if n['expression'].get('name')=='FoldDomain':return n['memberName']
        if n['memberName']=='length':
            if n['expression'].get('name')=='ret':return '|ret|'
            if n['expression'].get('memberName')=='code':return 'length'
    if kind=='UnaryOperation' and n['operator']=='!':return '!'+expr(n['subExpression'])
    if kind=='BinaryOperation' and n['operator'] in {'<','>','<=','>=','==','!=','+','*'}:
        return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    raise ValueError('Unsupported source expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Collections.sol']['ast']['nodes'] if x.get('name')=='Collections')
    names={'_domainElem','_checkTarget','_callWord'}
    functions={x['name']:form(x) for x in contract['nodes'] if x.get('nodeType')=='FunctionDefinition' and x['name'] in names}
    if set(functions)!=names:raise ValueError('Missing helper')
    functions['FoldDomain']=form(next(x for x in contract['nodes'] if x.get('nodeType')=='EnumDefinition' and x['name']=='FoldDomain'))
    slots={}
    def slot(node,key,name):slots[name]=expr(node[key]);node[key]={'translated-slot':name}
    domain=functions['_domainElem']['body']['statements']
    slot(domain[0],'condition','RANGE_GUARD');slot(domain[1],'condition','BYTE_GUARD')
    slot(domain[0]['trueBody']['expression']['arguments'],0,'RANGE_VALUE')
    byte=domain[1]['trueBody']['expression']['arguments'][0]['arguments'][0]['arguments'][0]
    slot(byte,'indexExpression','BYTE_INDEX')
    word=domain[2]['expression']['arguments'][0]
    slot(word,'startExpression','WORD_START');slot(word,'endExpression','WORD_END')
    slot(functions['_checkTarget']['body']['statements'][0],'condition','NO_CODE')
    call=functions['_callWord']['body']['statements']
    slot(call[2],'condition','FAILED');slot(call[3],'condition','BAD_LENGTH')
    failed=call[2]['trueBody']['statements'][1]['errorCall']['arguments']
    invalid=call[3]['trueBody']['errorCall']['arguments']
    slot(failed,1,'ERROR_INDEX');slot(failed,2,'ERROR_OTHER')
    slot(invalid,1,'INVALID_INDEX');slot(invalid,2,'INVALID_OTHER')
    load=call[4]['AST']['statements'][0]['value']
    address=load['arguments'][0]
    if address['functionName']['name']!='add' or address['arguments'][0]['name']!='ret':raise ValueError('Unsupported return word base')
    amount=address['arguments'][1]
    if amount['nodeType']!='YulLiteral' or amount['kind']!='number':raise ValueError('Unsupported return word offset')
    slots['READ_OFFSET']=str(int(amount['value'])-32);address['arguments'][1]={'translated-slot':'READ_OFFSET'}
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
