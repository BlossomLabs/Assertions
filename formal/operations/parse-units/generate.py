#!/usr/bin/env python3
"""Gate five complete bodies and translate both public parse-units controls."""
import argparse,copy,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
SOURCES=['contracts/Operations.sol','contracts/lib/AbiCodec.sol','node_modules/@openzeppelin/contracts/utils/math/Math.sol','node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol','node_modules/@openzeppelin/contracts/utils/Panic.sol']
NAMES={'parseUnits','parseUnitsUnsigned','_parseUnits','_signedMagnitude','_panic'}
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:form(v) for k,v in n.items() if k not in ignored}
def expr(n):
    k=n['nodeType']
    if k=='Identifier':return 'allowSigned' if n['name']=='signed' else n['name']
    if k=='UnaryOperation' and n['operator']=='!':return '!('+expr(n['subExpression'])+')'
    if k=='MemberAccess' and n['memberName'] in {'Trunc','Floor','Ceil'} and n['expression'].get('name')=='Rounding':return str({'Trunc':0,'Floor':1,'Ceil':2}[n['memberName']])
    if k=='Literal':
        if n['kind']=='string' and len(n['hexValue'])==2:return str(int(n['hexValue'],16))
        if n['kind']=='number':return str(int(n['value'],0))
        if n['kind']=='bool':return n['value']
    if k=='TupleExpression' and len(n['components'])==1:return expr(n['components'][0])
    if k=='MemberAccess' and n['memberName']=='length':return '|'+expr(n['expression'])+'|'
    if k=='BinaryOperation' and n['operator']=='**' and expr(n['leftExpression'])=='10':return 'U.Power('+expr(n['rightExpression'])+')'
    if k=='IndexAccess':return expr(n['baseExpression'])+'['+expr(n['indexExpression'])+']'
    if k=='BinaryOperation' and n['operator'] in {'<','>','<=','>=','==','!=','+','-','*','/','||','&&','%'}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    if k=='Conditional':return '(if '+expr(n['condition'])+' then '+expr(n['trueExpression'])+' else '+expr(n['falseExpression'])+')'
    if k=='FunctionCall' and n['kind']=='typeConversion' and n['expression']['typeName']['name']=='uint8':return '('+expr(n['arguments'][0])+' as int)'
    if k=='FunctionCall' and n['kind']=='typeConversion' and n['expression']['typeName']['name']=='uint256':return expr(n['arguments'][0])
    raise ValueError('Unsupported decimal expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
    req={'language':'Solidity','sources':{p.replace('node_modules/',''):{'content':(root/p).read_text()} for p in SOURCES},'settings':{'evmVersion':'cancun','optimizer':{'enabled':True,'runs':200},'outputSelection':{'*':{'':['ast'],'*':['abi','evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(x['severity']=='error' for x in data.get('errors',[])):raise ValueError(data['errors'])
    c=next(x for x in data['sources']['contracts/Operations.sol']['ast']['nodes'] if x.get('name')=='Operations')
    fs={}
    entries=[];slots={}
    for x in c['nodes']:
        if x.get('nodeType')!='FunctionDefinition' or x['name'] not in NAMES:continue
        f=copy.deepcopy(x);ts=[z['typeDescriptions']['typeString'].replace(' calldata','').replace('enum Operations.Rounding','uint8') for z in f['parameters']['parameters']];sig=f['name']+'('+','.join(ts)+')';fs[sig]=f
        if f['name'].startswith('_'):continue
        if data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][sig]!=f['functionSelector']:raise ValueError('Selector disagreement')
        entries.append({'signature':sig,'selector':f['functionSelector'],'symbol':f['name']})
    if len(fs)!=5:raise ValueError('Rendering inventory')
    def slot(node,key,name):
        if isinstance(node,dict) and node.get('nodeType')=='Assignment' and node.get('operator')=='*=':slots[name]='('+expr(node['leftHandSide'])+' * '+expr(node[key])+')'
        else:slots[name]=expr(node[key])
        node[key]={'translated-slot':name}
    helper=next(f for f in fs.values() if f['name']=='_parseUnits');r=helper['body']['statements'];slot(r[0],'condition','PRECISION');slot(r[1],'condition','EMPTY');slot(r[2]['expression'],'rightHandSide','NEGATIVE');slot(r[3],'condition','UNSIGNED_MINUS');slot(r[4],'initialValue','START');loop=r[9];slot(loop,'condition','LOOP');body=loop['body']['statements'];slot(body[1],'condition','POINT');slot(body[2],'condition','BAD');slot(body[4],'condition','DROP');slot(body[4]['trueBody']['statements'][0],'condition','STICKY');assignment=body[4]['falseBody']['statements'][0]['expression'];slots['PRODUCT']=expr(assignment['rightHandSide']['leftExpression']);slot(assignment,'rightHandSide','ACCUMULATE');slot(body[4]['falseBody']['statements'][1],'condition','FRACTIONAL');slot(r[10],'condition','NO_DIGITS');slot(r[11]['expression'],'rightHandSide','SCALE');slot(r[12],'condition','ROUND')
    for f in fs.values():
        if f['name']=='parseUnits':slot(f['body']['statements'][0]['initialValue']['arguments'],3,'SIGNED_MODE')
        elif f['name']=='parseUnitsUnsigned':slot(f['body']['statements'][0]['initialValue']['arguments'],3,'UNSIGNED_MODE')
    structure={name:form(f) for name,f in fs.items()}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete parse-units AST/selector drift')
    code=(HERE/'Control.template.dfy').read_text()
    for name,value in slots.items():code=code.replace('$'+name+'$',value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code);(out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0));(out/'mapping.json').write_text(json.dumps({'entries':entries,'slots':slots,'sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
