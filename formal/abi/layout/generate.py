#!/usr/bin/env python3
"""Gate the complete tupleLayout AST and translate its Yul scan arithmetic."""
import argparse,gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('dynamic_generator',HERE.parent/'dynamic/generate.py')
prior=importlib.util.module_from_spec(spec);spec.loader.exec_module(prior)
shape=prior.shape

def expr(n):
 if n['nodeType']=='YulIdentifier':return n['name']
 if n['nodeType']=='YulLiteral':return str(int(n['value'],0))
 assert n['nodeType']=='YulFunctionCall' and len(n['arguments'])==2
 op={'add':'+','sub':'-'}[n['functionName']['name']]
 return '(('+expr(n['arguments'][0])+' '+op+' '+expr(n['arguments'][1])+') % Limit())'

def generate(source,solc,bootstrap=False):
 *_,request,output=prior.generate(source,solc)
 contract=next(n for n in output['sources']['AbiCodec.sol']['ast']['nodes'] if n['nodeType']=='ContractDefinition')
 f=next(n for n in contract['nodes'] if n['nodeType']=='FunctionDefinition' and n['name']=='tupleLayout')
 tree=shape.form(f);slots={}
 for n in shape.walk(tree):
  if n.get('nodeType')=='Assignment' and n['leftHandSide'].get('memberName')=='headSize':
   assert n['operator']=='+='
   rhs=n['rightHandSide'];assert rhs['nodeType']=='BinaryOperation' and rhs['leftExpression'].get('name')=='words'
   assert rhs['operator'] in ('*','+') and rhs['rightExpression']['nodeType']=='Literal'
   slots['HEAD']='(head + (words '+rhs['operator']+' '+rhs['rightExpression']['value']+'))'
   n['rightHandSide']={'slot':'HEAD'}
  if n.get('nodeType')!='YulAssignment':continue
  lhs=n['variableNames'];rhs=n['value']
  if len(lhs)!=1 or rhs.get('nodeType')!='YulFunctionCall':continue
  name=lhs[0]['name']
  if name=='depth':slot='OPEN' if 'OPEN' not in slots else 'CLOSE'
  elif name=='count':slot='COMMA'
  elif name=='i':slot='ADVANCE'
  else:raise ValueError(name)
  slots[slot]=expr(rhs);n['value']={'slot':slot}
 structure={'tupleLayout':tree}
 if bootstrap:return structure
 assert structure==json.loads((HERE/'structure.json').read_text()),'Unsupported tupleLayout source drift'
 assert set(slots)=={'OPEN','CLOSE','COMMA','ADVANCE','HEAD'}
 text=(HERE/'Count.template.dfy').read_text().replace('$HASH',hashlib.sha256(source.encode()).hexdigest())
 for name,value in slots.items():text=text.replace('$'+name,value)
 layout=(HERE/'Layout.template.dfy').read_text().replace('$HASH',hashlib.sha256(source.encode()).hexdigest()).replace('$HEAD',slots['HEAD'])
 assert '$' not in layout
 assert '$' not in text
 mapping={'sourceSha256':hashlib.sha256(source.encode()).hexdigest(),'tupleLayout':{'id':f['id'],'src':f['src']},'translatedSlots':slots,
 'normalizations':['The source Yul loop projects each in-bounds calldata byte to t[i]. All scan counters retain modular uint256 arithmetic.',
 'The stray-close branch is normalized to immediate Stray(i): source records that index, forces exit, discards the wrapped depth decrement and reverts before consuming a layout.']}
 return text,layout,mapping,request,output

def main():
 p=argparse.ArgumentParser();p.add_argument('--solc',required=True);p.add_argument('--source',type=Path,default=ROOT/'contracts/lib/AbiCodec.sol');p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 text,layout,mapping,request,output=generate(a.source.read_text(),a.solc)
 a.output.mkdir(parents=True,exist_ok=True)
 (a.output/'Count.generated.dfy').write_text(text)
 (a.output/'Layout.generated.dfy').write_text(layout)
 (a.output/'mapping.json').write_text(json.dumps(mapping,indent=2)+'\n')
 (a.output/'solc-input.json').write_text(json.dumps(request))
 with gzip.open(a.output/'solc-output.json.gz','wt') as f:json.dump(output,f)
if __name__=='__main__':main()
