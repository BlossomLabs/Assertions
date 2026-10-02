#!/usr/bin/env python3
"""Gate complete fixed-point bodies and reached helper targets; translate every actual arithmetic operand."""
import argparse,copy,gzip,hashlib,importlib.util,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('muldiv',HERE.parent/'full-mul-div/generate.py');dep=importlib.util.module_from_spec(spec);spec.loader.exec_module(dep);SOURCES=dep.SOURCES
EQ=[50020603652535783019961831881945,-533845033583426703283633433725380,3604857256930695427073651918091429,-14423608567350463180887372962807573,26449188498355588339934803723976023]
LP=[24828157081833163892658089445524,43456485725739037958740375743393,-11111509109440967052023855526967,-45023709667254063763336534515857,-14706773417378608786704636184526]
LQ=[71694874799317883764090561454958,283447036172924575727196451306956,401686690394027663651624208769553,204048457590392012362485061816622,31853899698501571402653359427138,909429971244387300277376558375]
def literal(n):
    if n.get('nodeType')=='UnaryOperation' and n['operator']=='-':return -literal(n['subExpression'])
    if n.get('nodeType')=='BinaryOperation':
        a,b=literal(n['leftExpression']),literal(n['rightExpression']);op=n['operator']
        if op=='**':return a**b
        if op=='*':return a*b
        if op=='+':return a+b
        if op=='-':return a-b
        if op=='<<':return a<<b
        if op=='>>':return a>>b
    return dep.literal(n)
def wrap(text,t):return ('M.U('+text+')' if t=='uint256' else 'M.S('+text+')')
def expr(n):
    k=n.get('nodeType');t=n.get('typeDescriptions',{}).get('typeString','')
    if k=='Identifier':return n['name']
    if k=='TupleExpression' and len(n['components'])==1:return expr(n['components'][0])
    if k=='Literal' or (t.startswith('int_const') and k in ['BinaryOperation','UnaryOperation']):return str(literal(n))
    if k=='UnaryOperation' and n['operator']=='-':return wrap('-('+expr(n['subExpression'])+')',t)
    if k=='BinaryOperation':
        a,b=expr(n['leftExpression']),expr(n['rightExpression']);op=n['operator']
        if op in ['<','<=','>','>=','==','!=']:return '('+a+' '+op+' '+b+')'
        if op in ['+','-','*']:return wrap(a+op+b,t)
        if op=='/':return wrap('M.Trunc('+a+','+b+')',t)
        if op=='<<':return wrap('M.Shl('+a+',M.U('+b+'))',t)
        if op=='>>':return ('M.Shr' if n['leftExpression']['typeDescriptions']['typeString']=='uint256' else 'M.Sar')+'('+a+',M.U('+b+'))'
    if k=='FunctionCall':
        call=n['expression'];args=n['arguments']
        if call.get('nodeType')=='ElementaryTypeNameExpression':return wrap(expr(args[0]),call['typeName']['name'])
        if call.get('memberName')=='log2':return 'log'
    raise ValueError('Unsupported actual arithmetic AST '+str(n))
def assignment(n,outputs=()):
    if n['nodeType']=='VariableDeclarationStatement':
        name=n['declarations'][0]['name'];return ('var '+name+': int := ' if name not in outputs else name+' := ')+expr(n['initialValue'])+';'
    a=n['expression'];name=a['leftHandSide']['name'];rhs=expr(a['rightHandSide']);op=a['operator'];t=a['leftHandSide']['typeDescriptions']['typeString']
    if op=='=':value=rhs
    elif op in ['*=','+=','-=']:value=wrap(name+op[0]+rhs,t)
    elif op=='<<=':value=wrap('M.Shl('+name+',M.U('+rhs+'))',t)
    elif op=='>>=':value='M.Sar('+name+',M.U('+rhs+'))'
    else:raise ValueError('Unsupported assignment')
    return name+' := '+value+';'
def sequence(nodes,outputs=()):return '\n'.join('    '+assignment(n,outputs) for n in nodes)
def polynomial(nodes,name,coeffs,term,last_raw=False):
    lines=['    '+assignment(nodes[0],(name,)),f'    assert M.{term}(x) == M.Horner(x,{name},{coeffs});']
    for i,n in enumerate(nodes[1:]):
        lines.append('    '+assignment(n,(name,)));lines.append(f'    assert M.{term}(x) == M.Horner(x,{name},{coeffs[i+1:]});')
    return '\n'.join(lines)
