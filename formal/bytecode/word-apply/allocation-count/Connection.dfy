// SPDX-License-Identifier: MIT
// Physical raw public admission through checked count division to output allocation.
include "../raw-admission/Connection.dfy"
include "Count.generated.dfy"
module BytecodeApplyRawAllocationCount {
  import opened BytecodeScanMachine
  import E = BytecodeScanExecution
  import I = BytecodeApplyRawInputs
  import W = BytecodeApplyWindowInputs
  import MP = BytecodeWordMapPrefix
  import FP = BytecodeWordFilterPrefix
  import R = BytecodeApplyRawAdmission
  import C = BytecodeApplyAllocationCount
  predicate Matches(code: seq<Byte>) { R.Matches(code) && C.Matches(code) }
  function Destinations(): set<nat> { R.Destinations()+C.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,filter: bool)
    returns (state: State,trace: seq<State>)
    requires Matches(code) && I.Fits(data)
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    requires I.SourceLength(data)%32 == 0
    requires W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    ensures state == Running(12273,[if filter then 2005396296 else 3983393726,518]+R.Fields(data)+[96,5526]+R.Fields(data)+[if filter then 1 else 0,96,I.SourceLength(data)/32,I.SourceLength(data)],Store([],64,128))
    ensures E.Trace(code,Destinations(),0,data,trace)
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
    ensures |trace| == (if filter then 448 else 442)+53*(I.Count(data) as nat)
  {
    state,trace := R.Run(code,data,filter);
    E.WidenTrace(code,R.Destinations(),Destinations(),0,data,trace);
    var selector: Word := if filter then 2005396296 else 3983393726;
    var mode: Word := if filter then 1 else 0;
    var prefix := [selector,518]+R.Fields(data)+[96];
    var next: State;
    var part: seq<State>;
    next,part := C.Run(code,data,Store([],64,128),prefix,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),mode,0);
    E.WidenTrace(code,C.Destinations(),Destinations(),0,data,part);
    E.Join(code,Destinations(),0,data,trace,part);
    trace := trace+part[1..]; state := next;
  }
}
