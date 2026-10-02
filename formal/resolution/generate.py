#!/usr/bin/env python3
"""Gate resolver/judge ASTs; translate guards into the audited control-flow model."""
import argparse
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
spec = importlib.util.spec_from_file_location('navigation_generator', HERE.parent/'navigation/generate.py')
nav = importlib.util.module_from_spec(spec)
spec.loader.exec_module(nav)
FUNCTIONS = {'_resolve', '_staticCall', '_rejectOutOfGas', '_firstWord', '_asAddress', '_judge', 'assertParam', 'assertBatch'}


def expr(n, aliases):
    kind = n['nodeType']
    if kind == 'Identifier':
        if n['name'] not in aliases:
            raise ValueError(n)
        return aliases[n['name']]
    if kind == 'Literal':
        return str(int(n['value'],0))
    if kind == 'MemberAccess':
        key = n['expression'].get('name','')+'.'+n['memberName']
        if key in aliases:
            return aliases[key]
        if n['memberName'] == 'length' and n['expression']['nodeType'] == 'MemberAccess':
            base = n['expression']['expression']['name']+'.'+n['expression']['memberName']
            return '|'+aliases[base]+'|'
    if kind == 'FunctionCall':
        if n['kind'] == 'typeConversion' and n['expression']['typeName']['name'] == 'uint256':
            return expr(n['arguments'][0],aliases)
        if n['kind'] == 'typeConversion' and n['expression']['typeName']['name'] == 'address' and n['arguments'][0].get('value') == '0':
            return '0'
        if n['expression'].get('name') == 'gasleft' and not n['arguments']:
            return 'observed.gasAfter'
    if kind == 'BinaryOperation':
        if n['operator'] == '>>':
            if n['rightExpression'].get('value') != '160':
                raise ValueError('Only the address shift is supported')
            return '('+expr(n['leftExpression'],aliases)+' / AddressLimit())'
        if n['operator'] in {'<','<=','>','>=','==','!=','||','&&','/'}:
            return '('+expr(n['leftExpression'],aliases)+' '+n['operator']+' '+expr(n['rightExpression'],aliases)+')'
    raise ValueError(n)


def generate(solc, root, out, bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):
        raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Assertions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol']}
    request={'language':'Solidity','sources':{p:{'content':s} for p,s in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(request),capture_output=True,text=True,check=True)
    ast=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in ast.get('errors',[])):
        raise ValueError(ast['errors'])
    top=ast['sources']['contracts/Assertions.sol']['ast']['nodes']
    contract=next(n for n in top if n.get('name')=='Assertions')
    functions={}
    for n in contract['nodes']:
        if n['nodeType']=='FunctionDefinition' and n.get('name') in FUNCTIONS:
            name=n['name']+('/'+str(len(n['parameters']['parameters'])) if n['name'] in {'assertParam','assertBatch'} else '')
            functions[name]=nav.normalized_form(n)
    if len(functions)!=10:
        raise ValueError('Missing or duplicated source functions')
    slots={}
    locations=[('EXHAUSTED',functions['_rejectOutOfGas']['body']['statements'][2]),
               ('SHORT_WORD',functions['_firstWord']['body']['statements'][0]),
               ('DIRTY_ADDRESS',functions['_asAddress']['body']['statements'][0])]
    balance=functions['_resolve']['body']['statements'][0]['falseBody']['falseBody']['statements'][0]
    locations.append(('BALANCE_LENGTH',balance))
    loop=functions['_judge']['body']['statements'][0]['body']['statements']
    locations.append(('HAS_CALL',loop[-1]))
    aliases={'gasBefore':'observed.gasBefore','head':'head','SubcallOutOfGas.selector':'Signal()',
             'value.length':'|data|','word':'word','param.paramData':'param.data','target':'routed.build.target'}
    for key,node in locations:
        slots[key]=expr(node['condition'],aliases)
        node['condition']={'slot':key}
    for key,name in [('PARAM_MESSAGE','assertParam/1'),('BATCH_MESSAGE','assertBatch/1')]:
        literal=functions[name]['body']['statements'][0]['expression']['arguments'][1]
        if literal['nodeType']!='Literal' or literal['kind']!='string':
            raise ValueError('Expected literal default message')
        slots[key]='['+','.join(map(str,bytes.fromhex(literal['hexValue'])))+']'
        functions[name]['body']['statements'][0]['expression']['arguments'][1]={'slot':key}
    structure={'functions':functions,
               'errors':[nav.normalized_form(n) for n in contract['nodes'] if n['nodeType']=='ErrorDefinition'],
               'balanceInterface':nav.normalized_form(next(n for n in top if n.get('name')=='IERC20Balance')),
               'wire':[nav.normalized_form(n) for n in ast['sources']['contracts/lib/ERC8211.sol']['ast']['nodes'] if n['nodeType'] in {'StructDefinition','EnumDefinition','ErrorDefinition'}]}
    if bootstrap:
        (HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n')
        return
    if structure!=json.loads((HERE/'structure.json').read_text()):
        raise ValueError('Unsupported resolver/judge source drift')
    text=(HERE/'Source.template.dfy').read_text().replace('$HASH',hashlib.sha256(sources['contracts/Assertions.sol'].encode()).hexdigest())
    for k in sorted(slots,key=len,reverse=True): text=text.replace('$'+k,slots[k])
    if '$' in text: raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True)
    (out/'Source.generated.dfy').write_text(text)
    (out/'solc-input.json').write_text(json.dumps(request))
    (out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'translatedSlots':slots,'sourceSha256':{p:hashlib.sha256(s.encode()).hexdigest() for p,s in sources.items()},'functions':sorted(functions)},indent=2)+'\n')


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args()
    generate(a.solc,a.root,a.output,a.bootstrap)
