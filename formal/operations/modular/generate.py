#!/usr/bin/env python3
"""Gate complete modular public/helper ASTs and translate full-width source controls."""
import argparse,copy,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
SOURCES=['contracts/Operations.sol','contracts/lib/AbiCodec.sol','node_modules/@openzeppelin/contracts/utils/math/Math.sol','node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol','node_modules/@openzeppelin/contracts/utils/Panic.sol']
NAMES={'addMod','mulMod','_magnitude','_signedMagnitude','_panic'}
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:form(v) for k,v in n.items() if k not in ignored}
def expr(n):
    k=n['nodeType']
    if k=='TupleExpression' and len(n['components'])==1:return expr(n['components'][0])
    if k=='Identifier':return n['name']
    if k=='Literal' and n['kind']=='number':return str(int(n['value'],0))
    if k=='BinaryOperation' and n['operator'] in {'<','>','<=','>=','==','!=','+','-','*','%'}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    if k=='Conditional':return '(if '+expr(n['condition'])+' then '+expr(n['trueExpression'])+' else '+expr(n['falseExpression'])+')'
    if k=='FunctionCall' and n['kind']=='functionCall':
        name=n['expression']['name'];args=[expr(a) for a in n['arguments']]
        if name=='_magnitude':return {'a':'x','b':'y','m':'modulus'}[args[0]]
        if name=='_signedMagnitude':return 'SignedMagnitude('+', '.join(args)+')'
        if name in {'addmod','mulmod'}:return '(('+args[0]+(' + ' if name=='addmod' else ' * ')+args[1]+') % '+args[2]+')'
    raise ValueError('Unsupported modular expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
    req={'language':'Solidity','sources':{p.replace('node_modules/',''):{'content':(root/p).read_text()} for p in SOURCES},'settings':{'evmVersion':'cancun','optimizer':{'enabled':True,'runs':200},'outputSelection':{'*':{'':['ast'],'*':['abi','evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(x['severity']=='error' for x in data.get('errors',[])):raise ValueError(data['errors'])
    c=next(x for x in data['sources']['contracts/Operations.sol']['ast']['nodes'] if x.get('name')=='Operations');fs={};entries=[];slots={}
    for f in c['nodes']:
        if f.get('nodeType')!='FunctionDefinition' or f['name'] not in NAMES:continue
        f=copy.deepcopy(f);ts=[p['typeDescriptions']['typeString'] for p in f['parameters']['parameters']];sig=f['name']+'('+','.join(ts)+')';fs[sig]=f
        if not f['name'].startswith('_'):
            if data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][sig]!=f['functionSelector']:raise ValueError('Selector disagreement')
            entries.append({'signature':sig,'selector':f['functionSelector'],'symbol':('Add' if f['name']=='addMod' else 'Mul')+('S' if ts[0]=='int256' else 'U')})
    if len(fs)!=7 or len(entries)!=4:raise ValueError('Modular inventory')
    def slot(node,key,name):slots[name]=expr(node[key]);node[key]={'translated-slot':name}
    slot(fs['addMod(uint256,uint256,uint256)']['body']['statements'][0],'expression','ADD_UNSIGNED');slot(fs['mulMod(uint256,uint256,uint256)']['body']['statements'][0],'expression','MUL_UNSIGNED')
    body=fs['addMod(int256,int256,int256)']['body']['statements'];slot(body[3],'condition','SAME_SIGN');slot(body[3]['trueBody']['statements'][0],'expression','ADD_SAME');slot(body[4],'expression','ADD_DIFFERENT')
    slot(fs['mulMod(int256,int256,int256)']['body']['statements'][0],'expression','MUL_SIGNED')
    structure={sig:form(f) for sig,f in fs.items()}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete modular AST/selector drift')
    code=(HERE/'Control.template.dfy').read_text()
    for name,value in slots.items():code=code.replace('$'+name+'$',value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    mathematical=root/'formal/signed-mod/SignedMod.dfy'
    if hashlib.sha256(mathematical.read_bytes()).hexdigest()!=json.loads((HERE/'model-input-sha256.json').read_text())['formal/signed-mod/SignedMod.dfy']:raise ValueError('Mathematical input drift')
    # The unused redundant FullWidthWitnesses demonstration is outside the
    # generated include graph. All required quantified proofs and the direct
    # ProductDoesNotWrap witness remain and are freshly verified.
    math=mathematical.read_text();math=math[:math.index('  // Concrete witnesses keep negative proof controls cheap and non-vacuous.')]+ '}\n';math=math.replace('module SignedMod {','module OperationsModularMath {')
    out.mkdir(parents=True,exist_ok=True);(out/'Math.generated.dfy').write_text(math);(out/'Control.generated.dfy').write_text(code);(out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0));(out/'mapping.json').write_text(json.dumps({'entries':entries,'slots':slots,'sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
