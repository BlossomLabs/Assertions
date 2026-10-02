#!/usr/bin/env python3
"""Strengthen exact outcomes without changing the audited source control."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def main():
 p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 original=(a.root/'formal/abi/dynamic/Body.generated.dfy').read_text();text=original;edits=[]
 def change(old,new):
  nonlocal text
  if text.count(old)!=1:raise ValueError('Ambiguous strengthening: '+old)
  text=text.replace(old,new);edits.append((old,new))
 change('include "Semantics.dfy"','include "Spec.dfy"')
 change('module AbiDynamicSource {','module AbiExactOutcomeSource {\n  import Exact = AbiExactOutcomeSpec')
 change('    decreases TypeOf(s), 2, 0','    ensures r == Exact.Body(s,v,p)\n    decreases TypeOf(s), 2, 0')
 change('    decreases TypeOf(owner), 1, 0','    ensures r == Exact.Elements(owner.element,v,base,count,0,initialTail)\n    decreases TypeOf(owner), 1, 0')
 change('    decreases TypeOf(Group(fs)), 1, 0','    ensures r == Exact.Fields(fs,v,p,0,initialTail)\n    decreases TypeOf(Group(fs)), 1, 0')
 change('      decreases count-i','      invariant Exact.Elements(owner.element,v,base,count,0,initialTail) == Exact.Elements(owner.element,v,base,count,i,tail)\n      decreases count-i')
 change('      decreases |fs|-i','      invariant Exact.Fields(fs,v,p,0,initialTail) == Exact.Fields(fs[i..],v,p,head,tail)\n      decreases |fs|-i')
 change('      var parsed := Walk(TypeOf(owner.element),bs[tail..]);',
        '      Exact.ElementsStep(owner.element,v,base,count,i,tail,child);\n      var parsed := Walk(TypeOf(owner.element),bs[tail..]);')
 change('      var parsed := Walk(TypeOf(fs[i]),bs[start..]);',
        '      Exact.FieldsStep(fs[i..],v,p,head,tail,child);\n      var parsed := Walk(TypeOf(fs[i]),bs[start..]);')
 change('    ModelType(s); LastByte(s); FirstByte(s);','    reveal Exact.Body();\n    ModelType(s); LastByte(s); FirstByte(s);')
 erased=text
 for old,new in reversed(edits):erased=erased.replace(new,old)
 if erased!=original:raise ValueError('Control drift')
 a.output.mkdir(parents=True,exist_ok=True)
 (a.output/'Body.generated.dfy').write_text(text)
 mappings=[{'file':'Body.generated.dfy','source':'formal/abi/dynamic/Body.generated.dfy','sourceSha256':hashlib.sha256(original.encode()).hexdigest(),'edits':[{'before':x,'after':y} for x,y in edits]}]
 def adapter(file,source,begin,end,changes):
  raw=(a.root/source).read_text()
  imports=raw[:raw.index('  ghost method')]
  if file=='Static.generated.dfy': imports=raw[:raw.index('  ghost method')]
  fragment=imports+raw[raw.index(begin):raw.index(end)]+'}\n'
  transformed=fragment
  for old,new in changes:
   if transformed.count(old)!=1:raise ValueError('Ambiguous adapter edit '+old)
   transformed=transformed.replace(old,new)
  erased=transformed
  for old,new in reversed(changes):erased=erased.replace(new,old)
  if erased!=fragment:raise ValueError('Adapter control drift')
  (a.output/file).write_text(transformed)
  mappings.append({'file':file,'source':source,'sourceSha256':hashlib.sha256(raw.encode()).hexdigest(),'selection':[begin,end],'edits':[{'before':x,'after':y} for x,y in changes]})
 adapter('Static.generated.dfy','formal/abi/connection/Bridge.generated.dfy',
  '  ghost method LengthGuard(', '  // Same body array prelude:',[
  ('include "Descriptor.dfy"','include "Spec.dfy"'),
  ('module AbiConnectionSource {','module AbiExactOutcomeStatic {\n  import Exact = AbiExactOutcomeSpec\n  import AbiConnectionSource'),
  ('ExactWordLength(length,words);','AbiConnectionSource.ExactWordLength(length,words);'),
  ('    ensures |v| != 32*words ==> r == Invalid(0)','    ensures |v| != 32*words ==> r == Invalid(0)\n    ensures r == Exact.Validate(s,v)')])
 adapter('Dynamic.generated.dfy','formal/abi/dynamic/Validation.generated.dfy',
  '  ghost method ValidateDynamic(', '  // Actual noncached validate dispatch:',[
  ('module AbiDynamicValidation {','module AbiExactOutcomeDynamic {\n  import Exact = AbiExactOutcomeSpec'),
  ('  import opened AbiDynamicSource','  import opened AbiExactOutcomeSource'),
  ('    ensures r.Ok? ==> r == Ok(0)','    ensures r.Ok? ==> r == Ok(0)\n    ensures r == Exact.Validate(s,v)')])
 adapter('Cached.generated.dfy','formal/abi/construction/Validation.dfy',
  '  ghost method CachedValidate(', '  lemma CanonicalEnvelope(', [
  ('include "../layout/Soundness.dfy"','include "Static.generated.dfy"\ninclude "Dynamic.generated.dfy"'),
  ('module AbiConstructionValidation {','module AbiExactOutcomeCached {\n  import Exact = AbiExactOutcomeSpec\n  import AbiExactOutcomeStatic'),
  ('  import opened AbiDynamicValidation','  import opened AbiExactOutcomeDynamic'),
  ('AbiConnectionSource.ValidateStatic(t,v,words,s)','AbiExactOutcomeStatic.ValidateStatic(t,v,words,s)'),
  ('    ensures r.Ok? ==> r == Ok(0)','    ensures r.Ok? ==> r == Ok(0)\n    ensures r == Exact.Validate(s,v)')])
 adapter('Receipt.generated.dfy','formal/expressions/codec-errors/Connection.dfy',
  '  ghost method ValidateReceipt(', '  ghost method TupleReceipt(', [
  ('include "Encoding.dfy"','include "../../expressions/codec-errors/Encoding.dfy"\ninclude "Cached.generated.dfy"'),
  ('module ExpressionCodecErrorConnection {','module AbiExactOutcomeReceipt {\n  import Exact = AbiExactOutcomeSpec'),
  ('  import V = AbiConstructionValidation','  import V = AbiExactOutcomeCached'),
  ('    ensures !checked.Panic?','    ensures !checked.Panic?\n    ensures checked == Exact.Validate(s,value)\n    ensures raw == W.Receipt(C.Route(Exact.Validate(s,value),C.Context(C.ValueKind,0,0,0,0)),value)')])
 (a.output/'mapping.json').write_text(json.dumps({'controlErasureExact':True,'adapters':mappings},indent=2)+'\n')
if __name__=='__main__':main()
