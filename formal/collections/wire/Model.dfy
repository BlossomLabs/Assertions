// SPDX-License-Identifier: MIT
include "Signatures.generated.dfy"
include "../calls/Connection.dfy"
include "../../abi/Encoding.dfy"
include "../../abi/construction/Assembly.generated.dfy"

module CollectionsWireModel {
  import opened AbiFrames
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import R = CollectionsCallbackResultsModel
  import S = CollectionsWireSignatures
  import A = AbiConstructionAssembly
  import ABI = AbiEncoding
  import M = AbiByteSemantics

  function Blob(data: seq<Byte>): seq<Byte> { Word(|data|)+Padded(data) }
  function Buffers(values: seq<seq<Byte>>): seq<ABI.Value> {
    seq(|values|,i requires 0 <= i < |values| => ABI.Buffer(values[i]))
  }
  function BlobPieces(values: seq<seq<Byte>>): seq<Piece> {
    seq(|values|,i requires 0 <= i < |values| => Piece(true,Blob(values[i])))
  }
  function ArrayBody(values: seq<seq<Byte>>): seq<Byte> { Word(|values|)+Frame(BlobPieces(values)) }
  function Expression(expression: seq<Byte>, values: seq<seq<Byte>>): seq<Byte> {
    S.Evaluate()+Frame([Piece(true,Blob(expression)),Piece(true,ArrayBody(values))])
  }
  predicate Shape(p: P.Prepared) {
    |p.plan.parts| == |p.args| && (forall i :: 0 <= i < |p.args| && p.plan.parts[i].dynamic ==> |p.args[i]| >= 32)
  }
  function Pieces(p: P.Prepared): seq<Piece>
    requires Shape(p)
  {
    seq(|p.args|,i requires 0 <= i < |p.args| => Piece(p.plan.parts[i].dynamic,if p.plan.parts[i].dynamic then p.args[i][32..] else p.args[i]))
  }
  function Flags(p: P.Prepared): seq<bool> { seq(|p.plan.parts|,i requires 0 <= i < |p.plan.parts| => p.plan.parts[i].dynamic) }
  predicate DirectReady(p: P.Prepared) {
    Shape(p) && ValidPieces(Pieces(p)) && p.args == A.Values(Pieces(p)) && p.plan.headSize == HeadSize(Pieces(p)) &&
    M.Uint(|p.args|) && M.Uint(HeadSize(Pieces(p))+TailSize(Pieces(p)))
  }
  function Direct(plan: P.Layout, args: seq<seq<Byte>>, arrayMode: bool): C.Encoded {
    var p := P.Prepared(plan,args,false);
    if !arrayMode && DirectReady(p) then C.Data(Frame(Pieces(p))) else C.EncodeFailure([])
  }
  // The fallback is not a certified source result. Reached direct encodings
  // must satisfy DirectReady and use the false array flag.
  function Environment(env: C.Environment): C.Environment {
    C.Environment(env.codec,env.code,(h,plan,args,arrayMode) => Direct(plan,args,arrayMode),
                  (h,expression,args) => Expression(expression,args),env.call)
  }
  function ErrorPieces(e: C.Error): seq<Piece> {
    match e
    case InvalidTarget(target) => [Piece(false,Word(target))]
    case CallbackFailed(operation,index,other,target,data,reason) =>
      [Piece(false,operation+Zeros(28)),Piece(false,Word(index)),Piece(false,Word(other)),Piece(false,Word(target)),Piece(true,Blob(data)),Piece(true,Blob(reason))]
    case _ => []
  }
  predicate ErrorFits(e: C.Error) {
    match e
    case InvalidTarget(target) => target < Pow256(20)
    case CallbackFailed(operation,index,other,target,data,reason) =>
      |operation| == 4 && index < Pow256(32) && other < Pow256(32) && target < Pow256(20) &&
      |data| < Pow256(32) && |reason| < Pow256(32) && HeadSize(ErrorPieces(e))+TailSize(ErrorPieces(e)) < Pow256(32)
    case _ => true
  }
  function ErrorBytes(e: C.Error): seq<Byte> {
    match e
    case Helper(reason) => reason
    case InvalidTarget(_) => S.InvalidCallbackTarget()+Frame(ErrorPieces(e))
    case OutOfGas => S.SubcallOutOfGas()
    case CallbackFailed(_,_,_,_,_,_) => S.CallbackFailed()+Frame(ErrorPieces(e))
  }
  predicate ExpressionReady(expression: seq<Byte>, values: seq<seq<Byte>>) {
    |Expression(expression,values)| < Pow256(32) && |expression| < Pow256(32) && |values| < Pow256(32) &&
    (forall i :: 0 <= i < |values| ==> |values[i]| < Pow256(32))
  }
  predicate WireReady(out: C.Outcome, start: nat) {
    (out.Failed? ==> ErrorFits(out.error)) &&
    (forall i :: start <= i < |out.history| ==>
                   (out.history[i].Direct? ==> !out.history[i].envelope && DirectReady(P.Prepared(out.history[i].plan,out.history[i].args,false))) &&
                   (out.history[i].Expression? ==> ExpressionReady(out.history[i].expression,out.history[i].args)))
  }
  function Result(out: C.Outcome): R.CallOutcome {
    if out.Returned? then R.Returned(out.value) else R.Reverted(ErrorBytes(out.error))
  }
}
