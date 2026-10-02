// SPDX-License-Identifier: MIT
// Physical public prefix to successful shared raw decoding and ordered body admission.
include "../map-prefix/Prefix.generated.dfy"
include "../filter-prefix/Prefix.generated.dfy"
include "../decoder-invocation/Map.generated.dfy"
include "../decoder-invocation/Filter.generated.dfy"
include "../raw-decoder/Accepted.generated.dfy"
include "../decoded-admission/Connection.dfy"
module BytecodeApplyRawAdmission {
  import opened BytecodeScanMachine
  import E = BytecodeScanExecution
  import I = BytecodeApplyRawInputs
  import W = BytecodeApplyWindowInputs
  import MP = BytecodeWordMapPrefix
  import FP = BytecodeWordFilterPrefix
  import MD = BytecodeApplyDecodeInvokeMap
  import FD = BytecodeApplyDecodeInvokeFilter
  import D = BytecodeApplyDecoderAccepted
  import A = BytecodeApplyDecodedAdmission
  predicate Matches(code: seq<Byte>) { MP.Matches(code) && FP.Matches(code) && MD.Matches(code) && FD.Matches(code) && D.Matches(code) && A.Matches(code) }
  function Destinations(): set<nat> { MP.Destinations()+FP.Destinations()+MD.Destinations()+FD.Destinations()+D.Destinations()+A.Destinations() }
  function Fields(data: seq<Byte>): seq<Word> { [I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data)] }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,filter: bool)
    returns (state: State,trace: seq<State>)
    requires Matches(code) && I.Fits(data)
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    requires I.SourceLength(data)%32 == 0
    requires W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    ensures state == Running(12235,[if filter then 2005396296 else 3983393726,518]+Fields(data)+[96,5526]+Fields(data)+[if filter then 1 else 0,96],Store([],64,128))
    ensures E.Trace(code,Destinations(),0,data,trace)
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
    ensures |trace| == (if filter then 417 else 411)+53*(I.Count(data) as nat)
  {
    var selector: Word := if filter then 2005396296 else 3983393726;
    var returnPc: Word := if filter then 784 else 1050;
    var mem := Store([],64,128);
    if filter {
      state,trace := FP.Run(code,0,data);
      E.WidenTrace(code,FP.Destinations(),Destinations(),0,data,trace);
    } else {
      state,trace := MP.Run(code,0,data);
      E.WidenTrace(code,MP.Destinations(),Destinations(),0,data,trace);
    }
    var next: State;
    var part: seq<State>;
    if filter {
      next,part := FD.Run(code,data,mem,[selector],0);
      E.WidenTrace(code,FD.Destinations(),Destinations(),0,data,part);
    } else {
      next,part := MD.Run(code,data,mem,[selector],0);
      E.WidenTrace(code,MD.Destinations(),Destinations(),0,data,part);
    }
    E.Join(code,Destinations(),0,data,trace,part);
    trace := trace+part[1..]; state := next;
    next,part := D.Run(code,data,mem,[selector,518],returnPc,0);
    E.WidenTrace(code,D.Destinations(),Destinations(),0,data,part);
    E.Join(code,Destinations(),0,data,trace,part);
    trace := trace+part[1..]; state := next;
    next,part := A.Run(code,data,mem,[selector,518],I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),filter,0);
    E.WidenTrace(code,A.Destinations(),Destinations(),0,data,part);
    E.Join(code,Destinations(),0,data,trace,part);
    trace := trace+part[1..]; state := next;
  }
}
