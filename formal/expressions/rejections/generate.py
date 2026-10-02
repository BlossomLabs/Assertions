#!/usr/bin/env python3
"""Instantiate completion with exact source validator receipts."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def main():
 p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 original=(a.root/'formal/expressions/validation/Completion.dfy').read_text();text=original;edits=[]
 def change(old,new):
  nonlocal text
  if text.count(old)!=1:raise ValueError('Ambiguous strengthening '+old)
  text=text.replace(old,new);edits.append((old,new))
 change('include "Control.dfy"','include "Model.dfy"')
 change('module ExpressionValidationCompletion {','module ExpressionRejectionCompletion {\n  import R = ExpressionRejectionModel\n  import ExactReceipt = AbiExactOutcomeConnection')
 change('  import Codec = ExpressionCodecErrorConnection','  import Codec = AbiExactOutcomeReceipt')
 old='    ensures out == S.Complete(index,B.Canonical(types),Reject(receipt),body)'
 change(old,old+'\n    ensures out == S.Complete(index,B.Canonical(types),R.Reject(types),body)\n    ensures body.Success? ==> receipt.raw == ExactReceipt.Receipt(types[index],B.Narrow(body.value))')
 erased=text
 for old,new in reversed(edits):erased=erased.replace(new,old)
 if erased!=original:raise ValueError('Completion control drift')
 a.output.mkdir(parents=True,exist_ok=True)
 (a.output/'Completion.generated.dfy').write_text(text)
 completion={'source':'formal/expressions/validation/Completion.dfy','sourceSha256':hashlib.sha256(original.encode()).hexdigest(),'edits':[{'before':x,'after':y} for x,y in edits]}
 original=(a.root/'formal/expressions/validation/Connection.dfy').read_text();text=original;edits=[]
 change('include "Body.generated.dfy"','include "Completion.generated.dfy"\ninclude "../validation/Body.generated.dfy"')
 change('module ExpressionValidationConnection {','module ExpressionRejectionConnection {\n  import R = ExpressionRejectionModel\n  import ExactReceipt = AbiExactOutcomeConnection')
 change('  import Complete = ExpressionValidationCompletion','  import Complete = ExpressionRejectionCompletion')
 change('    ensures receipt.Checked? <==> body.Success?', '    ensures receipt.Checked? <==> body.Success?\n    ensures body.Success? ==> receipt.raw == ExactReceipt.Receipt(types[f.index],B.Narrow(body.value))')
 old='    requires G.Ready(c,types,initial,f.index,reject) && B.View(initial) == f.memo && f.index !in f.memo'
 change(old,old+'\n    requires reject == R.Reject(types)')
 old='    ensures (body.Success? && !B.Canonical(types)(f.index,body.value) ==> reject(f.index,body.value) == Complete.ErrorOf(receipt)) ==>\n              out == S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),f.index,f.memo,f.history)'
 change(old,'    ensures out == S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),f.index,f.memo,f.history)')
 erased=text
 for old,new in reversed(edits):erased=erased.replace(new,old)
 if erased!=original:raise ValueError('Cold completion control drift')
 (a.output/'Cold.generated.dfy').write_text(text)
 (a.output/'mapping.json').write_text(json.dumps({'controlErasureExact':True,'adapters':[completion,{'source':'formal/expressions/validation/Connection.dfy','sourceSha256':hashlib.sha256(original.encode()).hexdigest(),'edits':[{'before':x,'after':y} for x,y in edits]}]},indent=2)+'\n')
if __name__=='__main__':main()
