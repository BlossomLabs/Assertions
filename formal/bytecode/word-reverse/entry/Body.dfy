// SPDX-License-Identifier: MIT
// Actual complete reverseWords body: alignment, count, allocation, loop and physical return.
include "BodyStart.generated.dfy"
include "Aligned.generated.dfy"
include "Count.generated.dfy"
include "Unaligned.generated.dfy"
include "../loop/Mod.generated.dfy"
include "../loop/Div.generated.dfy"
include "../allocation/Engine.dfy"
include "../return/Connection.dfy"
include "../../copy/Lift.dfy"
module BytecodeReverseBodyConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyExecution
  import Lift = BytecodeCopyTraceLift
  import Start = BytecodeReverseAdmissionBodyStart
  import Align = BytecodeReverseAdmissionAligned
  import Count = BytecodeReverseAdmissionCount
  import Error = BytecodeReverseErrorUnaligned
  import Mod = BytecodeReverseHelperMod
  import Div = BytecodeReverseHelperDiv
  import Alloc = BytecodeReverseAllocationEngine
  import Output = BytecodeReverseLoopOutputConnection
  import R = BytecodeWordReverseMemory
  import B = BytecodeAlignedBytesReturnMemory
  predicate Fits(data: seq<S.Byte>, offset: S.Word, length: S.Word) {
    |data| < 0x10000000000000000 && (offset as nat)+(length as nat) <= |data|
  }
  predicate Matches(code: seq<S.Byte>) {
    Start.Matches(code) && Align.Matches(code) && Count.Matches(code) && Error.Matches(code) &&
    Mod.Matches(code) && Div.Matches(code) && Alloc.Matches(code) && Output.Matches(code)
  }
  function Destinations(): set<nat> {
    Start.Destinations()+Align.Destinations()+Count.Destinations()+Error.Destinations()+
    Mod.Destinations()+Div.Destinations()+Alloc.Destinations()+Output.Destinations()
  }
  function Expected(data: seq<S.Byte>, offset: S.Word, length: S.Word): S.State
    requires Fits(data,offset,length)
  {
    if length%32 != 0 then S.Reverted(G.Encode(0xa949d285,4)+G.Encode(length,32))
    else S.Returned(B.Bytes(length/32,R.Payload(length/32,offset,data)))
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
  ghost method Run(code: seq<S.Byte>, data: seq<S.Byte>, offset: S.Word, length: S.Word, value: S.Word)
    returns (state: S.State, trace: seq<S.State>)
    requires Matches(code) && Fits(data,offset,length)
    ensures state == Expected(data,offset,length)
    ensures C.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(5715,[2874738232,518,offset,length],S.Store([],64,128))
    ensures trace[|trace|-1] == state
  {
    var mem := S.Store([],64,128);
    state,trace := Start.Run(code,offset,length,mem,value,data);
    Lift.Trace(code,Start.Destinations(),value,data,trace);
    C.WidenTrace(code,Start.Destinations(),Destinations(),value,data,trace);
    var part: seq<S.State>;
    state,part := Mod.Run(code,[2874738232,518,offset,length,96],length,mem,value,data);
    Lift.Trace(code,Mod.Destinations(),value,data,part);
    trace := Append(code,value,data,trace,part,Mod.Destinations());
    if length%32 != 0 {
      state,part := Error.Run(code,offset,length,value,data);
      Lift.Trace(code,Error.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,Error.Destinations());
    } else {
      state,part := Align.Run(code,offset,length,mem,value,data);
      Lift.Trace(code,Align.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,Align.Destinations());
      state,part := Div.Run(code,[2874738232,518,offset,length,96,0],length,mem,value,data);
      Lift.Trace(code,Div.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,Div.Destinations());
      state,part := Count.Run(code,offset,length,mem,value,data);
      Lift.Trace(code,Count.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,Count.Destinations());
      assert (length/32)*32 == length;
      state,part := Alloc.Run(code,length/32,offset,value,data);
      trace := Append(code,value,data,trace,part,Alloc.Destinations());
      state,part := Output.Run(code,data,offset,length,value);
      trace := Append(code,value,data,trace,part,Output.Destinations());
    }
  }
}
