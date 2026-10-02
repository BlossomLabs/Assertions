#!/usr/bin/env python3
"""Compose the exact reached seed, scaling, six updates and correction."""
import argparse
from pathlib import Path
HERE=Path(__file__).resolve().parent
def generate(out):
 out.mkdir(parents=True,exist_ok=True)
 text='''// SPDX-License-Identifier: MIT
// Generated exact compiled square-root iteration connection; never edit directly.
include "../sqrt-seed-connection-v2/Connection.generated.dfy"
include "../sqrt-edge-controls/Scale.generated.dfy"
include "../sqrt-edge-controls/Correction.generated.dfy"
'''
 for i in range(6):text+=f'include "../sqrt-newton-controls/Newton{i}.generated.dfy"\n'
 text+='''module OperationsSquareRootPipeline {
  import M = OperationsBytecodeLog2Machine
  import E = OperationsSquareRootExecution
  import F = OperationsSquareRootMath
  import S = OperationsSquareRootSeed
  import L = OperationsSquareRootLimits
  import N = OperationsSquareRootNewton
  import W = OperationsSquareRootArithmetic
  import A = OperationsSquareRootAlgorithm
  import C = OperationsSquareRootSeedConnectionCore
  import Seed = OperationsSquareRootSeedConnection
  import Scale = OperationsSquareRootScale
  import Correction = OperationsSquareRootCorrection
'''
 for i in range(6):text+=f'  import R{i} = OperationsSquareRootNewton{i}\n'
 text+='  predicate Matches(code: seq<M.Byte>) {\n    Seed.Matches(code) && Scale.Matches(code) && Correction.Matches(code) &&\n    '+' && '.join(f'R{i}.Matches(code)' for i in range(6))+'\n  }\n'
 text+='''  lemma FinalEstimate(n: M.Word,seed: M.Word)
    requires n>=2 && seed==S.Initial(n)
    ensures F.Floor(n)<=A.Sixth(n,seed)<=F.Floor(n)+1
  {
    F.Fitting(n);L.Fitting(n);S.Bounds(n);S.Parity(S.Class(n));
    var root:=F.Floor(n);
    if seed<16 { N.SmallSteps(n,root,seed); }
    else { N.SixSteps(n,root,seed); }
  }
  method Run(code: seq<M.Byte>,destinations: set<nat>,initial: M.State,n: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>,value: M.Word,size: M.Word,word: M.Word,a: M.Word)
    returns(state: M.State,trace: seq<M.State>,dead: M.Word)
    requires n>=2 && 2<=|prefix|<=1000 && prefix[|prefix|-2]==n && Matches(code)
    requires {11151,11178,11201,11222,11242,11261,11273,11297,11321,11345,11369,11393,11417,11442,11448}<=destinations
    requires initial==M.Running(11130,prefix+[n,1],mem)
    ensures state==M.Running(11451,prefix+[dead,F.Floor(n)],mem) && 1<=dead<16
    ensures C.Trace(code,destinations,trace,value,size,word,a) && trace[0]==initial && trace[|trace|-1]==state
  {
    F.Fitting(n);L.Fitting(n);
    var root:=F.Floor(n);assert root>=1;
    var seed:M.Word;
    state,trace,dead,seed:=Seed.Run(code,destinations,initial,n,prefix,mem,value,size,word,a);
    assert seed==S.Initial(n) && 1<=seed<=F.Limit/2;
    var steps:seq<M.State>;
    state,steps:=Scale.Run(code,destinations,state,n,seed,dead,prefix,mem,value,size,word,a);
    Scale.SemanticResult(state,n,seed,dead,prefix,mem);
    C.Append(code,destinations,trace,steps,value,size,word,a);trace:=trace+steps[1..];
    var estimate:M.Word:=3*seed/2;
    W.FirstWindow(n,root,seed);
'''
 for i in range(6):
  if i:text+='    W.LaterWindow(n,root,estimate);\n'
  text+=f'''    {{
      var before:=estimate;
      state,steps:=R{i}.Run(code,destinations,state,n,before,dead,prefix,mem,value,size,word,a);
      R{i}.SemanticResult(state,n,before,dead,prefix,mem);
      estimate:=N.Next(n,before);
      assert 1<=root<=estimate<=2*F.Limit;
      C.Append(code,destinations,trace,steps,value,size,word,a);trace:=trace+steps[1..];
    }}
'''
 text+='''    assert estimate==A.Sixth(n,seed);
    FinalEstimate(n,seed);
    state,steps:=Correction.Run(code,destinations,state,n,estimate,dead,prefix,mem,value,size,word,a);
    Correction.SemanticResult(state,n,estimate,dead,prefix,mem,root);
    C.Append(code,destinations,trace,steps,value,size,word,a);trace:=trace+steps[1..];
  }
}
'''
 (out/'Pipeline.generated.dfy').write_text(text)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
