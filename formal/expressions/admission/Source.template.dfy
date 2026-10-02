// SPDX-License-Identifier: MIT
// Admission prefix of gated Expressions.sol $HASH
include "Model.dfy"
module ExpressionAdmissionSource {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened ExpressionAdmission
  import AbiParserSource

  ghost method CheckReferences(refs: seq<nat>, index: nat) returns (out: RefResult)
    ensures out == References(refs,index,0)
  {
    var j := 0;
    while j < |refs|
      invariant 0 <= j <= |refs|
      invariant forall k :: 0 <= k < j ==> refs[k] < index
      invariant References(refs,index,0) == References(refs,index,j)
    {
      if $REF_CHECK { out := BadRef(j,refs[j]); return; }
      j := j+1;
    }
    out := RefsOK;
  }

  ghost method CheckArity(nodes: seq<Node>, index: nat, hash: seq<Byte> -> nat) returns (ok: bool)
    requires index < |nodes| && Backwards(nodes[index].refs,index)
    ensures ok == Arity(nodes,index,hash)
  {
    var node := nodes[index];
    if node.kind == Call {
      if |node.refs| == 0 { ok := false; return; }
    } else if node.kind == Select {
      if $SELECT_COUNT { ok := false; return; }
    } else if node.kind == TryOrElse || node.kind == ProbeCall {
      if |node.refs| != 2 { ok := false; return; }
      if node.kind == ProbeCall && hash(nodes[node.refs[1]].valueType) != hash(BytesType()) { ok := false; return; }
    } else if node.kind == Wrap || node.kind == IsValid {
      if |node.refs| != 1 { ok := false; return; }
    } else if node.kind != Array && node.kind != Tuple && |node.refs| != 0 {
      ok := false; return;
    }
    ok := true;
  }

  ghost method Prepare(nodes: seq<Node>, result: nat, hash: seq<Byte> -> nat) returns (out: ExpressionAdmission.Outcome)
    requires forall i :: 0 <= i < |nodes| ==> Uint(|nodes[i].valueType|)
    ensures out == Admit(nodes,result,hash)
    ensures out.Accepted? ==> (forall i :: 0 <= i < |out.shapes| ==>
                                             out.shapes[i].Shaped? && Admissible(out.shapes[i].syntax) &&
                                             out.shapes[i].dynamic == Dyn(out.shapes[i].syntax) && out.shapes[i].words == Width(out.shapes[i].syntax) &&
                                             0 < out.shapes[i].words < Limit())
    ensures out.Accepted? ==> (result < |nodes| && |out.shapes| == |nodes| &&
                               (forall i :: 0 <= i < |nodes| ==> NodeValid(nodes,i,hash) && out.shapes[i] == Whole(nodes[i].valueType)))
  {
    if $RESULT_CHECK { out := Rejected(InvalidNode(result)); return; }
    var shapes: seq<ShapeResult> := [];
    var i := 0;
    while i < |nodes|
      invariant 0 <= i <= |nodes| && |shapes| == i
      invariant forall k :: 0 <= k < |shapes| ==> shapes[k].Shaped? && Admissible(shapes[k].syntax) &&
                                                  shapes[k].dynamic == Dyn(shapes[k].syntax) && shapes[k].words == Width(shapes[k].syntax) && 0 < shapes[k].words < Limit()
      invariant Admit(nodes,result,hash) == Prepend(shapes,Scan(nodes,i,hash))
    {
      var node := nodes[i];
      var shape := AbiParserSource.Shape(node.valueType);
      if shape.BadDescriptor? { out := Rejected(InvalidDescriptor(shape.at)); return; }
      if shape.ArithmeticPanic? { out := Rejected(ExpressionAdmission.Error.Panic(17)); return; }
      var refs := CheckReferences(node.refs,i);
      if refs.BadRef? { out := Rejected(InvalidReference(i,refs.reference)); return; }
      ReferenceVerdict(node.refs,i,0);
      var ok := CheckArity(nodes,i,hash);
      if !ok { out := Rejected(InvalidNode(i)); return; }
      shapes := shapes+[shape];
      i := i+1;
    }
    out := Accepted(shapes);
    ScanVerdict(nodes,0,hash);
  }
}
