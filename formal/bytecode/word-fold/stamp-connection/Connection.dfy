// SPDX-License-Identifier: MIT
// Exact count/domain, accumulator loads and accumulator-first supplied-order physical stamping.
include "../domain-connection/Connection.dfy"
include "../stamp-invocation/Invoke.generated.dfy"
include "../stamp-engine/Engine.dfy"
include "../element-windows/Inputs.dfy"
module BytecodeFoldStampConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import S = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import D = BytecodeFoldDomainConnection
  import I = BytecodeFoldStampInvoke
  import H = BytecodeFoldStampEngine
  import M = BytecodeFoldStampMemory
  import W = BytecodeFoldElementWindowInputs
  import A = BytecodeApplyWindowInputs
  predicate Matches(code: seq<Byte>) { D.Matches(code) && I.Matches(code) && H.Matches(code) }
  function Destinations(): set<nat> { D.Destinations()+I.Destinations()+H.Destinations() }
  lemma WindowBridge(templateLength: Word,arrayOffset: Word,count: Word,data: seq<Byte>)
    requires W.Valid(templateLength,arrayOffset,count,data)
    ensures A.Valid(templateLength,arrayOffset,count,data)
  {
    forall j: nat {:trigger A.At(arrayOffset,j,data)} | j < count
      ensures A.At(arrayOffset,j,data) <= templateLength-32
    { assert A.At(arrayOffset,j,data) == W.At(arrayOffset,j,data); }
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,returnWord: Word,callPtr: Word,index: Word,domain: Word,total: Word,accOffset: Word,acc: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && returnPc == 12157 && |prefix| <= 978
    requires D.Admitted(data,mem,domain,total,index,sourceOffset,sourceLength)
    requires Load(mem,224) == accOffset && Load(mem,256) == acc
    requires M.Fits(mem,callPtr,templateLength,accOffset,arrayOffset,count,data)
    ensures state == Running(16536,prefix+D.Fields(returnPc,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index)+[D.Element(data,mem,domain,total,index,sourceOffset,sourceLength)],M.Stamped(mem,callPtr,templateLength,accOffset,acc,arrayOffset,count,data,D.Element(data,mem,domain,total,index,sourceOffset,sourceLength),count))
    ensures S.Trace(code,Destinations(),value,data,trace)
    ensures |trace| > 0 && trace[0] == Running(16484,prefix+D.Fields(returnPc,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index),mem) && trace[|trace|-1] == state
    ensures |state.memory| == |mem|
    ensures forall j: nat {:trigger state.memory[j]} :: j < |mem| ==> state.memory[j] == M.LastByte(mem,callPtr,templateLength,accOffset,acc,arrayOffset,count,data,D.Element(data,mem,domain,total,index,sourceOffset,sourceLength),count,j)
    ensures forall slot: Word {:trigger Load(state.memory,slot)} :: (slot as nat)+32 <= callPtr ==> Load(state.memory,slot) == Load(mem,slot)
  {
    hide DataWord(); hide ShiftRight(); hide S.Trace();
    var element := D.Element(data,mem,domain,total,index,sourceOffset,sourceLength);
    state,trace := D.Run(code,data,mem,prefix,returnPc,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index,domain,total,value);
    S.WidenTrace(code,D.Destinations(),Destinations(),value,data,trace);
    var part: seq<State>;
    state,part := I.Run(code,data,mem,prefix,returnPc,128,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index,accOffset,acc,element,value);
    S.WidenTrace(code,I.Destinations(),Destinations(),value,data,part);
    assert trace[|trace|-1] == part[0];
    S.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    var lower := prefix+D.Fields(returnPc,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,returnWord,callPtr,index)+[element];
    state,part := H.Run(code,data,mem,lower,callPtr,templateLength,accOffset,acc,arrayOffset,count,element,value);
    S.WidenTrace(code,H.Destinations(),Destinations(),value,data,part);
    assert trace[|trace|-1] == part[0];
    S.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    forall slot: Word {:trigger Load(state.memory,slot)} | (slot as nat)+32 <= callPtr
      ensures Load(state.memory,slot) == Load(mem,slot)
    { M.WordFrame(mem,callPtr,templateLength,accOffset,acc,arrayOffset,count,data,element,count,slot); }
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
