// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsRepeatedCallConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import opened CollectionsRepeatedCallModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import A = AbiConstructionModel
  import K = CollectionsCodecStateModel
  import V = AbiConstructionContext
  import Call = CollectionsBoundCallConnection
  import Facts = CollectionsCallsConnection

  lemma Overwrite(cb: C.Callback, args: seq<seq<Byte>>, first: Step, next: Step, binary: bool)
    requires cb.first < |args| && (binary ==> cb.second < |args| && cb.first != cb.second)
    ensures Replace(cb,Replace(cb,args,first,binary),next,binary) == Replace(cb,args,next,binary)
  {}
  lemma RoomTail(fs: seq<Descriptor>, cb: C.Callback, args: seq<seq<Byte>>, steps: seq<Step>, binary: bool)
    requires cb.first < |fs| && |args| == |fs| && (binary ==> cb.second < |fs| && cb.first != cb.second)
    requires |steps| > 0 && Room(fs,cb,args,steps,binary)
    ensures Room(fs,cb,Replace(cb,args,steps[0],binary),steps[1..],binary)
  {
    forall i | 0 <= i < |steps|-1
      ensures Replace(cb,Replace(cb,args,steps[0],binary),steps[1..][i],binary) == Replace(cb,args,steps[i+1],binary)
    { Overwrite(cb,args,steps[0],steps[i+1],binary); }
  }
  lemma FinalCons(first: Record, rest: seq<Record>)
    ensures FinalState([first]+rest,first.before) == FinalState(rest,first.out.prepared)
    ensures FinalHistory([first]+rest,first.history) == FinalHistory(rest,first.out.history)
  {}

  lemma At(cb: C.Callback, steps: seq<Step>, binary: bool, p: P.Prepared, h: seq<C.Event>, records: seq<Record>, i: nat)
    requires Chain(cb,steps,binary,p,h,records) && i < |records|
    ensures i < |steps|
    ensures C.Admitted(records[i].env) && C.Valid(cb,records[i].before,binary)
    ensures records[i].out == C.Run(cb,records[i].before,steps[i].context,steps[i].a,steps[i].b,binary,records[i].history,records[i].env)
    ensures records[i].before == (if i == 0 then p else records[i-1].out.prepared)
    ensures records[i].history == (if i == 0 then h else records[i-1].out.history)
    decreases i
  {
    if i > 0 {
      At(cb,steps[1..],binary,records[0].out.prepared,records[0].out.history,records[1..],i-1);
    }
  }

  ghost method Run(fs: seq<Descriptor>, cb: C.Callback, args: seq<seq<Byte>>, flag: bool, steps: seq<Step>, binary: bool, h: seq<C.Event>, base: C.Environment) returns (records: seq<Record>)
    requires Admissible(Group(fs)) && Uint(|Render(Group(fs))|) && Uint(32*WidthSum(fs))
    requires cb.descriptor == Render(Group(fs)) && cb.first < |fs| && (binary ==> cb.second < |fs| && cb.first != cb.second)
    requires K.CanonicalExcept(fs,args,if binary then {cb.first,cb.second} else {cb.first})
    requires Room(fs,cb,args,steps,binary) && |cb.selector| == 4 && cb.target < Pow256(20)
    ensures Chain(cb,steps,binary,P.Prepared(K.Plan(fs),args,flag),h,records)
    ensures |records| <= |steps| && (|records| == 0) == (|steps| == 0)
    ensures Success(records) ==> |records| == |steps|
    ensures forall i :: 0 <= i < |records|-1 ==> records[i].out.Returned?
    ensures !Success(records) ==> |records| > 0 && records[|records|-1].out.Failed?
    ensures forall i :: 0 <= i < |records| && records[i].out.Returned? ==> A.ValidInputs(fs,records[i].out.prepared.args) && records[i].out.prepared.targetChecked
    ensures FinalState(records,P.Prepared(K.Plan(fs),args,flag)).plan == K.Plan(fs)
    ensures Facts.Targets(FinalHistory(records,h)) == Facts.Targets(h)+(if flag || |steps| == 0 then [] else [cb.target])
    ensures |Facts.Calls(h)| <= |Facts.Calls(FinalHistory(records,h))| <= |Facts.Calls(h)|+|records|
    ensures Success(records) ==> |Facts.Calls(FinalHistory(records,h))| == |Facts.Calls(h)|+|records|
    ensures h <= FinalHistory(records,h)
    decreases |steps|
  {
    records := [];
    if |steps| == 0 { return; }
    var r1: V.Result; var r2: V.Result; var env: C.Environment; var out: C.Outcome;
    r1,r2,env,out := Call.Run(fs,args,flag,cb,steps[0].context,steps[0].a,steps[0].b,binary,h,base);
    var same := Facts.Run(cb,P.Prepared(K.Plan(fs),args,flag),steps[0].context,steps[0].a,steps[0].b,binary,h,env);
    var first := Record(P.Prepared(K.Plan(fs),args,flag),h,env,out);
    records := [first];
    if out.Failed? { return; }
    RoomTail(fs,cb,args,steps,binary);
    var rest := Run(fs,cb,out.prepared.args,true,steps[1..],binary,out.history,base);
    records := [first]+rest;
    FinalCons(first,rest);
  }
}
