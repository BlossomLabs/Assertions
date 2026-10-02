#!/usr/bin/env python3
"""Restricted compiler-AST translation of complete scalar public bodies."""
import argparse,copy,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
SOURCES=['contracts/Operations.sol','contracts/lib/AbiCodec.sol','node_modules/@openzeppelin/contracts/utils/math/Math.sol','node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol','node_modules/@openzeppelin/contracts/utils/Panic.sol']
NAMES={'add','sub','mul','div','mod','min','max','absDiff','eq','ne','lt','gt','le','ge','bitAnd','bitOr','bitXor','shl','shr','bitSet'}
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:form(v) for k,v in n.items() if k not in ignored}
def expr(n,bit=False):
    kind=n['nodeType']
    if kind=='TupleExpression' and len(n['components'])==1:return expr(n['components'][0],bit)
    if kind=='Identifier':return {'a':'a','b':'b','mask':'a','index':'b','bits':'b'}[n['name']]
    if kind=='Literal' and n['kind']=='number':return n['value']
    if kind=='BinaryOperation':
        op=n['operator'];a=expr(n['leftExpression'],bit);b=expr(n['rightExpression'],bit)
        if op in {'&','|','^'}:return 'M.'+{'&':'And','|':'Or','^':'Xor'}[op]+'('+a+', '+b+')'
        if op=='<<':return 'M.Left('+a+', '+b+')'
        if op=='>>':return ('M.ArithmeticRight' if n['leftExpression']['typeDescriptions']['typeString']=='int256' else 'M.Right')+'('+a+', '+b+')'
        if op=='/':return 'M.Trunc(a, b)' if n['typeDescriptions']['typeString']=='int256' else 'M.Quotient(a, b)'
        if op=='%':return 'M.Rem(a, b)' if n['typeDescriptions']['typeString']=='int256' else 'M.Remainder(a, b)'
        if op in {'+','-','*','<','>','<=','>=','==','!='}:return '('+a+' '+op+' '+b+')'
    if kind=='Conditional':return '(if '+expr(n['condition'],bit)+' then '+expr(n['trueExpression'],bit)+' else '+expr(n['falseExpression'],bit)+')'
    if kind=='FunctionCall' and n['kind']=='typeConversion' and n['expression']['typeName']['name']=='uint256':return 'M.Wrap('+expr(n['arguments'][0],bit)+')'
    raise ValueError('Unsupported expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
    sources={p.replace('node_modules/',''):{'content':(root/p).read_text()} for p in SOURCES}
    req={'language':'Solidity','sources':sources,'settings':{'evmVersion':'cancun','optimizer':{'enabled':True,'runs':200},'outputSelection':{'*':{'':['ast'],'*':['abi','evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(x['severity']=='error' for x in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Operations.sol']['ast']['nodes'] if x.get('name')=='Operations')
    functions=[x for x in contract['nodes'] if x.get('nodeType')=='FunctionDefinition' and x['name'] in NAMES]
    if len(functions)!=33:raise ValueError('Missing scalar entries')
    controls=[];structure={};entries=[]
    for f in functions:
        types=[p['typeDescriptions']['typeString'] for p in f['parameters']['parameters']];signed=types[0]=='int256';name=f['name'];symbol=name+('S' if signed else 'U')
        signature=name+'('+','.join(types)+')'
        if data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][signature]!=f['functionSelector']:raise ValueError('Compiler selector disagreement')
        body=f['body']['statements'];unchecked=body[0]['nodeType']=='UncheckedBlock';ret=body[0]['statements'][0] if unchecked else body[0]
        if len(body)!=1 or ret['nodeType']!='Return':raise ValueError('Unsupported full body '+signature)
        expression=expr(ret['expression']);gate=copy.deepcopy(f);target=gate['body']['statements'][0]['statements'][0] if unchecked else gate['body']['statements'][0];target['expression']={'translated-expression':symbol};structure[signature]=form(gate)
        domain='M.Signed(a)' if signed else 'M.Word(a)';domain+=' && M.Word(b)' if name in {'shl','shr','bitSet'} else (' && M.Signed(b)' if signed else ' && M.Word(b)')
        boolean=name in {'eq','ne','lt','gt','le','ge','bitSet'}
        # The actual AST operator selects checked, divide, or remainder semantics.
        if name in {'add','sub','mul','div','mod'}:
            op=ret['expression']['operator']
            if op in {'/','%'}:expression='(if b == 0 then M.Panic(18) else '+ ('if a == M.Low && b == -1 then M.Panic(17) else ' if op=='/' and signed else '')+'M.Value('+expression+'))'
            else:expression=('M.CheckedS' if signed else 'M.CheckedU')+'('+expression+')'
        elif not boolean:expression='M.Value('+('M.Wrap('+expression+')' if unchecked else expression)+')'
        typ='bool' if boolean else 'M.Outcome'
        controls.append('  function '+symbol+'(a: int, b: int): '+typ+'\n    requires '+domain+'\n  { '+expression+' }\n')
        entries.append({'signature':signature,'selector':f['functionSelector'],'symbol':symbol,'signed':signed,'domain':domain,'boolean':boolean})
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Full scalar AST/selector drift')
    code='include "Model.dfy"\nmodule OperationsScalarSource {\n  import M = OperationsScalarModel\n'+ '\n'.join(controls)+'}\n'
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code);(out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0));(out/'mapping.json').write_text(json.dumps({'entries':entries,'sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
