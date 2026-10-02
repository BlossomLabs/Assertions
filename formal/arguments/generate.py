#!/usr/bin/env python3
"""Trusted restricted translation of the get and codec tuple composition."""
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
FUNCTIONS={'get','_encodeArguments'}


def normalized(node):
 # solc AST node ids are allocation metadata. Keep overload candidate counts;
 # the gated overload definitions, call names and argument structure remain.
 def strip(value):
  if isinstance(value,list):return [strip(x) for x in value]
  if isinstance(value,dict):return {k: (['compiler-node-id']*len(v) if k=='overloadedDeclarations' else strip(v)) for k,v in value.items()}
  return value
 return strip(nav.normalized_form(node))


def expr(n,aliases):
 if n['nodeType']=='BinaryOperation' and n['operator']=='+':
  return '('+expr(n['leftExpression'],aliases)+' + '+expr(n['rightExpression'],aliases)+')'
 return resolution.expr(n,aliases)


def generate(solc,root,out,bootstrap=False):
 if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
 sources={p:(root/p).read_text() for p in ['contracts/Assertions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol']}
 request={'language':'Solidity','sources':{p:{'content':s} for p,s in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
 proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(request),capture_output=True,text=True,check=True);ast=json.loads(proc.stdout)
 if any(e['severity']=='error' for e in ast.get('errors',[])):raise ValueError(ast['errors'])
 contract=next(n for n in ast['sources']['contracts/Assertions.sol']['ast']['nodes'] if n.get('name')=='Assertions')
 functions={n['name']:normalized(n) for n in contract['nodes'] if n.get('name') in FUNCTIONS}
 if set(functions)!=FUNCTIONS:raise ValueError('Missing functions')
 slots={}
 calls=[n for n in nav.shape.walk(functions['get']) if n.get('nodeType')=='FunctionCall' and n['expression'].get('name')=='_resolve' and n['arguments'][3].get('nodeType')=='BinaryOperation']
 if len(calls)!=1:raise ValueError('Missing argument resolver')
 slots['ARG_INDEX']=expr(calls[0]['arguments'][3],{'i':'i'});calls[0]['arguments'][3]={'slot':'ARG_INDEX'}
 empty=functions['_encodeArguments']['body']['statements'][1]['condition']['rightExpression']
 slots['EMPTY_COUNT']=expr(empty,{'values.length':'|args|'});functions['_encodeArguments']['body']['statements'][1]['condition']['rightExpression']={'slot':'EMPTY_COUNT'}
 codec=next(n for n in ast['sources']['contracts/lib/AbiCodec.sol']['ast']['nodes'] if n.get('name')=='AbiCodec')
 tuples=[normalized(n) for n in codec['nodes'] if n.get('name')=='tuple']
 if len(tuples)!=2:raise ValueError('Missing tuple overloads')
 planned=next(n for n in tuples if len(n['parameters']['parameters'])==3)
 guard=planned['body']['statements'][0]
 slots['COUNT_CHECK']=expr(guard['condition'],{'args.length':'|args|','plan.starts':'plan.starts'});guard['condition']={'slot':'COUNT_CHECK'}
 checks=[n for n in nav.shape.walk(planned) if n.get('nodeType')=='FunctionCall' and n['expression'].get('name')=='validateComponent']
 if len(checks)!=1:raise ValueError('Missing component validation')
 slots['COMPONENT_INDEX']=expr(checks[0]['arguments'][2],{'i':'i'});checks[0]['arguments'][2]={'slot':'COMPONENT_INDEX'}
 structure={'functions':functions,'tupleOverloads':tuples,
  'errors':[normalized(n) for owner in [contract,codec] for n in owner['nodes'] if n['nodeType']=='ErrorDefinition'],
  'wire':[normalized(n) for n in ast['sources']['contracts/lib/ERC8211.sol']['ast']['nodes'] if n['nodeType'] in {'StructDefinition','EnumDefinition','ErrorDefinition'}]}
 if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');return
 if structure!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported argument source drift')
 out.mkdir(parents=True,exist_ok=True)
 for name in ['Source','Tuple']:
  text=(HERE/(name+'.template.dfy')).read_text().replace('$HASH',hashlib.sha256(sources['contracts/Assertions.sol'].encode()).hexdigest()).replace('$CODEC_HASH',hashlib.sha256(sources['contracts/lib/AbiCodec.sol'].encode()).hexdigest())
  for key,value in slots.items():text=text.replace('$'+key,value)
  if '$' in text:raise ValueError('Unexpanded slot')
  (out/(name+'.generated.dfy')).write_text(text)
 (out/'solc-input.json').write_text(json.dumps(request));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
 (out/'mapping.json').write_text(json.dumps({'translatedSlots':slots,'functions':sorted(functions),'sourceSha256':{p:hashlib.sha256(s.encode()).hexdigest() for p,s in sources.items()}},indent=2)+'\n')


if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
