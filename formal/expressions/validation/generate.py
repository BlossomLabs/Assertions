#!/usr/bin/env python3
"""Strengthen the audited source-control contract without changing control."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def main():
 p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 original=(a.root/'formal/expressions/recursive/Source.generated.dfy').read_text();text=original;edits=[]
 def change(old,new):
  nonlocal text
  if text.count(old)!=1:raise ValueError('Ambiguous contract strengthening')
  text=text.replace(old,new);edits.append((old,new))
 change('include "Spec.dfy"','include "Completion.dfy"')
 change('module ExpressionRecursiveSource {','module ExpressionValidationSource {')
 old='    ensures out == S.Evaluate(nodes,valid,truth,reject,oracle,index,memo,history)'
 new=old+'\n    ensures index !in memo ==> Good(nodes,valid,S.Body(nodes,valid,truth,reject,oracle,index,memo,history).memo) &&\n                               Extends(memo,S.Body(nodes,valid,truth,reject,oracle,index,memo,history).memo) &&\n                               index !in S.Body(nodes,valid,truth,reject,oracle,index,memo,history).memo'
 change(old,new)
 erased=text
 for old,new in reversed(edits):erased=erased.replace(new,old)
 if erased!=original:raise ValueError('Control drift')
 a.output.mkdir(parents=True,exist_ok=True)
 (a.output/'Body.generated.dfy').write_text(text)
 (a.output/'mapping.json').write_text(json.dumps({'controlErasureExact':True,'sourceSha256':hashlib.sha256(original.encode()).hexdigest(),'edits':[{'before':x,'after':y} for x,y in edits]},indent=2)+'\n')
if __name__=='__main__':main()
