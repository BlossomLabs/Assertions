#!/usr/bin/env python3
"""Add proof-only request contracts to the retained recursive source lowering."""
import argparse
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--dafny',type=Path,required=True);a=p.parse_args()
s=(a.root/'formal/expressions/recursive/Source.generated.dfy').read_text()
s=s.replace('include "Spec.dfy"','include "Model.dfy"').replace('module ExpressionRecursiveSource','module ExpressionRequestSource')
s=s.replace('  import S = ExpressionRecursiveSpec','  import S = ExpressionRecursiveSpec\n  import T = ExpressionRequestModel\n  import B = ExpressionEvaluationBridge\n  import M = ExpressionScalarModel')
needle='    requires Program(nodes) && index < |nodes| && Good(nodes,valid,memo)'
assert s.count(needle)==1
s=s.replace(needle,needle+'''
    requires forall i: nat, v: Value :: i < |nodes| && valid(i,v) ==> B.Bytes(v)
    requires forall i: nat, v: Value :: i < |nodes| ==> B.Bytes(reject(i,v).payload)
    requires T.Receipts(nodes,valid,oracle) && T.History(nodes,valid,history)
    ensures T.History(nodes,valid,out.history)
    ensures out.Failure? ==> B.Bytes(out.error.payload)''')
s=s.replace('        invariant history <= seen','''        invariant history <= seen
        invariant T.History(nodes,valid,seen)
        invariant forall i :: 0 <= i < pos ==> valid(node.refs[i],values[i]) && B.Bytes(values[i])
        invariant pos > 0 && node.kind in {Call,ProbeCall} ==> M.AddressSpec(index,B.Narrow(values[0])).Addressed?''')
s=s.replace('var raw := oracle(request,seen); seen := seen+[request];','''assert T.Typed(nodes,valid,request);
        T.Append(nodes,valid,seen,request);
        var before := seen;
        var raw := oracle(request,seen); seen := seen+[request];''')
s=s.replace('if raw.Aborted? { out := Failure(raw.error,working,seen); return; }\n        }','''if raw.Aborted? { out := Failure(raw.error,working,seen); return; }
          assert M.AddressSpec(index,B.Narrow(child.value)).Addressed?;
        }''')
a.output.mkdir(parents=True,exist_ok=True);dest=a.output/'Source.dfy'
local=a.root/'formal/expressions/requests/Instrumented.dfy'
assert not local.exists(),'Temporary proof file already exists'
local.write_text(s)
# Formatting only normalizes presentation; native verification and dependency
# audits remain mandatory after this control-preservation check.
import subprocess
try:
    subprocess.run([str(a.dafny),'format',str(local)],check=True)
    dest.write_bytes(local.read_bytes())
finally:
    local.unlink()
expected=a.root/'formal/expressions/requests/Source.dfy'
assert dest.read_bytes()==expected.read_bytes(),'Proof instrumentation drift'
print('PASS: original control statements retained; only proof contracts/annotations and namespace/includes added')
