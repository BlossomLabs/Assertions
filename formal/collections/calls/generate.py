#!/usr/bin/env python3
"""Trusted restricted lowering of callback invocation and target checking."""
import argparse,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
FUNCTIONS={'_callValue','_checkTarget'}
def form(n):
    if isinstance(n,list):return [form(v) for v in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments'}
    return {k: (['compiler-node-id']*len(v) if k=='overloadedDeclarations' else form(v)) for k,v in n.items() if k not in ignored}
def walk(n):
    if isinstance(n,dict):
        yield n
        for v in n.values():yield from walk(v)
    elif isinstance(n,list):
        for v in n:yield from walk(v)
def key(n):
    if n['nodeType']=='Identifier':return n['name']
    if n['nodeType']=='MemberAccess':return key(n['expression'])+'.'+n['memberName']
    raise ValueError('Unsupported member')
def expr(n):
    k=n['nodeType']
    if k=='Literal' and n['kind'] in {'number','bool'}:return n['value']
    if k=='Identifier' and n['name'] in {'binary','a','b','i','j'}:return {'i':'c.index','j':'c.other'}.get(n['name'],n['name'])
    if k=='MemberAccess':
        aliases={'prepared.targetChecked':'prepared.targetChecked','cb.first':'cb.first','cb.second':'cb.second','cb.expression.length':'|cb.expression|','target.code.length':'codeLength'}
        if key(n) in aliases:return aliases[key(n)]
    if k=='UnaryOperation' and n['operator']=='!':return '!('+expr(n['subExpression'])+')'
    if k=='BinaryOperation' and n['operator'] in {'<','<=','>','>=','+','-','==','!='}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    raise ValueError('Unsupported expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    request={'language':'Solidity','sources':{p:{'content':s} for p,s in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(request),capture_output=True,text=True,check=True);ast=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in ast.get('errors',[])):raise ValueError(ast['errors'])
    contract=next(n for n in ast['sources']['contracts/Collections.sol']['ast']['nodes'] if n.get('name')=='Collections')
    functions={n['name']:form(n) for n in contract['nodes'] if n.get('nodeType')=='FunctionDefinition' and n['name'] in FUNCTIONS}
    if set(functions)!=set(FUNCTIONS):raise ValueError('Missing functions')
    slots={}
    def slot(n,key,name):slots[name]=expr(n[key]);n[key]={'slot':name}
    statements=functions['_callValue']['body']['statements'];nodes=list(walk(functions['_callValue']))
    first=statements[0];slot(first,'condition','CHECK_TARGET')
    slot(first['trueBody']['statements'][1]['expression'],'rightHandSide','CHECKED')
    slot(functions['_checkTarget']['body']['statements'][0],'condition','NO_CODE')
    binds=[n for n in nodes if n.get('nodeType')=='FunctionCall' and n['expression'].get('name')=='_bindValue']
    if len(binds)!=2:raise ValueError('Missing bindings')
    for prefix,call in zip(['FIRST','SECOND'],binds):
        slot(call['arguments'],2,prefix+'_SLOT');slot(call['arguments'],3,prefix+'_VALUE')
    slot(statements[2],'condition','BINARY');slot(statements[4],'condition','DIRECT')
    assembled=next(n for n in nodes if n.get('nodeType')=='FunctionCall' and n['expression'].get('memberName')=='assemble');slot(assembled['arguments'],3,'ENVELOPE')
    error=next(n for n in nodes if n.get('nodeType')=='FunctionCall' and n['expression'].get('name')=='CallbackFailed')
    slot(error['arguments'],1,'ERROR_INDEX');slot(error['arguments'],2,'ERROR_OTHER')
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(functions,indent=2)+'\n');return
    if functions!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported value traversal source drift')
    text=(HERE/'Source.template.dfy').read_text().replace('$HASH',hashlib.sha256(sources['contracts/Collections.sol'].encode()).hexdigest())
    for key,value in sorted(slots.items(),key=lambda kv:-len(kv[0])):text=text.replace('$'+key,value)
    if '$' in text:raise ValueError('Unexpanded slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Source.generated.dfy').write_text(text)
    (out/'solc-input.json').write_text(json.dumps(request));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'translatedSlots':slots,'functions':sorted(functions),'sourceSha256':{p:hashlib.sha256(s.encode()).hexdigest() for p,s in sources.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
