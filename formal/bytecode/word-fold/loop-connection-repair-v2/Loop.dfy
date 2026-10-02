// SPDX-License-Identifier: MIT
// Full finite successful compiled fold loop, through exhaustion or first canonical early stop.
include "../loop-model-repair-v2/Model.dfy"
include "../loop-gate-repair-v2/Exit.generated.dfy"
include "../loop-return/Return.generated.dfy"
include "../byte-representation-repair-v10/Representation.dfy"
module BytecodeFoldLoopConnectionV2 {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import S = BytecodeScanExecution
  import L = BytecodeFoldLoopModelV2
  import I = BytecodeFoldSuccessfulIterationV2
  import D = BytecodeFoldDomainConnectionV3
  import Q = BytecodeFoldSuccessfulIterationMemoryV2
  import F = BytecodeFoldIterationFrame
  import M = BytecodeFoldStampMemoryV2
  import C = BytecodeFoldLoopReturn
  import B = BytecodeFoldLoopExitV2
  import CB = BytecodeFoldCallbackEngine
  import H = BytecodeApplyCallbackSuccessMemory
  import K = BytecodeFoldCallbackMemoryV2
  import R = BytecodeFoldResultMemoryV3
  import P = BytecodeFoldByteRepresentationV10
  predicate Matches(code: seq<Byte>) { I.Matches(code) && B.Matches(code) && C.Matches(code) }
  function Destinations(): set<nat> { I.Destinations()+B.Destinations()+C.Destinations() }
  function Initial(prefix: seq<Word>,c: L.Configuration,index: Word,mem: seq<Byte>,oldReturn: seq<Byte>,cursor: nat): X.Frame
  { X.Frame(Running(16484,prefix+D.Fields(12157,c.sourceOffset,c.sourceLength,c.templateOffset,c.templateLength,c.arrayOffset,c.count,c.returnWord,c.callPtr,index),mem),oldReturn,cursor) }
  lemma Element(data: seq<Byte>,mem: seq<Byte>,c: L.Configuration,index: Word)
    requires L.Ready(data,mem,c) && index < c.total
    ensures D.Admitted(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength)
    ensures D.Element(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength) ==
            (if c.domain == 0 then index else if c.domain == 1 then data[c.sourceOffset+index] else DataWord(data,c.sourceOffset+index*32))
  {
    hide ShiftRight(); hide DataWord();
    L.Reached(data,mem,c,index);
    if c.domain == 1 { P.Source(data,c.sourceOffset,c.sourceLength,index); }
  }
  lemma Physical(data: seq<Byte>,mem: seq<Byte>,c: L.Configuration,index: Word,r: L.Receipt)
    requires L.StepReady(data,mem,c,index,r)
    ensures var element := D.Element(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength);
            var stamped := M.Stamped(mem,c.callPtr,c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,c.count);
            K.Fits(stamped,c.callPtr,Load(mem,64),c.templateLength,r.returned) &&
            R.Fits(K.Complete(stamped,c.callPtr,Load(mem,64),c.templateLength,r.returned)) &&
            L.Next(data,mem,c,index,r) == R.Updated(K.Complete(stamped,c.callPtr,Load(mem,64),c.templateLength,r.returned),H.Result(r.returned)) &&
            L.Payload(data,mem,c,index,r) == stamped[c.callPtr+32..c.callPtr+32+c.templateLength]
  {
    hide M.Stamped();hide K.Complete();hide R.Updated();
    var element := D.Element(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength);
    Q.Admission(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,r.returned);
  }
  lemma ResultHead(data: seq<Byte>,mem: seq<Byte>,c: L.Configuration,index: Word,receipts: seq<L.Receipt>)
    requires L.Resources(data,mem,c,index,receipts)
    ensures if index == c.total then L.Result(data,mem,c,index,receipts) == L.Outcome(mem,index,0,false,Load(mem,256)) else
            var next := L.Next(data,mem,c,index,receipts[0]);
            var word := H.Result(receipts[0].returned);
            if I.Stop(c.exit,word) then L.Result(data,mem,c,index,receipts) == L.Outcome(next,index,1,true,word) else
            var tail := L.Result(data,next,c,index+1,receipts[1..]);
            L.Result(data,mem,c,index,receipts) == L.Outcome(tail.memory,tail.index,tail.used+1,tail.stopped,tail.word)
  {
    hide L.Next(); hide F.Next(); hide F.Complete(); hide F.Stamped(); hide M.Stamped();
    reveal L.Result();
  }
  lemma LastReturnTail(receipts: seq<L.Receipt>,used: nat,oldReturn: seq<Byte>)
    requires |receipts| > 0 && used <= |receipts|-1
    ensures L.LastReturn(receipts,used+1,oldReturn) == L.LastReturn(receipts[1..],used,receipts[0].returned)
  {
    if used > 0 { assert receipts[1..][used-1] == receipts[used]; }
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,c: L.Configuration,index: Word,receipts: seq<L.Receipt>,self: Word,value: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && |prefix| <= 970 && X.Context(self)
    requires L.Resources(data,mem,c,index,receipts) && L.Truthful(data,mem,c,index,receipts,self,cursor,observations)
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| > 0 && trace[0] == Initial(prefix,c,index,mem,oldReturn,cursor) && trace[|trace|-1] == frame
    ensures var result := L.Result(data,mem,c,index,receipts);
            frame == X.Frame(Running(12157,prefix+[result.word],result.memory),L.LastReturn(receipts,result.used,oldReturn),cursor+3*result.used)
    decreases |receipts|
  {
    hide ShiftRight(); hide DataWord(); hide E.Trace(); hide S.Trace(); hide L.Result();
    hide L.Next(); hide L.Payload(); hide F.Next(); hide F.Complete(); hide F.Stamped(); hide M.Stamped(); hide K.Complete(); hide R.Updated();
    ResultHead(data,mem,c,index,receipts);
    var state: State; var states: seq<State>;
    if index == c.total {
      state,states := B.Run(code,data,mem,prefix,12157,128,c.sourceOffset,c.sourceLength,c.templateOffset,c.templateLength,c.arrayOffset,c.count,c.returnWord,c.callPtr,index,c.domain,c.total,Load(mem,256),value);
      CB.Lift(code,B.Destinations(),data,value,states,self,oldReturn,cursor,observations);
      trace := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor));
      E.WidenTrace(code,B.Destinations(),Destinations(),self,value,data,observations,trace);
      frame := trace[|trace|-1];
    } else {
      var r := receipts[0];
      var element := D.Element(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength);
      Q.Admission(mem,c.callPtr,Load(mem,64),c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,r.returned);
      Physical(data,mem,c,index,r);
      var next := L.Next(data,mem,c,index,r);
      var stopped: bool;
      frame,trace,stopped := I.Run(code,data,mem,prefix,c.sourceOffset,c.sourceLength,c.templateOffset,c.templateLength,c.arrayOffset,c.count,c.returnWord,c.callPtr,index,c.domain,c.total,c.accOffset,Load(mem,256),c.exit,c.target,Load(mem,64),self,value,oldReturn,r.returned,cursor,observations,r.gasBefore,r.requestedGas);
      E.WidenTrace(code,I.Destinations(),Destinations(),self,value,data,observations,trace);
      assert frame == X.Frame(Running(if stopped then 16664 else 16484,prefix+D.Fields(12157,c.sourceOffset,c.sourceLength,c.templateOffset,c.templateLength,c.arrayOffset,c.count,c.returnWord,c.callPtr,if stopped then index else index+1),next),r.returned,cursor+3);
      assert trace[|trace|-1] == frame;
      L.Readmission(data,mem,c,index,r);
      var part: seq<X.Frame>;
      if stopped {
        state,states := C.Run(code,data,next,prefix,12157,128,c.sourceOffset,c.sourceLength,c.templateOffset,c.templateLength,c.arrayOffset,c.count,c.returnWord,c.callPtr,index,c.domain,c.total,H.Result(r.returned),value);
        CB.Lift(code,C.Destinations(),data,value,states,self,r.returned,cursor+3,observations);
        part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],r.returned,cursor+3));
        E.WidenTrace(code,C.Destinations(),Destinations(),self,value,data,observations,part);
        assert trace[|trace|-1] == part[0];
        E.Join(code,Destinations(),self,value,data,observations,trace,part); trace := trace+part[1..];
        frame := part[|part|-1];
      } else {
        frame,part := Run(code,data,next,prefix,c,index+1,receipts[1..],self,value,r.returned,cursor+3,observations);
        assert trace[|trace|-1] == part[0];
        E.Join(code,Destinations(),self,value,data,observations,trace,part); trace := trace+part[1..];
        var tail := L.Result(data,next,c,index+1,receipts[1..]);
        LastReturnTail(receipts,tail.used,oldReturn);
      }
    }
  }
}
