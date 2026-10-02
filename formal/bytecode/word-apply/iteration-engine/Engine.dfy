// SPDX-License-Identifier: MIT
include "../element-read/Read.generated.dfy"
include "../stamp-invocation/Invoke.generated.dfy"
include "../stamp-engine/Engine.dfy"
include "../callback-invocation/Invoke.generated.dfy"
include "../callback-success-engine/Engine.dfy"
include "../result-iteration/Map.generated.dfy"
include "../result-iteration/Keep.generated.dfy"
include "../result-iteration/Skip.generated.dfy"
include "../iteration-memory/Memory.dfy"
include "../raw-element-read/Connection.dfy"
include "Sequence.dfy"
module BytecodeApplySuccessfulIterationEngine {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import SE = BytecodeScanExecution
  import O = BytecodeIotaOutput
  import H = BytecodeApplyCallbackSuccessMemory
  import P = BytecodeApplyCallbackCopyMemory
  import AM = BytecodeApplyAddressMask
  import M = BytecodeApplyRepeatedIterationMemory
  import L = BytecodeApplyRawFirstElement
  import R = BytecodeApplyElementRead
  import V = BytecodeApplyStampInvoke
  import B = BytecodeApplyStampEngine
  import C = BytecodeApplyCallbackInvoke
  import S = BytecodeApplySuccessfulCallEngine
  import A = BytecodeApplyResultMap
  import K = BytecodeApplyResultKeep
  import D = BytecodeApplyResultSkip
  import Q = BytecodeApplyCallbackSuccessScalar
  import Z = BytecodeApplyIterationStackSequence
  predicate Matches(code: seq<Byte>) { R.Matches(code) && V.Matches(code) && B.Matches(code) && C.Matches(code) && S.Matches(code) && A.Matches(code) && K.Matches(code) && D.Matches(code) }
  function Destinations(): set<nat> { R.Destinations()+V.Destinations()+B.Destinations()+C.Destinations()+S.Destinations()+A.Destinations()+K.Destinations()+D.Destinations() }
  function Output(mem: seq<Byte>,data: seq<Byte>,sourceOffset: Word,sourceLength: Word,templateLength: Word,arrayOffset: Word,count: Word,n: Word,kept: Word,index: Word,filter: bool,returned: seq<Byte>): seq<Byte>
    requires R.Admitted(data,sourceOffset,sourceLength,n,index) && kept <= index && |returned| == 32
    requires M.Fits(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data)
  {
    var word := DataWord(data,sourceOffset+index*32);
    var after := M.After(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data,word,returned);
    if filter && H.Result(returned) == 0 then after
    else Store(after,160+32*(if filter then kept else index),if filter then word else H.Result(returned))
  }
  ghost method Lift(code: seq<Byte>,small: set<nat>,data: seq<Byte>,states: seq<State>,self: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frames: seq<X.Frame>)
    requires SE.Trace(code,small,0,data,states) && small <= Destinations()
    ensures E.Trace(code,Destinations(),self,0,data,observations,frames)
    ensures frames == seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor))
  {
    L.Lift(code,small,data,states,self,returned,cursor,observations);
    frames := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor));
    E.WidenTrace(code,small,Destinations(),self,0,data,observations,frames);
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,n: Word,kept: Word,index: Word,filter: bool,self: Word,oldReturn: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && R.Admitted(data,sourceOffset,sourceLength,n,index) && kept <= index
    requires M.Fits(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data)
    requires X.Context(self) && target < AM.Bound() && |prefix| <= 984 && |returned| == 32
    requires !filter || H.Result(returned) <= 1
    requires cursor+2 < |observations| && observations[cursor] == X.Gas(gasBefore) && observations[cursor+1] == X.Gas(requestedGas)
    requires observations[cursor+2] == X.StaticCall(self,requestedGas,target,M.Stamped(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data,DataWord(data,sourceOffset+index*32))[O.Extent(n)+32..O.Extent(n)+32+templateLength],true,returned)
    ensures frame == X.Frame(Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,if filter then 1 else 0,128,n,kept+(if filter && H.Result(returned) == 0 then 0 else 1),O.Extent(n),index+1],Output(mem,data,sourceOffset,sourceLength,templateLength,arrayOffset,count,n,kept,index,filter,returned)),returned,cursor+3)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,if filter then 1 else 0,128,n,kept,O.Extent(n),index],mem),oldReturn,cursor) && trace[|trace|-1] == frame
    ensures |trace| == (if filter then (if H.Result(returned) == 0 then 339 else 371) else 358)+40*(count as nat)
  {
    hide G.BitAnd();
    hide M.After();
    hide M.Packed();
    var ptr: Word := O.Extent(n);
    var free: Word := Load(mem,64);
    var mode: Word := if filter then 1 else 0;
    var word: Word := DataWord(data,sourceOffset+index*32);
    var result := H.Result(returned);
    var fields := [returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,kept,ptr,index];
    var state: State; var states: seq<State>; var part: seq<X.Frame>;
    state,states := R.Run(code,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,kept,ptr,index,0);
    trace := Lift(code,R.Destinations(),data,states,self,oldReturn,cursor,observations);
    state,states := V.Run(code,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,kept,ptr,index,word,0);
    part := Lift(code,V.Destinations(),data,states,self,oldReturn,cursor,observations);
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
    var stampPrefix := prefix+fields+[word];
    Q.Append(prefix,fields,[word]);
    Q.Append(prefix,fields+[word],[12472,ptr,arrayOffset,count,word,0]);
    Q.Append(fields,[word],[12472,ptr,arrayOffset,count,word,0]);
    state,states := B.Run(code,data,mem,stampPrefix,ptr,arrayOffset,count,word,templateLength,0);
    part := Lift(code,B.Destinations(),data,states,self,oldReturn,cursor,observations);
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
    var stamped := M.Stamped(mem,ptr,free,templateLength,arrayOffset,count,data,word);
    state,states := C.Run(code,data,stamped,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,kept,ptr,index,word,0);
    part := Lift(code,C.Destinations(),data,states,self,oldReturn,cursor,observations);
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
    var callPrefix := prefix+fields+[word,0];
    Q.Append(prefix,fields,[word,0]);
    Q.Append(prefix,fields+[word,0],[12484,target,ptr,index,0,0]);
    Q.Append(fields,[word,0],[12484,target,ptr,index,0,0]);
    frame,part := S.Run(code,data,stamped,callPrefix,target,ptr,index,free,templateLength,self,0,oldReturn,returned,cursor,observations,gasBefore,requestedGas);
    E.WidenTrace(code,S.Destinations(),Destinations(),self,0,data,observations,part);
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
    var after := M.After(mem,ptr,free,templateLength,arrayOffset,count,data,word,returned);
    assert after == H.Complete(P.Packed(stamped,ptr,free,templateLength),free,returned) by {
      reveal M.After(); reveal M.Packed();
    }
    Q.Append(prefix,fields+[word,0],[result]);
    Q.Append(fields,[word,0],[result]);
    Z.Result(prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,kept,ptr,index,word,result);
    assert frame == X.Frame(Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,kept,ptr,index,word,0,result],after),returned,cursor+3);
    var small: set<nat>;
    if !filter {
      state,states := A.Run(code,data,after,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,128,n,kept,ptr,index,word,result,0);small := A.Destinations();
    } else if result == 1 {
      state,states := K.Run(code,data,after,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,128,n,kept,ptr,index,word,result,0);small := K.Destinations();
    } else {
      assert result == 0;
      state,states := D.Run(code,data,after,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,128,n,kept,ptr,index,word,result,0);small := D.Destinations();
    }
    part := Lift(code,small,data,states,self,returned,cursor+3,observations);
    assert trace[|trace|-1] == part[0];
    assert state == Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,kept+(if filter && result == 0 then 0 else 1),ptr,index+1],Output(mem,data,sourceOffset,sourceLength,templateLength,arrayOffset,count,n,kept,index,filter,returned)) by {
      if !filter {} else if result == 1 {} else { assert result == 0; }
    }
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];frame := part[|part|-1];
  }
}
