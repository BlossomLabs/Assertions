#!/usr/bin/env python3
"""Gate the entire Collections AST and ABI, and generate selector metadata."""
import argparse,gzip,hashlib,json,subprocess
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:(['compiler-node-id']*len(v) if k=='overloadedDeclarations' else form(v)) for k,v in n.items() if k not in ignored}
def canonical(t):return '('+','.join(canonical(x) for x in t['components'])+')'+t['type'][5:] if t['type'].startswith('tuple') else t['type']
def signature(f):return f['name']+'('+','.join(canonical(t) for t in f['inputs'])+')'
def compile_source(solc,root):
    assert '0.8.36+commit.8a079791' in subprocess.check_output([str(solc),'--version'],text=True)
    names=['contracts/Collections.sol','contracts/lib/AbiCodec.sol']
    req={'language':'Solidity','sources':{n:{'content':(root/n).read_text()} for n in names},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast'],'Collections':['abi','evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),text=True,capture_output=True,check=True)
    data=json.loads(proc.stdout);assert not any(e['severity']=='error' for e in data.get('errors',[]))
    contract=next(n for n in data['sources'][names[0]]['ast']['nodes'] if n.get('nodeType')=='ContractDefinition' and n['name']=='Collections')
    funcs=[n for n in contract['nodes'] if n['nodeType']=='FunctionDefinition']
    assert len(funcs)==51 and len({n['name'] for n in funcs})==51 and all(n['kind']=='function' and n['body'] is not None for n in funcs)
    assert not any(n.get('nodeType')=='VariableDeclaration' and n.get('visibility')=='public' for n in contract['nodes'])
    abi=data['contracts'][names[0]]['Collections'];methods=abi['evm']['methodIdentifiers']
    entries={signature(f):{'name':f['name'],'selector':methods[signature(f)],'inputs':[canonical(t) for t in f['inputs']],'outputs':[canonical(t) for t in f['outputs']],'mutability':f['stateMutability']} for f in abi['abi'] if f['type']=='function'}
    assert len(entries)==29 and len({v['selector'] for v in entries.values()})==29
    assert {v['name'] for v in entries.values()}=={n['name'] for n in funcs if n['visibility'] in {'external','public'}}
    assert all(v['mutability'] in {'pure','view'} for v in entries.values())
    return req,proc.stdout,{'functions':{n['name']:form(n) for n in funcs},'abi':entries}
def generate(solc,root,out,bootstrap=False):
    req,raw,structure=compile_source(solc,root)
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');return
    assert structure==json.loads((HERE/'structure.json').read_text()),'Complete Collections AST or public ABI drift'
    entries=list(sorted(structure['abi'].values(),key=lambda v:v['name']))
    cases=' | '.join(v['name'][0].upper()+v['name'][1:] for v in entries)
    def matches(kind,render):
        return '\n'.join('    case '+v['name'][0].upper()+v['name'][1:]+' => '+render(v) for v in entries)
    slots={'ENTRIES':cases,'ROUNDTRIP_CASES': '\n'.join('      case '+v['name'][0].upper()+v['name'][1:]+' => {}' for v in entries),'SELECTORS':matches('selector',lambda v:str(int(v['selector'],16))),
      'ARITIES':matches('arity',lambda v:str(len(v['inputs']))),'OUTPUTS':matches('outputs',lambda v:str(len(v['outputs']))),
      'VIEWS':matches('view',lambda v:str(v['mutability']=='view').lower()),
      'ROUTES':'\n'.join('    '+('if' if i==0 else 'else if')+' s == '+str(int(v['selector'],16))+' then Known('+v['name'][0].upper()+v['name'][1:]+')' for i,v in enumerate(entries))+'\n    else Unknown'}
    code=(HERE/'Boundary.template.dfy').read_text()
    for k,v in slots.items():code=code.replace('$'+k+'$',v)
    assert '$' not in code
    out.mkdir(parents=True,exist_ok=True);(out/'Boundary.generated.dfy').write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(raw.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'abi':structure['abi'],'functionDefinitions':len(structure['functions']),'sourceSha256':{n:sha(root/n) for n in req['sources']}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
