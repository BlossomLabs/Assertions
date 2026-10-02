// SPDX-License-Identifier: MIT
include "Control.dfy"
include "../cache/Model.dfy"
include "../admission/Model.dfy"
module ExpressionEvaluationBridge {
  import E = ExpressionEvaluationControl
  import C = ExpressionCache
  import A = ExpressionAdmission
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel

  function KindOf(kind: A.Kind): E.Kind {
    match kind
    case Literal => E.Literal
    case Parameter => E.Parameter
    case Resolve => E.Resolve
    case Call => E.Call
    case Select => E.Select
    case Wrap => E.Wrap
    case Array => E.Array
    case Tuple => E.Tuple
    case TryOrElse => E.TryOrElse
    case IsValid => E.IsValid
    case ProbeCall => E.ProbeCall
  }

  function Project(nodes: seq<A.Node>): seq<E.Node> {
    seq(|nodes|, i requires 0 <= i < |nodes| => E.Node(KindOf(nodes[i].kind),nodes[i].refs))
  }

  lemma AdmittedGraph(nodes: seq<A.Node>, result: nat, hash: seq<Byte>->nat)
    requires forall i | 0 <= i < |nodes| :: Uint(|nodes[i].valueType|)
    requires A.Admit(nodes,result,hash).Accepted?
    ensures result < |nodes| && E.Program(Project(nodes))
  {
    assert result < |nodes|;
    assert A.Scan(nodes,0,hash).Accepted?;
    A.ScanVerdict(nodes,0,hash);
    forall i | 0 <= i < |nodes|
      ensures A.Backwards(nodes[i].refs,i) && A.Arity(nodes,i,hash)
    { assert A.NodeValid(nodes,i,hash); }
  }

  predicate Bytes(v: E.Value) { forall i | 0 <= i < |v| :: 0 <= v[i] < 256 }

  function Narrow(v: E.Value): seq<Byte>
    requires Bytes(v)
  { seq(|v|, i requires 0 <= i < |v| => v[i] as Byte) }

  lemma ByteIdentity(v: seq<Byte>)
    ensures Bytes(v) && Narrow(v) == v
  {}

  ghost function Canonical(types: seq<Descriptor>): (nat,E.Value)->bool
    requires C.Types(types)
  {
    (i: nat,v: E.Value) => i < |types| && Bytes(v) && Validate(TypeOf(types[i]),Narrow(v)).Parsed?
  }

  function View(cache: C.Cache): map<nat,E.Value>
    requires |cache.values| == |cache.ready|
  { map i: nat | i < |cache.ready| && cache.ready[i] :: cache.values[i] }

  lemma ViewValid(nodes: seq<E.Node>, types: seq<Descriptor>, cache: C.Cache)
    requires |nodes| == |types| && C.Valid(types,cache)
    ensures E.Good(nodes,Canonical(types),View(cache))
  {
    forall i | i in View(cache)
      ensures i < |nodes| && Canonical(types)(i,View(cache)[i])
    { ByteIdentity(cache.values[i]); }
  }

  ghost function Reify(types: seq<Descriptor>, template: C.Cache, memo: map<nat,E.Value>): C.Cache
    requires C.Metadata(types,template)
    requires forall i | i in memo :: i < |types| && Bytes(memo[i])
  {
    C.Cache(seq(|types|, i requires 0 <= i < |types| => if i in memo then Narrow(memo[i]) else template.values[i]),
            seq(|types|, i requires 0 <= i < |types| => i in memo),template.dynamic,template.words)
  }

  lemma ReifyValid(nodes: seq<E.Node>, types: seq<Descriptor>, original: C.Cache, memo: map<nat,E.Value>)
    requires |nodes| == |types| && C.Valid(types,original)
    requires E.Good(nodes,Canonical(types),memo) && E.Extends(View(original),memo)
    ensures C.Valid(types,Reify(types,original,memo))
    ensures C.Extends(original,Reify(types,original,memo))
    ensures forall i | i in memo :: Reify(types,original,memo).ready[i] && Reify(types,original,memo).values[i] == Narrow(memo[i])
  {
    forall i | 0 <= i < |types| && original.ready[i]
      ensures Reify(types,original,memo).ready[i] && Reify(types,original,memo).values[i] == original.values[i]
    { ByteIdentity(original.values[i]); }
  }

  // Derives the cache package's successful-receipt obligation from recursive
  // control, rather than assuming a successful receipt at each guarded call.
  ghost method SuccessfulReceipt(nodes: seq<E.Node>, types: seq<Descriptor>, original: C.Cache,
                                 truth: E.Value->bool, oracle: (E.Request,seq<E.Request>)->E.Raw,
                                 index: nat, history: seq<E.Request>) returns (out: E.Result)
    requires E.Program(nodes) && index < |nodes| && |nodes| == |types|
    requires C.Valid(types,original)
    ensures E.Good(nodes,Canonical(types),out.memo) && E.Extends(View(original),out.memo)
    ensures out.Success? ==> Bytes(out.value)
    ensures out.Success? ==> C.SuccessfulReceipt(types,index,original,
                                                 C.Succeeded(Narrow(out.value),Reify(types,original,out.memo)))
    ensures out.Success? ==> Validate(TypeOf(types[index]),Narrow(out.value)).Parsed?
    ensures out.Success? ==> WellTyped(TypeOf(types[index]),Validate(TypeOf(types[index]),Narrow(out.value)).value)
    ensures out.Success? ==> Narrow(out.value) == Encode(TypeOf(types[index]),Validate(TypeOf(types[index]),Narrow(out.value)).value)
  {
    ViewValid(nodes,types,original);
    out := E.Run(nodes,Canonical(types),truth,oracle,index,View(original),history);
    ReifyValid(nodes,types,original,out.memo);
    if out.Success? { C.ReuseCanonical(types,Reify(types,original,out.memo),index); }
  }
}
