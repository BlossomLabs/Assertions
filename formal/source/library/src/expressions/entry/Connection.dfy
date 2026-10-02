// SPDX-License-Identifier: MIT
include "../execution/Connection.dfy"
include "../cache/Source.generated.dfy"
module ExpressionEntryConnection {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import A = ExpressionAdmission
  import C = ExpressionCache
  import Init = ExpressionCacheSource
  import B = ExpressionEvaluationBridge
  import E = ExpressionEvaluationControl
  import M = ExpressionOracleModel
  import X = ExpressionExecutionModel
  import Run = ExpressionExecutionConnection
  import S = ExpressionRecursiveSpec
  import Scalar = ExpressionScalarModel

  datatype Outcome = AdmissionRejected(error: A.Error)
                   | Evaluated(types: seq<Descriptor>, initial: C.Cache, updated: C.Cache,
                               execution: E.Result, replies: seq<M.Reply>, covered: bool, raw: E.Raw)

  function RawResult(out: E.Result): E.Raw {
    if out.Success? then E.Produced(out.value) else E.Aborted(out.error)
  }

  ghost predicate CanonicalCache(types: seq<Descriptor>, cache: C.Cache) {
    C.Valid(types,cache) && forall i :: 0 <= i < |types| && cache.ready[i] ==>
                                          WellTyped(TypeOf(types[i]),Validate(TypeOf(types[i]),cache.values[i]).value) &&
                                          cache.values[i] == Encode(TypeOf(types[i]),Validate(TypeOf(types[i]),cache.values[i]).value)
  }
  lemma CacheCanonical(types: seq<Descriptor>, cache: C.Cache)
    requires C.Valid(types,cache)
    ensures CanonicalCache(types,cache)
  {
    forall i | 0 <= i < |types| && cache.ready[i]
      ensures WellTyped(TypeOf(types[i]),Validate(TypeOf(types[i]),cache.values[i]).value) &&
              cache.values[i] == Encode(TypeOf(types[i]),Validate(TypeOf(types[i]),cache.values[i]).value)
    { C.ReuseCanonical(types,cache,i); }
  }

  ghost method CanonicalRun(c: M.Config, types: seq<Descriptor>, initial: C.Cache,
                            reject: (nat,E.Value)->E.Error, index: nat)
    returns (out: E.Result, replies: seq<M.Reply>, covered: bool, updated: C.Cache)
    requires E.Program(B.Project(c.nodes)) && index < |c.nodes| && |types| == |c.nodes|
    requires C.Valid(types,initial)
    requires forall i: nat,v: E.Value :: i < |c.nodes| ==> B.Bytes(reject(i,v).payload)
    ensures CanonicalCache(types,updated) && C.Extends(initial,updated)
    ensures X.Certified(c,out.history,replies) && covered == M.Covered(c,out.history)
    ensures out == S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,
                              M.Replay(out.history,replies),index,B.View(initial),[])
    ensures E.Good(B.Project(c.nodes),B.Canonical(types),out.memo) && E.Extends(B.View(initial),out.memo)
    ensures updated == B.Reify(types,initial,out.memo)
    ensures covered ==> M.ValidTrace(c,out.history,replies)
    ensures out.Failure? ==> B.Bytes(out.error.payload)
    ensures out.Success? ==> B.Bytes(out.value) &&
                             C.SuccessfulReceipt(types,index,initial,C.Succeeded(B.Narrow(out.value),updated)) &&
                             Validate(TypeOf(types[index]),B.Narrow(out.value)).Parsed? &&
                             WellTyped(TypeOf(types[index]),Validate(TypeOf(types[index]),B.Narrow(out.value)).value) &&
                             B.Narrow(out.value) == Encode(TypeOf(types[index]),Validate(TypeOf(types[index]),B.Narrow(out.value)).value)
    ensures initial.ready[index] ==> out == E.Success(initial.values[index],B.View(initial),[]) && updated == initial
  {
    B.ViewValid(B.Project(c.nodes),types,initial);
    var valid := B.Canonical(types);
    out,replies,covered := Run.Evaluate(c,valid,reject,index,B.View(initial));
    B.ReifyValid(B.Project(c.nodes),types,initial,out.memo);
    updated := B.Reify(types,initial,out.memo);
    CacheCanonical(types,updated);
    if out.Success? {
      C.ReuseCanonical(types,updated,index);
      B.ByteIdentity(updated.values[index]);
    }
    if initial.ready[index] {
      forall i | 0 <= i < |types|
        ensures updated.values[i] == initial.values[i] && updated.ready[i] == initial.ready[i]
      { if initial.ready[i] { B.ByteIdentity(initial.values[i]); } }
      assert updated.values == initial.values && updated.ready == initial.ready;
    }
  }

  ghost method Evaluate(c: M.Config, result: nat, hash: seq<Byte>->nat, reject: (nat,E.Value)->E.Error)
    returns (out: Outcome)
    requires forall i :: 0 <= i < |c.nodes| ==> Uint(|c.nodes[i].valueType|)
    requires forall i: nat,v: E.Value :: i < |c.nodes| ==> B.Bytes(reject(i,v).payload)
    ensures out.AdmissionRejected? <==> A.Admit(c.nodes,result,hash).Rejected?
    ensures out.AdmissionRejected? ==> out.error == A.Admit(c.nodes,result,hash).error
    ensures out.Evaluated? ==> E.Program(B.Project(c.nodes))
    ensures out.Evaluated? ==> result < |c.nodes| && |out.types| == |c.nodes| &&
                               (forall i :: 0 <= i < |c.nodes| ==> Render(out.types[i]) == c.nodes[i].valueType)
    ensures out.Evaluated? ==> out.initial == C.Cold(out.types) && B.View(out.initial) == map[] &&
                               CanonicalCache(out.types,out.updated) && C.Extends(out.initial,out.updated)
    ensures out.Evaluated? ==> X.Certified(c,out.execution.history,out.replies) && out.covered == M.Covered(c,out.execution.history)
    ensures out.Evaluated? ==> out.execution == S.Evaluate(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,reject,
                                                           M.Replay(out.execution.history,out.replies),result,map[],[]) && out.raw == RawResult(out.execution)
    ensures out.Evaluated? && out.covered ==> M.ValidTrace(c,out.execution.history,out.replies)
    ensures out.Evaluated? && out.raw.Aborted? ==> B.Bytes(out.raw.error.payload)
    ensures out.Evaluated? && out.raw.Produced? ==> B.Bytes(out.raw.value) &&
                                                    Validate(TypeOf(out.types[result]),B.Narrow(out.raw.value)).Parsed? &&
                                                    WellTyped(TypeOf(out.types[result]),Validate(TypeOf(out.types[result]),B.Narrow(out.raw.value)).value) &&
                                                    B.Narrow(out.raw.value) == Encode(TypeOf(out.types[result]),Validate(TypeOf(out.types[result]),B.Narrow(out.raw.value)).value)
  {
    var prepared := Init.Begin(c.nodes,result,hash);
    if prepared.AdmissionFailed? { out := AdmissionRejected(prepared.error); return; }
    B.AdmittedGraph(c.nodes,result,hash);
    assert B.View(prepared.cache) == map[];
    var evaluated,replies,covered,updated := CanonicalRun(c,prepared.types,prepared.cache,reject,result);
    out := Evaluated(prepared.types,prepared.cache,updated,evaluated,replies,covered,RawResult(evaluated));
  }
}
