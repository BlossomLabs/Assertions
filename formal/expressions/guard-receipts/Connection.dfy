// SPDX-License-Identifier: MIT
include "Events.dfy"
module ExpressionGuardReceiptConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import E = ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import B = ExpressionEvaluationBridge
  import C = ExpressionCache
  import O = ExpressionOracleModel
  import G = ExpressionGuardedModel
  import F = ExpressionFramesModel
  import Entry = ExpressionEntryConnection
  import Window = ExpressionTraceBoundsConnection
  import Context = ExpressionContextConnection
  import X = ExpressionExecutionModel
  import Execution = ExpressionExecutionConnection
  import Source = ExpressionRequestSource
  import CacheSource = ExpressionCacheSource
  import Scalar = ExpressionScalarModel
  import R = ResolutionModel
  import W = ExpressionGuardedEncoding
  import Shift = ExpressionContextShift
  import Events = ExpressionGuardReceiptEvents
  import FrameCache = ExpressionFramesConnection
  import Bounds = ExpressionTraceBounds

  ghost method EvaluateWindow(c: O.Config, types: seq<Descriptor>, initial: C.Cache, f: F.Frame,
                              reject: (nat,E.Value)->E.Error, trace: seq<E.Request>, replies: seq<O.Reply>)
    returns (attempt: G.Outcome)
    requires G.Ready(c,types,initial,f.index,reject) && B.View(initial) == f.memo
    requires O.Covered(c,trace) && O.ValidTrace(c,trace,replies) && f.history <= trace
    requires S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),f.index,f.memo,f.history).history <= trace
    ensures attempt.Attempted? && attempt.covered
    ensures attempt.execution == Window.Local(c,types,initial,f,reject,trace,replies)
    ensures Entry.CanonicalCache(types,attempt.updated) && C.Extends(initial,attempt.updated) && W.WordsFit(attempt.updated)
    ensures attempt.execution.Success? ==> B.Bytes(attempt.execution.value) &&
                                           C.SuccessfulReceipt(types,f.index,initial,C.Succeeded(B.Narrow(attempt.execution.value),attempt.updated))
    ensures attempt.execution.Failure? ==> B.Bytes(attempt.execution.error.payload)
    ensures Shift.ResultAt(f.history,attempt.execution) == S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,
                                                                      O.Replay(trace,replies),f.index,f.memo,f.history)
    ensures B.View(attempt.updated) == attempt.execution.memo
    ensures f.history+attempt.execution.history <= trace
    ensures |f.history|+|attempt.execution.history| <= |replies|
    ensures attempt.replies == replies[|f.history|..|f.history|+|attempt.execution.history|]
    ensures O.Covered(Context.At(c,f.history),attempt.execution.history)
    ensures O.ValidTrace(Context.At(c,f.history),attempt.execution.history,attempt.replies)
  {
    Window.Window(c,types,initial,f,reject,trace,replies);
    Context.Suffix(c,trace,replies,f.history);
    var localConfig := Context.At(c,f.history);
    var suffix := trace[|f.history|..];
    var remaining := replies[|f.history|..];
    assert X.Certified(localConfig,suffix,remaining);
    Execution.ReceiptContracts(localConfig,suffix,remaining,B.Canonical(types));
    B.ViewValid(B.Project(c.nodes),types,initial);
    var out := Source.Run(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(suffix,remaining),f.index,f.memo,[]);
    assert out == Window.Local(c,types,initial,f,reject,trace,replies);
    B.ReifyValid(B.Project(c.nodes),types,initial,out.memo);
    var updated := B.Reify(types,initial,out.memo);
    Entry.CacheCanonical(types,updated);
    FrameCache.EntryCache(c,types,initial,F.Frame(f.index,out.memo,out.history,-1),reject);
    if out.Success? { B.ByteIdentity(updated.values[f.index]); }
    var windowReplies := replies[|f.history|..|f.history|+|out.history|];
    attempt := G.Attempted(out,updated,windowReplies,true);
    assert attempt.execution == out && attempt.replies == windowReplies;
  }

  ghost method Apply(types: seq<Descriptor>, initial: C.Cache, index: nat, attempt: G.Outcome,
                     observed: R.Observation) returns (result: C.GuardResult, classified: E.Raw)
    requires attempt.Attempted? && C.Valid(types,initial)
    requires attempt.execution.Success? ==> B.Bytes(attempt.execution.value) &&
                                            C.SuccessfulReceipt(types,index,initial,C.Succeeded(B.Narrow(attempt.execution.value),attempt.updated))
    requires attempt.execution.Failure? ==> B.Bytes(attempt.execution.error.payload) &&
                                            observed.data == B.Narrow(attempt.execution.error.payload)
    ensures attempt.execution.Success? ==> result.Accepted? && result.value == B.Narrow(attempt.execution.value) &&
                                           result.cache == attempt.updated && C.Valid(types,result.cache) && C.Extends(initial,result.cache)
    ensures attempt.execution.Success? ==> classified == E.Produced(attempt.execution.value)
    ensures attempt.execution.Failure? ==> result.cache == initial && classified == Scalar.GuardSpec(observed)
    ensures attempt.execution.Failure? ==> (result.Exhaustion? <==> R.Exhausted(observed)) &&
                                           (result.OrdinaryFailure? <==> !R.Exhausted(observed))
    ensures attempt.execution.Failure? ==> (classified.Aborted? <==> result.Exhaustion?)
    ensures attempt.execution.Failure? && classified.Aborted? ==> classified.error.payload == R.Signal()
  {
    if attempt.execution.Success? {
      var receipt := C.Succeeded(B.Narrow(attempt.execution.value),attempt.updated);
      result := CacheSource.TryResult(initial,receipt);
      C.AdoptValid(types,initial,attempt.updated);
      B.ByteIdentity(B.Narrow(attempt.execution.value));
      classified := E.Produced(attempt.execution.value);
    } else {
      result := CacheSource.TryResult(initial,C.Failed(observed,attempt.updated));
      classified := Scalar.GuardSpec(observed);
    }
  }
  ghost method FromReachedFrame(c: O.Config, types: seq<Descriptor>, initial: C.Cache, f: F.Frame,
                                reject: (nat,E.Value)->E.Error, trace: seq<E.Request>, replies: seq<O.Reply>, frames: seq<F.Frame>)
    returns (attempt: G.Outcome, result: C.GuardResult, classified: E.Raw)
    requires G.Ready(c,types,initial,f.index,reject) && B.View(initial) == f.memo
    requires O.Covered(c,trace) && O.ValidTrace(c,trace,replies) && f.history <= trace
    requires S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),f.index,f.memo,f.history).history <= trace
    requires f in frames && f.guardOwner >= 0
    requires Events.Events(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),frames,trace)
    ensures attempt.Attempted? && attempt.covered
    ensures attempt.execution == Window.Local(c,types,initial,f,reject,trace,replies)
    ensures Entry.CanonicalCache(types,attempt.updated) && W.WordsFit(attempt.updated)
    ensures C.Valid(types,result.cache) && C.Extends(initial,result.cache)
    ensures B.View(result.cache) == (if attempt.execution.Success? then attempt.execution.memo else f.memo)
    ensures attempt.execution.Success? ==> B.Bytes(attempt.execution.value)
    ensures attempt.execution.Failure? ==> B.Bytes(attempt.execution.error.payload)
    ensures attempt.execution.Success? ==> result.Accepted? && result.value == B.Narrow(attempt.execution.value) &&
                                           result.cache == attempt.updated && C.Valid(types,result.cache) && C.Extends(initial,result.cache) &&
                                           classified == E.Produced(attempt.execution.value)
    ensures attempt.execution.Failure? ==> result.cache == initial &&
                                           |f.history|+|attempt.execution.history| < |trace| &&
                                           trace[|f.history|+|attempt.execution.history|] == E.Request(f.guardOwner as nat,E.GuardFailure,[attempt.execution.error.payload])
    ensures attempt.execution.Failure? ==> classified == replies[|f.history|+|attempt.execution.history|].raw &&
                                           (classified.Aborted? <==> result.Exhaustion?) && (classified.Produced? <==> result.OrdinaryFailure?)
    ensures attempt.execution.Failure? && classified.Aborted? ==> classified.error.payload == R.Signal()
  {
    attempt := EvaluateWindow(c,types,initial,f,reject,trace,replies);
    var observed := R.Observation(true,true,[],0,0);
    if attempt.execution.Failure? {
      var at := f.history+attempt.execution.history;
      var q := E.Request(f.guardOwner as nat,E.GuardFailure,[attempt.execution.error.payload]);
      assert at+[q] <= trace;
      assert trace[|at|] == q && trace[..|at|] == at;
      assert O.Eligible(c,q,at) && O.Matches(c,q,at,replies[|at|]);
      observed := c.frames(q,at).boundary;
      assert observed.data == B.Narrow(attempt.execution.error.payload);
      result,classified := Apply(types,initial,f.index,attempt,observed);
      assert classified == replies[|at|].raw;
    } else {
      result,classified := Apply(types,initial,f.index,attempt,observed);
    }
  }
  ghost method FromRoot(c: O.Config, types: seq<Descriptor>, initial: C.Cache, f: F.Frame,
                        reject: (nat,E.Value)->E.Error, trace: seq<E.Request>, replies: seq<O.Reply>, frames: seq<F.Frame>,
                        root: nat, rootMemo: map<nat,E.Value>)
    returns (attempt: G.Outcome, result: C.GuardResult, classified: E.Raw)
    requires G.Ready(c,types,initial,f.index,reject) && B.View(initial) == f.memo
    requires O.Covered(c,trace) && O.ValidTrace(c,trace,replies)
    requires f in frames && f.guardOwner >= 0
    requires root < |c.nodes|
    requires frames == F.Trace(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),root,rootMemo,[],-1)
    requires Bounds.Within(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),frames,[],trace)
    ensures attempt.Attempted? && attempt.covered
    ensures attempt.execution == Window.Local(c,types,initial,f,reject,trace,replies)
    ensures Entry.CanonicalCache(types,attempt.updated) && W.WordsFit(attempt.updated)
    ensures C.Valid(types,result.cache) && C.Extends(initial,result.cache)
    ensures B.View(result.cache) == (if attempt.execution.Success? then attempt.execution.memo else f.memo)
    ensures attempt.execution.Success? ==> B.Bytes(attempt.execution.value)
    ensures attempt.execution.Failure? ==> B.Bytes(attempt.execution.error.payload)
    ensures attempt.execution.Success? ==> result.Accepted? && result.value == B.Narrow(attempt.execution.value) &&
                                           result.cache == attempt.updated && C.Valid(types,result.cache) && C.Extends(initial,result.cache) &&
                                           classified == E.Produced(attempt.execution.value)
    ensures attempt.execution.Failure? ==> result.cache == initial &&
                                           |f.history|+|attempt.execution.history| < |trace| &&
                                           trace[|f.history|+|attempt.execution.history|] == E.Request(f.guardOwner as nat,E.GuardFailure,[attempt.execution.error.payload])
    ensures attempt.execution.Failure? ==> classified == replies[|f.history|+|attempt.execution.history|].raw &&
                                           (classified.Aborted? <==> result.Exhaustion?) && (classified.Produced? <==> result.OrdinaryFailure?)
    ensures attempt.execution.Failure? && classified.Aborted? ==> classified.error.payload == R.Signal()
  {
    Events.Root(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),root,rootMemo,frames,trace);
    attempt,result,classified := FromReachedFrame(c,types,initial,f,reject,trace,replies,frames);
  }
}