def generate(solc,root,out,bootstrap=False):
    out.mkdir(parents=True,exist_ok=True);dep.generate(solc,root,out/'muldiv-regenerated')
    for name in ['Control.generated.dfy','Helpers.generated.dfy']:
        if (out/'muldiv-regenerated'/name).read_bytes()!=(HERE.parent/'full-mul-div'/name).read_bytes():raise ValueError('Reached helper drift')
    data=json.loads(gzip.decompress((out/'muldiv-regenerated/solc-output.json.gz').read_bytes()));ops=next(n for n in data['sources']['contracts/Operations.sol']['ast']['nodes'] if n.get('name')=='Operations');fs={n['name']:copy.deepcopy(n) for n in ops['nodes'] if n.get('name') in ['expWad','lnWad','LogarithmUndefined']};entries=[];slots={};bindings=[]
    if set(fs)!={'expWad','lnWad','LogarithmUndefined'}:raise ValueError('Fixed-point inventory')
    math=next(n for n in data['sources']['@openzeppelin/contracts/utils/math/Math.sol']['ast']['nodes'] if n.get('name')=='Math');logdecl=next(n['id'] for n in math['nodes'] if n.get('name')=='log2' and len(n['parameters']['parameters'])==1);panicdecl=next(n['id'] for n in ops['nodes'] if n.get('name')=='_panic')
    for name in ['expWad','lnWad']:
        f=fs[name];sig=name+'(int256)';selector=data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][sig]
        if selector!=f['functionSelector']:raise ValueError('Selector mismatch')
        entries.append({'signature':sig,'selector':selector,'symbol':'Exp' if name=='expWad' else 'Ln'})
    e=fs['expWad']['body']['statements'][0]['statements'];l=fs['lnWad']['body']['statements'][0]['statements']
    if len(e)!=18 or len(l)!=23:raise ValueError('Complete statement inventory')
    if e[1]['trueBody']['expression']['expression'].get('referencedDeclaration')!=panicdecl or literal(e[1]['trueBody']['expression']['arguments'][0])!=17:raise ValueError('Unbound actual panic')
    logcall=l[1]['initialValue']['leftExpression']['arguments'][0]
    if logcall['expression'].get('referencedDeclaration')!=logdecl:raise ValueError('Unbound actual Math.log2')
    if len(logcall['arguments'])!=1 or expr(logcall['arguments'][0])!='M.U(x)':raise ValueError('Untranslated Math.log2 input')
    if l[0]['trueBody']['errorCall']['expression'].get('referencedDeclaration')!=fs['LogarithmUndefined']['id']:raise ValueError('Unbound logarithm error')
    bindings=[{'caller':'expWad','callee':'Operations._panic','compilerDeclaration':panicdecl},{'caller':'lnWad','callee':'Math.log2','compilerDeclaration':logdecl,'actualArgument':dep.form(logcall['arguments'][0])}]
    slots['E_ZERO']=expr(e[0]['condition']);slots['E_OVERFLOW']=expr(e[1]['condition']);slots['L_UNDEFINED']=expr(l[0]['condition'])
    slots['E_REDUCE']=sequence(e[2:5],('k',));slots['E_P']=sequence(e[5:7],('p',))+'\n    assert y == M.ExpY(x);\n'+sequence(e[7:9],('p',))+'\n    assert p == M.ExpCore(x);\n'+sequence(e[9:10],('p',));slots['E_Q']=polynomial(e[10:16],'q',EQ,'ExpDenominator');slots['E_Q_WITNESS']='\n'.join('    A.Identity('+str(value)+');\n    '+assignment(n,('q',))+'\n    assert q == '+str(value)+';' for n,value in zip(e[10:16],[-2855989394907223263936484059900]+EQ));slots['E_RATIO']='    '+assignment(e[16],('r',));slots['E_RESULT']=expr(e[17]['expression']['rightHandSide'])
    slots['L_NORMALIZE']=sequence(l[1:4],('k',));lp=['    '+assignment(l[4],('p',)),'    ghost var seed := p;',f'    assert M.Horner(x,seed,{LP}) == M.Horner(x,p,{LP});']
    for i,n in enumerate(l[5:10]):lp.extend(['    '+assignment(n,('p',)),f'    assert M.Horner(x,seed,{LP}) == M.Horner(x,p,{LP[i+1:]});'])
    lp.extend(['    assert p == M.Horner(x,seed,'+str(LP)+');','    '+assignment(l[10],('p',))]);slots['L_P']='\n'.join(lp);slots['L_Q']=polynomial(l[11:18],'q',LQ,'LnDenominator');slots['L_RATIO']='    '+assignment(l[18],('r',));slots['L_FINISH']=sequence(l[19:22],('r',))+'\n    ghost var previous := r;\n    '+assignment(l[22],('r',))+'\n    A.SignedShift(previous,M.U(174));'
    for prefix,body in [('E',e),('L',l)]:
        for i,n in enumerate(body):
            if n['nodeType']=='VariableDeclarationStatement':n['initialValue']={'translated-slot':prefix+str(i)}
            elif n['nodeType']=='ExpressionStatement':n['expression']['rightHandSide']={'translated-slot':prefix+str(i)}
    tree={name:dep.form(f) for name,f in fs.items()}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(tree,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if tree!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete fixed-point body/selector drift')
    code=(HERE/'Control.template.dfy').read_text()
    for name,value in slots.items():code=code.replace('$'+name+'$',value)
    if '$' in code:raise ValueError('Unexpanded slot')
    lines=code.splitlines();headers=[x for x in lines if x.startswith('include ')];body='\n'.join(x for x in lines if not x.startswith('include '))+'\n'
    formatted=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=body,text=True,check=True,capture_output=True).stdout
    (out/'Control.generated.dfy').write_text('\n'.join(headers)+'\n'+formatted);(out/'mapping.json').write_text(json.dumps({'entries':entries,'slots':slots,'helperBindings':bindings,'sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
