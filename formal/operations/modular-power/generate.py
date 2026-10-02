#!/usr/bin/env python3
"""Gate all public powMod bodies, complete helpers, corrected sequenced call/size guard and selectors."""
import argparse,copy,gzip,importlib.util,json,hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('inverse',HERE/'generate-inverse.py');inverse=importlib.util.module_from_spec(spec);spec.loader.exec_module(inverse);dep=inverse.dep;SOURCES=dep.SOURCES

def expr(n):
    k=n.get('nodeType')
    if k=='BinaryOperation':
        a,b=expr(n['leftExpression']),expr(n['rightExpression']);op=n['operator']
        if op=='%':return '('+a+'%'+b+')'
        if op in {'==','!=','<','>','<=','>='}:return '('+a+' '+op+' '+b+')'
        if op in {'&&','||'}:return '('+a+' '+op+' '+b+')'
        if op=='&':
            if n['leftExpression'].get('typeDescriptions',{}).get('typeString')=='int256':a='(('+a+')%B.Word)'
            return 'I.And('+a+','+b+')'
        if op=='>>':return 'P.Multiply(1,'+a+')/B.Power('+b+')'
    if k=='Identifier' and n['name']=='POW_MOD_PRECOMPILE_THRESHOLD':return str(2**32)
    if k=='FunctionCall' and n['expression'].get('name')=='mulmod':return 'P.Multiply('+expr(n['arguments'][0])+','+expr(n['arguments'][1])+')%'+expr(n['arguments'][2])
    return dep.expr(n)
