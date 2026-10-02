#!/usr/bin/env python3
"""Gate five complete bodies and translate both public decimal-render controls."""
import argparse,copy,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
SOURCES=['contracts/Operations.sol','contracts/lib/AbiCodec.sol','node_modules/@openzeppelin/contracts/utils/math/Math.sol','node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol','node_modules/@openzeppelin/contracts/utils/Panic.sol']
NAMES={'toString','_magnitude'}
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:form(v) for k,v in n.items() if k not in ignored}
def expr(n):
    k=n['nodeType']
    if k=='Identifier':return n['name']
    if k=='Literal':
        if n['kind']=='string' and len(n['hexValue'])==2:return str(int(n['hexValue'],16))
        if n['kind']=='number':return str(int(n['value'],0))
    if k=='TupleExpression' and len(n['components'])==1:return expr(n['components'][0])
    if k=='MemberAccess' and n['memberName']=='length':return '|'+expr(n['expression'])+'|'
    if k=='IndexAccess':return expr(n['baseExpression'])+'['+expr(n['indexExpression'])+']'
    if k=='BinaryOperation' and n['operator'] in {'<','>','<=','>=','==','!=','+','-','*','/','||','&&','%'}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    if k=='Conditional':return '(if '+expr(n['condition'])+' then '+expr(n['trueExpression'])+' else '+expr(n['falseExpression'])+')'
    if k=='FunctionCall' and n['kind']=='typeConversion' and n['expression']['typeName']['name'] in {'uint8','bytes1'}:return '('+expr(n['arguments'][0])+(' as bv8)' if n['expression']['typeName']['name']=='bytes1' else ')')
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
        f=copy.deepcopy(x);ts=[z['typeDescriptions']['typeString'].replace(' calldata','') for z in f['parameters']['parameters']];sig=f['name']+'('+','.join(ts)+')';fs[sig]=f
        if f['name'].startswith('_'):continue
        if data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][sig]!=f['functionSelector']:raise ValueError('Selector disagreement')
        entries.append({'signature':sig,'selector':f['functionSelector'],'symbol':f['name']})
    if len(fs)!=3:raise ValueError('Rendering inventory')
    def slot(node,key,name):
        slots[name]='('+expr(node['leftHandSide'])+' / '+expr(node[key])+')' if node.get('nodeType')=='Assignment' and node.get('operator')=='/=' else expr(node[key]);node[key]={'translated-slot':name}
    r=fs['toString(uint256)']['body']['statements'];slot(r[0],'condition','ZERO');loop=r[2];slot(loop,'condition','COUNT_LOOP');slot(loop['loopExpression']['expression'],'rightHandSide','COUNT_DIV');loop=r[4];slot(loop,'condition','WRITE_LOOP');slot(loop['loopExpression']['expression'],'rightHandSide','WRITE_DIV');slot(loop['body']['statements'][1]['expression'],'rightHandSide','DIGIT')
    n=fs['toString(int256)']['body']['statements'][0]['expression']['arguments'][0];slot(n,'condition','NEGATIVE')
    structure={name:form(f) for name,f in fs.items()}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete decimal-render AST/selector drift')
    code=(HERE/'Control.template.dfy').read_text()
    for name,value in slots.items():code=code.replace('$'+name+'$',value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code);(out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0));(out/'mapping.json').write_text(json.dumps({'entries':entries,'slots':slots,'sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
