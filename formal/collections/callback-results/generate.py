#!/usr/bin/env python3
"""Trusted restricted lowering of predicate and exhaustion postprocessing."""
import argparse,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
FUNCTIONS={'_predicate','_rejectOutOfGas'}
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
def expr(n):
    k=n['nodeType']
    if k=='Literal' and n['kind'] in {'number','bool'}:return n['value']
    if k=='Identifier' and n['name'] in {'answer','gasBefore','head'}:return n['name']
    if k=='MemberAccess':
        key=n['expression'].get('name','')+'.'+n['memberName']
        if key in {'out.length','ret.length','SubcallOutOfGas.selector'}:return {'out.length':'|data|','ret.length':'|reason|','SubcallOutOfGas.selector':'Signal()'}[key]
    if k=='FunctionCall' and n['expression'].get('name')=='gasleft' and not n['arguments']:return 'gasAfter'
    if k=='BinaryOperation' and n['operator'] in {'<','<=','>','>=','+','-','/','==','!=','||'}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
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
    def slot(n,key,name):
        slots[name]=expr(n[key]);n[key]={'slot':name}
    pred=functions['_predicate']['body']['statements']
    slot(pred[1],'condition','LENGTH');slot(pred[2]['initialValue']['arguments'],1,'OFFSET')
    slot(pred[3],'condition','BOUND');slot(pred[4],'expression','TRUTH')
    gas=functions['_rejectOutOfGas']['body']['statements']
    slot(gas[1],'condition','SIGNAL_LENGTH');slot(gas[2],'condition','EXHAUSTED')
    codec=next(n for n in ast['sources']['contracts/lib/AbiCodec.sol']['ast']['nodes'] if n.get('name')=='AbiCodec')
    error=next(n for n in codec['nodes'] if n.get('name')=='InvalidCallbackResult')
    selector=bytes.fromhex(error['errorSelector']);slots['ERROR_SELECTOR']=','.join(hex(v) for v in selector)
    functions['InvalidCallbackResult']=form(error)
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
