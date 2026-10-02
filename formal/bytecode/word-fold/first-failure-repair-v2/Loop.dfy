// SPDX-License-Identifier: MIT
// Exact complete trace through an arbitrary successful prefix and first failure, no later iteration.
include "Model.dfy"
include "../loop-connection-repair-v2/Loop.dfy"
module BytecodeFoldFirstFailureLoop {
  import opened BytecodeScanMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import L = BytecodeFoldLoopModelV2
  import M = BytecodeFoldFirstFailureModel
  import F = BytecodeFoldFailedIteration
  import C = BytecodeFoldLoopConnectionV2
  import I = BytecodeFoldSuccessfulIterationV2
  import D = BytecodeFoldDomainConnectionV3
  import Q = BytecodeFoldSuccessfulIterationMemoryV2
  import CL = BytecodeFoldCallbackLengthScalar
  predicate Matches(code: seq<Byte>) { I.Matches(code) && F.Matches(code) }
  function Destinations(): set<nat> { I.Destinations()+F.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,caller: seq<Word>,c: L.Configuration,index: Word,prefix: seq<L.Receipt>,failure: F.Receipt,self: Word,value: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && |caller| <= 970 && X.Context(self)
    requires M.Resources(data,mem,c,index,prefix,failure) && M.Truthful(data,mem,c,index,prefix,failure,self,cursor,observations)
    requires ShiftRight(DataWord(data,0),224) == CL.Selector(c.domain as nat)
    ensures frame == X.Frame(Reverted(M.Error(data,mem,c,index,prefix,failure)),failure.returned,cursor+3*|prefix|+(if failure.success then 3 else 4))
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| > 0 && trace[0] == C.Initial(caller,c,index,mem,oldReturn,cursor) && trace[|trace|-1] == frame
    decreases |prefix|
  {
    hide DataWord();hide ShiftRight();hide E.Trace();hide M.Error();hide L.Next();hide L.Payload();hide C.Initial();
    M.Reached(data,mem,c,index,prefix,failure);
    if |prefix| == 0 {
      frame,trace := F.Run(code,data,mem,caller,c,index,failure,self,value,oldReturn,cursor,observations);
      E.WidenTrace(code,F.Destinations(),Destinations(),self,value,data,observations,trace);
      reveal C.Initial();reveal M.Error();
    } else {
      var r := prefix[0];
      L.Reached(data,mem,c,index);
      var element := D.Element(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength);
      Q.Admission(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,r.returned);
      C.Physical(data,mem,c,index,r);
      var next := L.Next(data,mem,c,index,r);
      var stopped: bool;
      frame,trace,stopped := I.Run(code,data,mem,caller,c.sourceOffset,c.sourceLength,c.templateOffset,c.templateLength,c.arrayOffset,c.count,c.returnWord,c.callPtr,index,c.domain,c.total,c.accOffset,Load(mem,256),c.exit,c.target,Load(mem,64),self,value,oldReturn,r.returned,cursor,observations,r.gasBefore,r.requestedGas);
      E.WidenTrace(code,I.Destinations(),Destinations(),self,value,data,observations,trace);
      assert !stopped;
      assert frame == C.Initial(caller,c,index+1,next,r.returned,cursor+3) by { reveal C.Initial(); }
      assert trace[0] == C.Initial(caller,c,index,mem,oldReturn,cursor) by { reveal C.Initial(); }
      L.Readmission(data,mem,c,index,r);
      var part: seq<X.Frame>;
      frame,part := Run(code,data,next,caller,c,index+1,prefix[1..],failure,self,value,r.returned,cursor+3,observations);
      assert trace[|trace|-1] == part[0];
      E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
      reveal M.Error();
    }
  }
}
