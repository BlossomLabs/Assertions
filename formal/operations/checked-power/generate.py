#!/usr/bin/env python3
"""Gate the complete concat/copy bodies and translate the loops and opcode operands."""
import argparse,copy,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
SOURCES=['contracts/Operations.sol','contracts/lib/AbiCodec.sol','node_modules/@openzeppelin/contracts/utils/math/Math.sol','node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol','node_modules/@openzeppelin/contracts/utils/Panic.sol']
NAMES={'exp'}
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:form(v) for k,v in n.items() if k not in ignored}
def expr(n):
    k=n['nodeType']
    if k=='Identifier':return n['name']
    if k=='Literal' and n['kind']=='number':return str(int(n['value'],0))
    if k=='TupleExpression' and len(n['components'])==1:return expr(n['components'][0])
    if k=='BinaryOperation':
        a,b=expr(n['leftExpression']),expr(n['rightExpression']);op=n['operator']
        if op in {'*','+','-','==','!='}:return '('+a+' '+op+' '+b+')'
        if op=='**':return 'M.Power('+a+','+b+')'
        if op=='&' and b=='1':return '('+a+' % 2)'
    raise ValueError('Unsupported power expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
    req={'language':'Solidity','sources':{p.replace('node_modules/',''):{'content':(root/p).read_text()} for p in SOURCES},'settings':{'evmVersion':'cancun','optimizer':{'enabled':True,'runs':200},'outputSelection':{'*':{'':['ast'],'*':['abi','evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(x['severity']=='error' for x in data.get('errors',[])):raise ValueError(data['errors'])
    c=next(x for x in data['sources']['contracts/Operations.sol']['ast']['nodes'] if x.get('name')=='Operations');fs={};entries=[];slots={}
    for f in c['nodes']:
        if f.get('nodeType')!='FunctionDefinition' or f['name']!='exp':continue
        ts=[x['typeDescriptions']['typeString'] for x in f['parameters']['parameters']];sig='exp('+','.join(ts)+')';key='Unsigned' if ts[0]=='uint256' else 'Signed';fs[key]=copy.deepcopy(f)
        if data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][sig]!=f['functionSelector']:raise ValueError('Selector disagreement')
        entries.append({'signature':sig,'selector':f['functionSelector'],'symbol':key})
    if len(fs)!=2:raise ValueError('Power inventory')
    def slot(node,key,name):slots[name]=expr(node[key]);node[key]={'translated-slot':name}
    slot(fs['Unsigned']['body']['statements'][0],'expression','UNSIGNED');loop=fs['Signed']['body']['statements'][1];slot(loop,'condition','LOOP');b=loop['body']['statements'];slot(b[0],'condition','ODD');slot(b[2],'condition','SQUARE_GUARD')
    for node,key in [(b[0]['trueBody'],'PRODUCT'),(b[2]['trueBody'],'SQUARE')]:
        e=node['expression'];slots[key]='('+expr(e['leftHandSide'])+' * '+expr(e['rightHandSide'])+')';e['rightHandSide']={'translated-slot':key}
    e=b[1]['expression']
    if e['operator']!='>>=' or expr(e['rightHandSide'])!='1':raise ValueError('Shift must be one bit')
    slots['HALF']='('+expr(e['leftHandSide'])+' / 2)';e['rightHandSide']={'translated-slot':'HALF'}
    structure={name:form(f) for name,f in fs.items()}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete checked-power AST/selector drift')
    code=(HERE/'Control.template.dfy').read_text()
    for name,value in slots.items():code=code.replace('$'+name+'$',value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code);(out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0));(out/'mapping.json').write_text(json.dumps({'entries':entries,'slots':slots,'sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
