// SPDX-License-Identifier: MIT
// Source $HASH; complete wrapper AST bound by construction/generate.py.
include "Model.dfy"

module AbiConstructionTuple {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiTupleSemantics
  import opened AbiConnectionModel
  import opened AbiLayoutSpec
  import opened AbiLayoutCanonical
  import opened AbiConstructionModel
  import opened AbiConstructionContext
  import opened AbiConstructionComponent
  import opened AbiConstructionAssembly

  ghost method {:isolate_assertions} TuplePlan(plan: LayoutResult, t: seq<Byte>, args: seq<seq<Byte>>, fs: seq<Descriptor>)
    returns (out: seq<Byte>, r: Result)
    requires Admissible(Group(fs)) && t == Render(Group(fs)) && Uint(|t|)
    requires plan == PlanFor(0,fs,0) && Uint(plan.head)
    requires Uint(|args|) && (forall i :: 0 <= i < |args| ==> Uint(|args[i]|))
    requires Uint(TotalBytes(args))
    ensures !r.Panic? ==> r.Success? == ValidInputs(fs,args)
    ensures r.Success? ==> ValidInputs(fs,args) && out == Frame(Pieces(fs,args))
    ensures r.Success? ==> WellTyped(TypeOf(Group(fs)),Items(Decoded(fs,args)))
    ensures r.Success? ==> out == Body(TypeOf(Group(fs)),Items(Decoded(fs,args)))
    ensures r.ComponentCountMismatch? ==> r.expected == |fs| && r.actual == |args|
  {
    out := [];
    if |args| != |plan.starts| { r := ComponentCountMismatch(|plan.starts|,|args|); return; }
    PlanIndex(0,fs,0);
    var i := 0;
    while i < |args|
      invariant 0 <= i <= |args|
      invariant forall j :: 0 <= j < i ==> ValidInput(fs[j],args[j])
    {
      LocateField(t,0,|t|,fs,i);
      var part := t[plan.starts[i]..plan.ends[i]];
      assert part == Render(fs[i]);
      r := Component(part,args[i],i,plan.dynamics[i],plan.words[i],fs[i]);
      if !r.Success? { return; }
      i := i+1;
    }
    assert ValidInputs(fs,args);
    CanonicalPieces(fs,args); PiecesIndex(fs,args); FrameBudget(fs,args);
    out := Assemble(plan.dynamics,plan.head,args,false,Pieces(fs,args));
    ModelType(Group(fs)); TypesIndex(fs);
    assert Children(TypeOf(Group(fs)),|fs|) == TypesOf(fs);
    AggregateParts(TypeOf(Group(fs)),Decoded(fs,args));
    r := Success;
  }

  ghost method Tuple(t: seq<Byte>, args: seq<seq<Byte>>, fs: seq<Descriptor>)
    returns (out: seq<Byte>, r: Result)
    requires Admissible(Group(fs)) && t == Render(Group(fs)) && Uint(|t|)
    requires Uint(32*WidthSum(fs))
    requires Uint(|args|) && (forall i :: 0 <= i < |args| ==> Uint(|args[i]|))
    requires Uint(TotalBytes(args))
    ensures !r.Panic? ==> r.Success? == ValidInputs(fs,args)
    ensures r.Success? ==> ValidInputs(fs,args) && out == Frame(Pieces(fs,args))
    ensures r.Success? ==> WellTyped(TypeOf(Group(fs)),Items(Decoded(fs,args)))
    ensures r.Success? ==> out == Body(TypeOf(Group(fs)),Items(Decoded(fs,args)))
  {
    var plan := CanonicalLayout(t,fs);
    out,r := TuplePlan(plan,t,args,fs);
  }

  ghost method IsDynamic(plan: LayoutResult) returns (r: bool)
    requires plan.Plan?
    ensures r == (exists i :: 0 <= i < |plan.dynamics| && plan.dynamics[i])
  {
    var i := 0;
    while i < |plan.dynamics|
      invariant 0 <= i <= |plan.dynamics|
      invariant forall j :: 0 <= j < i ==> !plan.dynamics[j]
    {
      if plan.dynamics[i] { r := true; return; }
      i := i+1;
    }
    r := false;
  }
}
