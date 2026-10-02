// SPDX-License-Identifier: MIT
include "../validation/Connection.dfy"
include "../repeated-call/Connection.dfy"
module CollectionsCallResultsModel {
  import opened AbiFrames
  import opened AbiByteSemantics
  import C = CollectionsCallsModel
  import R = CollectionsCallbackResultsModel
  import T = CollectionsTraversalModel
  import W = CollectionsWireModel
  import V = CollectionsValidationModel

  function CallReply(out: C.Outcome, context: R.Context, asPredicate: bool): T.Reply {
    if asPredicate then R.Project(R.Judge(W.Result(out),context))
    else if out.Failed? then T.Error(W.ErrorBytes(out.error)) else T.Ok(out.value,false)
  }
  ghost function Checks(out: C.Outcome, t: seq<Byte>, context: R.Context, asPredicate: bool): seq<T.Reply>
    requires Uint(|t|)
  {
    if asPredicate || out.Failed? then [] else
    [V.Reply(T.ValidateResult(t,out.value,context.index),ReadNat(context.operation),context.target)]
  }
  ghost function Reply(out: C.Outcome, t: seq<Byte>, context: R.Context, asPredicate: bool): T.Reply
    requires Uint(|t|)
  {
    var call := CallReply(out,context,asPredicate);
    var checks := Checks(out,t,context,asPredicate);
    if |checks| == 0 then call else if checks[0].Error? then checks[0] else call
  }
  ghost predicate Room(out: C.Outcome, t: seq<Byte>, context: R.Context, asPredicate: bool) {
    Uint(|t|) && R.Fits(context) && (out.Failed? ==> W.ErrorFits(out.error)) &&
    (!asPredicate && out.Returned? ==> V.Room(t,out.value))
  }
}
