// SPDX-License-Identifier: MIT
include "../serialization/Connection.dfy"

module AssertionsCompletion {
  import opened AbiFrames
  import R = ResolutionModel
  import C = ConstraintModel
  import I = CoreRecursiveInvocation
  import T = CoreRawTree
  import Public = CorePublicConnection
  import Wire = CoreSerializationConnection
  import Bounds = CoreSerializationBounds
  import E = CoreSerializationEncoding
  import Errors = CoreSerializationErrors
  import W = CoreFrameWire

  function ParamMessage(custom: bool, message: seq<Byte>): seq<Byte> {
    if custom then message else [80,65,82,65,77]
  }
  function BatchMessage(custom: bool, message: seq<Byte>): seq<Byte> {
    if custom then message else [67,79,77,80,79,83,65,66,76,69]
  }
  function ParamCall(input: R.Param, custom: bool, message: seq<Byte>): I.Call {
    if custom then I.AssertOne(input,message) else I.DefaultOne(input)
  }
  function BatchCall(entries: seq<R.Entry>, custom: bool, message: seq<Byte>): I.Call {
    if custom then I.AssertBatch(entries,message) else I.DefaultBatch(entries)
  }
  function Acceptance(input: R.Param, message: seq<Byte>, env: R.Environment): bool {
    var fetched := R.Fetch(input,C.Context(message,0,0),env,[]);
    fetched.result.Value? && |input.constraints| <= |fetched.result.bytes|/32 &&
    (forall i :: 0 <= i < |input.constraints| ==>
                   C.Judge(C.Read(fetched.result.bytes[32*i..32*i+32]),input.constraints[i],env.decodeOr) == C.Yes)
  }
  function Encoded(out: R.Outcome): W.Raw {
    if out.result.Value? then W.Returned(out.result.bytes) else W.Reverted(E.Encode(Errors.Resolution(out.result.error)))
  }

  ghost method AssertParam(tree: T.Tree, core: R.Address, resolve: R.Param -> seq<Byte>, decode: seq<Byte> -> Public.Dispatch,
                           input: R.Param, custom: bool, message: seq<Byte>)
    returns (r: T.Receipt, raw: W.Raw, certified: bool)
    requires decode(tree.data) == Public.Explicit(ParamCall(input,custom,message))
    ensures T.Matches(tree,r,Public.Boundary(core,resolve,decode,Wire.Encoding()))
    ensures certified == (T.Complete(r,Public.Boundary(core,resolve,decode,Wire.Encoding())) && Bounds.TreeFits(r))
    ensures certified ==> T.Installed(r.children,r.env.base,Public.Boundary(core,resolve,decode,Wire.Encoding()))
    ensures r.state.Ran?
    ensures raw == T.Raw(r,Public.Boundary(core,resolve,decode,Wire.Encoding()))
    ensures raw == Encoded(R.AssertParam(input,ParamMessage(custom,message),r.env.base,[]))
    ensures T.History(r) == R.AssertParam(input,ParamMessage(custom,message),r.env.base,[]).history
    ensures raw.Returned? <==> Acceptance(input,ParamMessage(custom,message),r.env.base)
    ensures raw.Returned? ==> raw.data == []
  {
    r,certified := Wire.Compose(tree,core,resolve,decode);
    var expected := R.AssertParam(input,ParamMessage(custom,message),r.env.base,[]);
    assert r.state.Ran? && r.state.reply == I.Resolved(expected);
    raw := T.Raw(r,Public.Boundary(core,resolve,decode,Wire.Encoding()));
    if expected.result.Failed? { Wire.ResolverBytes(expected.result.error); }
    R.ResolveSuccess(input,C.Context(ParamMessage(custom,message),0,0),r.env.base,[]);
  }

  lemma BatchReturnsEmpty(entries: seq<R.Entry>, message: seq<Byte>, start: nat, env: R.Environment, history: seq<R.Request>)
    requires start <= |entries|
    ensures R.Batch(entries,message,start,env,history).result.Value? ==> R.Batch(entries,message,start,env,history).result.bytes == []
    decreases |entries|-start
  {
    if start < |entries| {
      var first := R.JudgeEntry(entries[start],message,start,env,history);
      if first.result.Value? { BatchReturnsEmpty(entries,message,start+1,env,first.history); }
    }
  }
  ghost method AssertBatch(tree: T.Tree, core: R.Address, resolve: R.Param -> seq<Byte>, decode: seq<Byte> -> Public.Dispatch,
                           entries: seq<R.Entry>, custom: bool, message: seq<Byte>)
    returns (r: T.Receipt, raw: W.Raw, evaluated: seq<R.Outcome>, certified: bool)
    requires decode(tree.data) == Public.Explicit(BatchCall(entries,custom,message))
    ensures T.Matches(tree,r,Public.Boundary(core,resolve,decode,Wire.Encoding()))
    ensures certified == (T.Complete(r,Public.Boundary(core,resolve,decode,Wire.Encoding())) && Bounds.TreeFits(r))
    ensures certified ==> T.Installed(r.children,r.env.base,Public.Boundary(core,resolve,decode,Wire.Encoding()))
    ensures r.state.Ran?
    ensures raw == T.Raw(r,Public.Boundary(core,resolve,decode,Wire.Encoding()))
    ensures raw == Encoded(R.Batch(entries,BatchMessage(custom,message),0,r.env.base,[]))
    ensures T.History(r) == R.Batch(entries,BatchMessage(custom,message),0,r.env.base,[]).history
    ensures raw.Returned? ==> raw.data == []
    ensures evaluated == R.BatchResults(entries,BatchMessage(custom,message),0,r.env.base,[])
    ensures raw.Returned? <==> |evaluated| == |entries| && (forall i :: 0 <= i < |evaluated| ==> evaluated[i].result.Value?)
    ensures forall i :: 0 <= i < |evaluated|-1 ==> evaluated[i].result.Value?
    ensures raw.Reverted? ==> |evaluated| > 0 && raw == Encoded(evaluated[|evaluated|-1]) && evaluated[|evaluated|-1].result.Failed?
  {
    r,certified := Wire.Compose(tree,core,resolve,decode);
    var expected := R.Batch(entries,BatchMessage(custom,message),0,r.env.base,[]);
    assert r.state.Ran? && r.state.reply == I.Resolved(expected);
    raw := T.Raw(r,Public.Boundary(core,resolve,decode,Wire.Encoding()));
    if expected.result.Failed? { Wire.ResolverBytes(expected.result.error); }
    evaluated := R.BatchResults(entries,BatchMessage(custom,message),0,r.env.base,[]);
    R.BatchFirstFailure(entries,BatchMessage(custom,message),0,r.env.base,[]);
    BatchReturnsEmpty(entries,BatchMessage(custom,message),0,r.env.base,[]);
  }
}
