// SPDX-License-Identifier: MIT
include "Wire.dfy"

module CoreFrameTree {
  import opened AbiFrames
  import opened AbiByteSemantics
  import I = CoreRecursiveInvocation
  import D = CoreRecursiveDispatch
  import R = ResolutionModel
  import G = GuardModel
  import W = CoreFrameWire
  import C = ConstraintModel

  datatype Tree = Frame(call: I.Call, base: R.Environment, children: Forest)
  datatype Forest = Empty | Branch(at: seq<R.Request>, before: C.Word, after: C.Word, child: Tree, rest: Forest)
  datatype Receipt = Limited(call: I.Call, env: G.SelfEnvironment, children: Receipts)
                   | Executed(call: I.Call, env: G.SelfEnvironment, children: Receipts, reply: I.Reply)
  datatype Receipts = None | More(at: seq<R.Request>, request: R.Request, before: C.Word, after: C.Word,
                                  child: Receipt, rest: Receipts)
  datatype Boundary = Boundary(core: R.Address, encode: I.Call -> seq<Byte>, wire: W.Encoding)

  function Request(call: I.Call, b: Boundary): R.Request { R.Call(b.core,b.encode(call)) }
  function Environment(base: R.Environment, b: Boundary): G.SelfEnvironment {
    G.SelfEnvironment(b.core,(p: R.Param) => b.encode(I.Resolve(p)),base)
  }
  function Install(base: R.Environment, at: seq<R.Request>, request: R.Request, observed: R.Observation): R.Environment {
    R.Environment((h: seq<R.Request>,q: R.Request) => if h == at && q == request then observed else base.call(h,q),
                  base.balance,base.decodeCall,base.decodeOr)
  }
  function Has(rs: Receipts, at: seq<R.Request>, q: R.Request): bool {
    match rs
    case None => false
    case More(h,r,_,_,_,tail) => (h == at && r == q) || Has(tail,at,q)
  }
  function Unique(rs: Receipts): bool {
    match rs
    case None => true
    case More(at,q,_,_,_,tail) => !Has(tail,at,q) && Unique(tail)
  }
  function Observation(child: Receipt, before: C.Word, after: C.Word, b: Boundary): R.Observation {
    // Limited is deliberately not source-certified by Complete below.
    W.Observe(if child.Executed? then W.Serialize(child.reply,b.wire) else W.Reverted([]),before,after)
  }
  function Linked(base: R.Environment, rs: Receipts, b: Boundary): R.Environment {
    match rs
    case None => base
    case More(at,q,before,after,child,tail) =>
      Install(Linked(base,tail,b),at,q,Observation(child,before,after,b))
  }
  function Sites(rs: Receipts): set<(seq<R.Request>,R.Request)> {
    match rs
    case None => {}
    case More(at,q,_,_,_,tail) => {(at,q)} + Sites(tail)
  }
  function Reached(history: seq<R.Request>, core: R.Address): set<(seq<R.Request>,R.Request)> {
    set i: int | 0 <= i < |history| && history[i].Call? && history[i].target == core :: (history[..i],history[i])
  }
  ghost predicate ChildrenComplete(rs: Receipts, b: Boundary) {
    match rs
    case None => true
    case More(_,q,_,_,child,tail) => q == Request(child.call,b) && Complete(child,b) && ChildrenComplete(tail,b)
  }
  ghost predicate Complete(r: Receipt, b: Boundary) {
    r.Executed? && r.env.core == b.core &&
    I.Ready(r.call,r.env.base,[]) && I.Post(r.call,r.env,[],r.reply) &&
    Unique(r.children) && ChildrenComplete(r.children,b) &&
    Sites(r.children) == Reached(I.History(r.reply),b.core)
  }
  ghost predicate Matches(tree: Tree, r: Receipt, b: Boundary) {
    r.call == tree.call && ForestMatches(tree.children,r.children,b) &&
    r.env == Environment(Linked(tree.base,r.children,b),b) &&
    (r.Executed? <==> I.Ready(tree.call,r.env.base,[])) &&
    (r.Executed? ==> I.Post(tree.call,r.env,[],r.reply))
  }
  ghost predicate ForestMatches(f: Forest, rs: Receipts, b: Boundary) {
    match f
    case Empty => rs.None?
    case Branch(at,before,after,child,rest) =>
      rs.More? && rs.at == at && rs.before == before && rs.after == after &&
      rs.request == Request(child.call,b) && Matches(child,rs.child,b) && ForestMatches(rest,rs.rest,b)
  }

