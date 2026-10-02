// SPDX-License-Identifier: MIT
include "Bounds.dfy"
module ExpressionAdmissionErrorConnection {
  import opened AbiFrames
  import opened AbiByteSemantics
  import AbiShapeSemantics
  import A = ExpressionAdmission
  import Source = ExpressionAdmissionSource
  import Bounds = ExpressionAdmissionErrorBounds
  import W = ExpressionAdmissionErrors

  datatype Result = Accepted(shapes: seq<AbiShapeSemantics.ShapeResult>) | Reverted(reason: seq<Byte>)

  ghost method Prepare(nodes: seq<A.Node>, result: nat, hash: seq<Byte>->nat) returns (out: Result)
    requires Bounds.WordNodes(nodes) && Uint(result)
    ensures out.Reverted? <==> A.Admit(nodes,result,hash).Rejected?
    ensures out.Reverted? ==> out.reason == W.Spec(A.Admit(nodes,result,hash).error)
    ensures out.Reverted? ==> W.Fits(A.Admit(nodes,result,hash).error)
    ensures out.Reverted? ==> |out.reason| == 4+32*|W.Fields(A.Admit(nodes,result,hash).error)|
    ensures out.Reverted? ==> forall i :: 0 <= i < |W.Fields(A.Admit(nodes,result,hash).error)| ==>
                                            ReadNat(out.reason[4+32*i..4+32*(i+1)]) == W.Fields(A.Admit(nodes,result,hash).error)[i]
    ensures out.Accepted? ==> out.shapes == A.Admit(nodes,result,hash).shapes
  {
    var admitted := Source.Prepare(nodes,result,hash);
    if admitted.Rejected? {
      Bounds.AdmissionFields(nodes,result,hash);
      W.Exact(admitted.error);
      out := Reverted(W.Encoded(admitted.error));
    } else { out := Accepted(admitted.shapes); }
  }
}
