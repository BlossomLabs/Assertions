// SPDX-License-Identifier: MIT
include "../callback-failed-controls-repair-v7/Before.generated.dfy"
include "../callback-failed-controls-repair-v7/Between.generated.dfy"
include "../callback-failed-controls-repair-v7/After.generated.dfy"
include "../dynamic-bytes-copy-repair-v2/Control.generated.dfy"
include "../../external-calls/Execution.dfy"
module BytecodeApplyCallbackFailedSerializerEngine {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeCopyExecution
  import SE = BytecodeScanExecution
  import XE = BytecodeExternalExecution
  import X = BytecodeExternalMachine
  import U = BytecodeApplyCallbackFailedBefore
  import V = BytecodeApplyCallbackFailedBetween
  import W = BytecodeApplyCallbackFailedAfter
  import M = BytecodeApplyCallbackFailedControlMemory
  import H = BytecodeApplyCallbackFailedMemory
  import D = BytecodeApplyDynamicBytesCopyControl
  import DM = BytecodeApplyDynamicBytesCopyMemory
  import A = BytecodeApplyAddressMask
  import CL = BytecodeApplyCallbackLengthScalar
  import Q = BytecodeApplyCallbackSuccessScalar
  predicate Matches(code: seq<Byte>) { U.Matches(code) && V.Matches(code) && W.Matches(code) && D.Matches(code,24352) && D.Matches(code,24370) }
  function Destinations(): set<nat> { U.Destinations()+V.Destinations()+W.Destinations()+D.Destinations(24352)+D.Destinations(24370) }
  function Tail(target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word): seq<Word>
  { [12484,target,ptr,index,0,gasBefore,0,receipt] }
  ghost method Lift(code: seq<Byte>,small: set<nat>,value: Word,data: seq<Byte>,states: seq<State>)
    requires SE.Trace(code,small,value,data,states) && small <= Destinations()
    ensures E.Trace(code,Destinations(),value,data,states)
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    { assert Step(code,small,states[i],value,data) != Bad;reveal Step(); }
    E.Lift(code,small,value,data,states);E.WidenTrace(code,small,Destinations(),value,data,states);
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word) returns (frame: State,trace: seq<State>)
    requires Matches(code) && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && |prefix| <= 997
    requires ShiftRight(DataWord(data,0),224) == CL.Selector(filter)
    ensures frame == Reverted(H.Packet(CL.Operation(filter),index,target,payload,reason))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| > 0 && trace[0] == Running(17017,prefix+Tail(target,ptr,index,gasBefore,receipt),mem) && trace[|trace|-1] == frame
  {
    hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide M.Heap();hide DM.Stage();hide E.Trace();hide H.Packet();hide Tail();
    U.Admit(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    V.Admit(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    W.Admit(data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    var op := CL.Operation(filter);var part: seq<State>;
    var tail := Tail(target,ptr,index,gasBefore,receipt);
    assert tail == [12484,target,ptr,index,0,gasBefore,0,receipt] by { reveal Tail(); }
    var fields := tail+[1114,op,index,0,target,ptr,receipt,free+4,0];
    var copyPrefix := prefix+fields;
    frame,trace := U.Run(code,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    Lift(code,U.Destinations(),value,data,trace);
    M.Info(mem,ptr,receipt,free,op,index,target,payload,reason,0);
    M.HeapProjection(mem,ptr,receipt,free,op,index,target,payload,reason,6);
    H.FirstAdmission(mem,ptr,receipt,free,op,index,target,payload,reason);
    Q.Append(prefix,fields,[24352,H.FirstDst(free),ptr]);
    assert frame == Running(20951,copyPrefix+[24352,H.FirstDst(free),ptr],H.Head(mem,free,op,index,target,6));
    assert D.Admitted(H.Head(mem,free,op,index,target,6),copyPrefix,ptr,H.FirstDst(free),|payload|,payload,24352,value,data);
    assert DM.Stage(H.Head(mem,free,op,index,target,6),ptr,H.FirstDst(free),|payload|,payload,0) == H.Head(mem,free,op,index,target,6) by { reveal DM.Stage(); }
    assert trace[|trace|-1] == frame;
    frame,part := D.Run(code,H.Head(mem,free,op,index,target,6),copyPrefix,ptr,H.FirstDst(free),|payload|,payload,24352,value,data);
    E.WidenTrace(code,D.Destinations(24352),Destinations(),value,data,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    M.FirstProjection(mem,ptr,receipt,free,op,index,target,payload,reason);
    M.HeapProjection(mem,ptr,receipt,free,op,index,target,payload,reason,7);
    assert DM.End(H.FirstDst(free),|payload|) == H.ReasonDst(free,payload);
    assert frame == Running(24352,copyPrefix+[H.ReasonDst(free,payload)],H.First(mem,ptr,receipt,free,op,index,target,payload,reason));
    Q.Append(prefix,fields,[H.ReasonDst(free,payload)]);
    assert trace[|trace|-1] == frame;
    Q.Append(tail,[1114,op,index,0,target,ptr,receipt,free+4,0],[H.ReasonDst(free,payload)]);
    assert copyPrefix+[H.ReasonDst(free,payload)] == prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,op,index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload)];
    frame,part := V.Run(code,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    Lift(code,V.Destinations(),value,data,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    M.HeapProjection(mem,ptr,receipt,free,op,index,target,payload,reason,8);
    H.ReasonAdmission(mem,ptr,receipt,free,op,index,target,payload,reason);
    var secondFields := fields+[H.ReasonDst(free,payload)];
    var secondPrefix := prefix+secondFields;
    Q.Append(prefix,secondFields,[24370,H.ReasonDst(free,payload),receipt]);
    assert frame == Running(20951,secondPrefix+[24370,H.ReasonDst(free,payload),receipt],H.Offset(mem,ptr,receipt,free,op,index,target,payload,reason));
    assert D.Admitted(H.Offset(mem,ptr,receipt,free,op,index,target,payload,reason),secondPrefix,receipt,H.ReasonDst(free,payload),|reason|,reason,24370,value,data);
    assert DM.Stage(H.Offset(mem,ptr,receipt,free,op,index,target,payload,reason),receipt,H.ReasonDst(free,payload),|reason|,reason,0) == H.Offset(mem,ptr,receipt,free,op,index,target,payload,reason) by { reveal DM.Stage(); }
    assert trace[|trace|-1] == frame;
    frame,part := D.Run(code,H.Offset(mem,ptr,receipt,free,op,index,target,payload,reason),secondPrefix,receipt,H.ReasonDst(free,payload),|reason|,reason,24370,value,data);
    E.WidenTrace(code,D.Destinations(24370),Destinations(),value,data,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    M.FinalProjection(mem,ptr,receipt,free,op,index,target,payload,reason);
    M.HeapProjection(mem,ptr,receipt,free,op,index,target,payload,reason,9);
    assert DM.End(H.ReasonDst(free,payload),|reason|) == H.End(free,payload,reason);
    assert frame == Running(24370,secondPrefix+[H.End(free,payload,reason)],H.Final(mem,ptr,receipt,free,op,index,target,payload,reason));
    Q.Append(prefix,secondFields,[H.End(free,payload,reason)]);
    assert trace[|trace|-1] == frame;
    Q.Append(tail,[1114,op,index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload)],[H.End(free,payload,reason)]);
    assert secondPrefix+[H.End(free,payload,reason)] == prefix+[12484,target,ptr,index,0,gasBefore,0,receipt,1114,op,index,0,target,ptr,receipt,free+4,0,H.ReasonDst(free,payload),H.End(free,payload,reason)];
    frame,part := W.Run(code,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    Lift(code,W.Destinations(),value,data,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
  }
  ghost method ExternalRun(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,filter: bool,target: Word,ptr: Word,index: Word,gasBefore: Word,receipt: Word,free: Word,payload: seq<Byte>,reason: seq<Byte>,value: Word,self: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && H.Fits(mem,ptr,receipt,free,payload,reason) && target < A.Bound() && |prefix| <= 997
    requires ShiftRight(DataWord(data,0),224) == CL.Selector(filter)
    ensures frame == X.Frame(Reverted(H.Packet(CL.Operation(filter),index,target,payload,reason)),returned,cursor)
    ensures XE.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| > 0 && trace[0] == X.Frame(Running(17017,prefix+Tail(target,ptr,index,gasBefore,receipt),mem),returned,cursor) && trace[|trace|-1] == frame
  {
    var state: State;var states: seq<State>;
    state,states := Run(code,data,mem,prefix,filter,target,ptr,index,gasBefore,receipt,free,payload,reason,value);
    XE.Lift(code,Destinations(),self,value,data,observations,states,returned,cursor);
    trace := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor));
    frame := trace[|trace|-1];
  }
}
