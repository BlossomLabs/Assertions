// SPDX-License-Identifier: MIT
// Actual arbitrary finite lane loop followed by physical ABI MCOPY and RETURN.
include "MemoryConnection.dfy"
include "../engine/Loop.dfy"
include "../../bytes-return/Control.generated.dfy"
include "../../copy/Lift.dfy"
module BytecodeZipPhysicalOutputConnection {
  import S = BytecodeScanMachine
  import R = BytecodeWordZipMemory
  import L = BytecodeZipExecutionConnection
  import H = BytecodeZipReturnHeapConnection
  import B = BytecodeAlignedBytesReturnMemory
  import RC = BytecodeAlignedBytesReturnControl
  import C = BytecodeCopyExecution
  import Lift = BytecodeCopyTraceLift
  predicate Matches(code: seq<S.Byte>) { L.Matches(code) && RC.Matches(code) }
  function Destinations(): set<nat> { L.Destinations()+RC.Destinations() }
  ghost method Run(code: seq<S.Byte>, data: seq<S.Byte>, a: S.Word, b: S.Word, length: S.Word, value: S.Word)
    returns (state: S.State, trace: seq<S.State>)
    requires Matches(code) && L.Fits(data,a,b,length)
    ensures state == S.Returned(B.Bytes(2*(length/32),R.Payload(length/32,a,b,data)))
    ensures C.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(2094,[269019481,518,a,length,b,length,128,length/32,0],R.Heap(length/32,0,a,b,data))
    ensures trace[|trace|-1] == state
  {
    var count: S.Word := length/32;
    var outputCount: S.Word := 2*count;
    state,trace := L.Run(code,data,a,b,length,value);
    Lift.Trace(code,L.Destinations(),value,data,trace);
    C.WidenTrace(code,L.Destinations(),Destinations(),value,data,trace);
    H.Heap(count,a,b,data);
    var payload := R.Payload(count,a,b,data);
    var terminal,serialized := RC.Run(code,outputCount,payload,269019481,value,data);
    C.WidenTrace(code,RC.Destinations(),Destinations(),value,data,serialized);
    C.Join(code,Destinations(),value,data,trace,serialized);
    trace := trace+serialized[1..]; state := terminal;
  }
}
