#!/usr/bin/env python3
"""Gate the complete split bodies and translate the loops and opcode operands."""
import argparse,copy,gzip,hashlib,json,subprocess,importlib.util,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
SOURCES=['contracts/Operations.sol','contracts/lib/AbiCodec.sol','node_modules/@openzeppelin/contracts/utils/math/Math.sol','node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol','node_modules/@openzeppelin/contracts/utils/Panic.sol']
NAMES={'split'}
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
    if k=='IndexRangeAccess':return expr(n['baseExpression'])+'['+(expr(n['startExpression']) if n.get('startExpression') else '')+'..'+(expr(n['endExpression']) if n.get('endExpression') else '')+']'
    if k=='BinaryOperation' and n['operator'] in {'<','>','<=','>=','==','!=','+','-','||','&&'}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    if k=='UnaryOperation' and n['operator'] in {'!','-'}:return n['operator']+'('+expr(n['subExpression'])+')'
    if k=='Conditional':return '(if '+expr(n['condition'])+' then '+expr(n['trueExpression'])+' else '+expr(n['falseExpression'])+')'
    if k=='FunctionCall' and n['expression'].get('name')=='_matchesAt' and [x.get('name') for x in n['arguments']]==['data','delimiter','position']:return 'matched'
    if k=='FunctionCall' and n['kind']=='typeConversion' and n['expression']['typeName']['name'] in {'uint256','int256'}:return expr(n['arguments'][0])
    raise ValueError('Unsupported occurrence expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    spec=importlib.util.spec_from_file_location('word_match_generator',root/'formal/operations/occurrence-index/generate.py');dependency=importlib.util.module_from_spec(spec);spec.loader.exec_module(dependency)
    with tempfile.TemporaryDirectory(prefix='occurrence-matcher-gate-') as temp:
        dependency.generate(solc,root,Path(temp))
        if (Path(temp)/'Control.generated.dfy').read_bytes()!=(root/'formal/operations/occurrence-index/Control.generated.dfy').read_bytes():raise ValueError('Reached count/matcher gate/regeneration drift')
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
    req={'language':'Solidity','sources':{p.replace('node_modules/',''):{'content':(root/p).read_text()} for p in SOURCES},'settings':{'evmVersion':'cancun','optimizer':{'enabled':True,'runs':200},'outputSelection':{'*':{'':['ast'],'*':['abi','evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(x['severity']=='error' for x in data.get('errors',[])):raise ValueError(data['errors'])
    c=next(x for x in data['sources']['contracts/Operations.sol']['ast']['nodes'] if x.get('name')=='Operations');fs={x['name']:copy.deepcopy(x) for x in c['nodes'] if x.get('nodeType')=='FunctionDefinition' and x['name'] in NAMES}
    if len(fs)!=1:raise ValueError('Matcher inventory')
    entries=[];slots={}
    for name,f in fs.items():
        if name.startswith('_'):continue
        ts=[x['typeDescriptions']['typeString'].replace(' calldata','') for x in f['parameters']['parameters']];sig=name+'('+','.join(ts)+')'
        if data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][sig]!=f['functionSelector']:raise ValueError('Selector disagreement')
        entries.append({'signature':sig,'selector':f['functionSelector'],'symbol':name})
    def slot(node,key,name):slots[name]=expr(node[key]);node[key]={'translated-slot':name}
    r=fs['split']['body']['statements'];slot(r[0],'condition','EMPTY');loop=r[5];slot(loop,'condition','LOOP');branch=loop['body']['statements'][0];slot(branch,'condition','FOUND');b=branch['trueBody']['statements'];slot(b[0]['expression'],'rightHandSide','SEGMENT');e=b[1]['expression'];slots['NEXT']='('+expr(e['leftHandSide'])+' + '+expr(e['rightHandSide'])+')';e['rightHandSide']={'translated-slot':'NEXT'};slot(b[2]['expression'],'rightHandSide','START');slot(r[6]['expression'],'rightHandSide','LAST')
    structure={name:form(f) for name,f in fs.items()}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete split AST/selector drift')
    code=(HERE/'Control.template.dfy').read_text()
    for name,value in slots.items():code=code.replace('$'+name+'$',value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code);(out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0));(out/'mapping.json').write_text(json.dumps({'entries':entries,'slots':slots,'sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
