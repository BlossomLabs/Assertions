// SPDX-License-Identifier: MIT
include "Tree.dfy"

module CoreFrameConnection {
  import opened AbiFrames
  import opened CoreFrameTree
  import I = CoreRecursiveInvocation
  import W = CoreFrameWire
  import R = ResolutionModel
  import G = GuardModel
  import K = CoreModel
  import C = ConstraintModel

  ghost method Find(rs: Receipts, h: seq<R.Request>, q: R.Request, env: R.Environment, b: Boundary)
    returns (child: Receipt, before: C.Word, after: C.Word)
    requires Has(rs,h,q) && ChildrenComplete(rs,b) && Installed(rs,env,b)
    ensures Complete(child,b) && q == Request(child.call,b)
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
    requires index < |I.History(r.reply)|
    requires I.History(r.reply)[index].Call? && I.History(r.reply)[index].target == b.core
    ensures Complete(child,b) && child.Executed?
    ensures I.History(r.reply)[index] == Request(child.call,b)
    ensures r.env.base.call(I.History(r.reply)[..index],I.History(r.reply)[index]) ==
            W.Observe(W.Serialize(child.reply,b.wire),before,after)
  {
    var h := I.History(r.reply)[..index];
    var q := I.History(r.reply)[index];
    assert (h,q) in Reached(I.History(r.reply),b.core);
    SiteMembership(r.children,h,q);
    child,before,after := Find(r.children,h,q,r.env.base,b);
  }

  // Instantiating the older guarded-resolution premise is now derived from
  // the actual child source receipt, rather than supplied as a child outcome.
  lemma ResolverReceipt(child: Receipt, b: Boundary, input: R.Param, before: C.Word, after: C.Word)
    requires Complete(child,b) && child.call == I.Resolve(input)
    ensures G.MatchesResolution(input,Observation(child,before,after,b),child.env.base,[],
                                (e: R.Error) => W.ResolverError(e,b.wire))
  {}

  ghost method RawLeaf(data: seq<Byte>, base: R.Environment, b: Boundary) returns (r: Receipt)
    ensures Complete(r,b) && r.Executed?
    ensures W.Serialize(r.reply,b.wire) == W.Returned(data)
    ensures I.History(r.reply) == []
  {
    var p := R.Param(R.CALL_DATA,R.RAW_BYTES,data,[]);
    var tree := Frame(I.Resolve(p),base,Empty);
    var certified: bool;
    r,certified := Compose(tree,b);
    assert r.children == None;
    assert R.Fetch(p,C.Context([],0,0),r.env.base,[]) == R.Outcome(R.Value(data),[]);
    assert R.Resolve(p,C.Context([],0,0),r.env.base,[]) == R.Outcome(R.Value(data),[]);
  }
}