def arguments(node):return ','.join(expr(x) for x in node['arguments'])
def generate(solc,root,out,bootstrap=False):
    out.mkdir(parents=True,exist_ok=True);inverse.generate(solc,root,out)
    data=json.loads(gzip.decompress((out/'muldiv-regenerated/solc-output.json.gz').read_bytes()))
    ops=next(x for x in data['sources']['contracts/Operations.sol']['ast']['nodes'] if x.get('name')=='Operations');nodes=ops['nodes'];fs={};entries=[];slots={};bindings=[]
    for node in nodes:
        if node.get('nodeType')=='FunctionDefinition' and node.get('name')=='powMod':
            types=[p['typeDescriptions']['typeString'] for p in node['parameters']['parameters']];key=('U' if types[0]=='uint256' else 'S')+('U' if types[1]=='uint256' else 'S');f=copy.deepcopy(node);fs[key]=f;signature='powMod('+','.join(types)+')';selector=data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][signature]
            if selector!=f['functionSelector']:raise ValueError('Public selector disagreement')
            entries.append({'signature':signature,'selector':selector,'symbol':key})
        elif node.get('name') in {'_powMod','_inverseMod','POW_MOD_PRECOMPILE_THRESHOLD','ModularInverseDoesNotExist'}:fs[node['name']]=copy.deepcopy(node)
    if len(fs)!=8 or len(entries)!=4:raise ValueError('Complete powMod inventory')
    if dep.literal(fs['POW_MOD_PRECOMPILE_THRESHOLD']['value'])!=2**32:raise ValueError('Threshold changed')
    targets={name:next(x['id'] for x in nodes if x.get('nodeType')=='FunctionDefinition' and x.get('name')==name) for name in ['_powMod','_inverseMod','_magnitude','_signedMagnitude']}
    targets['ModularInverseDoesNotExist']=fs['ModularInverseDoesNotExist']['id']
    math=next(x for x in data['sources']['@openzeppelin/contracts/utils/math/Math.sol']['ast']['nodes'] if x.get('name')=='Math')
    mathinv=next(x['id'] for x in math['nodes'] if x.get('nodeType')=='FunctionDefinition' and x.get('name')=='invMod')
    def bind(node,caller):
        if isinstance(node,list):
            for x in node:bind(x,caller)
        elif isinstance(node,dict):
            if node.get('nodeType')=='FunctionCall' and node.get('kind')=='functionCall':
                c=node['expression'];name=c.get('name') or c.get('memberName')
                if name=='mulmod':
                    if c.get('referencedDeclaration',0)>=0:raise ValueError('MULMOD builtin target')
                else:
                    target=mathinv if name=='invMod' and c.get('expression',{}).get('name')=='Math' else targets.get(name)
                    if target is None or c.get('referencedDeclaration')!=target:raise ValueError('Unbound reached call '+caller+'/'+str(name))
                    bindings.append({'caller':caller,'callee':name,'compilerDeclaration':target})
            if node.get('nodeType')=='Identifier' and node.get('name')=='POW_MOD_PRECOMPILE_THRESHOLD' and node.get('referencedDeclaration')!=fs['POW_MOD_PRECOMPILE_THRESHOLD']['id']:raise ValueError('Threshold target')
            for v in node.values():bind(v,caller)
    for name,f in fs.items():bind(f,name)
    b=fs['_powMod']['body']['statements'];loop=b[3]['body']['statements'];slots['INITIAL_RESULT']=expr(b[0]['expression']['rightHandSide']);slots['INITIAL_BASE']='(base%modulus)';slots['THRESHOLD_GUARD']=expr(b[2]['condition']);slots['LOOP']=expr(b[3]['condition']);slots['SELECTED']=expr(loop[0]['condition']);slots['SELECTED_VALUE']=expr(loop[0]['trueBody']['expression']['rightHandSide']);slots['SHIFT']='(exponent/B.Power('+str(dep.literal(loop[1]['expression']['rightHandSide']))+'))';slots['REMAINING']=expr(loop[2]['condition'])
    square=loop[2]['trueBody']['expression']['rightHandSide'];slots['SQUARE_VALUE']=expr(square);square['arguments']={'translated-slot':'SQUARE_VALUE'};slots['RETURN_VALUE']=fs['_powMod']['returnParameters']['parameters'][0]['name']
    asm=b[2]['trueBody']['statements'][1]['AST']['statements'];stores=[]
    if len(asm)!=9 or asm[0]['nodeType']!='YulVariableDeclaration' or asm[0]['value']['functionName']['name']!='mload':raise ValueError('Complete call assembly sequence')
    for index,node in enumerate(asm[1:7],1):
        call=node['expression'];args=call['arguments']
        if call['functionName']['name']!='mstore':raise ValueError('Request store')
        offset=dep.yul(args[0]);value=dep.yul(args[1]);previous='memory' if index==1 else 'state'+str(index-1);stores.append('    var state'+str(index)+' := R.Store('+previous+','+offset+','+value+');')
    slots['REQUEST_STORES']='\n'.join(stores)
    success=asm[7]
    if success['nodeType']!='YulVariableDeclaration' or success['variables'][0]['name']!='success' or success['value']['functionName']['name']!='staticcall':raise ValueError('STATICCALL must execute in separate declaration before return-size guard')
    args=success['value']['arguments'];slots['CALL_TARGET']=dep.yul(args[1]);slots['CALL_INPUT_SIZE']=dep.yul(args[3])
    if args[0]['functionName']['name']!='gas' or dep.yul(args[2])!='p' or dep.yul(args[4])!='p' or dep.yul(args[5])!='32':raise ValueError('Actual call inputs/output footprint')
    guard=asm[8]['condition']
    if guard['functionName']['name']!='and' or guard['arguments'][0].get('name')!='success':raise ValueError('Sequenced call guard')
    size=guard['arguments'][1]
    if size['functionName']['name']!='eq' or size['arguments'][0]['functionName']['name']!='returndatasize':raise ValueError('Fresh receipt size observation')
    slots['EXPECTED_RETURN_SIZE']=dep.yul(size['arguments'][1]);slots['CALL_GUARD']='I.And(success,B.Bool(returnedSize == '+slots['EXPECTED_RETURN_SIZE']+')) != 0'
    slots['LOAD_RESULT_OFFSET']=dep.yul(asm[8]['body']['statements'][0]['value']['arguments'][0])
    ib=fs['_inverseMod']['body']['statements'];slots['INVERSE_ZERO']=expr(ib[1]['condition']['leftExpression']);slots['INVERSE_MISSING']=expr(ib[1]['condition']['rightExpression']);slots['INVERSE_ERROR_ARGUMENTS']=arguments(ib[1]['trueBody']['errorCall'])
    slots['UU_ARGUMENTS']=arguments(fs['UU']['body']['statements'][0]['expression'])
    su=fs['SU']['body']['statements'][0]['expression'];slots['SU_NEGATIVE']=expr(su['arguments'][1])
    us=fs['US']['body']['statements'][0]['expression']['arguments'][0];slots['US_NEGATIVE']=expr(us['condition']);slots['US_INVERSE_ARGUMENTS']=arguments(us['trueExpression'])
    ss=fs['SS']['body']['statements'];slots['SS_NEGATIVE']=expr(ss[2]['condition']);slots['SS_INVERSE_ARGUMENTS']=arguments(ss[2]['trueBody']['expression']['rightHandSide']);slots['SS_RESTORE_NEGATIVE']=expr(ss[3]['expression']['arguments'][1])
    structure={name:dep.form(f) for name,f in fs.items()}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete corrected powMod/helper AST or selectors drift')
    code=(HERE/'Control.template.dfy').read_text()
    for name,value in slots.items():code=code.replace('$'+name+'$',value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    (out/'Control.generated.dfy').write_text(code)
    for filename in ['Control.generated.dfy','Inverse.generated.dfy']:
        text=(out/filename).read_text();lines=text.splitlines();headers=[x for x in lines if x.startswith('include ')]
        body='\n'.join(x for x in lines if not x.startswith('include '))+'\n'
        formatted=dep.subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=body,text=True,check=True,capture_output=True).stdout
        (out/filename).write_text('\n'.join(headers)+'\n'+formatted)
    (out/'mapping.json').write_text(json.dumps({'entries':entries,'slots':slots,'helperBindings':bindings,'callOrder':'Separate STATICCALL success declaration then fresh RETURNDATASIZE guard, complete AST gated.','sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
