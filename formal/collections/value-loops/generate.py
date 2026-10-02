#!/usr/bin/env python3
"""Trusted restricted lowering of the three value traversal bodies."""
import argparse,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
FUNCTIONS={'mapValues':'MAP','filterValues':'FILTER','foldValues':'FOLD'}
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
    if k=='Literal':
        if n['kind'] in {'number','bool'}:return n['value']
        if n['kind']=='string' and n['value']=='':return '[]'
    if k=='Identifier' and n['name'] in {'i','count','result','initial','inputType','outputType','accumulatorType'}:return n['name']
    if k=='MemberAccess' and n['expression'].get('name')=='values' and n['memberName']=='length':return '|values|'
    if k=='IndexAccess' and n['baseExpression'].get('name') in {'values','out'}:return {'values':'values','out':'buffer'}[n['baseExpression']['name']]+'['+expr(n['indexExpression'])+']'
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
    def slot(n,key,prefix,name):
        label=prefix+'_'+name;slots[label]=expr(n[key]);n[key]={'slot':label}
    for name,prefix in FUNCTIONS.items():
        f=functions[name];nodes=list(walk(f))
        loop=next(n for n in nodes if n.get('nodeType')=='ForStatement');slot(loop,'condition',prefix,'GUARD')
        prep=next(n for n in nodes if n.get('nodeType')=='FunctionCall' and n['expression'].get('name')=='_prepareCallback');slot(prep['arguments'],1,prefix,'PREP_BINARY')
        call=next(n for n in nodes if n.get('nodeType')=='FunctionCall' and n['expression'].get('name') in {'_callValue','_predicate'})
        for index,label in [(2,'A'),(3,'B'),(4,'BINARY'),(5,'INDEX'),(6,'OTHER')]:slot(call['arguments'],index,prefix,label)
        if prefix!='FILTER':
            validation=next(n for n in nodes if n.get('nodeType')=='FunctionCall' and n['expression'].get('name')=='_validateResult')
            for index,label in [(0,'RESULT_TYPE'),(1,'RESULT_VALUE'),(3,'RESULT_INDEX')]:slot(validation['arguments'],index,prefix,label)
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
