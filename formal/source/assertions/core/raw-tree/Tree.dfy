// SPDX-License-Identifier: MIT
include "../frame-tree/Connection.dfy"

module CoreRawTree {
  import opened AbiFrames
  import opened AbiByteSemantics
  import I = CoreRecursiveInvocation
  import D = CoreRecursiveDispatch
  import R = ResolutionModel
  import G = GuardModel
  import W = CoreFrameWire
  import C = ConstraintModel

  datatype Decode = Rejected | Accepted(call: I.Call)
  datatype Tree = Frame(data: seq<Byte>, base: R.Environment, children: Forest)
  datatype Forest = Empty | Branch(at: seq<R.Request>, before: C.Word, after: C.Word, child: Tree, rest: Forest)
  datatype State = DecodeRejected | Unready(call: I.Call) | Ran(call: I.Call, reply: I.Reply)
  datatype Receipt = Receipt(data: seq<Byte>, env: G.SelfEnvironment, children: Receipts, state: State)
  datatype Receipts = None | More(at: seq<R.Request>, request: R.Request, before: C.Word, after: C.Word,
                                  child: Receipt, rest: Receipts)
  datatype Boundary = Boundary(core: R.Address, encodeResolve: R.Param -> seq<Byte>, decode: seq<Byte> -> Decode, wire: W.Encoding)

  function Request(data: seq<Byte>, b: Boundary): R.Request { R.Call(b.core,data) }
  function Environment(base: R.Environment, b: Boundary): G.SelfEnvironment {
    G.SelfEnvironment(b.core,(p: R.Param) => b.encodeResolve(p),base)
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
    W.Observe(Raw(child,b),before,after)
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
    case More(_,q,_,_,child,tail) => q == Request(child.data,b) && Complete(child,b) && ChildrenComplete(tail,b)
  }
  function History(r: Receipt): seq<R.Request> {
    if r.state.Ran? then I.History(r.state.reply) else []
  }
  function Raw(r: Receipt, b: Boundary): W.Raw {
    if r.state.Ran? then W.Serialize(r.state.reply,b.wire) else W.Reverted([])
  }
  ghost predicate FramePost(r: Receipt, b: Boundary) {
    r.env.core == b.core && (forall p :: r.env.encodeResolve(p) == b.encodeResolve(p)) &&
    (match b.decode(r.data)
     case Rejected => r.state.DecodeRejected?
     case Accepted(call) =>
       !r.state.DecodeRejected? && r.state.call == call &&
       (r.state.Ran? <==> I.Ready(call,r.env.base,[])) &&
       (r.state.Ran? ==> I.Post(call,r.env,[],r.state.reply)))
  }
  ghost predicate Complete(r: Receipt, b: Boundary) {
    !r.state.Unready? && FramePost(r,b) &&
    Unique(r.children) && ChildrenComplete(r.children,b) &&
    Sites(r.children) == Reached(History(r),b.core)
  }
  ghost predicate Matches(tree: Tree, r: Receipt, b: Boundary) {
    r.data == tree.data && ForestMatches(tree.children,r.children,b) &&
    r.env == Environment(Linked(tree.base,r.children,b),b) && FramePost(r,b)
  }
  ghost predicate ForestMatches(f: Forest, rs: Receipts, b: Boundary) {
    match f
    case Empty => rs.None?
    case Branch(at,before,after,child,rest) =>
      rs.More? && rs.at == at && rs.before == before && rs.after == after &&
      rs.request == Request(child.data,b) && Matches(child,rs.child,b) && ForestMatches(rest,rs.rest,b)
  }

  ghost method Build(tree: Tree, b: Boundary) returns (r: Receipt)
    ensures Matches(tree,r,b)
    decreases tree
  {
    var children := BuildForest(tree.children,b);
    var env := Environment(Linked(tree.base,children,b),b);
    match b.decode(tree.data) {
      case Rejected => r := Receipt(tree.data,env,children,DecodeRejected);
      case Accepted(call) =>
        if I.Ready(call,env.base,[]) {
          var reply := D.Run(call,env,[]);
          r := Receipt(tree.data,env,children,Ran(call,reply));
        } else {
          r := Receipt(tree.data,env,children,Unready(call));
        }
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
        rs := More(at,Request(child.data,b),before,after,receipt,tail);
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
    ensures certified ==> Sites(r.children) == Reached(History(r),b.core)
  {
    r := Build(tree,b);
    certified := Complete(r,b);
    if certified { AllInstalled(tree.base,r.children,b); }
  }
}
