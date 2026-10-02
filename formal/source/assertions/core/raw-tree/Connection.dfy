// SPDX-License-Identifier: MIT
include "Tree.dfy"

module CoreRawConnection {
  import opened AbiFrames
  import opened CoreRawTree
  import I = CoreRecursiveInvocation
  import W = CoreFrameWire
  import R = ResolutionModel
  import G = GuardModel
  import C = ConstraintModel

  ghost method Find(rs: Receipts, h: seq<R.Request>, q: R.Request, env: R.Environment, b: Boundary)
    returns (child: Receipt, before: C.Word, after: C.Word)
    requires Has(rs,h,q) && ChildrenComplete(rs,b) && Installed(rs,env,b)
    ensures Complete(child,b) && q == Request(child.data,b)
    ensures env.call(h,q) == Observation(child,before,after,b)
    decreases rs
  {
    if rs.at == h && rs.request == q {
      child,before,after := rs.child,rs.before,rs.after;
    } else {
      child,before,after := Find(rs.rest,h,q,env,b);
    }
  }
  ghost method ReachedChild(r: Receipt, b: Boundary, index: nat)
    returns (child: Receipt, before: C.Word, after: C.Word)
    requires Complete(r,b) && Installed(r.children,r.env.base,b)
    requires index < |History(r)|
    requires History(r)[index].Call? && History(r)[index].target == b.core
    ensures Complete(child,b) && !child.state.Unready?
    ensures History(r)[index] == Request(child.data,b)
    ensures r.env.base.call(History(r)[..index],History(r)[index]) == W.Observe(Raw(child,b),before,after)
    ensures b.decode(child.data).Rejected? ==> child.state.DecodeRejected? && Raw(child,b) == W.Reverted([])
    ensures b.decode(child.data).Accepted? ==> child.state.Ran? && child.state.call == b.decode(child.data).call
  {
    var h := History(r)[..index];
    var q := History(r)[index];
    assert (h,q) in Reached(History(r),b.core);
    SiteMembership(r.children,h,q);
    child,before,after := Find(r.children,h,q,r.env.base,b);
  }
  lemma ResolverReceipt(child: Receipt, b: Boundary, input: R.Param, before: C.Word, after: C.Word)
    requires Complete(child,b) && b.decode(child.data) == Accepted(I.Resolve(input))
    ensures G.MatchesResolution(input,Observation(child,before,after,b),child.env.base,[],
                                (e: R.Error) => W.ResolverError(e,b.wire))
  {}

  ghost method RejectedLeaf(data: seq<Byte>, base: R.Environment, b: Boundary) returns (r: Receipt)
    requires b.decode(data).Rejected?
    ensures Complete(r,b) && r.state.DecodeRejected?
    ensures Raw(r,b) == W.Reverted([]) && History(r) == []
  {
    var certified: bool;
    r,certified := Compose(Frame(data,base,Empty),b);
    assert r.children == None;
  }
  ghost method RawLeaf(data: seq<Byte>, value: seq<Byte>, base: R.Environment, b: Boundary) returns (r: Receipt)
    requires b.decode(data) == Accepted(I.Resolve(R.Param(R.CALL_DATA,R.RAW_BYTES,value,[])))
    ensures Complete(r,b) && r.state.Ran?
    ensures Raw(r,b) == W.Returned(value) && History(r) == []
  {
    var p := R.Param(R.CALL_DATA,R.RAW_BYTES,value,[]);
    var certified: bool;
    r,certified := Compose(Frame(data,base,Empty),b);
    assert r.children == None;
    assert R.Fetch(p,C.Context([],0,0),r.env.base,[]) == R.Outcome(R.Value(value),[]);
    assert R.Resolve(p,C.Context([],0,0),r.env.base,[]) == R.Outcome(R.Value(value),[]);
  }
}
