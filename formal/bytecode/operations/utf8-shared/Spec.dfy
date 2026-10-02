// SPDX-License-Identifier: MIT
// Independent finite UTF-8 unit grammar and exact error positions; native pending.
include "../../scans/Machine.dfy"
module OperationsUtf8Inputs {
  import S = BytecodeScanMachine
  function Width(first:S.Byte):nat {
    if first<128 then 1 else if 194<=first<=223 then 2 else if 224<=first<=239 then 3 else if 240<=first<=244 then 4 else 0
  }
  function Low(first:S.Byte):nat { if first==224 then 160 else if first==240 then 144 else 128 }
  function High(first:S.Byte):nat { if first==237 then 159 else if first==244 then 143 else 191 }
  predicate Continuation(cell:S.Byte) { 128<=cell<=191 }
  predicate UnitGrammar(payload:seq<S.Byte>,at:nat,width:nat) {
    at<|payload| && width==Width(payload[at]) && 1<=width<=4 && at+width<=|payload| &&
    (width==1 || Low(payload[at])<=payload[at+1]<=High(payload[at])) &&
    (width<3 || Continuation(payload[at+2])) && (width<4 || Continuation(payload[at+3]))
  }
  datatype UnitResult = Good(width:nat) | Bad(at:nat)
  function Unit(payload:seq<S.Byte>,at:nat):UnitResult
    requires at<|payload|
    ensures Unit(payload,at).Good? ==> UnitGrammar(payload,at,Unit(payload,at).width)
    ensures Unit(payload,at).Bad? ==> at<=Unit(payload,at).at<|payload|
  {
    var width:=Width(payload[at]);
    if width==0 || at+width>|payload| then Bad(at)
    else if width==1 then Good(1)
    else if payload[at+1]<Low(payload[at]) || payload[at+1]>High(payload[at]) then Bad(at+1)
    else if width>=3 && !Continuation(payload[at+2]) then Bad(at+2)
    else if width==4 && !Continuation(payload[at+3]) then Bad(at+3)
    else Good(width)
  }
  datatype Verdict = Valid | Invalid(at:nat)
  function Check(payload:seq<S.Byte>,at:nat):Verdict
    requires at<=|payload|
    ensures Check(payload,at).Invalid? ==> at<=Check(payload,at).at<|payload|
    decreases |payload|-at
  {
    if at==|payload| then Valid
    else var unit:=Unit(payload,at);
         if unit.Bad? then Invalid(unit.at) else Check(payload,at+unit.width)
  }
  predicate Grammar(payload:seq<S.Byte>,at:nat)
    requires at<=|payload|
    decreases |payload|-at
  {
    at==|payload| || (UnitGrammar(payload,at,Width(payload[at])) && Grammar(payload,at+Width(payload[at])))
  }
  lemma UnitExact(payload:seq<S.Byte>,at:nat)
    requires at<|payload|
    ensures Unit(payload,at).Good? <==> UnitGrammar(payload,at,Width(payload[at]))
  {}
  lemma Characterization(payload:seq<S.Byte>,at:nat)
    requires at<=|payload|
    ensures Check(payload,at)==Valid <==> Grammar(payload,at)
    decreases |payload|-at
  {
    if at<|payload| {
      UnitExact(payload,at);var unit:=Unit(payload,at);
      if unit.Good? { Characterization(payload,at+unit.width); }
    }
  }
}
