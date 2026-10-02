#!/usr/bin/env python3
"""Gate full public/OZ/SafeCast bodies; generate exact reduction and lookup controls."""
import argparse,copy,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
SOURCES=['contracts/Operations.sol','contracts/lib/AbiCodec.sol','node_modules/@openzeppelin/contracts/utils/math/Math.sol','node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol','node_modules/@openzeppelin/contracts/utils/Panic.sol']
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:form(v) for k,v in n.items() if k not in ignored}
def expr(n):
    k=n['nodeType']
    if k=='Identifier':return n['name']
    if k=='TupleExpression' and len(n['components'])==1:return expr(n['components'][0])
    if k=='Literal' and n['kind']=='number':return str(int(n['value'],0))
    if k=='BinaryOperation':
        a,b=expr(n['leftExpression']),expr(n['rightExpression']);op=n['operator']
        if op in {'>','==','!='}:return '('+a+' '+op+' '+b+')'
        if op=='>>':return '('+a+'/M.Power('+b+' as int))'
        if op=='<<':return '(('+a+' as bv8) << '+b+')'
    if k=='FunctionCall' and n['expression'].get('memberName')=='toUint' and n['expression']['expression'].get('name')=='SafeCast' and len(n['arguments'])==1:return 'ToUint('+expr(n['arguments'][0])+')'
    raise ValueError('Unsupported logarithm expression '+str(n))
def yul(n):
    k=n['nodeType']
    if k=='YulIdentifier':return 'M.Bool(b)' if n['name']=='b' else n['name']
    if k=='YulLiteral':return str(int(n['value'],0))
    if k=='YulFunctionCall':
        op=n['functionName']['name'];a=[yul(x) for x in n['arguments']]
        if op=='iszero' and len(a)==1:return 'M.Iszero('+a[0]+')'
        if op=='shr' and len(a)==2:return '('+a[1]+'/M.Power('+a[0]+' as int))'
        if op=='byte' and len(a)==2:return '(M.Byte('+','.join(a)+') as bv8)'
        if op=='or' and len(a)==2:return 'M.Or('+','.join(a)+')'
    raise ValueError('Unsupported logarithm Yul '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
    req={'language':'Solidity','sources':{p.replace('node_modules/',''):{'content':(root/p).read_text()} for p in SOURCES},'settings':{'evmVersion':'cancun','optimizer':{'enabled':True,'runs':200},'outputSelection':{'*':{'':['ast'],'*':['abi','evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(x['severity']=='error' for x in data.get('errors',[])):raise ValueError(data['errors'])
    fs={}
    for file,contract,name,kind in [('contracts/Operations.sol','Operations','log2','uint256'),('@openzeppelin/contracts/utils/math/Math.sol','Math','log2','uint256'),('@openzeppelin/contracts/utils/math/SafeCast.sol','SafeCast','toUint','bool')]:
        c=next(x for x in data['sources'][file]['ast']['nodes'] if x.get('name')==contract)
        f=next(x for x in c['nodes'] if x.get('name')==name and x.get('nodeType')=='FunctionDefinition' and len(x['parameters']['parameters'])==1 and x['parameters']['parameters'][0]['typeDescriptions']['typeString']==kind)
        fs[contract+'.'+name]=copy.deepcopy(f)
    f=fs['Operations.log2'];sig='log2(uint256)';entries=[{'signature':sig,'selector':f['functionSelector'],'symbol':'log2'}]
    if data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][sig]!=f['functionSelector']:raise ValueError('Selector disagreement')
    slots={};r=f['body']['statements'];slots['ZERO']=expr(r[0]['condition']);r[0]['condition']={'translated-slot':'ZERO'}
    r=fs['SafeCast.toUint']['body']['statements'][0]['AST']['statements'][0];slots['CAST']=yul(r['value']);r['value']={'translated-slot':'CAST'}
    r=fs['Math.log2']['body']['statements'];stages=[]
    for i,step in enumerate([128,64,32,16,8,4]):
        e=r[i]['expression'];slots['FLAG_'+str(i)]=expr(e['rightHandSide']);e['rightHandSide']={'translated-slot':'FLAG_'+str(i)}
        stages.append('''    {
      var previous := r;
      var flag := $FLAG_'''+str(i)+'''$;
      r := M.Or(previous,flag);
      assert flag == (if x/M.Power(previous as int) >= M.Power('''+str(step)+''') then '''+str(step)+''' as bv8 else 0);
      assert previous&('''+str(step)+''' as bv8) == 0 && (previous as int)+'''+str(step)+''' < 256;
      M.Stage(x,previous,'''+str(step)+''',r);
      assert r&('''+str(step-1)+''' as bv8) == 0;
      assert M.Log(x) == (r as int)+M.Log(x/M.Power(r as int));
    }''')
    ret=r[6]['AST']['statements'][0]['value'];slots['RETURN']=yul(ret);table=ret['arguments'][1]['arguments'][1];slots['TABLE']=yul(table);ret['arguments'][1]['arguments'][1]={'translated-slot':'TABLE'};r[6]['AST']['statements'][0]['value']={'translated-slot':'RETURN'}
    structure={name:form(f) for name,f in fs.items()}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete Operations/Math/SafeCast AST drift')
    code=(HERE/'Control.template.dfy').read_text().replace('$STAGES$','\n'.join(stages))
    for name,value in slots.items():code=code.replace('$'+name+'$',value)
    if '$' in code:raise ValueError('Unexpanded slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code);(out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0));(out/'mapping.json').write_text(json.dumps({'entries':entries,'slots':slots,'sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
