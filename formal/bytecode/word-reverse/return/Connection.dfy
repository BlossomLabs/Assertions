// SPDX-License-Identifier: MIT
// Actual unbounded reverse loop followed by physical ABI MCOPY and RETURN.
include "MemoryConnection.dfy"
include "../loop/Loop.dfy"
include "../../bytes-return/Control.generated.dfy"
include "../../copy/Lift.dfy"
module BytecodeReverseLoopOutputConnection {
  import S = BytecodeScanMachine
  import R = BytecodeWordReverseMemory
  import L = BytecodeReverseLoopEngine
  import H = BytecodeReverseReturnMemoryConnection
  import B = BytecodeAlignedBytesReturnMemory
  import RC = BytecodeAlignedBytesReturnControl
  import C = BytecodeCopyExecution
  import Lift = BytecodeCopyTraceLift
  predicate Matches(code: seq<S.Byte>) { L.Matches(code) && RC.Matches(code) }
  function Destinations(): set<nat> { L.Destinations()+RC.Destinations() }
  ghost method Run(code: seq<S.Byte>, data: seq<S.Byte>, offset: S.Word, length: S.Word, value: S.Word)
    returns (state: S.State, trace: seq<S.State>)
    requires Matches(code) && L.Fits(data,offset,length)
    ensures state == S.Returned(B.Bytes(length/32,R.Payload(length/32,offset,data)))
    ensures C.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(5846,[2874738232,518,offset,length,128,length/32,0],R.Heap(length/32,0,offset,data))
    ensures trace[|trace|-1] == state
  {
    var count: S.Word := length/32;
    state,trace := L.Run(code,data,offset,length,value);
    Lift.Trace(code,L.Destinations(),value,data,trace);
    C.WidenTrace(code,L.Destinations(),Destinations(),value,data,trace);
    H.Heap(count,offset,data);
    var payload := R.Payload(count,offset,data);
    var terminal,serialized := RC.Run(code,count,payload,2874738232,value,data);
    C.WidenTrace(code,RC.Destinations(),Destinations(),value,data,serialized);
    C.Join(code,Destinations(),value,data,trace,serialized);
    trace := trace+serialized[1..]; state := terminal;
  }
}
