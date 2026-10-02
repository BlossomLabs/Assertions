// SPDX-License-Identifier: MIT
// Complete raw square-root composition candidate. No retained/public credit yet.
include "../sqrt-pipeline/Pipeline.generated.dfy"
include "../sqrt-return-controls/Iterated.generated.dfy"
include "../sqrt-return-controls/Early.generated.dfy"
include "../sqrt-raw-repair-v2/Nonzero.generated.dfy"
include "../sqrt-raw-repair-v2/Short.generated.dfy"
include "../sqrt-raw-repair-v2/Args.generated.dfy"
include "../sqrt-raw-repair-v2/Early.generated.dfy"
include "../sqrt-raw-repair-v2/Iterated.generated.dfy"
module OperationsSquareRootFull {
  import M = OperationsBytecodeLog2Machine
  import E = OperationsSquareRootExecution
  import F = OperationsSquareRootMath
  import C = OperationsSquareRootSeedConnectionCore
  import P = OperationsSquareRootPipeline
  import ReturnEarly = OperationsSquareRootReturnEarly
  import ReturnIterated = OperationsSquareRootReturnIterated
  import Nonzero = OperationsSquareRootRawNonzero
  import Short = OperationsSquareRootRawShort
  import Args = OperationsSquareRootRawArgs
  import Early = OperationsSquareRootRawEarly
  import Iterated = OperationsSquareRootRawIterated

  predicate Frame(data:seq<M.Byte>) { |data|<0x10000000000000000 }
  function DataWord(data:seq<M.Byte>,offset:nat):M.Word { M.Load(data,offset) }
  // Every reached CALLDATALOAD is at0 or4. These observations come from the
  // complete original byte sequence, including actual zero padding.
  function RawStep(code:seq<M.Byte>,destinations:set<nat>,state:M.State,value:M.Word,data:seq<M.Byte>):M.State
    requires Frame(data)
  { E.Execute(code,destinations,state,value,|data| as M.Word,DataWord(data,0),DataWord(data,4)) }
  function Destinations():set<nat> {
    {15,655,758,828,968,1266,1301,1329,1952,1971,1985,2984,5376,
     11113,11126,11151,11178,11201,11222,11242,11261,11273,11297,
     11321,11345,11369,11393,11417,11442,11448,18955,18971}
  }
  predicate Matches(code:seq<M.Byte>) {
    P.Matches(code) && ReturnEarly.Matches(code) && ReturnIterated.Matches(code) &&
    Nonzero.Matches(code) && Short.Matches(code) && Args.Matches(code) &&
    Early.Matches(code) && Iterated.Matches(code)
  }
  lemma Small(n:M.Word)
    requires n<=1
    ensures F.Floor(n)==n
  { assert F.IsRoot(n,n);F.Unique(n,n,F.Floor(n)); }

  method Run(code:seq<M.Byte>,value:M.Word,data:seq<M.Byte>) returns(state:M.State,trace:seq<M.State>)
    requires Frame(data) && Matches(code)
    requires value!=0 || |data|<4 || M.Selector(DataWord(data,0))==0x677342ce
    ensures value!=0 || |data|<36 ==> state==M.Reverted([])
    ensures value==0 && |data|>=36 ==> state==M.Returned(M.Encode(F.Floor(DataWord(data,4)),32))
    ensures |trace|>0 && trace[0]==M.Running(0,[],[]) && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==RawStep(code,Destinations(),trace[j],value,data)
  {
    var size:=|data| as M.Word;
    var word:=DataWord(data,0);var n:=DataWord(data,4);var destinations:=Destinations();
    M.LoadProjection(data,0);M.LoadProjection(data,4);
    if value!=0 { state,trace:=Nonzero.Run(code,destinations,value,size,word,n); }
    else if size<4 { state,trace:=Short.Run(code,destinations,value,size,word,n); }
    else if size<36 { state,trace:=Args.Run(code,destinations,value,size,word,n); }
    else if n<=1 {
      state,trace:=Early.Run(code,destinations,value,size,word,n);
      var steps:seq<M.State>;
      state,steps:=ReturnEarly.Run(code,destinations,state,n,0,n,value,size,word,n);
      C.Append(code,destinations,trace,steps,value,size,word,n);trace:=trace+steps[1..];
      Small(n);
    } else {
      state,trace:=Iterated.Run(code,destinations,value,size,word,n);
      var prefix:seq<M.Word>:=[0x677342ce,1329,n,0,2984,n,0];
      var steps:seq<M.State>;var dead:M.Word;
      state,steps,dead:=P.Run(code,destinations,state,n,prefix,M.Store([],64,128),value,size,word,n);
      C.Append(code,destinations,trace,steps,value,size,word,n);trace:=trace+steps[1..];
      F.Fitting(n);
      state,steps:=ReturnIterated.Run(code,destinations,state,n,dead,F.Floor(n) as M.Word,value,size,word,n);
      C.Append(code,destinations,trace,steps,value,size,word,n);trace:=trace+steps[1..];
    }
  }
}
