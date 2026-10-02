// SPDX-License-Identifier: MIT
// Physical callback GAS/packing/STATICCALL and exact32 return handling composition.
include "../callback-engine/Engine.dfy"
include "../callback-success/Success.generated.dfy"
include "Memory.dfy"
module BytecodeApplySuccessfulCallEngine {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import A = BytecodeApplyAddressMask
  import C = BytecodeApplyCallbackCopyMemory
  import H = BytecodeApplyCallbackSuccessMemory
  import M = BytecodeApplySuccessfulCallMemory
  import B = BytecodeApplyCallbackEngine
  import R = BytecodeApplyExactWordCallbackReturn
  predicate Matches(code: seq<Byte>) { B.Matches(code) && R.Matches(code) }
  function Destinations(): set<nat> { B.Destinations()+R.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,self: Word,value: Word,oldReturn: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word)
    returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && C.Fits(mem,ptr,free,length) && Load(mem,64) == free && Load(mem,ptr) == length
    requires (free as nat)+96 < G.Modulus()
    requires X.Context(self) && target < A.Bound() && |prefix| <= 1000 && |returned| == 32
    requires cursor+2 < |observations| && observations[cursor] == X.Gas(gasBefore) && observations[cursor+1] == X.Gas(requestedGas)
    requires observations[cursor+2] == X.StaticCall(self,requestedGas,target,mem[ptr+32..ptr+32+length],true,returned)
    ensures H.Fits(C.Packed(mem,ptr,free,length),free)
    ensures frame == X.Frame(Running(12484,prefix+[H.Result(returned)],H.Complete(C.Packed(mem,ptr,free,length),free,returned)),returned,cursor+3)
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace) && |trace| == 132
    ensures trace[0] == X.Frame(Running(16908,prefix+[12484,target,ptr,index,0,0],mem),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide G.BitAnd();
    M.Fits(mem,ptr,free,length);
    frame,trace := B.Run(code,data,mem,prefix,target,ptr,index,free,length,self,value,oldReturn,returned,true,cursor,observations,gasBefore,requestedGas);
    E.WidenTrace(code,B.Destinations(),Destinations(),self,value,data,observations,trace);
    var part: seq<X.Frame>;
    frame,part := R.Run(code,data,C.Packed(mem,ptr,free,length),prefix,target,ptr,index,free+length,free,gasBefore,returned,cursor+3,observations,self,value);
    E.WidenTrace(code,R.Destinations(),Destinations(),self,value,data,observations,part);
    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];
  }
}
