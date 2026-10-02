// SPDX-License-Identifier: MIT
include "Engine.dfy"
include "Memory.dfy"
include "Invoke.dfy"
include "../callback-receipt-engine/Engine.dfy"
include "../callback-out-of-gas-return-repair-v3/Control.generated.dfy"
module BytecodeApplyFailedCallbackGuardConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import SE = BytecodeScanExecution
  import CE = BytecodeCopyExecution
  import A = BytecodeApplyAddressMask
  import C = BytecodeApplyFullCallbackReceiptEngine
  import CM = BytecodeApplyFullCallbackReceiptMemory
  import P = BytecodeApplyCallbackCopyMemory
  import F = BytecodeApplyCallbackFlagDispatch
  import H = BytecodeApplyCallbackExhaustionScalar
  import M = BytecodeApplyCallbackExhaustionMemory
  import V = BytecodeApplyCallbackExhaustionInvoke
  import D = BytecodeApplyCallbackExhaustionEngine
  import O = BytecodeApplyCallbackOutOfGasReturnMemory
  import R = BytecodeApplyCallbackOutOfGasReturnControl
  import W = BytecodeApplyWrongCallbackMemory
  predicate Matches(code: seq<Byte>) { C.Matches(code) && V.Matches(code) && D.Matches(code) && R.Matches(code) }
  function Destinations(): set<nat> { C.Destinations()+V.Destinations()+D.Destinations() }
  ghost method Lift(code: seq<Byte>,value: Word,data: seq<Byte>,states: seq<State>,self: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frames: seq<X.Frame>)
    requires SE.Trace(code,{},value,data,states)
    ensures E.Trace(code,Destinations(),self,value,data,observations,frames)
    ensures frames == seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor))
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    { assert Step(code,{},states[i],value,data) != Bad; reveal Step(); }
    CE.Lift(code,{},value,data,states);
    E.Lift(code,{},self,value,data,observations,states,returned,cursor);
    frames := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor));
    E.WidenTrace(code,{},Destinations(),self,value,data,observations,frames);
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,self: Word,value: Word,oldReturn: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word,gasAfter: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && CM.Fits(mem,ptr,free,length,returned)
    requires X.Context(self) && target < A.Bound() && |prefix| <= 1000
    requires cursor+3 < |observations| && observations[cursor] == X.Gas(gasBefore) && observations[cursor+1] == X.Gas(requestedGas)
    requires observations[cursor+2] == X.StaticCall(self,requestedGas,target,mem[ptr+32..ptr+32+length],false,returned)
    requires observations[cursor+3] == X.Gas(gasAfter)
    ensures var after := CM.Final(mem,ptr,free,length,returned); var receipt := CM.Receipt(free,returned);
      frame == X.Frame(if D.Refused(|returned|,Load(after,receipt+32),gasBefore,gasAfter) then Reverted(O.Packet()) else Running(17017,prefix+V.Tail(target,ptr,index,gasBefore,receipt),after),returned,cursor+4)
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| > 0 && trace[0] == X.Frame(Running(16908,prefix+[12484,target,ptr,index,0,0],mem),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide G.BitAnd(); hide BitNot(); hide E.Trace(); hide CM.Final(); hide P.Packed(); hide H.Masked(); hide O.Packet();
    var after := CM.Final(mem,ptr,free,length,returned);
    var receipt := CM.Receipt(free,returned);
    var head := Load(after,receipt+32);
    var part: seq<X.Frame>;
    frame,trace := C.Run(code,data,mem,prefix,target,ptr,index,free,length,self,value,oldReturn,returned,false,cursor,observations,gasBefore,requestedGas);
    E.WidenTrace(code,C.Destinations(),Destinations(),self,value,data,observations,trace);
    assert F.Tail(target,ptr,index,gasBefore,false,receipt) == V.Tail(target,ptr,index,gasBefore,receipt);
    var before := frame;
    var expected := X.Frame(Running(17008,prefix+V.Tail(target,ptr,index,gasBefore,receipt),after),returned,cursor+3);
    assert before == expected;
    assert trace[|trace|-1] == expected;
    V.Initial(prefix,after,returned,cursor+3,target,ptr,index,gasBefore,receipt);
    assert V.At(0,prefix,after,returned,cursor+3,target,ptr,index,gasBefore,receipt) == expected;
    frame,part := V.Run(code,prefix,after,returned,cursor+3,target,ptr,index,gasBefore,receipt,self,value,data,observations);
    assert part[0] == expected;
    E.WidenTrace(code,V.Destinations(),Destinations(),self,value,data,observations,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
    M.Admission(mem,ptr,free,length,returned);
    var full := prefix+V.Tail(target,ptr,index,gasBefore,receipt);
    frame,part := D.Run(code,after,full,receipt,|returned|,head,gasBefore,gasAfter,self,value,data,returned,cursor+3,observations);
    E.WidenTrace(code,D.Destinations(),Destinations(),self,value,data,observations,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
    if D.Refused(|returned|,head,gasBefore,gasAfter) {
      CM.Header(mem,ptr,free,length,returned);
      var nextFree := Load(after,64);
      var rest := full+[17017,gasBefore,receipt,if |returned| == 4 then head else 0];
      assert W.Fits(after,nextFree);
      assert R.Admitted(after,rest,nextFree,value,data) by { reveal R.Admitted(); }
      var state: State; var states: seq<State>;
      state,states := R.Run(code,after,rest,nextFree,value,data);
      part := Lift(code,value,data,states,self,returned,cursor+4,observations);
      assert trace[|trace|-1] == part[0];
      E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
      frame := part[|part|-1];
    }
  }
}
