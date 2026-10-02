// SPDX-License-Identifier: MIT
// Physical PC-zero raw public admission through complete zeroed output allocation.
include "../allocation-count/Connection.dfy"
include "../allocation-header/Connection.dfy"
module BytecodeApplyRawOutputAllocation {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import X = BytecodeCopyExecution
  import I = BytecodeApplyRawInputs
  import W = BytecodeApplyWindowInputs
  import MP = BytecodeWordMapPrefix
  import FP = BytecodeWordFilterPrefix
  import R = BytecodeApplyRawAdmission
  import C = BytecodeApplyRawAllocationCount
  import A = BytecodeApplyOutputAllocation
  import M = BytecodeApplyAllocationMemory
  predicate Matches(code: seq<Byte>) { C.Matches(code) && A.Matches(code) }
  function Destinations(): set<nat> { C.Destinations()+A.Destinations() }
  lemma Lift(code: seq<Byte>,small: set<nat>,data: seq<Byte>,trace: seq<State>)
    requires small <= Destinations() && E.Trace(code,small,0,data,trace)
    ensures X.Trace(code,Destinations(),0,data,trace)
  {
    forall i {:trigger trace[i]} | 0 <= i < |trace|-1
      ensures !trace[i].Running? || trace[i].pc >= |code| || Fetch(code,trace[i].pc).op !in {0x37,0x5e}
    {
      assert Step(code,small,trace[i],0,data) != Bad;
      reveal Step();
    }
    X.Lift(code,small,0,data,trace);
    X.WidenTrace(code,small,Destinations(),0,data,trace);
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,filter: bool)
    returns (state: State,trace: seq<State>)
    requires Matches(code) && I.Fits(data)
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    requires I.SourceLength(data)%32 == 0
    requires W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    ensures var n: Word := I.SourceLength(data)/32;
            state == Running(12319,[if filter then 2005396296 else 3983393726,518]+R.Fields(data)+[96,5526]+R.Fields(data)+[if filter then 1 else 0,128,n],M.Heap(n))
    ensures X.Trace(code,Destinations(),0,data,trace)
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
    ensures |trace| == (if filter then 448 else 442)+53*(I.Count(data) as nat)+(if I.SourceLength(data) == 0 then 27 else 38)
  {
    var n: Word := I.SourceLength(data)/32;
    assert I.SourceLength(data) < 0x10000000000000000;
    assert n < 0x800000000000000 && n*32 == I.SourceLength(data);
    state,trace := C.Run(code,data,filter);
    Lift(code,C.Destinations(),data,trace);
    var selector: Word := if filter then 2005396296 else 3983393726;
    var mode: Word := if filter then 1 else 0;
    var prefix := [selector,518]+R.Fields(data)+[96];
    var part: seq<State>;
    state,part := A.Run(code,data,prefix,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),mode,n,0);
    X.WidenTrace(code,A.Destinations(),Destinations(),0,data,part);
    X.Join(code,Destinations(),0,data,trace,part);
    trace := trace+part[1..];
  }
}
