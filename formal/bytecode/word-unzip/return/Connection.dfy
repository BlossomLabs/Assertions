// SPDX-License-Identifier: MIT
// Actual arbitrary finite lane loop followed by physical ABI MCOPY and RETURN.
include "MemoryConnection.dfy"
include "../engine/Loop.dfy"
include "../../bytes-return/Control.generated.dfy"
include "../../copy/Lift.dfy"
module BytecodeUnzipPhysicalOutputConnection {
  import S = BytecodeScanMachine
  import R = BytecodeWordUnzipMemory
  import L = BytecodeUnzipExecutionConnection
  import H = BytecodeUnzipReturnHeapConnection
  import B = BytecodeAlignedBytesReturnMemory
  import RC = BytecodeAlignedBytesReturnControl
  import C = BytecodeCopyExecution
  import Lift = BytecodeCopyTraceLift
  predicate Matches(code: seq<S.Byte>) { L.Matches(code) && RC.Matches(code) }
  function Destinations(): set<nat> { L.Destinations()+RC.Destinations() }
  ghost method Run(code: seq<S.Byte>, data: seq<S.Byte>, offset: S.Word, length: S.Word, lane: S.Word, value: S.Word)
    returns (state: S.State, trace: seq<S.State>)
    requires Matches(code) && L.Fits(data,offset,length,lane)
    ensures state == S.Returned(B.Bytes(R.Count(length/32,lane),R.Payload(length/32,lane,offset,data)))
    ensures C.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(6162,[2989505972,518,offset,length,lane,128,length/32,R.Count(length/32,lane),0],R.Heap(length/32,0,lane,offset,data))
    ensures trace[|trace|-1] == state
  {
    var count: S.Word := length/32;
    var laneCount: S.Word := R.Count(count,lane);
    state,trace := L.Run(code,data,offset,length,lane,value);
    Lift.Trace(code,L.Destinations(),value,data,trace);
    C.WidenTrace(code,L.Destinations(),Destinations(),value,data,trace);
    H.Heap(count,lane,offset,data);
    var payload := R.Payload(count,lane,offset,data);
    var terminal,serialized := RC.Run(code,laneCount,payload,2989505972,value,data);
    C.WidenTrace(code,RC.Destinations(),Destinations(),value,data,serialized);
    C.Join(code,Destinations(),value,data,trace,serialized);
    trace := trace+serialized[1..]; state := terminal;
  }
}
