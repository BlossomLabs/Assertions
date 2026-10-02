// SPDX-License-Identifier: MIT
include "Records.dfy"
module CollectionsValueSortExecutionConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import opened CollectionsValueSortExecutionModel
  import Calls = CollectionsCallsConnection
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import K = CollectionsCodecStateModel
  import A = AbiConstructionModel
  import B = CollectionsBoundCallModel
  import R = CollectionsCallbackResultsModel
  import S = CollectionsSortComparatorSource
  import Compare = CollectionsSortComparatorConnection
  import T = CollectionsValueSortTraceModel
  import Proof = CollectionsValueSortTraceProperties
  import Records = CollectionsValueSortExecutionRecords
  import Source = CollectionsValueSortTraceConnection
  import Members = CollectionsSortMerge
  import Core = CollectionsSortModel
  import Replay = CollectionsValueSortExecutionReplay

  ghost method Step(k: Config,p: P.Prepared,h: seq<C.Event>,q: T.Request,fuel: nat) returns (r: Record)
    requires RequestIn(k,q) && fuel > 0 && Budget(k,fuel,p,h)
    ensures Receipt(k,r) && r.before == p && r.history == h && r.request == q
    ensures r.decision.TakeLeft? ==> Budget(k,fuel-1,r.out.prepared,r.out.history)
  {
    assert LocalRoom(k,p,h,q) by { reveal Budget(); }
    var r1,r2,env,out,decision := Compare.Run(k.fs,p.args,p.targetChecked,k.cb,Context(q),k.values[q.left],k.values[q.right],h,k.base);
    var same := Calls.Run(k.cb,p,Context(q),k.values[q.left],k.values[q.right],true,h,env);
    r := Record(q,p,h,r1,r2,env,out,decision);
    assert Receipt(k,r) by { reveal Receipt(); }
    if decision.TakeLeft? { reveal Budget(); }
  }

  ghost method Merge(k: Config,source: seq<nat>,middle: nat,end: nat,a: nat,b: nat,before: seq<T.Row>,p: P.Prepared,h: seq<C.Event>,fuel: nat)
    returns (env: T.Environment,out: T.Outcome,records: seq<Record>,prepared: P.Prepared,history: seq<C.Event>)
    requires a <= middle <= b <= end <= |source| == |k.values|
    requires forall i :: 0 <= i < |source| ==> source[i] < |k.values|
    requires fuel >= middle-a+end-b && Budget(k,fuel,p,h)
    requires T.Clear(before)
    ensures out == T.Merge(source,middle,end,a,b,before,env)
    ensures out.trace == before+Rows(records)
    ensures Chain(k,p,h,records) && |records| <= middle-a+end-b
    ensures prepared == FinalPrepared(p,records) && history == FinalHistory(h,records)
    ensures out.Success? ==> Budget(k,fuel-|records|,prepared,history)
    ensures out.Failure? ==> |records| > 0 && records[|records|-1].decision.Failure? && records[|records|-1].decision.reason == out.reason
    decreases middle-a+end-b
  {
    env := (t: seq<T.Row>,q: T.Request) => T.Chosen(true);
    records := []; prepared := p; history := h;
    if a == middle || b == end { out := T.Merge(source,middle,end,a,b,before,env); return; }
    var q := T.Request(a,b,source[a],source[b]);
    var r := Step(k,p,h,q,fuel);
    var choice := Choice(r.decision);
    var next := before+[T.Row(q,choice)];
    if choice.Rejected? {
      env := (t: seq<T.Row>,q: T.Request) => choice;
      records := [r]; prepared := r.out.prepared; history := r.out.history;
      out := T.Failure(choice.reason,next);
      return;
    }
    var nextA := if choice.left then a+1 else a;
    var nextB := if choice.left then b else b+1;
    assert T.Clear(next);
    var tailEnv,tail,rest;
    tailEnv,tail,rest,prepared,history := Merge(k,source,middle,end,nextA,nextB,next,r.out.prepared,r.out.history,fuel-1);
    env := Splice(choice,tailEnv,|next|);
    assert Future(tailEnv,env,|next|);
    Replay.Merge(source,middle,end,nextA,nextB,next,tailEnv,env);
    records := [r]+rest;
    out := T.Prepend([if choice.left then source[a] else source[b]],tail);
    assert Rows(records) == [T.Row(q,choice)]+Rows(rest);
    if |rest| > 0 { assert records[|records|-1] == rest[|rest|-1]; }
  }
  ghost method Pass(k: Config,source: seq<nat>,width: nat,start: nat,before: seq<T.Row>,p: P.Prepared,h: seq<C.Event>,fuel: nat)
    returns (env: T.Environment,out: T.Outcome,records: seq<Record>,prepared: P.Prepared,history: seq<C.Event>)
    requires width > 0 && |source| == |k.values|
    requires forall i :: 0 <= i < |source| ==> source[i] < |k.values|
    requires fuel >= |source|-Core.Min(start,|source|) && Budget(k,fuel,p,h)
    requires T.Clear(before)
    ensures out == T.Pass(source,width,start,before,env)
    ensures out.trace == before+Rows(records)
    ensures Chain(k,p,h,records) && |records| <= |source|-Core.Min(start,|source|)
    ensures prepared == FinalPrepared(p,records) && history == FinalHistory(h,records)
    ensures out.Success? ==> Budget(k,fuel-|records|,prepared,history)
    ensures out.Failure? ==> |records| > 0 && records[|records|-1].decision.Failure? && records[|records|-1].decision.reason == out.reason
    decreases |source|-start
  {
    env := (t: seq<T.Row>,q: T.Request) => T.Chosen(true);
    records := []; prepared := p; history := h;
    if start >= |source| { out := T.Success([],before); return; }
    var middle := Core.Min(start+width,|source|);
    var end := Core.Min(start+2*width,|source|);
    var firstEnv,one,first,nextP,nextH := Merge(k,source,middle,end,start,middle,before,p,h,fuel);
    if one.Failure? { env := firstEnv; out := one; records := first; prepared := nextP; history := nextH; return; }
    Proof.MergeFacts(source,middle,end,start,middle,before,firstEnv,(x: nat,y: nat)=>true);
    var tailEnv,tail,rest;
    tailEnv,tail,rest,prepared,history := Pass(k,source,width,start+2*width,one.trace,nextP,nextH,fuel-|first|);
    env := Join(firstEnv,tailEnv,|one.trace|);
    assert Window(firstEnv,env,|before|,|one.trace|);
    Replay.MergeWindow(source,middle,end,start,middle,before,firstEnv,env,|one.trace|);
    assert Window(tailEnv,env,|one.trace|,|tail.trace|);
    Replay.PassWindow(source,width,start+2*width,one.trace,tailEnv,env,|tail.trace|);
    records := first+rest; out := T.Prepend(one.ids,tail);
    Records.RowsJoin(first,rest);
    Records.ClearSuffix(before,Rows(first));
    Records.ChainJoin(k,p,h,first,rest); Records.FinalJoin(p,h,first,rest);
    if |rest| > 0 { assert records[|records|-1] == rest[|rest|-1]; }
  }

  function Cost(n: nat,width: nat): nat { n*(n-Core.Min(n,width)) }
  lemma CostStep(n: nat,width: nat)
    requires 0 < width < n
    ensures n+Cost(n,2*width) <= Cost(n,width)
  {
    if 2*width < n {
      assert n+Cost(n,2*width) == Cost(n,width)-n*(width-1);
    } else { assert n*(n-width-1) >= 0; }
  }

  ghost method Sort(k: Config,source: seq<nat>,width: nat,before: seq<T.Row>,p: P.Prepared,h: seq<C.Event>,fuel: nat)
    returns (env: T.Environment,out: T.Outcome,records: seq<Record>,prepared: P.Prepared,history: seq<C.Event>)
    requires width > 0 && |source| == |k.values|
    requires forall i :: 0 <= i < |source| ==> source[i] < |k.values|
    requires fuel >= Cost(|source|,width) && Budget(k,fuel,p,h)
    requires T.Clear(before)
    ensures out == T.Sort(source,width,before,env)
    ensures out.trace == before+Rows(records)
    ensures Chain(k,p,h,records) && |records| <= Cost(|source|,width)
    ensures prepared == FinalPrepared(p,records) && history == FinalHistory(h,records)
    ensures out.Success? ==> Budget(k,fuel-|records|,prepared,history)
    ensures out.Failure? ==> |records| > 0 && records[|records|-1].decision.Failure? && records[|records|-1].decision.reason == out.reason
    decreases |source|-width
  {
    env := (t: seq<T.Row>,q: T.Request) => T.Chosen(true);
    records := []; prepared := p; history := h;
    if width >= |source| { out := T.Success(source,before); return; }
    CostStep(|source|,width);
    var firstEnv,one,first,nextP,nextH := Pass(k,source,width,0,before,p,h,fuel);
    if one.Failure? { env := firstEnv; out := one; records := first; prepared := nextP; history := nextH; return; }
    Proof.PassFacts(source,width,0,before,firstEnv,(x: nat,y: nat)=>true);
    assert |one.ids| == |source|;
    forall i | 0 <= i < |one.ids| ensures one.ids[i] < |k.values|
    {
      Members.SameMember(one.ids,source,one.ids[i]);
      var j :| 0 <= j < |source| && source[j] == one.ids[i];
    }
    var tailEnv,tail,rest;
    tailEnv,tail,rest,prepared,history := Sort(k,one.ids,2*width,one.trace,nextP,nextH,fuel-|first|);
    env := Join(firstEnv,tailEnv,|one.trace|);
    assert Window(firstEnv,env,|before|,|one.trace|);
    Replay.PassWindow(source,width,0,before,firstEnv,env,|one.trace|);
    assert Window(tailEnv,env,|one.trace|,|tail.trace|);
    Replay.SortWindow(one.ids,2*width,one.trace,tailEnv,env,|tail.trace|);
    records := first+rest; out := tail;
    Records.RowsJoin(first,rest);
    Records.ClearSuffix(before,Rows(first));
    Records.ChainJoin(k,p,h,first,rest); Records.FinalJoin(p,h,first,rest);
    if |rest| > 0 { assert records[|records|-1] == rest[|rest|-1]; }
  }

  ghost method Run(k: Config,p: P.Prepared,h: seq<C.Event>,le: (nat,nat)->bool)
    returns (env: T.Environment,out: T.Outcome,records: seq<Record>,prepared: P.Prepared,history: seq<C.Event>)
    requires T.CountRoom(|k.values|) && Budget(k,Cost(|k.values|,1),p,h)
    ensures out == T.Sort(Core.Range(0,|k.values|),1,[],env)
    ensures out.trace == Rows(records) && Chain(k,p,h,records)
    ensures prepared == FinalPrepared(p,records) && history == FinalHistory(h,records)
    ensures |records| <= Cost(|k.values|,1)
    ensures h <= history && prepared.plan == p.plan
    ensures Calls.Targets(history) == Calls.Targets(h)+(if p.targetChecked || |records| == 0 then [] else [k.cb.target])
    ensures |Calls.Calls(h)| <= |Calls.Calls(history)| <= |Calls.Calls(h)|+|records|
    ensures out.Success? ==> |Calls.Calls(history)| == |Calls.Calls(h)|+|records|
    ensures T.Stopped(out)
    ensures out.Success? ==> |out.ids| == |k.values| && multiset(out.ids) == multiset(Core.Range(0,|k.values|))
    ensures out.Success? ==> (forall i :: 0 <= i < |out.ids| ==> out.ids[i] < |k.values|)
    ensures out.Success? ==> (forall i,j :: 0 <= i < j < |out.ids| ==> out.ids[i] != out.ids[j])
    ensures out.Success? && T.Coherent(out.trace,le) && Core.Order(|k.values|,le) ==>
              (forall i,j :: 0 <= i < j < |out.ids| ==> le(out.ids[i],out.ids[j]) && (le(out.ids[j],out.ids[i]) ==> out.ids[i] < out.ids[j]))
    ensures out.Failure? ==> |records| > 0 && records[|records|-1].decision.Failure? && records[|records|-1].decision.reason == out.reason
    ensures |k.values| < 2 ==> out == T.Success(Core.Range(0,|k.values|),[]) && records == [] && prepared == p && history == h
  {
    env,out,records,prepared,history := Sort(k,Core.Range(0,|k.values|),1,[],p,h,Cost(|k.values|,1));
    var sourceOut := Source.Run(|k.values|,env,le);
    Records.Summary(k,p,h,records);
  }

}
