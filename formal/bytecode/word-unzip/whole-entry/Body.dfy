// SPDX-License-Identifier: MIT
// Exact full body: alignment, lane, count arithmetic, allocation, loop and physical RETURN.
include "../entry/BodyStart.generated.dfy"
include "../entry/Aligned.generated.dfy"
include "../entry/LaneChecked.generated.dfy"
include "../entry/Divide.generated.dfy"
include "../entry/WhichZero.generated.dfy"
include "../entry/WhichOne.generated.dfy"
include "../entry/DivideZero.generated.dfy"
include "../entry/CountOne.generated.dfy"
include "../entry/Multiply.generated.dfy"
include "../entry/AllocationGuard.generated.dfy"
include "../loop/Mod.generated.dfy"
include "../loop/Div32.generated.dfy"
include "../loop/Div2.generated.dfy"
include "../loop/Add.generated.dfy"
include "../loop/Mul32.generated.dfy"
include "../entry/Unaligned.generated.dfy"
include "../entry/InvalidLane.generated.dfy"
include "../allocation/Engine.dfy"
include "../return/Connection.dfy"
include "../../copy/Lift.dfy"
module BytecodeUnzipBodyExecutionConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyExecution
  import Lift = BytecodeCopyTraceLift
  import Start = BytecodeUnzipAdmissionBodyStart
  import Align = BytecodeUnzipAdmissionAligned
  import Lane = BytecodeUnzipAdmissionLaneChecked
  import Divide = BytecodeUnzipAdmissionBeginDivide
  import Zero = BytecodeUnzipAdmissionWhichZero
  import One = BytecodeUnzipAdmissionWhichOne
  import DZ = BytecodeUnzipAdmissionDivideZero
  import CO = BytecodeUnzipAdmissionCountOne
  import Multiply = BytecodeUnzipAdmissionMultiply
  import Guard = BytecodeUnzipAdmissionAllocationGuard
  import Mod = BytecodeUnzipHelperMod
  import Div32 = BytecodeUnzipHelperDiv32
  import Div2 = BytecodeUnzipHelperDiv2
  import Add = BytecodeUnzipHelperAdd
  import Mul = BytecodeUnzipHelperMul32
  import Error = BytecodeUnzipErrorUnaligned
  import Invalid = BytecodeUnzipErrorInvalidLane
  import Alloc = BytecodeUnzipAllocationEngine
  import Output = BytecodeUnzipPhysicalOutputConnection
  import R = BytecodeWordUnzipMemory
  import B = BytecodeAlignedBytesReturnMemory
  predicate Fits(data: seq<S.Byte>, offset: S.Word, length: S.Word) {
    |data| < 0x10000000000000000 && (offset as nat)+(length as nat) <= |data|
  }
  predicate Matches(code: seq<S.Byte>) {
    Start.Matches(code) && Align.Matches(code) && Lane.Matches(code) && Divide.Matches(code) && Zero.Matches(code) && One.Matches(code) && DZ.Matches(code) && CO.Matches(code) && Multiply.Matches(code) && Guard.Matches(code) && Mod.Matches(code) && Div32.Matches(code) && Div2.Matches(code) && Add.Matches(code) && Mul.Matches(code) && Error.Matches(code) && Invalid.Matches(code) && Alloc.Matches(code) && Output.Matches(code)
  }
  function Destinations(): set<nat> {
    Start.Destinations()+Align.Destinations()+Lane.Destinations()+Divide.Destinations()+Zero.Destinations()+One.Destinations()+DZ.Destinations()+CO.Destinations()+Multiply.Destinations()+Guard.Destinations()+Mod.Destinations()+Div32.Destinations()+Div2.Destinations()+Add.Destinations()+Mul.Destinations()+Error.Destinations()+Invalid.Destinations()+Alloc.Destinations()+Output.Destinations()
  }
  function Expected(data: seq<S.Byte>, offset: S.Word, length: S.Word, lane: S.Word): S.State
    requires Fits(data,offset,length)
  {
    if length%32 != 0 then S.Reverted(G.Encode(0xa949d285,4)+G.Encode(length,32))
    else if lane > 1 then S.Reverted(G.Encode(0x1c133803,4)+G.Encode(lane,32))
    else S.Returned(B.Bytes(R.Count(length/32,lane),R.Payload(length/32,lane,offset,data)))
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
  ghost method Run(code: seq<S.Byte>, data: seq<S.Byte>, offset: S.Word, length: S.Word, lane: S.Word, value: S.Word)
    returns (state: S.State, trace: seq<S.State>)
    requires Matches(code) && Fits(data,offset,length)
    ensures state == Expected(data,offset,length,lane)
    ensures C.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(5936,[2989505972,518,offset,length,lane],S.Store([],64,128))
    ensures trace[|trace|-1] == state
  {
    var mem := S.Store([],64,128);
    var frame: seq<S.Word> := [2989505972,518,offset,length,lane];
    state,trace := Start.Run(code,offset,length,lane,mem,value,data);
    Lift.Trace(code,Start.Destinations(),value,data,trace);
    C.WidenTrace(code,Start.Destinations(),Destinations(),value,data,trace);
    var part: seq<S.State>;
    state,part := Mod.Run(code,frame+[96],length,mem,value,data);
    Lift.Trace(code,Mod.Destinations(),value,data,part);
    trace := Append(code,value,data,trace,part,Mod.Destinations());
    if length%32 != 0 {
      state,part := Error.Run(code,offset,length,lane,value,data);
      Lift.Trace(code,Error.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,Error.Destinations());
    } else {
      state,part := Align.Run(code,offset,length,lane,mem,value,data);
      Lift.Trace(code,Align.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,Align.Destinations());
      if lane > 1 {
        state,part := Invalid.Run(code,offset,length,lane,value,data);
        Lift.Trace(code,Invalid.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Invalid.Destinations());
      } else {
        state,part := Lane.Run(code,offset,length,lane,mem,value,data);
        Lift.Trace(code,Lane.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Lane.Destinations());
        state,part := Divide.Run(code,offset,length,lane,mem,value,data);
        Lift.Trace(code,Divide.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Divide.Destinations());
        state,part := Div32.Run(code,frame+[96,0],length,mem,value,data);
        Lift.Trace(code,Div32.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Div32.Destinations());
        var count: S.Word := length/32;
        var laneCount: S.Word := R.Count(count,lane);
        assert count*32 == length && count < 0x800000000000000;
        assert laneCount <= count && laneCount == Multiply.Count(length,lane);
        if lane == 0 {
          state,part := Zero.Run(code,offset,length,lane,mem,value,data);
          Lift.Trace(code,Zero.Destinations(),value,data,part);
          trace := Append(code,value,data,trace,part,Zero.Destinations());
          state,part := Add.Run(code,frame+[96,count,0,2],count,1,6069,mem,value,data);
          Lift.Trace(code,Add.Destinations(),value,data,part);
          trace := Append(code,value,data,trace,part,Add.Destinations());
          state,part := DZ.Run(code,offset,length,lane,mem,value,data);
          Lift.Trace(code,DZ.Destinations(),value,data,part);
          trace := Append(code,value,data,trace,part,DZ.Destinations());
          state,part := Div2.Run(code,frame+[96,count,0],count+1,6079,mem,value,data);
          Lift.Trace(code,Div2.Destinations(),value,data,part);
          trace := Append(code,value,data,trace,part,Div2.Destinations());
        } else {
          assert lane == 1;
          state,part := One.Run(code,offset,length,lane,mem,value,data);
          Lift.Trace(code,One.Destinations(),value,data,part);
          trace := Append(code,value,data,trace,part,One.Destinations());
          state,part := Div2.Run(code,frame+[96,count,0],count,6051,mem,value,data);
          Lift.Trace(code,Div2.Destinations(),value,data,part);
          trace := Append(code,value,data,trace,part,Div2.Destinations());
          state,part := CO.Run(code,offset,length,lane,mem,value,data);
          Lift.Trace(code,CO.Destinations(),value,data,part);
          trace := Append(code,value,data,trace,part,CO.Destinations());
        }
        state,part := Multiply.Run(code,offset,length,lane,mem,value,data);
        Lift.Trace(code,Multiply.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Multiply.Destinations());
        state,part := Mul.Run(code,frame+[96,count,laneCount],laneCount,6092,mem,value,data);
        Lift.Trace(code,Mul.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Mul.Destinations());
        state,part := Guard.Run(code,offset,length,lane,mem,value,data);
        Lift.Trace(code,Guard.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Guard.Destinations());
        state,part := Alloc.Run(code,laneCount,offset,length,lane,count,value,data);
        trace := Append(code,value,data,trace,part,Alloc.Destinations());
        state,part := Output.Run(code,data,offset,length,lane,value);
        trace := Append(code,value,data,trace,part,Output.Destinations());
      }
    }
  }
}
