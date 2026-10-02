// SPDX-License-Identifier: MIT
// Exact empty raw map/filter admission, actual empty body, and dynamic ABI RETURN.
include "Memory.dfy"
include "../raw-allocation/Connection.dfy"
include "../empty-return/EmptyMap.generated.dfy"
include "../empty-return/EmptyFilter.generated.dfy"
include "../../bytes-return/Control.generated.dfy"
include "../../external-calls/Execution.dfy"
module BytecodeApplyRawEmptyReturn {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import S = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeApplyRawInputs
  import W = BytecodeApplyWindowInputs
  import MP = BytecodeWordMapPrefix
  import FP = BytecodeWordFilterPrefix
  import R = BytecodeApplyRawAdmission
  import A = BytecodeApplyRawOutputAllocation
  import M = BytecodeApplyAllocationMemory
  import H = BytecodeApplyEmptyHeap
  import EM = BytecodeApplyEmptyMap
  import EF = BytecodeApplyEmptyFilter
  import B = BytecodeAlignedBytesReturnControl
  import BM = BytecodeAlignedBytesReturnMemory
  predicate Matches(code: seq<Byte>) { A.Matches(code) && EM.Matches(code) && EF.Matches(code) && B.Matches(code) }
  function Destinations(): set<nat> { A.Destinations()+EM.Destinations()+EF.Destinations()+B.Destinations() }
  lemma Lift(code: seq<Byte>, small: set<nat>, data: seq<Byte>, states: seq<State>)
    requires small <= Destinations() && S.Trace(code,small,0,data,states)
    ensures C.Trace(code,Destinations(),0,data,states)
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    { assert Step(code,small,states[i],0,data) != Bad; reveal Step(); }
    C.Lift(code,small,0,data,states);
    C.WidenTrace(code,small,Destinations(),0,data,states);
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, filter: bool)
    returns (state: State, trace: seq<State>)
    requires Matches(code) && I.Fits(data) && I.SourceLength(data) == 0
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    requires W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    ensures state == Returned(G.Encode(32,32)+G.Encode(0,32))
    ensures C.Trace(code,Destinations(),0,data,trace)
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
    ensures |trace| == (if filter then 593 else 582)+53*(I.Count(data) as nat)
  {
    H.Exact();
    var selector: Word := if filter then 2005396296 else 3983393726;
    var part: seq<State>;
    state,trace := A.Run(code,data,filter);
    C.WidenTrace(code,A.Destinations(),Destinations(),0,data,trace);
    if filter {
      state,part := EF.Run(code,data,M.Heap(0),[selector],5526,I.Offset(I.SourceHead(data)),0,I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),1,0);
      Lift(code,EF.Destinations(),data,part);
    } else {
      state,part := EM.Run(code,data,M.Heap(0),[selector],5526,I.Offset(I.SourceHead(data)),0,I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),0,0);
      Lift(code,EM.Destinations(),data,part);
    }
    C.Join(code,Destinations(),0,data,trace,part); trace := trace+part[1..];
    state,part := B.Run(code,0,[],selector,0,data);
    C.WidenTrace(code,B.Destinations(),Destinations(),0,data,part);
    C.Join(code,Destinations(),0,data,trace,part); trace := trace+part[1..];
  }
  lemma NoObservations(code: seq<Byte>, data: seq<Byte>, self: Word, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, states: seq<State>)
    requires C.Trace(code,Destinations(),0,data,states)
    ensures E.Trace(code,Destinations(),self,0,data,observations,seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor)))
  { E.Lift(code,Destinations(),self,0,data,observations,states,returned,cursor); }
}
