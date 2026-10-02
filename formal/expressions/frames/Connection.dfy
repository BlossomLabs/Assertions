// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
module ExpressionFramesConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import C = ExpressionCache
  import O = ExpressionOracleModel
  import F = ExpressionFramesModel
  import Source = ExpressionFramesSource
  import G = ExpressionGuardedModel
  import W = ExpressionGuardedEncoding
  import Entry = ExpressionEntryConnection
  import Scalar = ExpressionScalarModel

  lemma MetadataWords(types: seq<Descriptor>, cache: C.Cache)
    requires C.Metadata(types,cache)
    ensures W.WordsFit(cache)
  {
    forall i | 0 <= i < |cache.words|
      ensures Uint(cache.words[i])
    { assert Admissible(types[i]) && Good(types[i]); }
  }

  lemma EntryCache(c: O.Config, types: seq<Descriptor>, initial: C.Cache, f: F.Frame,
                   reject: (nat,E.Value)->E.Error)
    requires E.Program(B.Project(c.nodes)) && |types| == |c.nodes| && C.Valid(types,initial)
    requires forall i :: 0 <= i < |types| ==> Render(types[i]) == c.nodes[i].valueType
    requires forall i: nat,v: E.Value :: i < |c.nodes| ==> B.Bytes(reject(i,v).payload)
    requires f.index < |c.nodes| && E.Good(B.Project(c.nodes),B.Canonical(types),f.memo)
    requires E.Extends(B.View(initial),f.memo)
    ensures C.Valid(types,B.Reify(types,initial,f.memo)) && C.Extends(initial,B.Reify(types,initial,f.memo))
    ensures G.Ready(c,types,B.Reify(types,initial,f.memo),f.index,reject)
    ensures B.View(B.Reify(types,initial,f.memo)) == f.memo
    ensures Entry.CanonicalCache(types,B.Reify(types,initial,f.memo))
  {
    B.ReifyValid(B.Project(c.nodes),types,initial,f.memo);
    var cache := B.Reify(types,initial,f.memo);
    MetadataWords(types,cache);
    Entry.CacheCanonical(types,cache);
    forall i | i in f.memo
      ensures B.View(cache)[i] == f.memo[i]
    { assert B.Bytes(f.memo[i]); assert B.Narrow(f.memo[i]) == f.memo[i]; }
  }

  ghost method Evaluate(c: O.Config, result: nat, hash: seq<Byte>->nat, reject: (nat,E.Value)->E.Error)
    returns (out: Entry.Outcome, frames: seq<F.Frame>, caches: seq<C.Cache>)
    requires forall i :: 0 <= i < |c.nodes| ==> Uint(|c.nodes[i].valueType|)
    requires forall i: nat,v: E.Value :: i < |c.nodes| ==> B.Bytes(reject(i,v).payload)
    ensures out.AdmissionRejected? ==> frames == [] && caches == []
    ensures out.Evaluated? ==> C.Valid(out.types,out.initial) && |out.types| == |c.nodes| && result < |c.nodes|
    ensures out.Evaluated? ==> E.Program(B.Project(c.nodes)) && out.initial == C.Cold(out.types)
    ensures out.Evaluated? ==> out.covered == O.Covered(c,out.execution.history)
    ensures out.Evaluated? && out.covered ==> O.ValidTrace(c,out.execution.history,out.replies)
    ensures out.Evaluated? ==> |frames| > 0 && |frames| == |caches| &&
                               F.Safe(B.Project(c.nodes),B.Canonical(out.types),B.View(out.initial),[],result,frames)
    ensures out.Evaluated? ==> |out.execution.history| == |out.replies|
    ensures out.Evaluated? ==> frames == F.Trace(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,reject,
                                                 O.Replay(out.execution.history,out.replies),result,B.View(out.initial),[],-1)
    ensures out.Evaluated? ==> frames[0] == F.Frame(result,B.View(out.initial),[],-1)
    ensures out.Evaluated? ==> forall j :: 0 <= j < |frames| ==>
                                             G.Ready(c,out.types,caches[j],frames[j].index,reject) &&
                                             Entry.CanonicalCache(out.types,caches[j]) && C.Extends(out.initial,caches[j]) &&
                                             B.View(caches[j]) == frames[j].memo
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
    caches := seq(|frames|, j requires 0 <= j < |frames| => B.Reify(out.types,out.initial,frames[j].memo));
    forall j | 0 <= j < |frames|
      ensures G.Ready(c,out.types,caches[j],frames[j].index,reject) &&
              Entry.CanonicalCache(out.types,caches[j]) && C.Extends(out.initial,caches[j]) &&
              B.View(caches[j]) == frames[j].memo
    { EntryCache(c,out.types,out.initial,frames[j],reject); }
  }
}
