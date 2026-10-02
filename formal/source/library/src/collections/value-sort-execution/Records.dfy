// SPDX-License-Identifier: MIT
include "Replay.dfy"
module CollectionsValueSortExecutionRecords {
  import opened AbiFrames
  import opened CollectionsValueSortExecutionModel
  import Calls = CollectionsCallsConnection
  import Wire = CollectionsWireModel
  import Result = CollectionsCallbackResultsModel
  import Comparator = CollectionsSortComparatorModel
  import S = CollectionsSortComparatorSource
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import T = CollectionsValueSortTraceModel
  lemma RowsLength(rs: seq<Record>)
    ensures |Rows(rs)| == |rs|
    decreases |rs|
  { if |rs| > 0 { RowsLength(rs[1..]); } }
  lemma RowsJoin(a: seq<Record>,b: seq<Record>)
    ensures Rows(a+b) == Rows(a)+Rows(b)
    decreases |a|
  {
    if |a| > 0 {
      RowsJoin(a[1..],b);
      assert (a+b)[0] == a[0];
      assert (a+b)[1..] == a[1..]+b;
      assert Rows(a+b) == [T.Row(a[0].request,Choice(a[0].decision))]+Rows(a[1..]+b);
      assert Rows(a) == [T.Row(a[0].request,Choice(a[0].decision))]+Rows(a[1..]);
      assert Rows(a+b) == Rows(a)+Rows(b);
    } else { assert a == []; assert a+b == b; assert Rows(a) == []; }
  }
  lemma FinalJoin(p: P.Prepared,h: seq<C.Event>,a: seq<Record>,b: seq<Record>)
    ensures FinalPrepared(p,a+b) == FinalPrepared(FinalPrepared(p,a),b)
    ensures FinalHistory(h,a+b) == FinalHistory(FinalHistory(h,a),b)
  {
    if |b| > 0 { assert (a+b)[|a+b|-1] == b[|b|-1]; }
  }
  lemma ChainJoin(k: Config,p: P.Prepared,h: seq<C.Event>,a: seq<Record>,b: seq<Record>)
    requires Chain(k,p,h,a) && T.Clear(Rows(a))
    requires Chain(k,FinalPrepared(p,a),FinalHistory(h,a),b)
    ensures Chain(k,p,h,a+b)
    decreases |a|
  {
    if |a| > 0 {
      var r := a[0];
      assert Rows(a) == [T.Row(r.request,Choice(r.decision))]+Rows(a[1..]);
      assert Rows(a)[0].choice == Choice(r.decision);
      assert r.decision.TakeLeft?;
      forall i | 0 <= i < |Rows(a[1..])|
        ensures Rows(a[1..])[i].choice.Chosen?
      { assert Rows(a[1..])[i] == Rows(a)[i+1]; }
      assert FinalPrepared(p,a) == FinalPrepared(r.out.prepared,a[1..]);
      assert FinalHistory(h,a) == FinalHistory(r.out.history,a[1..]);
      ChainJoin(k,r.out.prepared,r.out.history,a[1..],b);
      assert (a+b)[0] == r;
      assert (a+b)[1..] == a[1..]+b;
      assert Chain(k,p,h,a+b);
    } else { assert a == []; assert a+b == b; assert FinalPrepared(p,a) == p && FinalHistory(h,a) == h; }
  }
  lemma At(k: Config,p: P.Prepared,h: seq<C.Event>,rs: seq<Record>,i: nat)
    requires Chain(k,p,h,rs) && i < |rs|
    ensures Receipt(k,rs[i])
    ensures rs[i].before == (if i == 0 then p else rs[i-1].out.prepared)
    ensures rs[i].history == (if i == 0 then h else rs[i-1].out.history)
    ensures i < |rs|-1 ==> rs[i].decision.TakeLeft?
    ensures Rows(rs)[i] == T.Row(rs[i].request,Choice(rs[i].decision))
    ensures |Rows(rs)| == |rs|
    decreases i
  {
    RowsLength(rs);
    if i > 0 {
      At(k,rs[0].out.prepared,rs[0].out.history,rs[1..],i-1);
      assert rs[1..][i-1] == rs[i];
      if i > 1 { assert rs[1..][i-2] == rs[i-1]; }
    }
  }
  lemma ClearSuffix(prefix: seq<T.Row>,tail: seq<T.Row>)
    requires T.Clear(prefix+tail)
    ensures T.Clear(tail)
  {
    forall i | 0 <= i < |tail| ensures tail[i].choice.Chosen?
    { assert tail[i] == (prefix+tail)[|prefix|+i]; }
  }

  lemma Summary(k: Config,p: P.Prepared,h: seq<C.Event>,rs: seq<Record>)
    requires Chain(k,p,h,rs)
    ensures h <= FinalHistory(h,rs) && FinalPrepared(p,rs).plan == p.plan
    ensures Calls.Targets(FinalHistory(h,rs)) == Calls.Targets(h)+(if p.targetChecked || |rs| == 0 then [] else [k.cb.target])
    ensures |Calls.Calls(h)| <= |Calls.Calls(FinalHistory(h,rs))| <= |Calls.Calls(h)|+|rs|
    ensures T.Clear(Rows(rs)) ==> |Calls.Calls(FinalHistory(h,rs))| == |Calls.Calls(h)|+|rs|
    decreases |rs|
  {
    if |rs| == 0 { return; }
    var r := rs[0];
    reveal Receipt();
    assert r.before == p && r.history == h;
    assert Rows(rs)[0].choice == Choice(r.decision);
    if r.decision.Failure? { assert |rs| == 1; return; }
    assert r.out.Returned? && r.out.prepared.targetChecked;
    Summary(k,r.out.prepared,r.out.history,rs[1..]);
    assert FinalPrepared(p,rs) == FinalPrepared(r.out.prepared,rs[1..]);
    assert FinalHistory(h,rs) == FinalHistory(r.out.history,rs[1..]);
    if T.Clear(Rows(rs)) { ClearSuffix([Rows(rs)[0]],Rows(rs[1..])); }
  }
  lemma Meaning(k: Config,r: Record)
    requires Receipt(k,r)
    ensures r.decision.TakeLeft? == (r.out.Returned? && |r.out.value| == 32)
    ensures r.decision.TakeLeft? ==> r.decision.value == Comparator.NonPositive(r.out.value)
    ensures r.out.Failed? ==> r.decision.Failure? && r.decision.reason == Wire.ErrorBytes(r.out.error)
    ensures r.out.Returned? && |r.out.value| != 32 ==> r.decision.Failure? && r.decision.reason == Result.InvalidBytes(Result.Context(S.Operation(),r.request.a,r.request.b,k.cb.target))
  { reveal Receipt(); }

}
