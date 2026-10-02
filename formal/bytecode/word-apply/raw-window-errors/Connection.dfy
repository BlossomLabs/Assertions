// SPDX-License-Identifier: MIT
// Raw decoder/alignment then the actual first window rejection.
include "../raw-window-prefix/Connection.dfy"
include "../window-rejection/Engine.dfy"
include "Witness.dfy"
module BytecodeApplyRawWindowErrors {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import I = BytecodeApplyRawInputs
  import W = BytecodeApplyWindowInputs
  import MP = BytecodeWordMapPrefix
  import FP = BytecodeWordFilterPrefix
  import R = BytecodeApplyRawWindowPrefix
  import B = BytecodeApplyWindowRejection
  import F = BytecodeApplyFirstInvalidWindow
  import E = BytecodeScanExecution
  predicate Matches(code: seq<Byte>) { R.Matches(code) && B.Matches(code) }
  function Destinations(): set<nat> { R.Destinations()+B.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,filter: bool) returns (state: State,trace: seq<State>,bad: Word)
    requires Matches(code) && I.Fits(data) && I.SourceLength(data)%32 == 0
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    requires !W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    ensures I.TemplateLength(data) < 32 ==> bad == 0
    ensures I.TemplateLength(data) >= 32 ==> bad < I.Count(data) && W.At(I.Offset(I.ArrayHead(data)),bad,data) > I.TemplateLength(data)-32
    ensures I.TemplateLength(data) >= 32 ==> forall j: nat :: j < bad ==> W.At(I.Offset(I.ArrayHead(data)),j,data) <= I.TemplateLength(data)-32
    ensures state == Reverted(G.Encode(0x1a0d83de,4)+G.Encode(if I.TemplateLength(data) < 32 then 0 else W.At(I.Offset(I.ArrayHead(data)),bad,data),32)+G.Encode(I.TemplateLength(data),32))
    ensures E.Trace(code,Destinations(),0,data,trace)
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
    ensures |trace| == (if I.TemplateLength(data) < 32 then (if filter then 431 else 425) else (if filter then 499 else 493)+53*(bad as nat))
  {
    state,trace := R.Run(code,data,filter);
    E.WidenTrace(code,R.Destinations(),Destinations(),0,data,trace);
    var selector: Word := if filter then 2005396296 else 3983393726;
    var prefix := [selector,518]+R.Fields(data)+[96,5526]+R.Fields(data)+[if filter then 1 else 0,96];
    W.RawFrame(data);
    var part: seq<State>;
    if I.TemplateLength(data) < 32 {
      bad := 0;
      state,part := B.Short(code,data,prefix,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),0);
    } else {
      bad := F.Find(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data);
      state,part := B.Bad(code,data,prefix,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),bad,0);
    }
    E.WidenTrace(code,B.Destinations(),Destinations(),0,data,part);
    E.Join(code,Destinations(),0,data,trace,part); trace := trace+part[1..];
  }
}
