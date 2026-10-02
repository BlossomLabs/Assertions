// SPDX-License-Identifier: MIT
// Actual alignment, guard, allocation, selected-word loop and physical bytes RETURN.
include "../entry/BodyStart.generated.dfy"
include "../entry/Aligned.generated.dfy"
include "../entry/AllocationGuard.generated.dfy"
include "../entry/Unaligned.generated.dfy"
include "../kernels/Mod.generated.dfy"
include "../allocation/Engine.dfy"
include "../engine/Loop.dfy"
include "../../capacity-return/UniqueHeap.dfy"
include "../../capacity-return/Control.generated.dfy"
include "../../copy/Lift.dfy"
module BytecodeUniqueBodyExecutionConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyExecution
  import Lift = BytecodeCopyTraceLift
  import Start = BytecodeUniqueAdmissionBodyStart
  import Align = BytecodeUniqueAdmissionAligned
  import Guard = BytecodeUniqueAdmissionAllocationGuard
  import Mod = BytecodeUniqueHelperMod
  import Error = BytecodeUniqueErrorUnaligned
  import Alloc = BytecodeUniqueAllocationEngine
  import F = BytecodeUniqueEngineFrames
  import Loop = BytecodeUniqueLoopConnection
  import P = BytecodeWordUniqueSelection
  import R = BytecodeWordUniqueMemory
  import H = BytecodeUniqueCapacityReturnConnection
  import B = BytecodeCapacityBytesReturnMemory
  import Return = BytecodeCapacityBytesReturnControl
  predicate Fits(data: seq<S.Byte>, offset: S.Word, length: S.Word, ordered: S.Word) {
    |data| < 0x10000000000000000 && (offset as nat)+(length as nat) <= |data| && ordered <= 1
  }
  predicate Matches(code: seq<S.Byte>) {
    Start.Matches(code) && Align.Matches(code) && Guard.Matches(code) && Mod.Matches(code) &&
    Error.Matches(code) && Alloc.Matches(code) && F.Matches(code) && Return.Matches(code)
  }
  function Destinations(): set<nat> {
    Start.Destinations()+Align.Destinations()+Guard.Destinations()+Mod.Destinations()+
    Error.Destinations()+Alloc.Destinations()+F.Destinations()+Return.Destinations()
  }
  function Payload(data: seq<S.Byte>, offset: S.Word, length: S.Word, ordered: S.Word): seq<S.Byte>
    requires Fits(data,offset,length,ordered) && length%32 == 0
    ensures |Payload(data,offset,length,ordered)|%32 == 0 && |Payload(data,offset,length,ordered)| <= length
  {
    F.SelectedFrame(data,offset,length,ordered,length/32);
    R.Payload(length/32,P.Selected(F.Values(data,offset,length),ordered == 1,length/32),offset,data)
  }
  function Expected(data: seq<S.Byte>, offset: S.Word, length: S.Word, ordered: S.Word): S.State
    requires Fits(data,offset,length,ordered)
  {
    if length%32 != 0 then S.Reverted(G.Encode(0xa949d285,4)+G.Encode(length,32))
    else var payload := Payload(data,offset,length,ordered);
         S.Returned(G.Encode(32,32)+G.Encode(|payload|,32)+payload)
  }
  ghost method Append(code: seq<S.Byte>, value: S.Word, data: seq<S.Byte>, trace: seq<S.State>, part: seq<S.State>, small: set<nat>) returns (combined: seq<S.State>)
    requires C.Trace(code,Destinations(),value,data,trace) && C.Trace(code,small,value,data,part)
    requires small <= Destinations() && trace[|trace|-1] == part[0]
    ensures C.Trace(code,Destinations(),value,data,combined)
    ensures combined[0] == trace[0] && combined[|combined|-1] == part[|part|-1]
  {
    C.WidenTrace(code,small,Destinations(),value,data,part);
    C.Join(code,Destinations(),value,data,trace,part);
    combined := trace+part[1..];
  }
  ghost method Run(code: seq<S.Byte>, data: seq<S.Byte>, offset: S.Word, length: S.Word, ordered: S.Word, value: S.Word)
    returns (state: S.State, trace: seq<S.State>)
    requires Matches(code) && Fits(data,offset,length,ordered)
    ensures state == Expected(data,offset,length,ordered)
    ensures C.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(6606,[3045624246,518,offset,length,ordered],S.Store([],64,128)) && trace[|trace|-1] == state
  {
    var mem := S.Store([],64,128);
    var frame: seq<S.Word> := [3045624246,518,offset,length,ordered];
    state,trace := Start.Run(code,offset,length,ordered,mem,value,data);
    Lift.Trace(code,Start.Destinations(),value,data,trace);
    C.WidenTrace(code,Start.Destinations(),Destinations(),value,data,trace);
    var part: seq<S.State>;
    state,part := Mod.Run(code,frame+[96],length,mem,value,data);
    Lift.Trace(code,Mod.Destinations(),value,data,part);
    trace := Append(code,value,data,trace,part,Mod.Destinations());
    if length%32 != 0 {
      state,part := Error.Run(code,offset,length,ordered,value,data);
      Lift.Trace(code,Error.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,Error.Destinations());
    } else {
      state,part := Align.Run(code,offset,length,ordered,mem,value,data);
      Lift.Trace(code,Align.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,Align.Destinations());
      state,part := Guard.Run(code,offset,length,ordered,mem,value,data);
      Lift.Trace(code,Guard.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,Guard.Destinations());
      var count: S.Word := length/32;
      assert count*32 == length && count < 0x800000000000000;
      state,part := Alloc.Run(code,count,offset,length,ordered,value,data);
      trace := Append(code,value,data,trace,part,Alloc.Destinations());
      state,part := Loop.Run(code,data,offset,length,ordered,value);
      Lift.Trace(code,F.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,F.Destinations());
      var ids := P.Selected(F.Values(data,offset,length),ordered == 1,count);
      var kept: S.Word := |ids|;
      var payload := R.Payload(count,ids,offset,data);
      H.Heap(count,ids,offset,data);
      state,part := Return.Run(code,count,kept,payload,3045624246,value,data);
      trace := Append(code,value,data,trace,part,Return.Destinations());
    }
  }
}
