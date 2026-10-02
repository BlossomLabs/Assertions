// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsCallResultsConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import R = CollectionsCallbackResultsModel
  import T = CollectionsTraversalModel
  import W = CollectionsWireModel
  import WS = CollectionsWireConnection
  import V = CollectionsValidationConnection
  import VC = AbiConstructionContext
  import E = AbiEncoding
  import A = AbiValidation
  import M = CollectionsCallResultsModel
  import Trace = CollectionsRepeatedCallModel
  import Repeated = CollectionsRepeatedCallConnection

  ghost method Complete(out: C.Outcome, t: seq<Byte>, context: R.Context, asPredicate: bool)
    returns (call: T.Reply, checks: seq<T.Reply>, reply: T.Reply)
    requires M.Room(out,t,context,asPredicate)
    ensures call == M.CallReply(out,context,asPredicate) && checks == M.Checks(out,t,context,asPredicate) && reply == M.Reply(out,t,context,asPredicate)
    ensures |checks| == (if !asPredicate && out.Returned? then 1 else 0)
    ensures out.Failed? ==> reply == T.Error(W.ErrorBytes(out.error)) && call == reply && checks == []
    ensures asPredicate && out.Returned? ==> (reply.Ok? == (out.value == Word(0) || out.value == Word(1)))
    ensures asPredicate && reply.Ok? ==> out.Returned? && reply == T.Ok([],out.value == Word(1))
    ensures asPredicate && out.Returned? && reply.Error? ==> reply.reason == R.InvalidBytes(context)
    ensures !asPredicate && out.Returned? ==> call == T.Ok(out.value,false)
    ensures !asPredicate && out.Returned? && Whole(t).Shaped? ==> E.WellFormed(TypeOf(Whole(t).syntax))
    ensures !asPredicate && out.Returned? ==> (reply.Ok? == (Whole(t).Shaped? && A.Validate(TypeOf(Whole(t).syntax),out.value).Parsed?))
    ensures !asPredicate && reply.Ok? ==> out.Returned? && reply == T.Ok(out.value,false)
    ensures !asPredicate && out.Returned? && reply.Error? ==> reply == checks[0]
    ensures !asPredicate && out.Returned? && Whole(t).Shaped? && reply.Error? ==> reply.reason == R.InvalidBytes(R.Context(context.operation,context.index,0,context.target))
  {
    checks := [];
    if asPredicate {
      NatBytesRoundTrip(0,32);
      NatBytesRoundTrip(1,32);
      assert Word(0) != Word(1);
      var judged := WS.PredicateResult(out,context);
      call := R.Project(judged);
      reply := call;
      return;
    }
    if out.Failed? {
      WS.ErrorLayout(out.error);
      call := T.Error(W.ErrorBytes(out.error));
      reply := call;
      return;
    }
    call := T.Ok(out.value,false);
    var result: VC.Result;
    var checked: T.Reply;
    BytesNatRoundTrip(context.operation);
    result,checked := V.Result(t,out.value,ReadNat(context.operation),context.index,context.target);
    checks := [checked];
    reply := if checked.Error? then checked else call;
  }

  ghost method FromRecord(cb: C.Callback, steps: seq<Trace.Step>, binary: bool, initial: P.Prepared, history: seq<C.Event>, records: seq<Trace.Record>, index: nat, t: seq<Byte>, asPredicate: bool)
    returns (call: T.Reply, checks: seq<T.Reply>, reply: T.Reply)
    requires Trace.Chain(cb,steps,binary,initial,history,records) && index < |records|
    requires index < |steps|
    requires M.Room(records[index].out,t,R.Context(steps[index].context.operation,steps[index].context.index,steps[index].context.other,cb.target),asPredicate)
    ensures C.Admitted(records[index].env) && C.Valid(cb,records[index].before,binary)
    ensures records[index].out == C.Run(cb,records[index].before,steps[index].context,steps[index].a,steps[index].b,binary,records[index].history,records[index].env)
    ensures call == M.CallReply(records[index].out,R.Context(steps[index].context.operation,steps[index].context.index,steps[index].context.other,cb.target),asPredicate)
    ensures checks == M.Checks(records[index].out,t,R.Context(steps[index].context.operation,steps[index].context.index,steps[index].context.other,cb.target),asPredicate)
    ensures reply == M.Reply(records[index].out,t,R.Context(steps[index].context.operation,steps[index].context.index,steps[index].context.other,cb.target),asPredicate)
    ensures records[index].out.Failed? ==> reply == T.Error(W.ErrorBytes(records[index].out.error)) && checks == []
  {
    Repeated.At(cb,steps,binary,initial,history,records,index);
    call,checks,reply := Complete(records[index].out,t,R.Context(steps[index].context.operation,steps[index].context.index,steps[index].context.other,cb.target),asPredicate);
  }
}
