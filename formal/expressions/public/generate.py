#!/usr/bin/env python3
"""Bind the source entry composition to exact validator rejection after admission."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def main():
 p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 raw=(a.root/'formal/expressions/entry/Connection.dfy').read_text()
 original=raw[:raw.index('  datatype Outcome')]+raw[raw.index('  ghost method Evaluate('):]
 text=original;edits=[]
 def change(old,new):
  nonlocal text
  if text.count(old)!=1:raise ValueError('Ambiguous entry instantiation '+old)
  text=text.replace(old,new);edits.append((old,new))
 change('include "../execution/Connection.dfy"\ninclude "../cache/Source.generated.dfy"','include "../entry/Connection.dfy"\ninclude "../rejections/Model.dfy"')
 change('module ExpressionEntryConnection {','module ExpressionPublicEntry {\n  import opened ExpressionEntryConnection\n  import R = ExpressionRejectionModel')
 change('hash: seq<Byte>->nat, reject: (nat,E.Value)->E.Error)','hash: seq<Byte>->nat)')
 change('returns (out: Outcome)','returns (out: ExpressionEntryConnection.Outcome)')
 anchor='    requires forall i :: 0 <= i < |c.nodes| ==> Uint(|c.nodes[i].valueType|)\n'
 change(anchor+'    requires forall i: nat,v: E.Value :: i < |c.nodes| ==> B.Bytes(reject(i,v).payload)\n',anchor)
 change('Scalar.TotalTruth,reject,\n','Scalar.TotalTruth,R.Reject(out.types),\n')
 change('    ensures out.Evaluated? ==> E.Program(B.Project(c.nodes))','    ensures out.Evaluated? ==> E.Program(B.Project(c.nodes)) && C.Valid(out.types,out.initial)')
 change('    B.AdmittedGraph(c.nodes,result,hash);','    B.AdmittedGraph(c.nodes,result,hash);\n    R.AllBytes(prepared.types);\n    var reject := R.Reject(prepared.types);')
 erased=text
 for old,new in reversed(edits):erased=erased.replace(new,old)
 if erased!=original:raise ValueError('Entry control drift')
 a.output.mkdir(parents=True,exist_ok=True)
 (a.output/'Entry.generated.dfy').write_text(text)
 entry={'file':'Entry.generated.dfy','source':'formal/expressions/entry/Connection.dfy','sourceSha256':hashlib.sha256(raw.encode()).hexdigest(),'selection':'imports and Evaluate declaration','edits':[{'before':x,'after':y} for x,y in edits]}
 raw=(a.root/'formal/expressions/guarded/Source.generated.dfy').read_text();original=raw;text=raw;edits=[]
 change('module ExpressionGuardedSource {','module ExpressionPublicGuardedSource {\n  import Reject = ExpressionRejectionModel\n  import S = ExpressionRecursiveSpec\n  import Scalar = ExpressionScalarModel')
 change('                        reject: (nat,E.Value)->E.Error, caller: R.Address)','                        caller: R.Address)')
 change('    requires caller == c.self ==> M.Ready(c,types,initial,index,reject)',
        '    requires caller == c.self ==> C.Types(types) && M.Ready(c,types,initial,index,Reject.Reject(types))')
 anchor='    ensures out.Attempted? ==> out.covered == O.Covered(c,out.execution.history)'
 change(anchor,anchor+'\n    ensures out.Attempted? ==> |out.execution.history| == |out.replies| &&\n                               out.execution == S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,Reject.Reject(types),\n                                                           O.Replay(out.execution.history,out.replies),index,B.View(initial),[])')
 change('    var copied := initial;','    Reject.AllBytes(types);\n    var reject := Reject.Reject(types);\n    var copied := initial;')
 erased=text
 for old,new in reversed(edits):erased=erased.replace(new,old)
 if erased!=original:raise ValueError('Guarded entry control drift')
 (a.output/'Guarded.generated.dfy').write_text(text)
 (a.output/'mapping.json').write_text(json.dumps({'controlErasureExact':True,'adapters':[entry,{'file':'Guarded.generated.dfy','source':'formal/expressions/guarded/Source.generated.dfy','sourceSha256':hashlib.sha256(raw.encode()).hexdigest(),'edits':[{'before':x,'after':y} for x,y in edits]}]},indent=2)+'\n')
if __name__=='__main__':main()
