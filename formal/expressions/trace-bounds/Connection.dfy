// SPDX-License-Identifier: MIT
include "Bounds.dfy"
module ExpressionTraceBoundsConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiByteSemantics
  import E = ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import B = ExpressionEvaluationBridge
  import C = ExpressionCache
  import O = ExpressionOracleModel
  import G = ExpressionGuardedModel
  import Entry = ExpressionEntryConnection
  import F = ExpressionFramesModel
  import Source = ExpressionFramesSource
  import Cache = ExpressionFramesConnection
  import Scalar = ExpressionScalarModel
  import Bounds = ExpressionTraceBounds
  import Context = ExpressionContextConnection
  import Shift = ExpressionContextShift

  lemma Prefix(c: O.Config, trace: seq<E.Request>, replies: seq<O.Reply>, prefix: seq<E.Request>)
    requires O.Covered(c,trace) && O.ValidTrace(c,trace,replies) && prefix <= trace
    ensures O.Covered(c,prefix) && O.ValidTrace(c,prefix,replies[..|prefix|])
  {
    forall i | 0 <= i < |prefix|
      ensures O.Eligible(c,prefix[i],prefix[..i]) && O.Matches(c,prefix[i],prefix[..i],replies[i])
    { assert prefix[i] == trace[i] && prefix[..i] == trace[..i]; }
  }
  ghost function Local(c: O.Config, types: seq<Descriptor>, cache: C.Cache, f: F.Frame,
                       reject: (nat,E.Value)->E.Error, trace: seq<E.Request>, replies: seq<O.Reply>): E.Result
    requires G.Ready(c,types,cache,f.index,reject) && B.View(cache) == f.memo
    requires |trace| == |replies| && f.history <= trace
  {
    S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,
               O.Replay(trace[|f.history|..],replies[|f.history|..]),f.index,f.memo,[])
  }
  lemma Window(c: O.Config, types: seq<Descriptor>, cache: C.Cache, f: F.Frame,
               reject: (nat,E.Value)->E.Error, trace: seq<E.Request>, replies: seq<O.Reply>)
    requires G.Ready(c,types,cache,f.index,reject) && B.View(cache) == f.memo
    requires O.Covered(c,trace) && O.ValidTrace(c,trace,replies) && f.history <= trace
    requires S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),f.index,f.memo,f.history).history <= trace
    ensures f.history+Local(c,types,cache,f,reject,trace,replies).history <= trace
    ensures O.Covered(Context.At(c,f.history),Local(c,types,cache,f,reject,trace,replies).history)
    ensures O.ValidTrace(Context.At(c,f.history),Local(c,types,cache,f,reject,trace,replies).history,
                         replies[|f.history|..|f.history|+|Local(c,types,cache,f,reject,trace,replies).history|])
    ensures Shift.ResultAt(f.history,Local(c,types,cache,f,reject,trace,replies)) ==
            S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),f.index,f.memo,f.history)
  {
    Context.FromTrace(c,types,cache,f.index,f.history,reject,trace,replies);
    var local := Local(c,types,cache,f,reject,trace,replies);
    assert f.history+local.history <= trace;
    assert local.history <= trace[|f.history|..];
    Prefix(Context.At(c,f.history),trace[|f.history|..],replies[|f.history|..],local.history);
    assert replies[|f.history|..][..|local.history|] == replies[|f.history|..|f.history|+|local.history|];
  }

  ghost method Evaluate(c: O.Config, result: nat, hash: seq<Byte>->nat, reject: (nat,E.Value)->E.Error)
    returns (out: Entry.Outcome, frames: seq<F.Frame>, caches: seq<C.Cache>)
    requires forall i :: 0 <= i < |c.nodes| ==> Uint(|c.nodes[i].valueType|)
    requires forall i: nat,v: E.Value :: i < |c.nodes| ==> B.Bytes(reject(i,v).payload)
    ensures out.AdmissionRejected? ==> frames == [] && caches == []
    ensures out.Evaluated? ==> C.Valid(out.types,out.initial) && |out.types| == |c.nodes| && result < |c.nodes|
    ensures out.Evaluated? ==> E.Program(B.Project(c.nodes)) && |out.execution.history| == |out.replies|
    ensures out.Evaluated? ==> |frames| > 0 && |frames| == |caches|
    ensures out.Evaluated? ==> frames == F.Trace(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,reject,
                                                 O.Replay(out.execution.history,out.replies),result,B.View(out.initial),[],-1)
    ensures out.Evaluated? ==> Bounds.Within(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,reject,
                                             O.Replay(out.execution.history,out.replies),frames,[],out.execution.history)
    ensures out.Evaluated? ==> forall j :: 0 <= j < |frames| ==>
                                             G.Ready(c,out.types,caches[j],frames[j].index,reject) &&
                                             Entry.CanonicalCache(out.types,caches[j]) && C.Extends(out.initial,caches[j]) &&
                                             B.View(caches[j]) == frames[j].memo
    ensures out.Evaluated? && out.covered ==> forall j :: 0 <= j < |frames| ==>
                                                            var f := frames[j];
                                                            var local := Local(c,out.types,caches[j],f,reject,out.execution.history,out.replies);
                                                            f.history+local.history <= out.execution.history &&
                                                            O.Covered(Context.At(c,f.history),local.history) &&
                                                            O.ValidTrace(Context.At(c,f.history),local.history,out.replies[|f.history|..|f.history|+|local.history|]) &&
                                                            Shift.ResultAt(f.history,local) == S.Evaluate(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,reject,
                                                                                                          O.Replay(out.execution.history,out.replies),f.index,f.memo,f.history)
  {
    out := Entry.Evaluate(c,result,hash,reject);
    frames := []; caches := [];
    if out.AdmissionRejected? { return; }
    B.ViewValid(B.Project(c.nodes),out.types,out.initial);
    var replay := O.Replay(out.execution.history,out.replies);
    var confirmed;
    confirmed,frames := Source.Run(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,reject,replay,
                                   result,B.View(out.initial),[],-1);
    assert confirmed == out.execution;
    Bounds.Evaluate(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,reject,replay,result,B.View(out.initial),[],-1);
    caches := seq(|frames|, j requires 0 <= j < |frames| => B.Reify(out.types,out.initial,frames[j].memo));
    forall j | 0 <= j < |frames|
      ensures G.Ready(c,out.types,caches[j],frames[j].index,reject) &&
              Entry.CanonicalCache(out.types,caches[j]) && C.Extends(out.initial,caches[j]) && B.View(caches[j]) == frames[j].memo
    { Cache.EntryCache(c,out.types,out.initial,frames[j],reject); }
    if out.covered {
      forall j | 0 <= j < |frames|
        ensures var f := frames[j];
                var local := Local(c,out.types,caches[j],f,reject,out.execution.history,out.replies);
                f.history+local.history <= out.execution.history &&
                O.Covered(Context.At(c,f.history),local.history) &&
                O.ValidTrace(Context.At(c,f.history),local.history,out.replies[|f.history|..|f.history|+|local.history|]) &&
                Shift.ResultAt(f.history,local) == S.Evaluate(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,reject,
                                                              replay,f.index,f.memo,f.history)
      { Window(c,out.types,caches[j],frames[j],reject,out.execution.history,out.replies); }
    }
  }
}
