// SPDX-License-Identifier: MIT
include "../call-results/Connection.dfy"
module CollectionsIterationModel {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import V = AbiConstructionContext
  import K = CollectionsCodecStateModel
  import B = CollectionsBoundCallModel
  import R = CollectionsCallbackResultsModel
  import Result = CollectionsCallResultsModel

  function A(mode: T.Mode, value: seq<Byte>, acc: seq<Byte>): seq<Byte> { if mode == T.Fold then acc else value }
  function BArg(mode: T.Mode, value: seq<Byte>): seq<Byte> { if mode == T.Fold then value else [] }
  function CallRequest(mode: T.Mode, value: seq<Byte>, index: nat, acc: seq<Byte>): T.Request {
    if mode == T.Filter then T.Predicate(value,[],false,index,0)
    else T.Call(A(mode,value,acc),BArg(mode,value),mode == T.Fold,index,0)
  }
  function Environment(c: T.Context, input: T.Request, inputReply: T.Reply, call: T.Request, callReply: T.Reply, result: T.Request, resultReply: T.Reply): T.Environment {
    T.Environment((q,at) =>
                    if at == c && q == input then T.Observation(inputReply,c.state)
                    else if at == T.Context(c.state,c.history+[input]) && q == call then T.Observation(callReply,c.state+1)
                    else if at == T.Context(c.state+1,c.history+[input,call]) && q == result then T.Observation(resultReply,c.state+1)
                    else T.Observation(T.Error([]),at.state))
  }
  // Only resource conditions on possible actual callback outcomes; no verdict
  // or canonical-return assumption. Validity guards protect the model call.
  ghost predicate AfterRoom(fs: seq<Descriptor>, args: seq<seq<Byte>>, flag: bool, cb: C.Callback, context: C.Context, a: seq<Byte>, b: seq<Byte>, binary: bool, h: seq<C.Event>, base: C.Environment, t: seq<Byte>, asPredicate: bool)
    requires cb.first < |fs| && (binary ==> cb.second < |fs|)
  {
    forall r1: V.Result, r2: V.Result {:trigger B.Environment(base,B.Query(fs,cb.first,a),r1,B.Query(fs,if binary then cb.second else cb.first,if binary then b else a),r2)} ::
      var env := B.Environment(base,B.Query(fs,cb.first,a),r1,B.Query(fs,if binary then cb.second else cb.first,if binary then b else a),r2);
      C.Admitted(env) && C.Valid(cb,P.Prepared(K.Plan(fs),args,flag),binary) ==>
        Result.Room(C.Run(cb,P.Prepared(K.Plan(fs),args,flag),context,a,b,binary,h,env),t,R.Context(context.operation,context.index,context.other,cb.target),asPredicate)
  }
}
