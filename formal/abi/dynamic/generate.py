#!/usr/bin/env python3
"""Gate the complete body AST and translate recursive composition expressions."""
import argparse,gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('tuple_generator',HERE.parent/'tuples/generate.py')
prior=importlib.util.module_from_spec(spec);spec.loader.exec_module(prior)
shape=prior.shape
spec=importlib.util.spec_from_file_location('byte_generator',HERE.parent/'source/generate.py')
bytegen=importlib.util.module_from_spec(spec);spec.loader.exec_module(bytegen)

def expr(n):
 k=n['nodeType']
 if k=='Identifier':return n['name']
 if k=='Literal':return str(int(n['value'],0))
 if k=='MemberAccess':
  assert n['expression'].get('name')=='x'
  return {'base':'base','tail':'tail'}[n['memberName']]
 if k=='BinaryOperation':
  assert n['operator'] in ('+','-','*')
  return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
 raise ValueError(k)

def generate(source,solc,bootstrap=False):
 _,_,request,output=prior.generate(source,solc)
 contract=next(n for n in output['sources']['AbiCodec.sol']['ast']['nodes'] if n['nodeType']=='ContractDefinition')
 fs={n['name']:n for n in contract['nodes'] if n['nodeType']=='FunctionDefinition'}
 body=shape.form(fs['body']);slots={};nexts=0;returns=0
 for n in shape.walk(body):
  if n.get('nodeType')=='Assignment':
   lhs=n['leftHandSide'];rhs=n['rightHandSide']
   if lhs.get('nodeType')=='MemberAccess' and lhs['memberName']=='j' and rhs.get('nodeType')=='BinaryOperation' and rhs['leftExpression'].get('name')=='next':
    nexts+=1
    if nexts==2:slots['SECOND_NEXT']=expr(rhs);n['rightHandSide']={'slot':'SECOND_NEXT'}
   if lhs.get('nodeType')=='MemberAccess' and lhs['memberName']=='base' and rhs.get('nodeType')=='BinaryOperation':
    assert n['operator'] in ('+=','-=')
    slots['TUPLE_ADVANCE']='(head '+n['operator'][0]+' '+expr(rhs).replace('w','words')+')'
    n['operator']='$TUPLE_ADVANCE';n['rightHandSide']={'slot':'TUPLE_ADVANCE'}
  if n.get('nodeType')=='Return' and n.get('expression',{}).get('nodeType')=='BinaryOperation':
   e=n['expression']
   if any(q.get('nodeType')=='MemberAccess' and q.get('memberName')=='base' for q in shape.walk(e)):
    value=expr(e)
    assert 'BODY_EXTENT' not in slots or slots['BODY_EXTENT']==value
    slots['BODY_EXTENT']=value;returns+=1;n['expression']={'slot':'BODY_EXTENT'}
 assert nexts==2 and returns==2
 structure={'validateDynamic':shape.form(fs['validateDynamic']),'body':body,'suffixStart':shape.form(fs['suffixStart']),'validateStatic':shape.form(fs['validateStatic']),
            'validateDispatch':[shape.form(n) for n in contract['nodes'] if n['nodeType']=='FunctionDefinition' and n['name']=='validate']}
 if bootstrap:return structure
 assert structure==json.loads((HERE/'structure.json').read_text()),'Unsupported body source drift'
 assert set(slots)=={'SECOND_NEXT','BODY_EXTENT','TUPLE_ADVANCE'}
 text=(HERE/'Body.template.dfy').read_text().replace('$HASH',hashlib.sha256(source.encode()).hexdigest())
 for name,value in slots.items():text=text.replace('$'+name,value)
 assert '$' not in text
 mapping={'sourceSha256':hashlib.sha256(source.encode()).hexdigest(),'functions':{n:{'id':fs[n]['id'],'src':fs[n]['src']} for n in ('body','checkWords','suffixStart','validateStatic')},'translatedSlots':slots,
 'normalizations':['FullBody preserves the complete array, tuple and bytes/string branch structure. ArrayLoop and TupleLoop factor source loops; ghost values track independent validator results only.',
 'Source-derived checked cursor kernels and parser/head/word helpers are reused through verified contracts. ZeroWords retains the actual zero-copy cursor overflow.',
 'Default Value-context failures are explicit outcomes. Other Context routes and allocator/compiler semantics require their separately recorded boundaries.']}
 raw,_,byte_mapping,_,_=bytegen.generate(source,solc)
 start=raw.index('  ghost method ValidateBytes(')
 start=raw.index('\n  {',start)+len('\n  {\n')
 end=raw.rindex('\n  }\n')
 wrapper=raw[start:end]
 assert wrapper.count('BytesBody(v,32)')==1
 wrapper=wrapper.replace('BytesBody(v,32)','FullBody(t,0,|t|,v,32,s)')
 validation=(HERE/'Validation.template.dfy').read_text().replace('$HASH',mapping['sourceSha256']).replace('    $VALIDATE_BODY',wrapper)
 assert '$' not in validation
 mapping['validationLoweredNodes']=byte_mapping['loweredNodes']
 mapping['normalizations'].append('The AST-lowered validateDynamic wrapper is instantiated with FullBody in place of the previous BytesBody specialization; all other statements remain source-derived.')
 return text,validation,mapping,request,output

def main():
 p=argparse.ArgumentParser();p.add_argument('--solc',required=True);p.add_argument('--source',type=Path,default=ROOT/'contracts/lib/AbiCodec.sol');p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 text,validation,mapping,request,output=generate(a.source.read_text(),a.solc)
 a.output.mkdir(parents=True,exist_ok=True)
 (a.output/'Body.generated.dfy').write_text(text)
 (a.output/'Validation.generated.dfy').write_text(validation)
 (a.output/'mapping.json').write_text(json.dumps(mapping,indent=2)+'\n')
 (a.output/'solc-input.json').write_text(json.dumps(request))
 with gzip.open(a.output/'solc-output.json.gz','wt') as f:json.dump(output,f)
if __name__=='__main__':main()
