// SPDX-License-Identifier: MIT
// AbiCodec.sol gated source 485f0d49f35528cc4c9be7767c631be6903ff57b5cb95bcbb25d6cd04ce5fed6
include "../abi/construction/Tuple.generated.dfy"
module ArgumentsTuple {
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

  ghost method {:isolate_assertions} TupleChecked(plan: LayoutResult, t: seq<Byte>, args: seq<seq<Byte>>, fs: seq<Descriptor>)
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
    ensures r.ComponentCountMismatch? <==> |fs| != |args|
    ensures r.InvalidComponentEnvelope? || r.InvalidComponentLength? || r.InvalidComponentValue? ==>
              r.index < |fs| && |fs| == |args| && !ValidInput(fs[r.index],args[r.index]) &&
              (forall j :: 0 <= j < r.index ==> ValidInput(fs[j],args[j]))
    ensures r.InvalidComponentEnvelope? ==> r.length == |args[r.index]| &&
                                            r.head == (if |args[r.index]| >= 32 then ReadNat(args[r.index][..32]) else 0)
    ensures r.InvalidComponentLength? ==> r.expected == 32*Width(fs[r.index]) && r.actual == |args[r.index]|
    ensures !r.InvalidValue? && !r.InvalidCallbackResult? && !r.InvalidDescriptor?
  {
    out := [];
    if (|args| != |plan.starts|) { r := ComponentCountMismatch(|plan.starts|,|args|); return; }
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

}
