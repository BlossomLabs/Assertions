// SPDX-License-Identifier: MIT
// Full fitting zipWords body: both checks, count errors, output size, pair loop and physical RETURN.
include "../entry/BodyStart.generated.dfy"
include "../alignment-b/SecondAligned.generated.dfy"
include "../entry/FirstAligned.generated.dfy"
include "../entry/BothAlignedEqual.generated.dfy"
include "../entry/DivideCount.generated.dfy"
include "../entry/Multiply.generated.dfy"
include "../entry/AllocationGuard.generated.dfy"
include "../entry/LargeOutputGuard.generated.dfy"
include "../entry/MismatchFirstDivide.generated.dfy"
include "../entry/MismatchSecondDivide.generated.dfy"
include "../entry/FirstUnaligned.generated.dfy"
include "../entry/SecondUnaligned.generated.dfy"
include "../entry/CountMismatch.generated.dfy"
include "../entry/AllocationPanic.generated.dfy"
include "../loop/Mod.generated.dfy"
include "../loop/Div32.generated.dfy"
include "../loop/Mul2.generated.dfy"
include "../allocation/Engine.dfy"
include "../return/Connection.dfy"
include "../../copy/Lift.dfy"
module BytecodeZipBodyExecutionConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyExecution
  import Lift = BytecodeCopyTraceLift
  import R = BytecodeWordZipMemory
  import B = BytecodeAlignedBytesReturnMemory
  import Alloc = BytecodeZipAllocationEngine
  import Output = BytecodeZipPhysicalOutputConnection
  import AlignedB = BytecodeZipAdmissionSecondAligned
  import Start = BytecodeZipAdmissionBodyStart
  import AlignA = BytecodeZipAdmissionFirstAligned
  import Equal = BytecodeZipAdmissionBothAlignedEqual
  import Divide = BytecodeZipAdmissionDivideCount
  import Multiply = BytecodeZipAdmissionMultiply
  import Guard = BytecodeZipAdmissionAllocationGuard
  import Large = BytecodeZipAdmissionLargeOutputGuard
  import MismatchA = BytecodeZipAdmissionMismatchFirstDivide
  import MismatchB = BytecodeZipAdmissionMismatchSecondDivide
  import ErrorA = BytecodeZipErrorFirstUnaligned
  import ErrorB = BytecodeZipErrorSecondUnaligned
  import Mismatch = BytecodeZipErrorCountMismatch
  import Panic = BytecodeZipErrorAllocationPanic
  import Mod = BytecodeZipHelperMod
  import Div = BytecodeZipHelperDiv32
  import Mul = BytecodeZipHelperMul2
  predicate Matches(code: seq<S.Byte>) { AlignedB.Matches(code) && Start.Matches(code) && AlignA.Matches(code) && Equal.Matches(code) && Divide.Matches(code) && Multiply.Matches(code) && Guard.Matches(code) && Large.Matches(code) && MismatchA.Matches(code) && MismatchB.Matches(code) && ErrorA.Matches(code) && ErrorB.Matches(code) && Mismatch.Matches(code) && Panic.Matches(code) && Mod.Matches(code) && Div.Matches(code) && Mul.Matches(code) && Alloc.Matches(code) && Output.Matches(code) }
  function Destinations(): set<nat> { AlignedB.Destinations()+Start.Destinations()+AlignA.Destinations()+Equal.Destinations()+Divide.Destinations()+Multiply.Destinations()+Guard.Destinations()+Large.Destinations()+MismatchA.Destinations()+MismatchB.Destinations()+ErrorA.Destinations()+ErrorB.Destinations()+Mismatch.Destinations()+Panic.Destinations()+Mod.Destinations()+Div.Destinations()+Mul.Destinations()+Alloc.Destinations()+Output.Destinations() }
  predicate Fits(data: seq<S.Byte>, a: S.Word, lengthA: S.Word, b: S.Word, lengthB: S.Word) {
    |data| < 0x10000000000000000 && (a as nat)+(lengthA as nat) <= |data| && (b as nat)+(lengthB as nat) <= |data|
  }
  function Expected(data: seq<S.Byte>, a: S.Word, lengthA: S.Word, b: S.Word, lengthB: S.Word): S.State
    requires Fits(data,a,lengthA,b,lengthB)
  {
    if lengthA%32 != 0 then S.Reverted(G.Encode(0xa949d285,4)+G.Encode(lengthA,32))
    else if lengthB%32 != 0 then S.Reverted(G.Encode(0xa949d285,4)+G.Encode(lengthB,32))
    else if lengthA != lengthB then S.Reverted(G.Encode(0x1b10636a,4)+G.Encode(lengthA/32,32)+G.Encode(lengthB/32,32))
    else if lengthA >= 0x8000000000000000 then S.Reverted(G.Encode(0x4e487b71,4)+G.Encode(65,32))
    else S.Returned(B.Bytes(2*(lengthA/32),R.Payload(lengthA/32,a,b,data)))
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
  ghost method Run(code: seq<S.Byte>, data: seq<S.Byte>, a: S.Word, lengthA: S.Word, b: S.Word, lengthB: S.Word, value: S.Word)
    returns (state: S.State, trace: seq<S.State>)
    requires Matches(code) && Fits(data,a,lengthA,b,lengthB)
    ensures state == Expected(data,a,lengthA,b,lengthB)
    ensures C.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(1846,[269019481,518,a,lengthA,b,lengthB],S.Store([],64,128))
    ensures trace[|trace|-1] == state
  {
    var mem := S.Store([],64,128);
    var frame: seq<S.Word> := [269019481,518,a,lengthA,b,lengthB];
    state,trace := Start.Run(code,a,lengthA,b,lengthB,mem,value,data);
    Lift.Trace(code,Start.Destinations(),value,data,trace);
    C.WidenTrace(code,Start.Destinations(),Destinations(),value,data,trace);
    var part: seq<S.State>;
    state,part := Mod.Run(code,frame+[96],lengthA,1859,mem,value,data);
    Lift.Trace(code,Mod.Destinations(),value,data,part);
    trace := Append(code,value,data,trace,part,Mod.Destinations());
    if lengthA%32 != 0 {
      state,part := ErrorA.Run(code,a,lengthA,b,lengthB,value,data);
      Lift.Trace(code,ErrorA.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,ErrorA.Destinations());
    } else {
      state,part := AlignA.Run(code,a,lengthA,b,lengthB,mem,value,data);
      Lift.Trace(code,AlignA.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,AlignA.Destinations());
      state,part := Mod.Run(code,frame+[96],lengthB,1903,mem,value,data);
      Lift.Trace(code,Mod.Destinations(),value,data,part);
      trace := Append(code,value,data,trace,part,Mod.Destinations());
      if lengthB%32 != 0 {
        state,part := ErrorB.Run(code,a,lengthA,b,lengthB,value,data);
        Lift.Trace(code,ErrorB.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,ErrorB.Destinations());
      } else if lengthA != lengthB {
        state,part := AlignedB.Run(code,a,lengthA,b,lengthB,mem,value,data);
        Lift.Trace(code,AlignedB.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,AlignedB.Destinations());
        state,part := MismatchA.Run(code,a,lengthA,b,lengthB,mem,value,data);
        Lift.Trace(code,MismatchA.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,MismatchA.Destinations());
        state,part := Div.Run(code,frame+[96],lengthA,1954,mem,value,data);
        Lift.Trace(code,Div.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Div.Destinations());
        state,part := MismatchB.Run(code,a,lengthA,b,lengthB,mem,value,data);
        Lift.Trace(code,MismatchB.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,MismatchB.Destinations());
        state,part := Div.Run(code,frame+[96,lengthA/32],lengthB,1965,mem,value,data);
        Lift.Trace(code,Div.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Div.Destinations());
        state,part := Mismatch.Run(code,a,lengthA,b,lengthB,value,data);
        Lift.Trace(code,Mismatch.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Mismatch.Destinations());
      } else {
        state,part := Equal.Run(code,a,lengthA,b,lengthB,mem,value,data);
        Lift.Trace(code,Equal.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Equal.Destinations());
        state,part := Divide.Run(code,a,lengthA,b,lengthB,mem,value,data);
        Lift.Trace(code,Divide.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Divide.Destinations());
        state,part := Div.Run(code,frame+[96,0],lengthA,2011,mem,value,data);
        Lift.Trace(code,Div.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Div.Destinations());
        state,part := Multiply.Run(code,a,lengthA,b,lengthB,mem,value,data);
        Lift.Trace(code,Multiply.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Multiply.Destinations());
        state,part := Mul.Run(code,frame+[96,lengthA/32],lengthA,2024,mem,value,data);
        Lift.Trace(code,Mul.Destinations(),value,data,part);
        trace := Append(code,value,data,trace,part,Mul.Destinations());
        if lengthA >= 0x8000000000000000 {
          state,part := Large.Run(code,a,lengthA,b,lengthB,mem,value,data);
          Lift.Trace(code,Large.Destinations(),value,data,part);
          trace := Append(code,value,data,trace,part,Large.Destinations());
          state,part := Panic.Run(code,a,lengthA,b,lengthB,value,data);
          Lift.Trace(code,Panic.Destinations(),value,data,part);
          trace := Append(code,value,data,trace,part,Panic.Destinations());
        } else {
          var count: S.Word := lengthA/32;
          assert count*32 == lengthA && count < 0x400000000000000;
          assert lengthA*2 == 2*count*32;
          state,part := Guard.Run(code,a,lengthA,b,lengthB,mem,value,data);
          Lift.Trace(code,Guard.Destinations(),value,data,part);
          trace := Append(code,value,data,trace,part,Guard.Destinations());
          state,part := Alloc.Run(code,2*count,a,lengthA,b,count,value,data);
          trace := Append(code,value,data,trace,part,Alloc.Destinations());
          state,part := Output.Run(code,data,a,b,lengthA,value);
          trace := Append(code,value,data,trace,part,Output.Destinations());
        }
      }
    }
  }
}
