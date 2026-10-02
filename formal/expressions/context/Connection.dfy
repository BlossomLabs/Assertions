// SPDX-License-Identifier: MIT
include "Shift.dfy"
module ExpressionContextConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import E = ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import B = ExpressionEvaluationBridge
  import C = ExpressionCache
  import O = ExpressionOracleModel
  import G = ExpressionGuardedModel
  import Entry = ExpressionEntryConnection
  import Scalar = ExpressionScalarModel
  import H = ExpressionContextShift
  import Stable = ExpressionOracleStability

  function At(c: O.Config, prefix: seq<E.Request>): O.Config {
    O.Config(c.nodes,c.parameters,c.core,c.self,c.resolveSelector,c.guard,c.decode,
             (q: E.Request,h: seq<E.Request>) => c.frames(q,prefix+h))
  }
  lemma Observations(c: O.Config, prefix: seq<E.Request>, q: E.Request, h: seq<E.Request>)
    ensures At(c,prefix).frames(q,h) == c.frames(q,prefix+h)
    ensures O.Eligible(At(c,prefix),q,h) == O.Eligible(c,q,prefix+h)
  {}
  lemma Receipt(c: O.Config, prefix: seq<E.Request>, q: E.Request, h: seq<E.Request>, reply: O.Reply)
    requires O.Eligible(c,q,prefix+h)
    ensures O.Eligible(At(c,prefix),q,h)
    ensures O.Matches(At(c,prefix),q,h,reply) == O.Matches(c,q,prefix+h,reply)
  { Observations(c,prefix,q,h); }

  lemma Suffix(c: O.Config, trace: seq<E.Request>, replies: seq<O.Reply>, prefix: seq<E.Request>)
    requires O.Covered(c,trace) && O.ValidTrace(c,trace,replies) && prefix <= trace
    ensures O.Covered(At(c,prefix),trace[|prefix|..])
    ensures O.ValidTrace(At(c,prefix),trace[|prefix|..],replies[|prefix|..])
  {
    var suffix := trace[|prefix|..];
    forall i | 0 <= i < |suffix|
      ensures O.Eligible(At(c,prefix),suffix[i],suffix[..i]) &&
              O.Matches(At(c,prefix),suffix[i],suffix[..i],replies[|prefix|+i])
    {
      assert prefix+suffix[..i] == trace[..|prefix|+i];
      assert suffix[i] == trace[|prefix|+i];
      Receipt(c,prefix,suffix[i],suffix[..i],replies[|prefix|+i]);
    }
  }

  lemma ReplaySuffix(trace: seq<E.Request>, replies: seq<O.Reply>, prefix: seq<E.Request>)
    requires |trace| == |replies| && prefix <= trace
    ensures forall q: E.Request,h: seq<E.Request> :: H.Oracle(O.Replay(trace,replies),prefix)(q,h) == O.Replay(trace[|prefix|..],replies[|prefix|..])(q,h)
  {
    var suffix := trace[|prefix|..];
    var more := replies[|prefix|..];
    forall q: E.Request,h: seq<E.Request>
      ensures H.Oracle(O.Replay(trace,replies),prefix)(q,h) == O.Replay(suffix,more)(q,h)
    {
      if |h| < |suffix| {
        assert trace[..|prefix|+|h|] == prefix+suffix[..|h|];
        assert (prefix+h == prefix+suffix[..|h|]) == (h == suffix[..|h|]);
        assert trace[|prefix|+|h|] == suffix[|h|];
        assert replies[|prefix|+|h|] == more[|h|];
      }
    }
  }

  lemma FromTrace(c: O.Config, types: seq<Descriptor>, initial: C.Cache, index: nat,
                  prefix: seq<E.Request>, reject: (nat,E.Value)->E.Error,
                  trace: seq<E.Request>, replies: seq<O.Reply>)
    requires G.Ready(c,types,initial,index,reject)
    requires O.Covered(c,trace) && O.ValidTrace(c,trace,replies) && prefix <= trace
    ensures O.Covered(At(c,prefix),trace[|prefix|..])
    ensures O.ValidTrace(At(c,prefix),trace[|prefix|..],replies[|prefix|..])
    ensures S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),index,B.View(initial),prefix) ==
            H.ResultAt(prefix,S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,
                                         O.Replay(trace[|prefix|..],replies[|prefix|..]),index,B.View(initial),[]))
  {
    Suffix(c,trace,replies,prefix);
    ReplaySuffix(trace,replies,prefix);
    H.Rebase(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),
             O.Replay(trace[|prefix|..],replies[|prefix|..]),prefix,index,B.View(initial));
  }

  function Resume(prefix: seq<E.Request>, local: (E.Request,seq<E.Request>)->E.Raw): (E.Request,seq<E.Request>)->E.Raw {
    (q: E.Request,h: seq<E.Request>) => if prefix <= h then local(q,h[|prefix|..]) else E.Aborted(E.Error([]))
  }
  lemma ResumeIdentity(prefix: seq<E.Request>, local: (E.Request,seq<E.Request>)->E.Raw)
    ensures forall q: E.Request,h: seq<E.Request> :: H.Oracle(Resume(prefix,local),prefix)(q,h) == local(q,h)
  {
    forall q: E.Request,h: seq<E.Request>
      ensures H.Oracle(Resume(prefix,local),prefix)(q,h) == local(q,h)
    { assert (prefix+h)[|prefix|..] == h; }
  }

  ghost method EvaluateAt(c: O.Config, types: seq<Descriptor>, initial: C.Cache, index: nat,
                          prefix: seq<E.Request>, reject: (nat,E.Value)->E.Error)
    returns (out: E.Result, replies: seq<O.Reply>, covered: bool, updated: C.Cache,
             outer: (E.Request,seq<E.Request>)->E.Raw)
    requires G.Ready(c,types,initial,index,reject)
    ensures Entry.CanonicalCache(types,updated) && C.Extends(initial,updated)
    ensures |out.history| == |replies|
    ensures outer == Resume(prefix,O.Replay(out.history,replies))
    ensures H.ResultAt(prefix,out) == S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,
                                                 outer,index,B.View(initial),prefix)
    ensures covered == O.Covered(At(c,prefix),out.history)
    ensures covered ==> O.ValidTrace(At(c,prefix),out.history,replies)
    ensures covered ==> forall i :: 0 <= i < |out.history| ==>
                                      O.Eligible(c,out.history[i],prefix+out.history[..i]) &&
                                      O.Matches(c,out.history[i],prefix+out.history[..i],replies[i])
    ensures out.Failure? ==> B.Bytes(out.error.payload)
    ensures out.Success? ==> B.Bytes(out.value) && C.SuccessfulReceipt(types,index,initial,C.Succeeded(B.Narrow(out.value),updated))
  {
    var localConfig := At(c,prefix);
    out,replies,covered,updated := Entry.CanonicalRun(localConfig,types,initial,reject,index);
    var local := O.Replay(out.history,replies);
    outer := Resume(prefix,local);
    ResumeIdentity(prefix,local);
    H.Rebase(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,outer,local,prefix,index,B.View(initial));
    if covered {
      forall i | 0 <= i < |out.history|
        ensures O.Eligible(c,out.history[i],prefix+out.history[..i]) &&
                O.Matches(c,out.history[i],prefix+out.history[..i],replies[i])
      {
        Observations(c,prefix,out.history[i],out.history[..i]);
        Receipt(c,prefix,out.history[i],out.history[..i],replies[i]);
      }
    }
  }
}
