// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
include "../recursive/Connection.dfy"
module ExpressionScalarConnection {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import M = ExpressionScalarModel
  import B = ExpressionEvaluationBridge
  import E = ExpressionEvaluationControl
  import A = ExpressionAdmission
  import C = ExpressionCache
  import Recursive = ExpressionRecursiveConnection
  import S = ExpressionRecursiveSpec

  ghost method EvaluateWithWordTruth(nodes: seq<A.Node>, types: seq<Descriptor>, original: C.Cache,
                                     hash: seq<Byte>->nat, reject: (nat,E.Value)->E.Error,
                                     oracle: (E.Request,seq<E.Request>)->E.Raw,
                                     index: nat, history: seq<E.Request>) returns (out: E.Result)
    requires forall i | 0 <= i < |nodes| :: Uint(|nodes[i].valueType|)
    requires A.Admit(nodes,index,hash).Accepted?
    requires |nodes| == |types| && C.Valid(types,original)
    requires forall i | 0 <= i < |types| :: Render(types[i]) == nodes[i].valueType
    ensures index < |types| && E.Program(B.Project(nodes))
    ensures E.Good(B.Project(nodes),B.Canonical(types),out.memo) && E.Extends(B.View(original),out.memo)
    ensures out == S.Evaluate(B.Project(nodes),B.Canonical(types),M.TotalTruth,reject,oracle,index,B.View(original),history)
    ensures out.Success? ==> B.Bytes(out.value)
    ensures out.Success? ==> Validate(TypeOf(types[index]),B.Narrow(out.value)).Parsed?
    ensures out.Success? ==> |out.value| >= 32
  {
    out := Recursive.EvaluateInitialized(nodes,types,original,hash,M.TotalTruth,reject,oracle,index,history);
    if out.Success? { M.CanonicalHasWord(TypeOf(types[index]),B.Narrow(out.value)); }
  }
}
