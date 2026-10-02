#!/usr/bin/env python3
"""Trusted restricted translation of the core's raw-resolution primitives."""
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
FUNCTIONS={'resolve','gather','pick','chain','read','cond','_rawWord','_asAddress'}


def expression(n):
 k=n['nodeType']
 if k=='Identifier' and n['name'] in {'wordIndex','words','i'}:return {'wordIndex':'index'}.get(n['name'],n['name'])
 if k=='Literal':return str(int(n['value'],0))
 if k=='UnaryOperation' and n['operator']=='-':return '(-'+expression(n['subExpression'])+')'
 if k=='FunctionCall' and n['kind']=='typeConversion' and n['expression']['typeName']['name']=='uint256':
  operand=n['arguments'][0]
  if operand['nodeType']!='UnaryOperation' or operand['operator']!='-' or operand['subExpression'].get('name')!='wordIndex':raise ValueError('Unsupported cast')
  return expression(operand)
 if k=='BinaryOperation' and n['operator'] in {'+','-'}:return '('+expression(n['leftExpression'])+' '+n['operator']+' '+expression(n['rightExpression'])+')'
 raise ValueError(n)


def generate(solc,root,out,bootstrap=False):
 if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
 sources={p:(root/p).read_text() for p in ['contracts/Assertions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol']}
 request={'language':'Solidity','sources':{p:{'content':s} for p,s in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
 proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(request),capture_output=True,text=True,check=True);ast=json.loads(proc.stdout)
 if any(e['severity']=='error' for e in ast.get('errors',[])):raise ValueError(ast['errors'])
 contract=next(n for n in ast['sources']['contracts/Assertions.sol']['ast']['nodes'] if n.get('name')=='Assertions')
 functions={n['name']:nav.normalized_form(n) for n in contract['nodes'] if n.get('name') in FUNCTIONS}
 if set(functions)!=FUNCTIONS:raise ValueError('Missing functions')
 slots={}
 node=functions['_asAddress']['body']['statements'][0]
 slots['DIRTY_ADDRESS']=resolution.expr(node['condition'],{'word':'word'});node['condition']={'slot':'DIRTY_ADDRESS'}
 assignments=[n for n in nav.shape.walk(functions['_rawWord']) if n['nodeType']=='Assignment' and n['leftHandSide'].get('name')=='wanted' and n['rightHandSide']['nodeType']=='BinaryOperation']
 if len(assignments)!=1:raise ValueError('Missing index arithmetic')
 node=assignments[0];slots['NEGATIVE_INDEX']=expression(node['rightHandSide']);node['rightHandSide']={'slot':'NEGATIVE_INDEX'}
 for function,callee,index,key in [('read','_resolve',3,'READ_INDEX'),('chain','_asAddress',1,'HOP_INDEX')]:
  calls=[n for n in nav.shape.walk(functions[function]) if n['nodeType']=='FunctionCall' and n['expression'].get('name')==callee and n['arguments'][index]['nodeType']=='BinaryOperation']
  if len(calls)!=1:raise ValueError('Missing operand index '+key)
  node=calls[0];slots[key]=expression(node['arguments'][index]);node['arguments'][index]={'slot':key}
 structure={'functions':functions,'errors':[nav.normalized_form(n) for n in contract['nodes'] if n['nodeType']=='ErrorDefinition'],
  'wire':[nav.normalized_form(n) for n in ast['sources']['contracts/lib/ERC8211.sol']['ast']['nodes'] if n['nodeType'] in {'StructDefinition','EnumDefinition','ErrorDefinition'}]}
 if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');return
 if structure!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported core source drift')
 text=(HERE/'Source.template.dfy').read_text().replace('$HASH',hashlib.sha256(sources['contracts/Assertions.sol'].encode()).hexdigest())
 for key,value in slots.items():text=text.replace('$'+key,value)
 if '$' in text:raise ValueError('Unexpanded slot')
 out.mkdir(parents=True,exist_ok=True);(out/'Source.generated.dfy').write_text(text)
 (out/'solc-input.json').write_text(json.dumps(request));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
 (out/'mapping.json').write_text(json.dumps({'translatedSlots':slots,'functions':sorted(functions),'sourceSha256':{p:hashlib.sha256(s.encode()).hexdigest() for p,s in sources.items()}},indent=2)+'\n')


if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
