#!/usr/bin/env python3
"""Gate Operations.sqrt and its complete Math/SafeCast callees; lower opcode operands."""
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
    if k=='Literal' and n['kind']=='number':return str(int(n['value'],0))
    if k=='TupleExpression' and len(n['components'])==1:return expr(n['components'][0])
    if k=='BinaryOperation':
        a,b=expr(n['leftExpression']),expr(n['rightExpression']);op=n['operator']
        if op in {'>=','<=','>','<','/'}:return '('+a+' '+op+' '+b+')'
        if op in {'+','-','*'}:return '(('+a+' '+op+' '+b+') % B.Word)'
        if op=='<<':return '(('+a+' * B.Power('+b+')) % B.Word)'
        if op=='>>':return '('+a+' / B.Power('+b+'))'
    raise ValueError('Unsupported root expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
    req={'language':'Solidity','sources':{p.replace('node_modules/',''):{'content':(root/p).read_text()} for p in SOURCES},'settings':{'evmVersion':'cancun','optimizer':{'enabled':True,'runs':200},'outputSelection':{'*':{'':['ast'],'*':['abi','evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(x['severity']=='error' for x in data.get('errors',[])):raise ValueError(data['errors'])
    def contract(p,name):return next(x for x in data['sources'][p]['ast']['nodes'] if x.get('name')==name)
    ops=contract('contracts/Operations.sol','Operations');math=contract('@openzeppelin/contracts/utils/math/Math.sol','Math');cast=contract('@openzeppelin/contracts/utils/math/SafeCast.sol','SafeCast')
    public=copy.deepcopy(next(x for x in ops['nodes'] if x.get('nodeType')=='FunctionDefinition' and x.get('name')=='sqrt'))
    library=copy.deepcopy(next(x for x in math['nodes'] if x.get('name')=='sqrt' and len(x['parameters']['parameters'])==1))
    boolean=copy.deepcopy(next(x for x in cast['nodes'] if x.get('name')=='toUint' and x['parameters']['parameters'][0]['typeDescriptions']['typeString']=='bool'))
    sig='sqrt(uint256)';selector=public['functionSelector']
    if data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][sig]!=selector:raise ValueError('Selector disagreement')
    entries=[{'signature':sig,'selector':selector,'symbol':'Public'}];slots={};body=library['body']['statements'][0]['statements']
    slots['EARLY']=expr(body[0]['condition']);slots['INITIAL']=expr(body[10]['expression']['rightHandSide'])
    for i in range(6):
        n=body[11+i]['expression'];slots['NEWTON'+str(i+1)]=expr(n['rightHandSide']);n['rightHandSide']={'translated-slot':'NEWTON'+str(i+1)}
    final=body[17]['expression']['rightExpression']['arguments'];slots['FINAL']=expr(final[0]);final[0]={'translated-slot':'FINAL'}
    stagecode=[];methods=[];bound=0
    for index in range(7):
        stage=body[3+index];condition=expr(stage['condition']);bs=stage['trueBody']['statements'];shift=bs[-1]['expression']
        k=int(shift['rightHandSide']['value']);threshold=2*k
        if shift['operator']!='<<=' or shift['leftHandSide']['name']!='xn':raise ValueError('Seed shift')
        methods += [f'  method Seed{k}(a: nat,aa: nat,xn: nat,ghost e: nat) returns (nextAA: nat,nextXN: nat,ghost nextE: nat)',
          f'    requires e+{k} <= 127 && aa == a/B.Power(2*e) && xn == B.Power(e)',
          f'    requires 1 <= aa < B.Power({4*k})',
          f'    ensures nextE == e+(if aa >= B.Power({threshold}) then {k} else 0)',
          f'    ensures nextE <= e+{k} && nextXN == B.Power(nextE)',
          f'    ensures 1 <= a/B.Power(2*nextE) < B.Power({threshold})']
        if index<6:methods += ['    ensures nextAA == a/B.Power(2*nextE)']
        else:methods += ['    ensures nextAA == aa']
        methods += ['  {','    B.KnownPowers();',f'    S.Advance(a,e,{k},aa,xn);','    nextAA,nextXN,nextE := aa,xn,e;',f'    if {condition} {{']
        if index<6:
            ar=bs[0]['expression']
            if ar['operator']!='>>=' or ar['leftHandSide']['name']!='aa' or int(ar['rightHandSide']['value'])!=threshold:raise ValueError('Seed quotient')
            methods += [f'      nextAA := aa/B.Power({threshold});']
        methods += [f'      assert xn*B.Power({k}) == B.Power(e+{k});',f'      S.PowerMonotone(e+{k},127);',
          '      assert B.Power(128) == 2*B.Power(127);',f'      assert xn*B.Power({k}) < B.Word;',
          f'      nextXN := (xn*B.Power({k})) % B.Word;',f'      nextE := e+{k};','    }','  }']
        stagecode += [f'    assert e <= {bound};',f'    aa,xn,e := Seed{k}(a,aa,xn,e);']
        bound+=k
    slots['STAGES']='\n'.join(stagecode)
    slots['STAGE_METHODS']='\n'.join(methods)
    updates=[]
    for i in range(1,7):
        updates += [f'  method Update{i}(a: nat,t: nat,xn: nat,ghost r: nat) returns (next: nat)',
          '    requires 1 <= t <= B.Power(127) && t*t <= a < 4*t*t',
          '    requires M.Root(a,r) && t <= r && t <= xn <= 8*t+8',
          '    ensures next == M.Newton(a,xn) && t <= next <= 8*t+8','  {',
          '    B.KnownPowers();','    S.Coarse(a,t,xn);','    M.NewtonLower(a,xn,r);',
          '    next := '+slots['NEWTON'+str(i)]+';','  }']
    slots['UPDATE_METHODS']='\n'.join(updates)
    y=boolean['body']['statements'][0]['AST']['statements'][0]['value']
    def yexpr(n):
        if n['nodeType']=='YulIdentifier' and n['name']=='b':return 'B.Bool(b)'
        if n['nodeType']=='YulFunctionCall' and n['functionName']['name']=='iszero' and len(n['arguments'])==1:return 'B.Iszero('+yexpr(n['arguments'][0])+')'
        raise ValueError('Bool lowering')
    slots['CAST']=yexpr(y)
    structure={'public':form(public),'library':form(library),'boolean':form(boolean)}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete root AST/selector drift')
    code=(HERE/'Control.template.dfy').read_text()
    for name,value in slots.items():code=code.replace('$'+name+'$',value)
    if '$' in code:raise ValueError('Unexpanded slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code);(out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0));(out/'mapping.json').write_text(json.dumps({'entries':entries,'slots':slots,'sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
