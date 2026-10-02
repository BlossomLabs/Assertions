// SPDX-License-Identifier: MIT
// Exact physical sort buffer selection connected to actual ABI bytes RETURN.
include "../memory/Memory.dfy"
include "../serializer/Control.generated.dfy"
module BytecodeSortSerializationConnection {
  import opened BytecodeScanMachine
  import M = BytecodeWordSortMemory
  import O = BytecodeWordSortOriginalSpec
  import R = BytecodeSortBytesReturnMemory
  import C = BytecodeSortBytesReturnControl
  import E = BytecodeCopyExecution
  ghost method Run(code: seq<Byte>, n: Word, left: seq<nat>, right: seq<nat>, offset: Word, data: seq<Byte>, which: bool, value: Word)
    returns (state: State, trace: seq<State>)
    requires C.Matches(code) && M.Admitted(n,left,right,offset,data) && O.Bounds(n,(if which then right else left))
    ensures state == Returned(R.Bytes(n,O.Payload(data,offset,n,(if which then right else left))))
    ensures E.Trace(code,C.Destinations(),value,data,trace)
    ensures trace[0] == Running(518,[785862473,M.Base(n,which)],M.Heap(n,left,right,offset,data)) && trace[|trace|-1] == state
    ensures |trace| == 76
  {
    var mem := M.Heap(n,left,right,offset,data);
    var out: Word := M.Base(n,which);
    var payload := O.Payload(data,offset,n,(if which then right else left));
    M.Headers(n,left,right,offset,data);
    M.Rounded(n);
    M.OriginalPayload(n,left,right,offset,data,which);
    assert R.Admitted(mem,n,out,payload);
    state,trace := C.Run(code,mem,n,out,payload,785862473,value,data);
  }
}
