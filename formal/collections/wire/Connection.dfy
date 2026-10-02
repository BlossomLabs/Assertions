// SPDX-License-Identifier: MIT
include "Model.dfy"

module CollectionsWireConnection {
  import opened AbiFrames
  import opened CollectionsWireModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import R = CollectionsCallbackResultsModel
  import S = CollectionsWireSignatures
  import Call = CollectionsCallsConnection
  import Predicate = CollectionsCallbackResultsSource
  import A = AbiConstructionAssembly
  import ABI = AbiEncoding

  lemma ExpressionCanonical(expression: seq<Byte>, values: seq<seq<Byte>>)
    ensures ABI.WellTyped(ABI.Tuple([ABI.Bytes,ABI.Array(ABI.Bytes)]),ABI.Items([ABI.Buffer(expression),ABI.Items(Buffers(values))]))
    ensures Expression(expression,values) == S.Evaluate()+ABI.Body(ABI.Tuple([ABI.Bytes,ABI.Array(ABI.Bytes)]),ABI.Items([ABI.Buffer(expression),ABI.Items(Buffers(values))]))
  {
    assert forall i :: 0 <= i < |values| ==> ABI.WellTyped(ABI.Bytes,Buffers(values)[i]);
    assert ABI.Parts(ABI.Array(ABI.Bytes),ABI.Items(Buffers(values))) == BlobPieces(values);
    assert ABI.Parts(ABI.Tuple([ABI.Bytes,ABI.Array(ABI.Bytes)]),ABI.Items([ABI.Buffer(expression),ABI.Items(Buffers(values))])) == [Piece(true,Blob(expression)),Piece(true,ArrayBody(values))];
  }
  ghost method DirectAssembly(p: P.Prepared) returns (data: seq<Byte>)
    requires DirectReady(p)
    ensures data == Frame(Pieces(p))
    ensures Direct(p.plan,p.args,false) == C.Data(data)
  {
    assert forall i :: 0 <= i < |Pieces(p)| ==> Flags(p)[i] == Pieces(p)[i].dynamic;
    data := A.Assemble(Flags(p),p.plan.headSize,p.args,false,Pieces(p));
  }
  lemma {:fuel HeadSize, 8} {:fuel Heads, 8} {:fuel Tails, 8} ErrorLayout(e: C.Error)
    requires ErrorFits(e)
    ensures e.Helper? ==> ErrorBytes(e) == e.reason
    ensures e.OutOfGas? ==> ErrorBytes(e) == R.Signal()
    ensures e.InvalidTarget? ==> ErrorBytes(e) == S.InvalidCallbackTarget()+Word(e.target)
    ensures e.CallbackFailed? ==> (ErrorBytes(e) == S.CallbackFailed()+e.operation+Zeros(28)+Word(e.index)+Word(e.other)+Word(e.target)+
                                                    Word(192)+Word(192+|Blob(e.data)|)+Blob(e.data)+Blob(e.reason))
  {
    if e.CallbackFailed? { PaddingLayout(e.data); PaddingLayout(e.reason); }
  }
  lemma ErrorPiecesValid(e: C.Error)
    requires ErrorFits(e)
    ensures e.CallbackFailed? ==> ValidPieces(ErrorPieces(e))
  {
    if e.CallbackFailed? {
      PaddingLayout(e.data); PaddingLayout(e.reason);
      forall i | 0 <= i < |ErrorPieces(e)|
        ensures |ErrorPieces(e)[i].data| > 0 && |ErrorPieces(e)[i].data| % 32 == 0
      {}
    }
  }
  lemma EnvironmentAdmitted(env: C.Environment)
    requires C.Admitted(env)
    ensures C.Admitted(Environment(env))
  {}
  ghost method Run(cb: C.Callback, p: P.Prepared, c: C.Context, a: seq<Byte>, b: seq<Byte>, binary: bool, h: seq<C.Event>, env: C.Environment) returns (out: C.Outcome, raw: R.CallOutcome)
    requires C.Admitted(env) && C.Valid(cb,p,binary)
    requires |cb.selector| == 4 && cb.target < Pow256(20)
    requires |c.operation| == 4 && c.index < Pow256(32) && c.other < Pow256(32)
    requires WireReady(C.Run(cb,p,c,a,b,binary,h,Environment(env)),|h|)
    ensures out == C.Run(cb,p,c,a,b,binary,h,Environment(env))
    ensures WireReady(out,|h|)
    ensures raw == Result(out)
    ensures out.Returned? ==> raw == R.Returned(out.value)
    ensures out.Failed? ==> raw == R.Reverted(ErrorBytes(out.error))
    ensures out.Returned? ==> out.prepared.targetChecked
  {
    EnvironmentAdmitted(env);
    out := Call.Run(cb,p,c,a,b,binary,h,Environment(env));
    raw := Result(out);
  }
  lemma PredicateErrorSelector(c: R.Context)
    ensures R.InvalidBytes(c)[..4] == S.InvalidCallbackResult()
  {}
  ghost method PredicateResult(out: C.Outcome, c: R.Context) returns (result: R.PredicateOutcome)
    requires out.Failed? ==> ErrorFits(out.error)
    ensures result == R.Judge(Result(out),c)
    ensures out.Failed? ==> result == R.Failure(ErrorBytes(out.error))
  {
    result := Predicate.Predicate(Result(out),c);
  }
}
