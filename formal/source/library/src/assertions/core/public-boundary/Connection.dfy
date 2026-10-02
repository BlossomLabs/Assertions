// SPDX-License-Identifier: MIT
include "Getters.generated.dfy"

module CorePublicConnection {
  import opened AbiFrames
  import T = CoreRawTree
  import RC = CoreRawConnection
  import I = CoreRecursiveInvocation
  import W = CoreFrameWire
  import G = CorePublicGetters
  import R = ResolutionModel
  import C = ConstraintModel
  import ResolutionWords

  datatype Dispatch = Rejected | Explicit(call: I.Call) | Getter(getter: G.Getter)

  function Literal(g: G.Getter): I.Call {
    I.Resolve(R.Param(R.CALL_DATA,R.RAW_BYTES,G.Data(g),[]))
  }
  function Lower(d: Dispatch): T.Decode {
    match d
    case Rejected => T.Rejected
    case Explicit(call) => T.Accepted(call)
    case Getter(g) => T.Accepted(Literal(g))
  }
  function Boundary(core: R.Address, resolve: R.Param -> seq<Byte>, decode: seq<Byte> -> Dispatch, wire: W.Encoding): T.Boundary {
    T.Boundary(core,resolve,(data: seq<Byte>) => Lower(decode(data)),wire)
  }
  // Lowering a getter to a literal resolver is a proof representation only.
  // The deployed getter does not call resolve. Both emit the same constant
  // ABI word, with no external observations or constraints.
  ghost method GetterResult(r: T.Receipt, b: T.Boundary, g: G.Getter) returns (source: seq<Byte>)
    requires T.FramePost(r,b) && b.decode(r.data) == T.Accepted(Literal(g))
    ensures r.state.Ran?
    ensures T.Raw(r,b) == W.Returned(source) && source == G.Data(g)
    ensures T.History(r) == []
    ensures ReadNat(source) == (G.Expected(g)+ResolutionWords.Limit()) as nat
  {
    source := G.Source(g);
    var p := R.Param(R.CALL_DATA,R.RAW_BYTES,G.Data(g),[]);
    assert R.Fetch(p,C.Context([],0,0),r.env.base,[]) == R.Outcome(R.Value(G.Data(g)),[]);
    assert R.Resolve(p,C.Context([],0,0),r.env.base,[]) == R.Outcome(R.Value(G.Data(g)),[]);
  }
  ghost predicate PublicPost(r: T.Receipt, b: T.Boundary, decoded: Dispatch) {
    match decoded
    case Rejected => r.state.DecodeRejected? && T.Raw(r,b) == W.Reverted([]) && T.History(r) == []
    case Explicit(call) =>
      !r.state.DecodeRejected? && r.state.call == call &&
      (r.state.Ran? <==> I.Ready(call,r.env.base,[])) &&
      (r.state.Ran? ==> I.Post(call,r.env,[],r.state.reply))
    case Getter(g) => r.state.Ran? && T.Raw(r,b) == W.Returned(G.Data(g)) && T.History(r) == []
  }
  ghost method FrameReceipt(r: T.Receipt, b: T.Boundary, decoded: Dispatch)
    requires T.FramePost(r,b) && b.decode(r.data) == Lower(decoded)
    ensures PublicPost(r,b,decoded)
  {
    if decoded.Getter? { var source := GetterResult(r,b,decoded.getter); }
  }
  ghost method ReachedChild(r: T.Receipt, core: R.Address, resolve: R.Param -> seq<Byte>,
                            decode: seq<Byte> -> Dispatch, wire: W.Encoding, index: nat)
    returns (child: T.Receipt, before: C.Word, after: C.Word)
    requires T.Complete(r,Boundary(core,resolve,decode,wire))
    requires T.Installed(r.children,r.env.base,Boundary(core,resolve,decode,wire))
    requires index < |T.History(r)| && T.History(r)[index].Call? && T.History(r)[index].target == core
    ensures T.Complete(child,Boundary(core,resolve,decode,wire))
    ensures PublicPost(child,Boundary(core,resolve,decode,wire),decode(child.data))
    ensures T.History(r)[index] == R.Call(core,child.data)
    ensures r.env.base.call(T.History(r)[..index],T.History(r)[index]) ==
            W.Observe(T.Raw(child,Boundary(core,resolve,decode,wire)),before,after)
  {
    var b := Boundary(core,resolve,decode,wire);
    child,before,after := RC.ReachedChild(r,b,index);
    FrameReceipt(child,b,decode(child.data));
  }
  ghost method Compose(tree: T.Tree, core: R.Address, resolve: R.Param -> seq<Byte>,
                       decode: seq<Byte> -> Dispatch, wire: W.Encoding)
    returns (r: T.Receipt, certified: bool)
    ensures T.Matches(tree,r,Boundary(core,resolve,decode,wire))
    ensures PublicPost(r,Boundary(core,resolve,decode,wire),decode(tree.data))
    ensures certified == T.Complete(r,Boundary(core,resolve,decode,wire))
    ensures certified ==> T.Installed(r.children,r.env.base,Boundary(core,resolve,decode,wire))
    ensures decode(tree.data).Rejected? ==> r.state.DecodeRejected? && T.Raw(r,Boundary(core,resolve,decode,wire)) == W.Reverted([])
    ensures decode(tree.data).Getter? ==> r.state.Ran? && T.History(r) == [] &&
                                          T.Raw(r,Boundary(core,resolve,decode,wire)) == W.Returned(G.Data(decode(tree.data).getter))
  {
    var b := Boundary(core,resolve,decode,wire);
    r,certified := T.Compose(tree,b);
    FrameReceipt(r,b,decode(tree.data));
    if decode(tree.data).Getter? {
      var source := GetterResult(r,b,decode(tree.data).getter);
    }
  }
}
