#!/usr/bin/env python3
"""Gate complete Operations/OZ mulDiv callees and lower the reached source operands."""
import argparse,copy,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
SOURCES=['contracts/Operations.sol','contracts/lib/AbiCodec.sol','node_modules/@openzeppelin/contracts/utils/math/Math.sol','node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol','node_modules/@openzeppelin/contracts/utils/Panic.sol']
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:form(v) for k,v in n.items() if k not in ignored}
def literal(n):
    if n['nodeType']=='Literal' and n['kind']=='number':return int(n['value'],0)
    if n['nodeType']=='TupleExpression' and len(n['components'])==1:return literal(n['components'][0])
    if n['nodeType']=='FunctionCall' and n['kind']=='typeConversion' and len(n['arguments'])==1:
        return literal(n['arguments'][0])
    if n['nodeType']=='BinaryOperation' and n['operator']=='<<':return literal(n['leftExpression']) << literal(n['rightExpression'])
    raise ValueError('Nonliteral')
def expr(n,helper=False):
    try:return str(literal(n))
    except ValueError:pass
    k=n['nodeType'];signed='Signed' if helper else 'H.Signed';unsigned='Unsigned' if helper else None
    def wrap(code):
        if n.get('typeDescriptions',{}).get('typeString')=='int256':return signed+'('+code+')'
        return unsigned+'('+code+')' if unsigned else '(('+code+') % B.Word)'
    if k=='Identifier':return n['name']
    if k=='Literal' and n['kind']=='bool':return n['value']
    if k=='TupleExpression' and len(n['components'])==1:return expr(n['components'][0],helper)
    if k=='Conditional':return '(if '+expr(n['condition'],helper)+' then '+expr(n['trueExpression'],helper)+' else '+expr(n['falseExpression'],helper)+')'
    if k=='BinaryOperation':
        a,b=expr(n['leftExpression'],helper),expr(n['rightExpression'],helper);op=n['operator']
        if op in {'<','>','<=','>=','==','!='}:return '('+a+' '+op+' '+b+')'
        if op in {'&&','||'}:return '('+a+' '+op+' '+b+')'
        if op in {'+','-','*'}:return wrap(a+' '+op+' '+b)
        if op=='/':return 'P.Div('+a+','+b+')'
        if op in {'&','|','^'}:return 'I.'+{'&':'And','|':'Or','^':'Xor'}[op]+'('+a+','+b+')'
    if k=='UnaryOperation' and n['operator']=='-':return wrap('-'+expr(n['subExpression'],helper))
    if k=='UnaryOperation' and n['operator']=='!':return '!'+expr(n['subExpression'],helper)
    if k=='MemberAccess':
        if n['memberName'] in {'Trunc','Floor','Ceil'} and n['expression'].get('name')=='Rounding':return str({'Trunc':0,'Floor':1,'Ceil':2}[n['memberName']])
        if n['memberName']=='max' and n['expression'].get('nodeType')=='FunctionCall' and n['expression']['expression'].get('name')=='type':return '(Half-1)' if helper else '(M.Half-1)'
    if k=='FunctionCall':
        if n['kind']=='typeConversion':
            typ=n['expression']['typeName']['name'];v=expr(n['arguments'][0],helper)
            if typ=='uint256':return ('Unsigned('+v+')') if helper else '(('+v+') % B.Word)'
            if typ=='int256':return signed+'('+v+')'
        name=n['expression'].get('name');args=[expr(a,helper) for a in n['arguments']]
        if n['expression'].get('nodeType')=='MemberAccess' and n['expression'].get('memberName')=='toUint' and n['expression']['expression'].get('name')=='SafeCast':return 'ToUint('+','.join(args)+')'
        if name=='mulmod' and len(args)==3:return '(('+args[0]+' * '+args[1]+') % '+args[2]+')'
    raise ValueError('Unsupported mulDiv Solidity operand '+str(n))
