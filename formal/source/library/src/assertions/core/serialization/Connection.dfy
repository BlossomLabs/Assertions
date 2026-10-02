// SPDX-License-Identifier: MIT
include "Bounds.dfy"

module CoreSerializationConnection {
  import opened AbiFrames
  import E = CoreSerializationEncoding
  import Errors = CoreSerializationErrors
  import S = CoreSerializationSignatures
  import W = CoreFrameWire
  import R = ResolutionModel
  import K = CoreModel
  import P = ProbeModel
  import A = AbiConstructionContext
  import N = NavigationRuntime
  import Public = CorePublicConnection
  import T = CoreRawTree
  import Bounds = CoreSerializationBounds
  import C = ConstraintModel

  function Encoding(): W.Encoding {
    W.Encoding((e: R.Error) => E.Encode(Errors.Resolution(e)), E.Encode(E.Error(S.EmptyCallChain,[])),
               (e: P.Error) => E.Encode(Errors.Probe(e)),(e: A.Result) => E.Encode(Errors.Codec(e)),
               (e: N.Error) => E.Encode(Errors.Navigation(e)),(v: seq<seq<Byte>>) => E.Gather(v))
  }
  lemma ResolverBytes(e: R.Error)
    ensures W.ResolverError(e,Encoding()) == E.Encode(Errors.Resolution(e))
    ensures E.Shape(Errors.Resolution(e))
  { Errors.ResolutionShape(e); }
  lemma CoreBytes(e: K.CoreError)
    ensures W.CoreError(e,Encoding()) == E.Encode(Errors.Core(e))
    ensures E.Shape(Errors.Core(e))
  {
    Errors.CoreShape(e);
    if e.Base? { ResolverBytes(e.error); }
  }
  lemma ProbeBytes(e: P.Error)
    ensures W.ProbeError(e,Encoding()) == E.Encode(Errors.Probe(e))
    ensures E.Shape(Errors.Probe(e))
  {
    Errors.ProbeShape(e);
    match e
    case ResolutionError(error) => ResolverBytes(error);
    case _ =>
  }
  ghost method Find(rs: T.Receipts, h: seq<R.Request>, q: R.Request, env: R.Environment, b: T.Boundary)
    returns (child: T.Receipt, before: C.Word, after: C.Word)
    requires T.Has(rs,h,q) && T.ChildrenComplete(rs,b) && T.Installed(rs,env,b) && Bounds.ForestFits(rs)
    ensures T.Complete(child,b) && Bounds.TreeFits(child) && q == T.Request(child.data,b)
    ensures env.call(h,q) == T.Observation(child,before,after,b)
    decreases rs
  {
    if rs.at == h && rs.request == q {
      child,before,after := rs.child,rs.before,rs.after;
    } else {
      child,before,after := Find(rs.rest,h,q,env,b);
    }
  }
  ghost method ReachedChild(r: T.Receipt, core: R.Address, resolve: R.Param -> seq<Byte>, decode: seq<Byte> -> Public.Dispatch, index: nat)
    returns (child: T.Receipt, before: C.Word, after: C.Word)
    requires T.Complete(r,Public.Boundary(core,resolve,decode,Encoding())) && Bounds.TreeFits(r)
    requires T.Installed(r.children,r.env.base,Public.Boundary(core,resolve,decode,Encoding()))
    requires index < |T.History(r)| && T.History(r)[index].Call? && T.History(r)[index].target == core
    ensures T.Complete(child,Public.Boundary(core,resolve,decode,Encoding())) && Bounds.TreeFits(child)
    ensures Public.PublicPost(child,Public.Boundary(core,resolve,decode,Encoding()),decode(child.data))
    ensures T.History(r)[index] == R.Call(core,child.data)
    ensures r.env.base.call(T.History(r)[..index],T.History(r)[index]) ==
            W.Observe(T.Raw(child,Public.Boundary(core,resolve,decode,Encoding())),before,after)
  {
    var b := Public.Boundary(core,resolve,decode,Encoding());
    var h := T.History(r)[..index];
    var q := T.History(r)[index];
    assert (h,q) in T.Reached(T.History(r),core);
    T.SiteMembership(r.children,h,q);
    child,before,after := Find(r.children,h,q,r.env.base,b);
    Public.FrameReceipt(child,b,decode(child.data));
  }
  ghost method Compose(tree: T.Tree, core: R.Address, resolve: R.Param -> seq<Byte>, decode: seq<Byte> -> Public.Dispatch)
    returns (r: T.Receipt, certified: bool)
    ensures T.Matches(tree,r,Public.Boundary(core,resolve,decode,Encoding()))
    ensures certified == (T.Complete(r,Public.Boundary(core,resolve,decode,Encoding())) && Bounds.TreeFits(r))
    ensures Public.PublicPost(r,Public.Boundary(core,resolve,decode,Encoding()),decode(tree.data))
    ensures certified ==> T.Installed(r.children,r.env.base,Public.Boundary(core,resolve,decode,Encoding()))
  {
    var sourceComplete: bool;
    r,sourceComplete := Public.Compose(tree,core,resolve,decode,Encoding());
    certified := sourceComplete && Bounds.TreeFits(r);
  }
}
