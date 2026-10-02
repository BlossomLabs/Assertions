// SPDX-License-Identifier: MIT
include "Guards.dfy"

module ExpressionPublicConnection {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiShapeSemantics
  import opened AbiConnectionModel
  import opened AbiByteSemantics
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import C = ExpressionCache
  import O = ExpressionOracleModel
  import A = ExpressionAdmission
  import Admission = ExpressionAdmissionErrorConnection
  import AdmissionBounds = ExpressionAdmissionErrorBounds
  import AdmissionWire = ExpressionAdmissionErrors
  import Source = ExpressionPublicEntry
  import Entry = ExpressionEntryConnection
  import R = ExpressionRejectionModel
  import V = ExpressionRejectionRun
  import Cache = ExpressionFramesConnection
  import G = ExpressionGuardedModel
  import M = ExpressionPublicModel
  import Guard = ExpressionPublicGuards
  import Bounds = ExpressionTraceBounds
  import Scalar = ExpressionScalarModel
  import Memory = ExpressionReturnMemory
  import Return = ExpressionReturnConnection

  ghost method Evaluate(c: O.Config, result: nat, hash: seq<Byte>->nat)
    returns (out: Entry.Outcome, raw: E.Raw, evidence: M.Evidence, guards: seq<Guard.Record>)
    requires AdmissionBounds.WordNodes(c.nodes) && Uint(result)
    ensures M.EntryResult(c,result,out) && raw == M.Raw(out)
    ensures out.AdmissionRejected? <==> A.Admit(c.nodes,result,hash).Rejected?
    ensures out.AdmissionRejected? ==> raw == E.Aborted(E.Error(AdmissionWire.Spec(A.Admit(c.nodes,result,hash).error)))
    ensures out.Evaluated? ==> raw == out.raw && raw.Produced? == out.execution.Success?
    ensures raw.Aborted? ==> B.Bytes(raw.error.payload)
    ensures raw.Produced? ==> out.Evaluated? && B.Bytes(raw.value) &&
                              Validate(TypeOf(out.types[result]),B.Narrow(raw.value)).Parsed? &&
                              WellTyped(TypeOf(out.types[result]),Validate(TypeOf(out.types[result]),B.Narrow(raw.value)).value) &&
                              raw.value == Encode(TypeOf(out.types[result]),Validate(TypeOf(out.types[result]),B.Narrow(raw.value)).value)
    ensures M.Certified(c,result,out,evidence)
    ensures evidence.Complete? ==> |guards| == |evidence.frames| &&
                                   forall j :: 0 <= j < |guards| ==> Guard.Certified(c,result,out,evidence,j,guards[j])
  {
    out := Source.Evaluate(c,result,hash);
    raw := M.Raw(out);
    evidence := M.Uncovered;
    guards := [];
    if out.AdmissionRejected? {
      var admitted := Admission.Prepare(c.nodes,result,hash);
      assert admitted.Reverted? && admitted.reason == raw.error.payload;
      B.ByteIdentity(admitted.reason);
      return;
    }
    assert M.EntryResult(c,result,out);
    if !out.covered { return; }
    if !M.Room(c,result,out) { evidence := M.ResourceLimited; return; }
    R.AllBytes(out.types);
    Cache.MetadataWords(out.types,out.initial);
    assert G.Ready(c,out.types,out.initial,result,R.Reject(out.types));
    var confirmed,frames,caches,validators := V.FromRoot(c,out.types,out.initial,result,out.execution.history,out.replies);
    assert confirmed == out.execution;
    Bounds.Evaluate(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,R.Reject(out.types),O.Replay(out.execution.history,out.replies),result,map[],[],-1);
    evidence := M.Complete(frames,caches,validators);
    guards := Guard.All(c,result,out,evidence);
  }

  // Actual return-memory projection remains explicit and is applied to the
  // canonical bytes returned by the public evaluator, without ABI re-wrapping.
  ghost method ReturnValue(t: AbiType, raw: E.Raw, memory: seq<Byte>, pointer: nat)
    returns (direct: E.Raw, encoded: E.Raw)
    requires raw.Produced? ==> B.Bytes(raw.value) && WellFormed(t) &&
                               Validate(t,B.Narrow(raw.value)).Parsed? && Memory.Object(memory,pointer,B.Narrow(raw.value))
    ensures direct == raw && encoded == raw
    ensures raw.Produced? ==> WellTyped(t,Validate(t,B.Narrow(raw.value)).value)
    ensures raw.Produced? ==> direct.value == Encode(t,Validate(t,B.Narrow(raw.value)).value)
  {
    direct,encoded := raw,raw;
    if raw.Produced? {
      var a,b := Return.CanonicalReturn(t,B.Narrow(raw.value),memory,pointer);
      direct,encoded := E.Produced(a),E.Produced(b);
    }
  }
}