def yul(n):
    if n['nodeType']=='YulIdentifier':return n['name']
    if n['nodeType']=='YulLiteral':return str(int(n['value'],0))
    if n['nodeType']=='YulFunctionCall':
        name=n['functionName']['name'];a=[yul(x) for x in n['arguments']]
        if name in {'add','sub','mul'}:return '(('+a[0]+' '+{'add':'+','sub':'-','mul':'*'}[name]+' '+a[1]+') % B.Word)'
        if name in {'lt','gt','eq'}:return 'B.Bool('+a[0]+' '+{'lt':'<','gt':'>','eq':'=='}[name]+' '+a[1]+')'
        if name=='iszero':return 'B.Iszero('+a[0]+')'
        if name=='not':return '(B.Word-1-'+a[0]+')'
        if name=='div':return 'OpcodeDiv('+','.join(a)+')'
        if name=='mulmod':return '(if '+a[2]+' == 0 then 0 else ('+a[0]+' * '+a[1]+') % '+a[2]+')'
    raise ValueError('Unsupported mulDiv Yul operand '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
    req={'language':'Solidity','sources':{p.replace('node_modules/',''):{'content':(root/p).read_text()} for p in SOURCES},'settings':{'evmVersion':'cancun','optimizer':{'enabled':True,'runs':200},'outputSelection':{'*':{'':['ast'],'*':['abi','evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(x['severity']=='error' for x in data.get('errors',[])):raise ValueError(data['errors'])
    def contract(p,name):return next(x for x in data['sources'][p]['ast']['nodes'] if x.get('name')==name)
    ops=contract('contracts/Operations.sol','Operations');math=contract('@openzeppelin/contracts/utils/math/Math.sol','Math');cast=contract('@openzeppelin/contracts/utils/math/SafeCast.sol','SafeCast');panic=contract('@openzeppelin/contracts/utils/Panic.sol','Panic')
    fs={};entries=[];slots={}
    for f in ops['nodes']:
        if f.get('nodeType')=='EnumDefinition' and f['name']=='Rounding':fs['Operations.Rounding']=copy.deepcopy(f)
        if f.get('nodeType')!='FunctionDefinition' or f['name'] not in {'mulDiv','_magnitude','_signedMagnitude','_panic'}:continue
        if f['name']=='mulDiv':
            ts=[x['typeDescriptions']['typeString'] for x in f['parameters']['parameters']];key='Unsigned' if ts[0]=='uint256' else 'Signed';sig='mulDiv('+','.join('uint8' if x.startswith('enum ') else x for x in ts)+')'
            if data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][sig]!=f['functionSelector']:raise ValueError('Selector disagreement')
            entries.append({'signature':sig,'selector':f['functionSelector'],'symbol':key});fs[key]=copy.deepcopy(f)
        else:fs[f['name']]=copy.deepcopy(f)
    for name in ['mul512','ternary','mulDiv']:
        fs['Math.'+name]=copy.deepcopy(next(x for x in math['nodes'] if x.get('nodeType')=='FunctionDefinition' and x.get('name')==name and (name!='mulDiv' or len(x['parameters']['parameters'])==3)))
    fs['SafeCast.toUint']=copy.deepcopy(next(x for x in cast['nodes'] if x.get('name')=='toUint' and x['parameters']['parameters'][0]['typeDescriptions']['typeString']=='bool'))
    fs['Panic.panic']=copy.deepcopy(next(x for x in panic['nodes'] if x.get('name')=='panic'))
    for x in panic['nodes']:
        if x.get('name') in {'UNDER_OVERFLOW','DIVISION_BY_ZERO'}:fs['Panic.'+x['name']]=copy.deepcopy(x)
    if len(entries)!=2 or len(fs)!=13:raise ValueError('Complete mulDiv/helper inventory '+str(len(fs)))
    if [m['name'] for m in fs['Operations.Rounding']['members']]!=['Trunc','Floor','Ceil']:raise ValueError('Decoded rounding enum order')
    bindings=[]
    def bind_calls(node,owner):
        if isinstance(node,list):
            for x in node:bind_calls(x,owner)
            return
        if not isinstance(node,dict):return
        target=None
        if node.get('nodeType')=='FunctionCall' and node.get('kind')=='functionCall':
            callee=node['expression']
            if callee.get('nodeType')=='Identifier':
                name=callee['name']
                if name in {'_magnitude','_signedMagnitude','_panic'}:target=name
                elif name in {'mul512','ternary'}:target='Math.'+name
                elif name=='mulmod' and callee.get('referencedDeclaration',0)>=0:raise ValueError('MULMOD must resolve to compiler builtin')
            elif callee.get('nodeType')=='MemberAccess':
                receiver=callee['expression'].get('name');member=callee['memberName']
                target={('Math','mulDiv'):'Math.mulDiv',('SafeCast','toUint'):'SafeCast.toUint',('Panic','panic'):'Panic.panic'}.get((receiver,member))
            if target:
                if callee.get('referencedDeclaration')!=fs[target]['id']:raise ValueError('Reached helper declaration mismatch '+owner+'/'+target)
                bindings.append({'caller':owner,'callee':target,'compilerDeclaration':fs[target]['id']})
        if node.get('nodeType')=='MemberAccess':
            receiver=node['expression'].get('name');member=node['memberName']
            if receiver=='Panic' and member in {'UNDER_OVERFLOW','DIVISION_BY_ZERO'} and node.get('referencedDeclaration')!=fs['Panic.'+member]['id']:raise ValueError('Panic constant declaration mismatch')
            if receiver=='Rounding' and member in {'Trunc','Floor','Ceil'}:
                expected=next(x for x in fs['Operations.Rounding']['members'] if x['name']==member)['id']
                if node.get('referencedDeclaration')!=expected:raise ValueError('Rounding declaration mismatch')
        for x in node.values():bind_calls(x,owner)
    for name,node in fs.items():bind_calls(node,name)
    def slot(node,key,name,render=expr):slots[name]=render(node[key]);node[key]={'translated-slot':name}
    u=fs['Unsigned']['body']['statements'];slot(u[1],'condition','UNSIGNED_ROUND')
    s=fs['Signed']['body']['statements'];slots['SIGNED_NEGATIVE']=expr(s[0]['initialValue']);slot(s[5],'condition','SIGNED_ROUND')
    slot(fs['_magnitude']['body']['statements'][0]['statements'][0],'expression','MAGNITUDE',lambda n:expr(n,True))
    sm=fs['_signedMagnitude']['body']['statements'];slot(sm[0],'condition','SIGNED_GUARD',lambda n:expr(n,True));slot(sm[1]['statements'][0],'expression','SIGNED_VALUE',lambda n:expr(n,True))
    asm=fs['Math.mul512']['body']['statements'][0]['AST']['statements'];slots['MM']=yul(asm[0]['value']);slots['LOW']=yul(asm[1]['value']);slot(asm[2],'value','HIGH',yul)
    slots['CAST']=yul(fs['SafeCast.toUint']['body']['statements'][0]['AST']['statements'][0]['value']).replace('B.Iszero(b)','B.Iszero(B.Bool(b))')
    slots['TERNARY']=expr(fs['Math.ternary']['body']['statements'][0]['statements'][0]['expression'])
    body=fs['Math.mulDiv']['body']['statements'][0]['statements'];slots['HIGH_ZERO']=expr(body[1]['condition']);slots['OVERFLOW']=expr(body[2]['condition'])
    for node,key in [(body[4]['AST']['statements'][0],'REMAINDER'),(body[4]['AST']['statements'][1],'BORROW_HIGH'),(body[4]['AST']['statements'][2],'BORROW_LOW')]:slots[key]=yul(node['value'])
    slots['TWOS']=expr(body[5]['initialValue'])
    for node,key in zip(body[6]['AST']['statements'],['DIV_DENOM','DIV_LOW','FLIP']):slots[key]=yul(node['value'])
    combine=body[7]['expression'];slots['COMBINE']='I.Or(low,'+expr(combine['rightHandSide'])+')'
    slot(body[8],'initialValue','INVERSE_SEED')
    updates=[]
    for index in range(6):
        assignment=body[9+index]['expression'];op={'nodeType':'BinaryOperation','operator':'*','leftExpression':assignment['leftHandSide'],'rightExpression':assignment['rightHandSide'],'typeDescriptions':{'typeString':'uint256'}}
        value=expr(op);step=4*(2**index)
        updates += [f'  method Update{step}(denominator: nat,inverse: nat) returns (next: nat)',
          '    requires denominator < B.Word && inverse < B.Word',f'    requires (denominator*inverse)%B.Power({step}) == 1',
          f'    ensures next < B.Word && (denominator*next)%B.Power({step*2}) == 1',
          '  {',f'    V.Hensel(denominator,inverse,{step});','    next := '+value+';',
          '    assert next == V.Update(denominator,inverse);','  }']
    slots['UPDATES']='\n'.join(updates)
    slots['RESULT']=expr(body[15]['expression']['rightHandSide'])
    for name,func in [('OPS_PANIC',fs['_panic']),('MATH_PANIC',fs['Panic.panic'])]:
        a=func['body']['statements'][0]['AST']['statements'];first,second,ret=[x['expression']['arguments'] for x in a]
        for key,node in [('FIRST_OFFSET',first[0]),('SELECTOR',first[1]),('SECOND_OFFSET',second[0]),('READ_OFFSET',ret[0]),('READ_LENGTH',ret[1])]:slots[name+'_'+key]=yul(node)
    structure={name:form(f) for name,f in fs.items()}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete mulDiv/helper AST or selector drift')
    out.mkdir(parents=True,exist_ok=True)
    for template,target in [('Control.template.dfy','Control.generated.dfy'),('Helpers.template.dfy','Helpers.generated.dfy')]:
        code=(HERE/template).read_text()
        for name,value in slots.items():code=code.replace('$'+name+'$',value)
        if '$' in code:raise ValueError('Unexpanded slot '+target)
        (out/target).write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0));(out/'mapping.json').write_text(json.dumps({'entries':entries,'slots':slots,'helperBindings':bindings,'sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