  ghost method Build(tree: Tree, b: Boundary) returns (r: Receipt)
    ensures Matches(tree,r,b)
    decreases tree
  {
    var children := BuildForest(tree.children,b);
    var env := Environment(Linked(tree.base,children,b),b);
    if I.Ready(tree.call,env.base,[]) {
      var reply := D.Run(tree.call,env,[]);
      r := Executed(tree.call,env,children,reply);
    } else {
      r := Limited(tree.call,env,children);
    }
  }
  ghost method BuildForest(f: Forest, b: Boundary) returns (rs: Receipts)
    ensures ForestMatches(f,rs,b)
    decreases f
  {
    match f {
      case Empty => rs := None;
      case Branch(at,before,after,child,rest) =>
        var receipt := Build(child,b);
        var tail := BuildForest(rest,b);
        rs := More(at,Request(child.call,b),before,after,receipt,tail);
    }
  }
  lemma SiteMembership(rs: Receipts, at: seq<R.Request>, q: R.Request)
    ensures Has(rs,at,q) <==> (at,q) in Sites(rs)
  {
    if rs.More? { SiteMembership(rs.rest,at,q); }
  }
  lemma Unrelated(base: R.Environment, rs: Receipts, b: Boundary, h: seq<R.Request>, q: R.Request)
    requires !Has(rs,h,q)
    ensures Linked(base,rs,b).call(h,q) == base.call(h,q)
    ensures Linked(base,rs,b).balance == base.balance
    ensures Linked(base,rs,b).decodeCall == base.decodeCall && Linked(base,rs,b).decodeOr == base.decodeOr
  {
    if rs.More? { Unrelated(base,rs.rest,b,h,q); }
  }
  ghost predicate Installed(rs: Receipts, env: R.Environment, b: Boundary) {
    match rs
    case None => true
    case More(at,q,before,after,child,tail) =>
      env.call(at,q) == Observation(child,before,after,b) && Installed(tail,env,b)
  }
  lemma PreserveInstalled(rs: Receipts, env: R.Environment, b: Boundary, h: seq<R.Request>, q: R.Request, ob: R.Observation)
    requires Installed(rs,env,b) && !Has(rs,h,q)
    ensures Installed(rs,Install(env,h,q,ob),b)
  {
    if rs.More? { PreserveInstalled(rs.rest,env,b,h,q,ob); }
  }
  lemma AllInstalled(base: R.Environment, rs: Receipts, b: Boundary)
    requires Unique(rs)
    ensures Installed(rs,Linked(base,rs,b),b)
  {
    if rs.More? {
      AllInstalled(base,rs.rest,b);
      PreserveInstalled(rs.rest,Linked(base,rs.rest,b),b,rs.at,rs.request,Observation(rs.child,rs.before,rs.after,b));
    }
  }
  ghost method Compose(tree: Tree, b: Boundary) returns (r: Receipt, certified: bool)
    ensures Matches(tree,r,b)
    ensures certified == Complete(r,b)
    ensures certified ==> Installed(r.children,r.env.base,b)
    ensures certified ==> Sites(r.children) == Reached(I.History(r.reply),b.core)
  {
    r := Build(tree,b);
    certified := Complete(r,b);
    if certified { AllInstalled(tree.base,r.children,b); }
  }
}
