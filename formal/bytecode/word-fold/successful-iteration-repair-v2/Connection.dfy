// SPDX-License-Identifier: MIT
// Complete reached finite successful fold iteration, real physical call and exhaustive canonical early exit.
include "../stamp-connection-repair-v4/Connection.dfy"
include "../callback-invocation-repair-v2/Invoke.generated.dfy"
include "../callback-engine/Success.dfy"
include "../iteration-result-repair-v3/ContinueNever.generated.dfy"
include "../iteration-result-repair-v3/ContinueZeroWhenNonZero.generated.dfy"
include "../iteration-result-repair-v3/ContinueNonZeroWhenZero.generated.dfy"
include "../iteration-result-repair-v3/BreakNonZero.generated.dfy"
include "../iteration-result-repair-v3/BreakZero.generated.dfy"
include "Memory.dfy"
module BytecodeFoldSuccessfulIterationV2 {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import S = BytecodeScanExecution
  import D = BytecodeFoldDomainConnectionV3
  import T = BytecodeFoldStampConnectionV4
  import M = BytecodeFoldStampMemoryV2
  import A = BytecodeApplyAddressMask
  import P = BytecodeApplyCallbackCopyMemory
  import H = BytecodeApplyCallbackSuccessMemory
  import C = BytecodeFoldCallbackMemoryV2
  import Q = BytecodeFoldSuccessfulIterationMemoryV2
  import V = BytecodeFoldCallbackInvokeV2
  import CB = BytecodeFoldCallbackEngine
  import B = BytecodeFoldSuccessfulCallEngine
  import R = BytecodeFoldResultMemoryV3
  import N = BytecodeFoldResultContinueNeverV3
  import CZ = BytecodeFoldResultContinueZeroWhenNonZeroV3
  import CN = BytecodeFoldResultContinueNonZeroWhenZeroV3
  import BN = BytecodeFoldResultBreakNonZeroV3
  import BZ = BytecodeFoldResultBreakZeroV3
  predicate Matches(code: seq<Byte>) { T.Matches(code) && V.Matches(code) && B.Matches(code) && N.Matches(code) && CZ.Matches(code) && CN.Matches(code) && BN.Matches(code) && BZ.Matches(code) }
  function Destinations(): set<nat> { T.Destinations()+V.Destinations()+B.Destinations()+N.Destinations()+CZ.Destinations()+CN.Destinations()+BN.Destinations()+BZ.Destinations() }
  predicate Stop(exit: Word,nextWord: Word) { (exit == 1 && nextWord != 0) || (exit == 2 && nextWord == 0) }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,sourceOffset: Word,sourceLength: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,returnWord: Word,callPtr: Word,index: Word,domain: Word,total: Word,accOffset: Word,acc: Word,exit: Word,target: Word,free: Word,self: Word,value: Word,oldReturn: seq<Byte>,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word) returns (frame: X.Frame,trace: seq<X.Frame>,stopped: bool)
    requires Matches(code) && |prefix| <= 970 && D.Admitted(data,mem,domain,total,index,sourceOffset,sourceLength) && X.Context(self)
    requires M.Fits(mem,callPtr,templateLength,accOffset,arrayOffset,count,data) && 320 <= callPtr
    requires P.Fits(mem,callPtr,free,templateLength) && (free as nat)+96 < G.Modulus()
    requires Load(mem,64) == free && Load(mem,callPtr) == templateLength && Load(mem,224) == accOffset && Load(mem,256) == acc
    requires Load(mem,192) == target && target < A.Bound() && Load(mem,288) == exit && exit <= 2 && |returned| == 32
    requires cursor+2 < |observations| && observations[cursor] == X.Gas(gasBefore) && observations[cursor+1] == X.Gas(requestedGas)
    requires observations[cursor+2] == X.StaticCall(self,requestedGas,target,M.Stamped(mem,callPtr,templateLength,accOffset,acc,arrayOffset,count,data,D.Element(data,mem,domain,total,index,sourceOffset,sourceLength),count)[callPtr+32..callPtr+32+templateLength],true,returned)
    requires C.Fits(M.Stamped(mem,callPtr,templateLength,accOffset,acc,arrayOffset,count,data,D.Element(data,mem,domain,total,index,sourceOffset,sourceLength),count),callPtr,free,templateLength,returned)
    // Explicit finite-memory representation premise for the reached physical callback completion.
    requires R.Fits(C.Complete(M.Stamped(mem,callPtr,templateLength,accOffset,acc,arrayOffset,count,data,D.Element(data,mem,domain,total,index,sourceOffset,sourceLength),count),callPtr,free,templateLength,returned))
    ensures stopped == Stop(exit,H.Result(returned))
    ensures var updated := R.Updated(C.Complete(M.Stamped(mem,callPtr,templateLength,accOffset,acc,arrayOffset,count,data,D.Element(data,mem,domain,total,index,sourceOffset,sourceLength),count),callPtr,free,templateLength,returned),H.Result(returned));
            frame == X.Frame(Running(if stopped then 16664 else 16484,prefix+D.Fields(12157,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,if stopped then index else index+1),updated),returned,cursor+3)
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| > 0 && trace[0] == X.Frame(Running(16484,prefix+D.Fields(12157,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index),mem),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide G.BitAnd(); hide DataWord(); hide ShiftRight(); hide E.Trace(); hide S.Trace();
    var element := D.Element(data,mem,domain,total,index,sourceOffset,sourceLength);
    var stamped := M.Stamped(mem,callPtr,templateLength,accOffset,acc,arrayOffset,count,data,D.Element(data,mem,domain,total,index,sourceOffset,sourceLength),count);
    Q.Admission(mem,callPtr,free,templateLength,accOffset,acc,arrayOffset,count,data,element,returned);
    M.WordFrame(mem,callPtr,templateLength,accOffset,acc,arrayOffset,count,data,element,count,192);
    var state: State; var states: seq<State>;
    state,states := T.Run(code,data,mem,prefix,12157,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index,domain,total,accOffset,acc,value);
    trace := T.ExternalLift(code,data,value,self,states,oldReturn,cursor,observations);
    E.WidenTrace(code,T.Destinations(),Destinations(),self,value,data,observations,trace);
    state,states := V.Run(code,data,stamped,prefix,12157,128,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index,target,element,value);
    CB.Lift(code,V.Destinations(),data,value,states,self,oldReturn,cursor,observations);
    var part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor));
    E.WidenTrace(code,V.Destinations(),Destinations(),self,value,data,observations,part);
    E.Join(code,Destinations(),self,value,data,observations,trace,part); trace := trace+part[1..];
    var fields := D.Fields(12157,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index);
    frame,part := B.Run(code,data,stamped,prefix+fields+[0],target,callPtr,index,free,templateLength,self,value,oldReturn,returned,cursor,observations,gasBefore,requestedGas);
    E.WidenTrace(code,B.Destinations(),Destinations(),self,value,data,observations,part);
    E.Join(code,Destinations(),self,value,data,observations,trace,part); trace := trace+part[1..];
    var completed := C.Complete(stamped,callPtr,free,templateLength,returned);
    C.WordFrame(stamped,callPtr,free,templateLength,returned,288);
    M.WordFrame(mem,callPtr,templateLength,accOffset,acc,arrayOffset,count,data,element,count,288);
    var nextWord := H.Result(returned);
    stopped := Stop(exit,nextWord);
    if exit == 0 {
      state,states := N.Run(code,data,completed,prefix,12157,128,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index,exit,nextWord,value);
      S.WidenTrace(code,N.Destinations(),Destinations(),value,data,states);
    } else if exit == 1 && nextWord == 0 {
      state,states := CZ.Run(code,data,completed,prefix,12157,128,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index,exit,nextWord,value);
      S.WidenTrace(code,CZ.Destinations(),Destinations(),value,data,states);
    } else if exit == 2 && nextWord != 0 {
      state,states := CN.Run(code,data,completed,prefix,12157,128,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index,exit,nextWord,value);
      S.WidenTrace(code,CN.Destinations(),Destinations(),value,data,states);
    } else if exit == 1 {
      state,states := BN.Run(code,data,completed,prefix,12157,128,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index,exit,nextWord,value);
      S.WidenTrace(code,BN.Destinations(),Destinations(),value,data,states);
    } else {
      state,states := BZ.Run(code,data,completed,prefix,12157,128,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index,exit,nextWord,value);
      S.WidenTrace(code,BZ.Destinations(),Destinations(),value,data,states);
    }
    CB.Lift(code,Destinations(),data,value,states,self,returned,cursor+3,observations);
    part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor+3));
    E.Join(code,Destinations(),self,value,data,observations,trace,part); trace := trace+part[1..];
    frame := part[|part|-1];
  }
}
