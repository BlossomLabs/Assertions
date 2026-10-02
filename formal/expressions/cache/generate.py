#!/usr/bin/env python3
"""Bind selected cache/auth transitions, not the recursive evaluator body."""
import argparse,gzip,hashlib,importlib.util,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('resolution_generator',HERE.parents[1]/'resolution/generate.py')
r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
FUNCTIONS={'evaluate','evaluateGuarded','_evaluate','_tryEvaluate','_rejectOutOfGas'}

def normalized(node):
 def strip(value):
  if isinstance(value,list):return [strip(x) for x in value]
  if isinstance(value,dict):return {k:(['compiler-node-id']*len(v) if k=='overloadedDeclarations' else strip(v)) for k,v in value.items()}
  return value
 return strip(r.nav.normalized_form(node))

def auth(n):
 if n['nodeType']=='MemberAccess' and n['expression'].get('name')=='msg' and n['memberName']=='sender':return 'caller'
 if n['nodeType']=='FunctionCall' and n['kind']=='typeConversion' and n['expression']['typeName']['name']=='address' and len(n['arguments'])==1 and n['arguments'][0].get('name')=='this':return 'self'
 if n['nodeType']=='BinaryOperation' and n['operator'] in {'==','!='}:return '('+auth(n['leftExpression'])+' '+n['operator']+' '+auth(n['rightExpression'])+')'
 raise ValueError(n)

def generate(solc,root,out,bootstrap=False):
 if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Unpinned solc')
 sources={p:(root/p).read_text() for p in ['contracts/Expressions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol']}
 request={'language':'Solidity','sources':{p:{'content':s} for p,s in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
 proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(request),capture_output=True,text=True,check=True);ast=json.loads(proc.stdout)
 if any(e['severity']=='error' for e in ast.get('errors',[])):raise ValueError(ast['errors'])
 contract=next(n for n in ast['sources']['contracts/Expressions.sol']['ast']['nodes'] if n.get('name')=='Expressions')
 functions={n['name']:normalized(n) for n in contract['nodes'] if n.get('name') in FUNCTIONS}
 if set(functions)!=FUNCTIONS:raise ValueError('Missing functions')
 slots={};guard=functions['evaluateGuarded']['body']['statements'][0]
 slots['AUTH_CHECK']=auth(guard['condition']);guard['condition']={'slot':'AUTH_CHECK'}
 hit=functions['_evaluate']['body']['statements'][0]['trueBody']['expression']
 if hit['nodeType']!='IndexAccess':raise ValueError('Cache return changed')
 slots['HIT_INDEX']=r.expr(hit['indexExpression'],{'index':'index'});hit['indexExpression']={'slot':'HIT_INDEX'}
 store=functions['_evaluate']['body']['statements'][-1]['expression']
 flag=store['rightHandSide']
 if flag['nodeType']!='Literal' or flag['value'] not in {'true','false'}:raise ValueError('Ready value changed')
 slots['STORE_READY']=flag['value'];store['rightHandSide']={'slot':'STORE_READY'}
 for member,key in [('values','ADOPT_VALUES'),('ready','ADOPT_READY')]:
  writes=[n for n in r.nav.shape.walk(functions['_tryEvaluate']) if n.get('nodeType')=='Assignment' and n['leftHandSide'].get('memberName')==member]
  if len(writes)!=1:raise ValueError('Cache adoption changed')
  write=writes[0];slots[key]=r.expr(write['rightHandSide'],{'updated.values':'attempted.updated.values','updated.ready':'attempted.updated.ready','cache.values':'original.values','cache.ready':'original.ready'});write['rightHandSide']={'slot':key}
 guard=functions['_rejectOutOfGas']['body']['statements'][2]
 slots['EXHAUSTED']=r.expr(guard['condition'],{'gasBefore':'observed.gasBefore','head':'head','SubcallOutOfGas.selector':'R.Signal()'});guard['condition']={'slot':'EXHAUSTED'}
 structure={'functions':functions,'typesAndErrors':[normalized(n) for n in contract['nodes'] if n['nodeType'] in {'StructDefinition','EnumDefinition','ErrorDefinition'}]}
 if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');return
 if structure!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported cache source drift')
 out.mkdir(parents=True,exist_ok=True)
 text=(HERE/'Source.template.dfy').read_text().replace('$HASH',hashlib.sha256(sources['contracts/Expressions.sol'].encode()).hexdigest())
 for key,value in slots.items():text=text.replace('$'+key,value)
 if '$' in text:raise ValueError('Unexpanded template')
 (out/'Source.generated.dfy').write_text(text)
 (out/'solc-input.json').write_text(json.dumps(request));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
 (out/'mapping.json').write_text(json.dumps({'scope':'Initialization projection and selected cache/auth transitions only; node evaluation and successful receipt invariant not proved here','translatedSlots':slots,'sourceSha256':{p:hashlib.sha256(s.encode()).hexdigest() for p,s in sources.items()}},indent=2)+'\n')

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
