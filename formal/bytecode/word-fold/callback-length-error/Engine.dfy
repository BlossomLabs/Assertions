// SPDX-License-Identifier: MIT
// Full actual callback receipt to exact WrongCallbackResult for wrong size.
include "../callback-receipt/Engine.dfy"
include "WrongSize.generated.dfy"
module BytecodeFoldWrongSizeCallbackEngine {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import S = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import A = BytecodeApplyAddressMask
  import M = BytecodeApplyFullCallbackReceiptMemory
  import V = BytecodeFoldFullCallbackReceiptEngine
  import L = BytecodeFoldCallbackLengthError
  import H = BytecodeApplyWrongCallbackMemory
  import CL = BytecodeFoldCallbackLengthScalar
  predicate Matches(code: seq<Byte>) { V.Matches(code) && L.Matches(code) }
  function Destinations(): set<nat> { V.Destinations()+L.Destinations() }
  ghost method Lift(code: seq<Byte>,states: seq<State>,self: Word,value: Word,data: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frames: seq<X.Frame>)
    requires S.Trace(code,L.Destinations(),value,data,states)
    ensures E.Trace(code,Destinations(),self,value,data,observations,frames)
    ensures frames == seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor))
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    { assert Step(code,L.Destinations(),states[i],value,data) != Bad; reveal Step(); }
    C.Lift(code,L.Destinations(),value,data,states);
    E.Lift(code,L.Destinations(),self,value,data,observations,states,returned,cursor);
    frames := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor));
    E.WidenTrace(code,L.Destinations(),Destinations(),self,value,data,observations,frames);
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,domain: nat,target: Word,ptr: Word,index: Word,free: Word,length: Word,self: Word,value: Word,oldReturn: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires domain < 3 && Matches(code) && M.Fits(mem,ptr,free,length,returned)
    requires X.Context(self) && target < A.Bound() && |prefix| <= 1000 && |returned| != 32
    requires ShiftRight(DataWord(data,0),224) == CL.Selector(domain)
    requires cursor+2 < |observations| && observations[cursor] == X.Gas(gasBefore) && observations[cursor+1] == X.Gas(requestedGas)
    requires observations[cursor+2] == X.StaticCall(self,requestedGas,target,mem[ptr+32..ptr+32+length],true,returned)
    ensures frame == X.Frame(Reverted(H.Packet(CL.Operation(domain),index,target)),returned,cursor+3)
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures trace[0] == X.Frame(Running(16908,prefix+[16553,target,ptr,index,0,0],mem),oldReturn,cursor) && trace[|trace|-1] == frame
    ensures |trace| == (if |returned| == 0 then 173 else 194)
  {
    hide G.BitAnd(); hide BitNot(); hide E.Trace(); hide M.Final(); hide DataWord(); hide ShiftRight();
    frame,trace := V.Run(code,data,mem,prefix,target,ptr,index,free,length,self,value,oldReturn,returned,true,cursor,observations,gasBefore,requestedGas);
    E.WidenTrace(code,V.Destinations(),Destinations(),self,value,data,observations,trace);
    M.Header(mem,ptr,free,length,returned);
    var after := M.Final(mem,ptr,free,length,returned);
    var nextFree := Load(after,64);
    var receipt := M.Receipt(free,returned);
    assert H.Fits(after,nextFree);
    assert L.Admitted(data,after,prefix+[16553],domain,target,ptr,index,gasBefore,receipt,|returned|,nextFree,value) by { reveal L.Admitted(); }
    var state: State; var states: seq<State>;
    state,states := L.Run(code,data,after,prefix+[16553],domain,target,ptr,index,gasBefore,receipt,|returned|,nextFree,value);
    var part := Lift(code,states,self,value,data,returned,cursor+3,observations);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,value,data,observations,trace,part); trace := trace+part[1..]; frame := part[|part|-1];
  }
}
