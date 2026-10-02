#!/usr/bin/env python3
"""Gate the complete index/count bodies and translate the loops and opcode operands."""
import argparse,copy,gzip,hashlib,json,subprocess,importlib.util,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
SOURCES=['contracts/Operations.sol','contracts/lib/AbiCodec.sol','node_modules/@openzeppelin/contracts/utils/math/Math.sol','node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol','node_modules/@openzeppelin/contracts/utils/Panic.sol']
NAMES={'indexOf','_countOccurrences'}
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
    if k=='UnaryOperation' and n['operator'] in {'!','-'}:return n['operator']+'('+expr(n['subExpression'])+')'
    if k=='Conditional':return '(if '+expr(n['condition'])+' then '+expr(n['trueExpression'])+' else '+expr(n['falseExpression'])+')'
    if k=='FunctionCall' and n['expression'].get('name')=='_matchesAt' and [x.get('name') for x in n['arguments']]==['s','needle','p']:return 'matched'
    if k=='FunctionCall' and n['kind']=='typeConversion' and n['expression']['typeName']['name'] in {'uint256','int256'}:return expr(n['arguments'][0])
    raise ValueError('Unsupported occurrence expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    spec=importlib.util.spec_from_file_location('word_match_generator',root/'formal/operations/word-match/generate.py');dependency=importlib.util.module_from_spec(spec);spec.loader.exec_module(dependency)
    with tempfile.TemporaryDirectory(prefix='occurrence-matcher-gate-') as temp:
        dependency.generate(solc,root,Path(temp))
        if (Path(temp)/'Control.generated.dfy').read_bytes()!=(root/'formal/operations/word-match/Control.generated.dfy').read_bytes():raise ValueError('Reached matcher gate/regeneration drift')
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
    r=fs['indexOf']['body']['statements'];slot(r[0],'condition','EMPTY');er=r[0]['trueBody']['statements'];slot(er[0],'initialValue','EMPTY_COUNT');slot(er[1],'condition','POSITIVE');slot(er[1]['trueBody']['statements'][0],'expression','EMPTY_RESULT');slot(er[2],'condition','EMPTY_TOO_NEGATIVE');slot(er[3],'expression','EMPTY_NEGATIVE_RESULT')
    slot(r[2],'condition','NEGATIVE');nr=r[2]['trueBody']['statements'];slot(nr[1],'condition','TOO_NEGATIVE');slot(nr[2]['expression'],'rightHandSide','NEGATIVE_RESULT');slot(r[2]['falseBody']['statements'][0]['expression'],'rightHandSide','POSITIVE_RESULT');loop=r[5];slot(loop,'condition','INDEX_LOOP');branch=loop['body']['statements'][0];slot(branch,'condition','INDEX_FOUND');slot(branch['trueBody']['statements'][0],'condition','WANTED')
    def advance(node,key):
        e=node['expression'];slots[key]='('+expr(e['leftHandSide'])+' + '+expr(e['rightHandSide'])+')';e['rightHandSide']={'translated-slot':key}
    advance(branch['trueBody']['statements'][2],'INDEX_NEXT')
    r=fs['_countOccurrences']['body']['statements'];loop=r[1];slot(loop,'condition','COUNT_LOOP');branch=loop['body']['statements'][0];slot(branch,'condition','COUNT_FOUND');advance(branch['trueBody']['statements'][1],'COUNT_NEXT')
    structure={name:form(f) for name,f in fs.items()}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete occurrence AST/selector drift')
    code=(HERE/'Control.template.dfy').read_text()
    for name,value in slots.items():code=code.replace('$'+name+'$',value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code);(out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0));(out/'mapping.json').write_text(json.dumps({'entries':entries,'slots':slots,'sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
