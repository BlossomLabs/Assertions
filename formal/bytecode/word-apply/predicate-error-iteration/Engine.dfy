// SPDX-License-Identifier: MIT
include "../wrong-size-iteration-repair-v9/Engine.dfy"
include "../callback-success-engine/Engine.dfy"
include "../predicate-error-repair-v3/Predicate.generated.dfy"
module BytecodeApplyNoncanonicalPredicateIteration {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import O = BytecodeIotaOutput
  import A = BytecodeApplyAddressMask
  import M = BytecodeApplyRepeatedIterationMemory
  import R = BytecodeApplyElementRead
  import W = BytecodeApplyWrongSizeIterationEngine
  import C = BytecodeApplySuccessfulCallEngine
  import P = BytecodeApplyPredicateError
  import H = BytecodeApplyCallbackSuccessMemory
  import CP = BytecodeApplyCallbackCopyMemory
  import WH = BytecodeApplyWrongCallbackMemory
  import SC = BytecodeApplyWrongCallbackScalar
  import Q = BytecodeApplyCallbackSuccessScalar
  import L = BytecodeApplyRawFirstElement
  predicate Matches(code: seq<Byte>) { W.Matches(code) && C.Matches(code) && P.Matches(code) }
  function Destinations(): set<nat> { W.Destinations()+C.Destinations()+P.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,n: Word,kept: Word,index: Word,self: Word,oldReturn: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && R.Admitted(data,sourceOffset,sourceLength,n,index) && kept <= index && n < 0x800000000000000
    requires M.Fits(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data)
    requires X.Context(self) && target < A.Bound() && |prefix| <= 984
    requires |returned| == 32 && H.Result(returned) > 1 && ShiftRight(DataWord(data,0),224) == 2005396296
    requires cursor+2 < |observations| && observations[cursor] == X.Gas(gasBefore) && observations[cursor+1] == X.Gas(requestedGas)
    requires observations[cursor+2] == X.StaticCall(self,requestedGas,target,M.Stamped(mem,O.Extent(n),Load(mem,64),templateLength,arrayOffset,count,data,DataWord(data,sourceOffset+index*32))[O.Extent(n)+32..O.Extent(n)+32+templateLength],true,returned)
    ensures frame == X.Frame(Reverted(WH.Packet(SC.Operation(),index,target)),returned,cursor+3)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures |trace| > 0 && trace[0] == W.Initial(mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,n,kept,index,true,oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide G.BitAnd();hide BitNot();hide DataWord();hide ShiftRight();hide M.Stamped();hide M.After();hide M.Packed();hide H.Complete();hide WH.Stage();hide WH.Packet();hide E.Trace();
    var ptr: Word := O.Extent(n);var free := Load(mem,64);var word := DataWord(data,sourceOffset+index*32);var result := H.Result(returned);
    var fields := [returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,128,n,kept,ptr,index];
    frame,trace := W.BeforeCall(code,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,n,kept,index,true,self,oldReturn,cursor,observations);
    var stamped := M.Stamped(mem,ptr,free,templateLength,arrayOffset,count,data,word);
    var callPrefix := prefix+fields+[word,0];
    Q.Append(prefix,fields,[word,0]);Q.Append(prefix,fields+[word,0],[12484,target,ptr,index,0,0]);
    Q.Append(fields,[word,0],[12484,target,ptr,index,0,0]);Q.Append(prefix,fields,[word,0,12484,target,ptr,index,0,0]);
    assert frame == X.Frame(Running(16908,callPrefix+[12484,target,ptr,index,0,0],stamped),oldReturn,cursor);
    assert trace[|trace|-1] == frame;
    var part: seq<X.Frame>;
    frame,part := C.Run(code,data,stamped,callPrefix,target,ptr,index,free,templateLength,self,0,oldReturn,returned,cursor,observations,gasBefore,requestedGas);
    E.WidenTrace(code,W.Destinations(),Destinations(),self,0,data,observations,trace);E.WidenTrace(code,C.Destinations(),Destinations(),self,0,data,observations,part);
    assert trace[|trace|-1] == part[0];E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
    var after := M.After(mem,ptr,free,templateLength,arrayOffset,count,data,word,returned);
    M.Bounds(mem,ptr,free,templateLength,arrayOffset,count,data,word,returned);M.Layout(mem,ptr,free,templateLength,arrayOffset,count,data,word,returned);
    assert after == H.Complete(CP.Packed(stamped,ptr,free,templateLength),free,returned) by { reveal M.After();reveal M.Packed(); }
    Q.Append(prefix,fields+[word,0],[result]);Q.Append(fields,[word,0],[result]);
    assert frame == X.Frame(Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,128,n,kept,ptr,index,word,0,result],after),returned,cursor+3);
    assert WH.Fits(after,free+64);
    assert WH.Stage(after,free+64,SC.Operation(),index,target,0) == after by { reveal WH.Stage(); }
    assert P.Admitted(data,after,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,128,n,kept,ptr,index,word,result,free+64,0) by { reveal P.Admitted(); }
    var state: State;var states: seq<State>;
    state,states := P.Run(code,data,after,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,128,n,kept,ptr,index,word,result,free+64,0);
    L.Lift(code,P.Destinations(),data,states,self,returned,cursor+3,observations);
    part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor+3));
    E.WidenTrace(code,P.Destinations(),Destinations(),self,0,data,observations,part);
    assert trace[|trace|-1] == part[0];E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];frame := part[|part|-1];
  }
}
