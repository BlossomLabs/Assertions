// SPDX-License-Identifier: MIT
// Actual raw nonempty admission through one positive EXTCODESIZE target observation.
include "../raw-allocation/Connection.dfy"
include "../target-invocation/Invoke.generated.dfy"
include "../target-check/Code.generated.dfy"
module BytecodeApplyRawPositiveTarget {
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
  import V = BytecodeApplyTargetInvoke
  import T = BytecodeApplyTargetCode
  predicate Matches(code: seq<Byte>) { A.Matches(code) && V.Matches(code) && T.Matches(code) }
  function Destinations(): set<nat> { A.Destinations()+V.Destinations()+T.Destinations() }
  lemma Lift(code: seq<Byte>, data: seq<Byte>, small: set<nat>, states: seq<State>)
    requires S.Trace(code,small,0,data,states) && small <= Destinations()
    ensures C.Trace(code,Destinations(),0,data,states)
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    { assert Step(code,small,states[i],0,data) != Bad; reveal Step(); }
    C.Lift(code,small,0,data,states);
    C.WidenTrace(code,small,Destinations(),0,data,states);
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, filter: bool, self: Word, returned: seq<Byte>, cursor: nat, codeSize: Word, observations: seq<X.Observation>)
    returns (frame: X.Frame, trace: seq<X.Frame>)
    requires Matches(code) && I.Fits(data) && 0 < I.SourceLength(data) && I.SourceLength(data)%32 == 0
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    requires W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    requires X.Context(self) && 0 < codeSize && cursor < |observations| && observations[cursor] == X.CodeSize(I.Target(data),codeSize)
    ensures var n: Word := I.SourceLength(data)/32;
            frame == X.Frame(Running(12334,[if filter then 2005396296 else 3983393726,518]+R.Fields(data)+[96,5526]+R.Fields(data)+[if filter then 1 else 0,128,n,0],M.Heap(n)),returned,cursor+1)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(0,[],[]),returned,cursor) && trace[|trace|-1] == frame
    ensures |trace| == (if filter then 511 else 505)+53*(I.Count(data) as nat)
  {
    var n: Word := I.SourceLength(data)/32;
    assert 0 < n < 0x800000000000000;
    var selector: Word := if filter then 2005396296 else 3983393726;
    var mode: Word := if filter then 1 else 0;
    var prefix := [selector,518]+R.Fields(data)+[96];
    var state: State;
    var states: seq<State>;
    state,states := A.Run(code,data,filter);
    C.WidenTrace(code,A.Destinations(),Destinations(),0,data,states);
    var part: seq<State>;
    state,part := V.Run(code,data,M.Heap(n),prefix,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),mode,n,0);
    Lift(code,data,V.Destinations(),part);
    C.Join(code,Destinations(),0,data,states,part); states := states+part[1..];
    E.Lift(code,Destinations(),self,0,data,observations,states,returned,cursor);
    trace := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor));
    var frames: seq<X.Frame>;
    var targetPrefix := prefix+[5526]+R.Fields(data)+[mode,128,n,0];
    frame,frames := T.Run(code,I.Target(data),codeSize,targetPrefix,M.Heap(n),returned,cursor,observations,self,0,data);
    E.WidenTrace(code,T.Destinations(),Destinations(),self,0,data,observations,frames);
    E.Join(code,Destinations(),self,0,data,observations,trace,frames); trace := trace+frames[1..];
  }
}
