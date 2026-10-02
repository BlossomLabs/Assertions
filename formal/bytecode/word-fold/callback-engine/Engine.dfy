// SPDX-License-Identifier: MIT
// Complete actual callback path from first GAS to full STATICCALL receipt.
include "../callback-pack-control/Before.generated.dfy"
include "../callback-pack-control/After.generated.dfy"
include "../../word-apply/callback-pack/Pack.generated.dfy"
include "../../word-apply/callback-observation/Binding.dfy"
module BytecodeFoldCallbackEngine {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import S = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import A = BytecodeApplyAddressMask
  import H = BytecodeApplyCallbackCopyMemory
  import B = BytecodeFoldCallbackPackBefore
  import P = BytecodeApplyCallbackPack
  import T = BytecodeFoldCallbackPackAfter
  import O = BytecodeApplyCallbackObservation
  predicate Matches(code: seq<Byte>) {
    B.Matches(code) && P.Matches(code) && T.Matches(code) && |code| > 16947 && code[16908] == 0x5a && code[16946] == 0x5a && code[16947] == 0xfa
  }
  function Destinations(): set<nat> { B.Destinations()+P.Destinations()+T.Destinations() }
  lemma Lift(code: seq<Byte>,small: set<nat>,data: seq<Byte>,value: Word,states: seq<State>,self: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires S.Trace(code,small,value,data,states)
    ensures E.Trace(code,small,self,value,data,observations,seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor)))
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    { assert Step(code,small,states[i],value,data) != Bad; reveal Step(); }
    C.Lift(code,small,value,data,states);
    E.Lift(code,small,self,value,data,observations,states,oldReturn,cursor);
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,self: Word,value: Word,oldReturn: seq<Byte>,returned: seq<Byte>,success: bool,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word)
    returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && H.Fits(mem,ptr,free,length) && Load(mem,64) == free && Load(mem,ptr) == length
    requires X.Context(self) && target < A.Bound() && |prefix| <= 1000 && |returned| < G.Modulus()
    requires cursor+2 < |observations| && observations[cursor] == X.Gas(gasBefore) && observations[cursor+1] == X.Gas(requestedGas)
    requires observations[cursor+2] == X.StaticCall(self,requestedGas,target,mem[ptr+32..ptr+32+length],success,returned)
    ensures frame == X.Frame(Running(16948,prefix+[16553,target,ptr,index,0,gasBefore,0,0,target,free+length,if success then 1 else 0],H.Packed(mem,ptr,free,length)),returned,cursor+3)
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace) && |trace| == 68
    ensures trace[0] == X.Frame(Running(16908,prefix+[16553,target,ptr,index,0,0],mem),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    frame,trace := O.FirstGas(code,prefix+[16553,target,ptr,index,0,0],mem,self,value,data,oldReturn,cursor,observations,gasBefore);
    E.WidenTrace(code,{},Destinations(),self,value,data,observations,trace);
    var state: State; var states: seq<State>;
    state,states := B.Run(code,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    Lift(code,B.Destinations(),data,value,states,self,oldReturn,cursor+1,observations);
    var part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor+1));
    E.WidenTrace(code,B.Destinations(),Destinations(),self,value,data,observations,part);
    E.Join(code,Destinations(),self,value,data,observations,trace,part); trace := trace+part[1..];
    var packPrefix := prefix+[16553,target,ptr,index,0,gasBefore,0,0,target];
    state,states := P.Run(code,data,mem,packPrefix,ptr,free,length,value);
    E.Lift(code,P.Destinations(),self,value,data,observations,states,oldReturn,cursor+1);
    part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor+1));
    E.WidenTrace(code,P.Destinations(),Destinations(),self,value,data,observations,part);
    E.Join(code,Destinations(),self,value,data,observations,trace,part); trace := trace+part[1..];
    H.Bounds(mem,ptr,free,length); H.FreePointer(mem,ptr,free,length);
    state,states := T.Run(code,data,H.Packed(mem,ptr,free,length),prefix,target,ptr,index,free,length,gasBefore,value);
    Lift(code,T.Destinations(),data,value,states,self,oldReturn,cursor+1,observations);
    part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor+1));
    E.WidenTrace(code,T.Destinations(),Destinations(),self,value,data,observations,part);
    E.Join(code,Destinations(),self,value,data,observations,trace,part); trace := trace+part[1..];
    assert X.Address(target) == target;
    frame,part := O.Call(code,packPrefix+[free+length],mem,ptr,free,length,target,self,value,data,oldReturn,returned,success,cursor+1,observations,requestedGas);
    E.WidenTrace(code,{},Destinations(),self,value,data,observations,part);
    E.Join(code,Destinations(),self,value,data,observations,trace,part); trace := trace+part[1..];
  }
}
