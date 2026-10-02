#!/usr/bin/env python3
"""Gate the complete contains/matcher bodies and translate the loops and opcode operands."""
import argparse,copy,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
SOURCES=['contracts/Operations.sol','contracts/lib/AbiCodec.sol','node_modules/@openzeppelin/contracts/utils/math/Math.sol','node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol','node_modules/@openzeppelin/contracts/utils/Panic.sol']
NAMES={'contains','_matchesAt'}
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:form(v) for k,v in n.items() if k not in ignored}
def expr(n):
    k=n['nodeType']
    if k=='Identifier':return n['name']
    if k=='Literal' and n['kind']=='number':return str(int(n['value'],0))
    if k=='MemberAccess' and n['memberName']=='length':return '|'+expr(n['expression'])+'|'
    if k=='BinaryOperation' and n['operator'] in {'<','>','<=','>=','==','!=','+','-','||','&&'}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    if k=='UnaryOperation' and n['operator']=='!':return '!('+expr(n['subExpression'])+')'
    if k=='FunctionCall' and n['expression'].get('name')=='_matchesAt' and [x.get('name') for x in n['arguments']]==['s','needle','i']:return 'matched'
    raise ValueError('Unsupported matcher expression '+str(n))
def yul(n):
    k=n['nodeType']
    if k=='YulIdentifier':return {'s.offset':'sOffset','needle.offset':'needleOffset'}.get(n['name'],n['name'])
    if k=='YulLiteral':return str(int(n['value'],0))
    if k=='YulFunctionCall':
        op=n['functionName']['name'];a=[yul(x) for x in n['arguments']]
        if op in {'add','sub'} and len(a)==2:return '(('+a[0]+(' + ' if op=='add' else ' - ')+a[1]+') % M.Word)'
        if op in {'lt','eq'} and len(a)==2:return '('+a[0]+(' < ' if op=='lt' else ' == ')+a[1]+')'
        if op=='iszero' and len(a)==1:return '!'+a[0]
        if op in {'shr','shl'} and len(a)==2:return 'M.'+op.title()+'('+','.join(a)+')'
    raise ValueError('Unsupported matcher Yul '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
    req={'language':'Solidity','sources':{p.replace('node_modules/',''):{'content':(root/p).read_text()} for p in SOURCES},'settings':{'evmVersion':'cancun','optimizer':{'enabled':True,'runs':200},'outputSelection':{'*':{'':['ast'],'*':['abi','evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(x['severity']=='error' for x in data.get('errors',[])):raise ValueError(data['errors'])
    c=next(x for x in data['sources']['contracts/Operations.sol']['ast']['nodes'] if x.get('name')=='Operations');fs={x['name']:copy.deepcopy(x) for x in c['nodes'] if x.get('nodeType')=='FunctionDefinition' and x['name'] in NAMES}
    if len(fs)!=2:raise ValueError('Matcher inventory')
    entries=[];slots={}
    for name,f in fs.items():
        if name.startswith('_'):continue
        ts=[x['typeDescriptions']['typeString'].replace(' calldata','') for x in f['parameters']['parameters']];sig=name+'('+','.join(ts)+')'
        if data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][sig]!=f['functionSelector']:raise ValueError('Selector disagreement')
        entries.append({'signature':sig,'selector':f['functionSelector'],'symbol':name})
    def slot(node,key,name):slots[name]=expr(node[key]);node[key]={'translated-slot':name}
    r=fs['contains']['body']['statements'];slot(r[0],'condition','EMPTY');slot(r[1],'condition','TOO_LONG');slot(r[2],'condition','CONTAINS_LOOP');slot(r[2]['body']['statements'][0],'condition','FOUND')
    r=fs['_matchesAt']['body']['statements'][0]['AST']['statements']
    def ys(node,key,name):slots[name]=yul(node[key]);node[key]={'translated-slot':name}
    ys(r[2],'value','A');loop=r[3];ys(loop,'condition','MATCH_LOOP');ys(loop['post']['statements'][0],'value','MATCH_NEXT');b=loop['body']['statements']
    for idx,key in [(0,'X_ADDRESS'),(1,'Y_ADDRESS')]:
        load=b[idx]['value'];slots[key]=yul(load['arguments'][0]);load['arguments'][0]={'translated-slot':key}
    ys(b[2],'value','LEFT');ys(b[3],'condition','TAIL');tb=b[3]['body']['statements'];ys(tb[0],'value','DROP');ys(tb[1],'value','SHIFT_X');ys(tb[2],'value','SHIFT_Y');ys(b[4],'condition','MISMATCH')
    structure={name:form(f) for name,f in fs.items()}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete matcher AST/selector drift')
    code=(HERE/'Control.template.dfy').read_text()
    for name,value in slots.items():code=code.replace('$'+name+'$',value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code);(out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0));(out/'mapping.json').write_text(json.dumps({'entries':entries,'slots':slots,'sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
