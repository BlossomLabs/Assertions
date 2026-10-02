// SPDX-License-Identifier: MIT
include "../element-read/Read.generated.dfy"
include "../stamp-invocation/Invoke.generated.dfy"
include "../stamp-engine/Engine.dfy"
include "../callback-invocation/Invoke.generated.dfy"
include "../callback-length-engine-repair-v2/Engine.dfy"
include "Memory.dfy"
include "../iteration-memory/Memory.dfy"
include "../raw-element-read/Connection.dfy"
module BytecodeApplyWrongSizeIterationEngine {
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
  import SM = BytecodeApplyStampMemory
  import L = BytecodeApplyRawFirstElement
  import R = BytecodeApplyElementRead
  import V = BytecodeApplyStampInvoke
  import B = BytecodeApplyStampEngine
  import C = BytecodeApplyCallbackInvoke
  import S = BytecodeApplyWrongSizeCallbackEngine
  import CM = BytecodeApplyFullCallbackReceiptMemory
  import RH = BytecodeApplyCallbackReceiptMemory
  import WM = BytecodeApplyWrongSizeIterationMemory
  import CL = BytecodeApplyCallbackLengthScalar
  import WH = BytecodeApplyWrongCallbackMemory
  import Q = BytecodeApplyCallbackSuccessScalar
  predicate Matches(code: seq<Byte>) { R.Matches(code) && V.Matches(code) && B.Matches(code) && C.Matches(code) && S.Matches(code) }
  function Destinations(): set<nat> { R.Destinations()+V.Destinations()+B.Destinations()+C.Destinations()+S.Destinations() }
  ghost method Lift(code: seq<Byte>,small: set<nat>,data: seq<Byte>,states: seq<State>,self: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frames: seq<X.Frame>)
    requires SE.Trace(code,small,0,data,states) && small <= Destinations()
    ensures E.Trace(code,Destinations(),self,0,data,observations,frames)
    ensures frames == seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor))
  {
    L.Lift(code,small,data,states,self,returned,cursor,observations);
    frames := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor));
    E.WidenTrace(code,small,Destinations(),self,0,data,observations,frames);
  }
  ghost method BeforeCall(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,n: Word,kept: Word,index: Word,filter: bool,self: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && R.Admitted(data,sourceOffset,sourceLength,n,index) && kept <= index
    requires M.Fits(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data)
    requires X.Context(self) && target < AM.Bound() && |prefix| <= 984
    ensures var word := DataWord(data,sourceOffset+index*32);
      frame == X.Frame(Running(16908,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,if filter then 1 else 0,128,n,kept,O.Extent(n),index,word,0,12484,target,O.Extent(n),index,0,0],M.Stamped(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data,word)),oldReturn,cursor)
    ensures |trace| > 0
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,if filter then 1 else 0,128,n,kept,O.Extent(n),index],mem),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide G.BitAnd(); hide BitNot(); hide DataWord(); hide ShiftRight(); hide E.Trace(); hide CM.Final(); hide M.Stamped(); hide WH.Packet(); hide CL.Operation();
    hide M.After();
    hide M.Packed();
    var ptr: Word := O.Extent(n);
    var free: Word := Load(mem,64);
    var mode: Word := if filter then 1 else 0;
    var word: Word := DataWord(data,sourceOffset+index*32);
    var fields := [returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,kept,ptr,index];
    var state: State; var states: seq<State>; var part: seq<X.Frame>;
    state,states := R.Run(code,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,kept,ptr,index,0);
    trace := Lift(code,R.Destinations(),data,states,self,oldReturn,cursor,observations);
    state,states := V.Run(code,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,kept,ptr,index,word,0);
    part := Lift(code,V.Destinations(),data,states,self,oldReturn,cursor,observations);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
    var stampPrefix := prefix+fields+[word];
    Q.Append(prefix,fields,[word]);
    Q.Append(prefix,fields+[word],[12472,ptr,arrayOffset,count,word,0]);
    Q.Append(fields,[word],[12472,ptr,arrayOffset,count,word,0]);
    state,states := B.Run(code,data,mem,stampPrefix,ptr,arrayOffset,count,word,templateLength,0);
    part := Lift(code,B.Destinations(),data,states,self,oldReturn,cursor,observations);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
    var stamped := M.Stamped(mem,ptr,free,templateLength,arrayOffset,count,data,word);
    assert stamped == SM.Stamped(mem,ptr,templateLength,arrayOffset,count,data,word,count) by { reveal M.Stamped(); }
    assert trace[|trace|-1] == X.Frame(Running(12472,stampPrefix,stamped),oldReturn,cursor);
    state,states := C.Run(code,data,stamped,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,kept,ptr,index,word,0);
    part := Lift(code,C.Destinations(),data,states,self,oldReturn,cursor,observations);
    assert trace[|trace|-1] == X.Frame(Running(12472,stampPrefix,stamped),oldReturn,cursor);
    assert part[0] == X.Frame(Running(12472,stampPrefix,stamped),oldReturn,cursor);
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
    frame := part[|part|-1];
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,n: Word,kept: Word,index: Word,filter: bool,self: Word,oldReturn: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && R.Admitted(data,sourceOffset,sourceLength,n,index) && kept <= index
    requires M.Fits(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data)
    requires X.Context(self) && target < AM.Bound() && |prefix| <= 984 && |returned| != 32
    requires ShiftRight(DataWord(data,0),224) == CL.Selector(filter)
    requires 128 <= |mem| && 160 <= Load(mem,64) && Load(mem,64)%32 == 0 && Load(mem,96) == 0
    requires Load(mem,64)+|returned|+256 < RH.Bound()
    requires cursor+2 < |observations| && observations[cursor] == X.Gas(gasBefore) && observations[cursor+1] == X.Gas(requestedGas)
    requires observations[cursor+2] == X.StaticCall(self,requestedGas,target,M.Stamped(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data,DataWord(data,sourceOffset+index*32))[O.Extent(n)+32..O.Extent(n)+32+templateLength],true,returned)
    ensures frame == X.Frame(Reverted(WH.Packet(CL.Operation(filter),index,target)),returned,cursor+3)
    ensures |trace| > 0
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,if filter then 1 else 0,128,n,kept,O.Extent(n),index],mem),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide G.BitAnd(); hide BitNot(); hide DataWord(); hide ShiftRight(); hide E.Trace(); hide CM.Final(); hide M.Stamped(); hide WH.Packet(); hide CL.Operation();
    var ptr: Word := O.Extent(n); var free: Word := Load(mem,64);
    var mode: Word := if filter then 1 else 0;
    var word: Word := DataWord(data,sourceOffset+index*32);
    var fields := [returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,kept,ptr,index];
    frame,trace := BeforeCall(code,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,n,kept,index,filter,self,oldReturn,cursor,observations);
    var stamped := M.Stamped(mem,ptr,free,templateLength,arrayOffset,count,data,word);
    var callPrefix := prefix+fields+[word,0];
    Q.Append(prefix,fields,[word,0]);
    Q.Append(prefix,fields+[word,0],[12484,target,ptr,index,0,0]);
    Q.Append(fields,[word,0],[12484,target,ptr,index,0,0]);
    assert |callPrefix| == |prefix|+16;
    WM.StampedAdmission(mem,ptr,free,templateLength,arrayOffset,count,data,word,returned);
    var part: seq<X.Frame>;
    frame,part := S.Run(code,data,stamped,callPrefix,filter,target,ptr,index,free,templateLength,self,0,oldReturn,returned,cursor,observations,gasBefore,requestedGas);
    E.WidenTrace(code,S.Destinations(),Destinations(),self,0,data,observations,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part); trace := trace+part[1..];
  }
}
