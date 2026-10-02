// SPDX-License-Identifier: MIT
// Exact reached first failing fold iteration, with accumulator-first stamping and all callback failures.
include "../loop-model-repair-v2/Model.dfy"
include "../successful-iteration-repair-v2/Connection.dfy"
include "../callback-length-error/Engine.dfy"
include "../callback-failed/Connection.dfy"
module BytecodeFoldFailedIteration {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import SE = BytecodeScanExecution
  import L = BytecodeFoldLoopModelV2
  import D = BytecodeFoldDomainConnectionV3
  import T = BytecodeFoldStampConnectionV4
  import M = BytecodeFoldStampMemoryV2
  import Q = BytecodeFoldSuccessfulIterationMemoryV2
  import V = BytecodeFoldCallbackInvokeV2
  import CB = BytecodeFoldCallbackEngine
  import CM = BytecodeApplyFullCallbackReceiptMemory
  import K = BytecodeApplyCallbackExhaustionEngine
  import DB = BytecodeApplyDynamicBytesCopyMemory
  import W = BytecodeFoldWrongSizeCallbackEngine
  import F = BytecodeFoldOrdinaryFailedCallbackConnection
  import C = BytecodeFoldFailedCallbackGuardConnection
  import CL = BytecodeFoldCallbackLengthScalar
  import WH = BytecodeApplyWrongCallbackMemory
  import FH = BytecodeApplyCallbackFailedMemory
  import O = BytecodeApplyCallbackOutOfGasReturnMemory
  datatype Receipt = Receipt(returned: seq<Byte>,success: bool,gasBefore: Word,requestedGas: Word,gasAfter: Word)
  predicate Matches(code: seq<Byte>) { T.Matches(code) && V.Matches(code) && W.Matches(code) && F.Matches(code) && C.Matches(code) }
  function Destinations(): set<nat> { T.Destinations()+V.Destinations()+W.Destinations()+F.Destinations()+C.Destinations() }
  function Stamped(data: seq<Byte>,mem: seq<Byte>,c: L.Configuration,index: Word): seq<Byte>
    requires L.Ready(data,mem,c) && index < c.total
  {
    L.Reached(data,mem,c,index);
    M.Stamped(mem,c.callPtr,c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,D.Element(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength),c.count)
  }
  function Payload(data: seq<Byte>,mem: seq<Byte>,c: L.Configuration,index: Word): seq<Byte>
    requires L.Ready(data,mem,c) && index < c.total
  { Stamped(data,mem,c,index)[c.callPtr+32..c.callPtr+32+c.templateLength] }
  predicate Resources(data: seq<Byte>,mem: seq<Byte>,c: L.Configuration,index: Word,r: Receipt) {
    L.Ready(data,mem,c) && index < c.total && (!r.success || |r.returned| != 32) &&
    CM.Fits(Stamped(data,mem,c,index),c.callPtr,Load(mem,64),c.templateLength,r.returned) &&
    (var after := CM.Final(Stamped(data,mem,c,index),c.callPtr,Load(mem,64),c.templateLength,r.returned);
     var receipt := CM.Receipt(Load(mem,64),r.returned);
     r.success || K.Refused(|r.returned|,Load(after,receipt+32),r.gasBefore,r.gasAfter) ||
     Load(after,64)+c.templateLength+|r.returned|+512 < DB.Bound())
  }
  predicate Truthful(data: seq<Byte>,mem: seq<Byte>,c: L.Configuration,index: Word,r: Receipt,self: Word,cursor: nat,observations: seq<X.Observation>)
    requires Resources(data,mem,c,index,r)
  {
    cursor+2 < |observations| && observations[cursor] == X.Gas(r.gasBefore) && observations[cursor+1] == X.Gas(r.requestedGas) &&
    observations[cursor+2] == X.StaticCall(self,r.requestedGas,c.target,Payload(data,mem,c,index),r.success,r.returned) &&
    (r.success || (cursor+3 < |observations| && observations[cursor+3] == X.Gas(r.gasAfter)))
  }
  function Error(data: seq<Byte>,mem: seq<Byte>,c: L.Configuration,index: Word,r: Receipt): seq<Byte>
    requires Resources(data,mem,c,index,r)
  {
    var after := CM.Final(Stamped(data,mem,c,index),c.callPtr,Load(mem,64),c.templateLength,r.returned);
    var receipt := CM.Receipt(Load(mem,64),r.returned);
    if r.success then WH.Packet(CL.Operation(c.domain as nat),index,c.target)
    else if K.Refused(|r.returned|,Load(after,receipt+32),r.gasBefore,r.gasAfter) then O.Packet()
    else FH.Packet(CL.Operation(c.domain as nat),index,c.target,Payload(data,mem,c,index),r.returned)
  }
  lemma Header(data: seq<Byte>,mem: seq<Byte>,c: L.Configuration,index: Word)
    requires L.Ready(data,mem,c) && index < c.total
    ensures Load(Stamped(data,mem,c,index),64) == Load(mem,64)
    ensures Load(Stamped(data,mem,c,index),c.callPtr) == c.templateLength
    ensures Load(Stamped(data,mem,c,index),192) == c.target
    ensures |Stamped(data,mem,c,index)| == |mem|
  {
    L.Reached(data,mem,c,index);
    var element := D.Element(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength);
    M.Extent(mem,c.callPtr,c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,c.count);
    Q.Header(mem,c.callPtr,c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element);
    M.WordFrame(mem,c.callPtr,c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,c.count,64);
    M.WordFrame(mem,c.callPtr,c.templateLength,c.accOffset,Load(mem,256),c.arrayOffset,c.count,data,element,c.count,192);
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,c: L.Configuration,index: Word,r: Receipt,self: Word,value: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && |prefix| <= 970 && X.Context(self)
    requires Resources(data,mem,c,index,r) && Truthful(data,mem,c,index,r,self,cursor,observations)
    requires ShiftRight(DataWord(data,0),224) == CL.Selector(c.domain as nat)
    ensures frame == X.Frame(Reverted(Error(data,mem,c,index,r)),r.returned,cursor+(if r.success then 3 else 4))
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| > 0 && trace[0] == X.Frame(Running(16484,prefix+D.Fields(12157,c.sourceOffset,c.sourceLength,c.templateOffset,c.templateLength,c.arrayOffset,c.count,c.returnWord,c.callPtr,index),mem),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide G.BitAnd();hide DataWord();hide ShiftRight();hide E.Trace();hide SE.Trace();hide CM.Final();hide Error();
    L.Reached(data,mem,c,index);Header(data,mem,c,index);
    var stamped := Stamped(data,mem,c,index);
    var element := D.Element(data,mem,c.domain,c.total,index,c.sourceOffset,c.sourceLength);
    var state: State;var states: seq<State>;
    state,states := T.Run(code,data,mem,prefix,12157,c.sourceOffset,c.sourceLength,c.templateOffset,c.templateLength,c.arrayOffset,c.count,c.returnWord,c.callPtr,index,c.domain,c.total,c.accOffset,Load(mem,256),value);
    trace := T.ExternalLift(code,data,value,self,states,oldReturn,cursor,observations);
    E.WidenTrace(code,T.Destinations(),Destinations(),self,value,data,observations,trace);
    state,states := V.Run(code,data,stamped,prefix,12157,128,c.sourceOffset,c.sourceLength,c.templateOffset,c.templateLength,c.arrayOffset,c.count,c.returnWord,c.callPtr,index,c.target,element,value);
    CB.Lift(code,V.Destinations(),data,value,states,self,oldReturn,cursor,observations);
    var part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor));
    E.WidenTrace(code,V.Destinations(),Destinations(),self,value,data,observations,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
    var fields := D.Fields(12157,c.sourceOffset,c.sourceLength,c.templateOffset,c.templateLength,c.arrayOffset,c.count,c.returnWord,c.callPtr,index);
    var lower := prefix+fields+[0];
    if r.success {
      frame,part := W.Run(code,data,stamped,lower,c.domain as nat,c.target,c.callPtr,index,Load(mem,64),c.templateLength,self,value,oldReturn,r.returned,cursor,observations,r.gasBefore,r.requestedGas);
      E.WidenTrace(code,W.Destinations(),Destinations(),self,value,data,observations,part);
    } else {
      var after := CM.Final(stamped,c.callPtr,Load(mem,64),c.templateLength,r.returned);
      var receipt := CM.Receipt(Load(mem,64),r.returned);
      if K.Refused(|r.returned|,Load(after,receipt+32),r.gasBefore,r.gasAfter) {
        frame,part := C.Run(code,data,stamped,lower,c.target,c.callPtr,index,Load(mem,64),c.templateLength,self,value,oldReturn,r.returned,cursor,observations,r.gasBefore,r.requestedGas,r.gasAfter);
        E.WidenTrace(code,C.Destinations(),Destinations(),self,value,data,observations,part);
      } else {
        frame,part := F.Run(code,data,stamped,lower,c.domain as nat,c.target,c.callPtr,index,Load(mem,64),c.templateLength,Payload(data,mem,c,index),self,value,oldReturn,r.returned,cursor,observations,r.gasBefore,r.requestedGas,r.gasAfter);
        E.WidenTrace(code,F.Destinations(),Destinations(),self,value,data,observations,part);
      }
    }
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
    reveal Error();
  }
}
