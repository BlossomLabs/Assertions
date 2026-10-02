// SPDX-License-Identifier: MIT
include "../../abi/parser/Parser.generated.dfy"
module ExpressionAdmission {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec

  datatype Kind = Literal | Parameter | Resolve | Call | Select | Wrap | Array | Tuple | TryOrElse | IsValid | ProbeCall
  datatype Node = Node(kind: Kind, valueType: seq<Byte>, data: seq<Byte>, refs: seq<nat>, selector: seq<Byte>, arguments: seq<Byte>)
  datatype Error = InvalidNode(index: nat) | InvalidReference(index: nat, reference: nat)
                 | InvalidDescriptor(position: nat) | Panic(code: nat)
  datatype RefResult = RefsOK | BadRef(position: nat, reference: nat)
  datatype Outcome = Rejected(error: Error) | Accepted(shapes: seq<ShapeResult>)

  function BytesType(): seq<Byte> { [98,121,116,101,115] }
  function References(refs: seq<nat>, bound: nat, start: nat): RefResult
    requires start <= |refs|
    decreases |refs|-start
  {
    if start == |refs| then RefsOK else
    if refs[start] >= bound then BadRef(start,refs[start]) else References(refs,bound,start+1)
  }

  predicate Backwards(refs: seq<nat>, bound: nat) {
    forall j :: 0 <= j < |refs| ==> refs[j] < bound
  }

  predicate Arity(nodes: seq<Node>, index: nat, hash: seq<Byte> -> nat)
    requires index < |nodes| && Backwards(nodes[index].refs,index)
  {
    var n := nodes[index];
    match n.kind
    case Call => |n.refs| > 0
    case Select => |n.refs| == 3
    case TryOrElse => |n.refs| == 2
    case ProbeCall => |n.refs| == 2 && hash(nodes[n.refs[1]].valueType) == hash(BytesType())
    case Wrap => |n.refs| == 1
    case IsValid => |n.refs| == 1
    case Array => true
    case Tuple => true
    case _ => |n.refs| == 0
  }

  function Prepend(shapes: seq<ShapeResult>, rest: Outcome): Outcome {
    if rest.Rejected? then rest else Accepted(shapes+rest.shapes)
  }

  function Scan(nodes: seq<Node>, start: nat, hash: seq<Byte> -> nat): Outcome
    requires start <= |nodes|
    requires forall i :: start <= i < |nodes| ==> Uint(|nodes[i].valueType|)
    decreases |nodes|-start
  {
    if start == |nodes| then Accepted([]) else
    var shape := Whole(nodes[start].valueType);
    if shape.BadDescriptor? then Rejected(InvalidDescriptor(shape.at)) else
    if shape.ArithmeticPanic? then Rejected(Error.Panic(17)) else
    var refs := References(nodes[start].refs,start,0);
    if refs.BadRef? then Rejected(InvalidReference(start,refs.reference)) else
    ReferenceVerdict(nodes[start].refs,start,0);
    if !Arity(nodes,start,hash) then Rejected(InvalidNode(start)) else
    Prepend([shape],Scan(nodes,start+1,hash))
  }

  function Admit(nodes: seq<Node>, result: nat, hash: seq<Byte> -> nat): Outcome
    requires forall i :: 0 <= i < |nodes| ==> Uint(|nodes[i].valueType|)
  { if result >= |nodes| then Rejected(InvalidNode(result)) else Scan(nodes,0,hash) }

  lemma ReferenceVerdict(refs: seq<nat>, bound: nat, start: nat)
    requires start <= |refs|
    ensures References(refs,bound,start).RefsOK? <==> (forall j :: start <= j < |refs| ==> refs[j] < bound)
    ensures References(refs,bound,start).BadRef? ==>
              start <= References(refs,bound,start).position < |refs| &&
              References(refs,bound,start).reference == refs[References(refs,bound,start).position] &&
              References(refs,bound,start).reference >= bound &&
              (forall j :: start <= j < References(refs,bound,start).position ==> refs[j] < bound)
    decreases |refs|-start
  {
    if start < |refs| && refs[start] < bound { ReferenceVerdict(refs,bound,start+1); }
  }

  ghost predicate NodeValid(nodes: seq<Node>, index: nat, hash: seq<Byte> -> nat)
    requires index < |nodes| && Uint(|nodes[index].valueType|)
  {
    Whole(nodes[index].valueType).Shaped? && Backwards(nodes[index].refs,index) && Arity(nodes,index,hash)
  }

  lemma ScanVerdict(nodes: seq<Node>, start: nat, hash: seq<Byte> -> nat)
    requires start <= |nodes|
    requires forall i :: start <= i < |nodes| ==> Uint(|nodes[i].valueType|)
    ensures Scan(nodes,start,hash).Accepted? <==> (forall i :: start <= i < |nodes| ==> NodeValid(nodes,i,hash))
    ensures Scan(nodes,start,hash).Accepted? ==>
              |Scan(nodes,start,hash).shapes| == |nodes|-start &&
              (forall i :: 0 <= i < |nodes|-start ==> Scan(nodes,start,hash).shapes[i] == Whole(nodes[start+i].valueType))
    decreases |nodes|-start
  {
    if start < |nodes| {
      ReferenceVerdict(nodes[start].refs,start,0);
      ScanVerdict(nodes,start+1,hash);
      assert Scan(nodes,start,hash).Accepted? == (NodeValid(nodes,start,hash) && Scan(nodes,start+1,hash).Accepted?);
      if Scan(nodes,start,hash).Accepted? {
        forall i | start <= i < |nodes|
          ensures NodeValid(nodes,i,hash)
        { if i > start { assert start+1 <= i; } }
      } else {
        if !NodeValid(nodes,start,hash) { assert !(forall i :: start <= i < |nodes| ==> NodeValid(nodes,i,hash)); }
        else { assert !Scan(nodes,start+1,hash).Accepted?; }
      }
    }
  }

  lemma ProbeType(nodes: seq<Node>, index: nat, hash: seq<Byte> -> nat)
    requires index < |nodes| && Uint(|nodes[index].valueType|)
    requires NodeValid(nodes,index,hash) && nodes[index].kind == ProbeCall
    requires forall j :: 0 <= j < |nodes| && hash(nodes[j].valueType) == hash(BytesType()) ==> nodes[j].valueType == BytesType()
    ensures nodes[nodes[index].refs[1]].valueType == BytesType()
  {}
}
