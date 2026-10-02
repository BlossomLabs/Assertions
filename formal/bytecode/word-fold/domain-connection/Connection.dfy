// SPDX-License-Identifier: MIT
// Actual full-word count branch and domain helper return, with no external observation.
include "../loop-gate/Enter.generated.dfy"
include "../domain-element/Range.generated.dfy"
include "../domain-element/Bytes.generated.dfy"
include "../domain-element/Words.generated.dfy"
include "../../external-calls/Execution.dfy"
module BytecodeFoldDomainConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import S = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import L = BytecodeFoldLoopEnter
  import R = BytecodeFoldDomainRange
  import B = BytecodeFoldDomainBytes
  import W = BytecodeFoldDomainWords
  predicate Matches(code: seq<Byte>) { L.Matches(code) && R.Matches(code) && B.Matches(code) && W.Matches(code) }
  function Destinations(): set<nat> { L.Destinations()+R.Destinations()+B.Destinations()+W.Destinations() }
  predicate Admitted(data: seq<Byte>,mem: seq<Byte>,domain: Word,total: Word,index: Word,sourceOffset: Word,sourceLength: Word) {
    L.Admitted(data,mem,128,domain,total,0,index) &&
    (if domain == 0 then R.Admitted(data,domain,index,sourceOffset,sourceLength)
     else if domain == 1 then B.Admitted(data,domain,index,sourceOffset,sourceLength) && total == sourceLength
     else W.Admitted(data,domain,index,sourceOffset,sourceLength) && total == (sourceLength as nat)/32)
  }
  function Element(data: seq<Byte>,mem: seq<Byte>,domain: Word,total: Word,index: Word,sourceOffset: Word,sourceLength: Word): Word
    requires Admitted(data,mem,domain,total,index,sourceOffset,sourceLength)
  {
    if domain == 0 then index
    else if domain == 1 then ShiftRight(DataWord(data,sourceOffset+index),248)
    else DataWord(data,sourceOffset+index*32)
  }
  function Fields(returnPc: Word,sourceOffset: Word,sourceLength: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,returnWord: Word,callPtr: Word,index: Word): seq<Word>
  { [returnPc,128,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index] }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,returnWord: Word,callPtr: Word,index: Word,domain: Word,total: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && returnPc == 12157 && |prefix| <= 980 && Admitted(data,mem,domain,total,index,sourceOffset,sourceLength)
    ensures state == Running(16512,prefix+Fields(returnPc,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index)+[0,Element(data,mem,domain,total,index,sourceOffset,sourceLength)],mem)
    ensures S.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 22+(if domain == 0 then 26 else if domain == 1 then 57 else 173)
    ensures trace[0] == Running(16484,prefix+Fields(returnPc,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index),mem) && trace[|trace|-1] == state
  {
    hide DataWord(); hide ShiftRight(); hide S.Trace();
    state,trace := L.Run(code,data,mem,prefix,returnPc,128,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index,domain,total,0,value);
    S.WidenTrace(code,L.Destinations(),Destinations(),value,data,trace);
    var lower := prefix+Fields(returnPc,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index)+[0];
    var part: seq<State>;
    if domain == 0 {
      state,part := R.Run(code,data,mem,lower,16512,domain,index,sourceOffset,sourceLength,value);
      S.WidenTrace(code,R.Destinations(),Destinations(),value,data,part);
    } else if domain == 1 {
      state,part := B.Run(code,data,mem,lower,16512,domain,index,sourceOffset,sourceLength,value);
      S.WidenTrace(code,B.Destinations(),Destinations(),value,data,part);
    } else {
      state,part := W.Run(code,data,mem,lower,16512,domain,index,sourceOffset,sourceLength,value);
      S.WidenTrace(code,W.Destinations(),Destinations(),value,data,part);
    }
    assert trace[|trace|-1] == part[0];
    S.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
  ghost method ExternalLift(code: seq<Byte>,data: seq<Byte>,value: Word,self: Word,states: seq<State>,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frames: seq<X.Frame>)
    requires S.Trace(code,Destinations(),value,data,states)
    ensures E.Trace(code,Destinations(),self,value,data,observations,frames)
    ensures frames == seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor))
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    { assert Step(code,Destinations(),states[i],value,data) != Bad; reveal Step(); }
    C.Lift(code,Destinations(),value,data,states);
    E.Lift(code,Destinations(),self,value,data,observations,states,oldReturn,cursor);
    frames := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor));
  }
}
