#!/usr/bin/env python3
"""Restricted source gate/translation for guarded resolution and revert probes."""
import argparse
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
spec=importlib.util.spec_from_file_location('resolution_generator',HERE.parent/'resolution/generate.py')
resolution=importlib.util.module_from_spec(spec);spec.loader.exec_module(resolution)
nav=resolution.nav
FUNCTIONS={'orElse','isValid','revertData','_rejectOutOfGas','resolve'}


def generate(solc,root,out,bootstrap=False):
 if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
 sources={p:(root/p).read_text() for p in ['contracts/Assertions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol']}
 request={'language':'Solidity','sources':{p:{'content':s} for p,s in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
 proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(request),capture_output=True,text=True,check=True);ast=json.loads(proc.stdout)
 if any(e['severity']=='error' for e in ast.get('errors',[])):raise ValueError(ast['errors'])
 contract=next(n for n in ast['sources']['contracts/Assertions.sol']['ast']['nodes'] if n.get('name')=='Assertions')
 functions={n['name']:nav.normalized_form(n) for n in contract['nodes'] if n.get('name') in FUNCTIONS}
 if set(functions)!=FUNCTIONS:raise ValueError('Missing source')
 slots={};aliases={'gasBefore':'observed.gasBefore','head':'head','SubcallOutOfGas.selector':'Signal()',
  'param.fetcherType':'param.fetcher','a.fetcherType':'param.fetcher','InputParamFetcherType.STATIC_CALL':'STATIC_CALL',
  'a.constraints':'param.constraints','ret.length':'|observed.data|'}
 gas=functions['_rejectOutOfGas']['body']['statements'][2]
 slots['GUARD_EXHAUSTED']=resolution.expr(gas['condition'],aliases);gas['condition']={'slot':'GUARD_EXHAUSTED'}
 statements=functions['revertData']['body']['statements']
 for key,node in [('PROBE_FETCHER_CHECK',statements[0]),('PROBE_CONSTRAINED',statements[1])]:
  slots[key]=resolution.expr(node['condition'],aliases);node['condition']={'slot':key}
 heads=[n for n in nav.shape.walk(functions['revertData']) if n.get('nodeType')=='IfStatement' and n['condition'].get('nodeType')=='BinaryOperation' and n['condition']['leftExpression'].get('memberName')=='length' and n['condition']['leftExpression']['expression'].get('name')=='ret']
 if len(heads)!=1:raise ValueError('Missing selector length guard')
 slots['PROBE_HEAD_LENGTH']=resolution.expr(heads[0]['condition'],aliases);heads[0]['condition']={'slot':'PROBE_HEAD_LENGTH'}
 calls=[n for n in nav.shape.walk(functions['orElse']) if n.get('nodeType')=='FunctionCall' and n['expression'].get('name')=='_resolve']
 if len(calls)!=1:raise ValueError('Missing fallback')
 slots['FALLBACK_INDEX']=resolution.expr(calls[0]['arguments'][3],{});calls[0]['arguments'][3]={'slot':'FALLBACK_INDEX'}
 returned=functions['isValid']['body']['statements'][-1]['expression']
 if returned['nodeType']!='Conditional':raise ValueError('Missing validity choice')
 for field,key in [('trueExpression','VALID_TRUE'),('falseExpression','VALID_FALSE')]:
  slots[key]=resolution.expr(returned[field],{});returned[field]={'slot':key}
 structure={'functions':functions,'errors':[nav.normalized_form(n) for n in contract['nodes'] if n['nodeType']=='ErrorDefinition'],
  'wire':[nav.normalized_form(n) for n in ast['sources']['contracts/lib/ERC8211.sol']['ast']['nodes'] if n['nodeType'] in {'StructDefinition','EnumDefinition','ErrorDefinition'}]}
 if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');return
 if structure!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported control source drift')
 out.mkdir(parents=True,exist_ok=True)
 for name in ['ProbeSource','GuardSource']:
  text=(HERE/(name+'.template.dfy')).read_text().replace('$HASH',hashlib.sha256(sources['contracts/Assertions.sol'].encode()).hexdigest())
  for key,value in slots.items():text=text.replace('$'+key,value)
  if '$' in text:raise ValueError('Unexpanded slot')
  (out/(name+'.generated.dfy')).write_text(text)
 (out/'solc-input.json').write_text(json.dumps(request));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
 (out/'mapping.json').write_text(json.dumps({'translatedSlots':slots,'functions':sorted(functions),'sourceSha256':{p:hashlib.sha256(s.encode()).hexdigest() for p,s in sources.items()}},indent=2)+'\n')


if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
