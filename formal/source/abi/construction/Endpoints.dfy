// SPDX-License-Identifier: MIT
include "Unpack.generated.dfy"

module AbiConstructionEndpoints {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import AbiParserSource
  import opened AbiConnectionModel
  import opened AbiDynamicSemantics
  import opened AbiLayoutSpec
  import opened AbiLayoutSource
  import opened AbiLayoutSoundness
  import opened AbiConstructionContext
  import opened AbiConstructionModel
  import opened AbiConstructionTuple
  import opened AbiConstructionSplitting
  import opened AbiConstructionUnpack

  ghost method Unpack(t: seq<Byte>, encoded: seq<Byte>) returns (values: seq<seq<Byte>>, r: Result)
    requires Uint(|t|) && Uint(|encoded|)
    ensures Whole(t).BadDescriptor? ==> r == InvalidDescriptor(Whole(t).at)
    ensures Whole(t).ArithmeticPanic? ==> r == Result.Panic(17)
    ensures Whole(t).Shaped? ==> WellFormed(Array(TypeOf(Whole(t).syntax)))
    ensures Whole(t).Shaped? && r.Panic? ==> !CursorRoom(Whole(t).syntax,|encoded|)
    ensures Whole(t).Shaped? && !r.Panic? ==> r.Success? == Validate(Array(TypeOf(Whole(t).syntax)),encoded).Parsed?
    ensures r.Success? ==> Whole(t).Shaped? && WellTyped(Array(TypeOf(Whole(t).syntax)),Validate(Array(TypeOf(Whole(t).syntax)),encoded).value)
    ensures r.Success? ==> values == Encodings(TypeOf(Whole(t).syntax),Validate(Array(TypeOf(Whole(t).syntax)),encoded).value.values)
  {
    values := [];
    var shape := AbiParserSource.Shape(t);
    if shape.BadDescriptor? { r := InvalidDescriptor(shape.at); return; }
    if shape.ArithmeticPanic? { r := Result.Panic(17); return; }
    var raw: Outcome;
    values,raw := UnpackParsed(t,encoded,shape.syntax);
    r := Route(raw,Context(ValueKind,0,0,0,0));
  }

  ghost method TupleEntrypoint(t: seq<Byte>, args: seq<seq<Byte>>) returns (out: seq<Byte>, r: Result)
    requires Uint(|t|) && Uint(|args|) && Uint(TotalBytes(args))
    requires forall i :: 0 <= i < |args| ==> Uint(|args[i]|)
    ensures Reference(t).BadLayout? ==> r == InvalidDescriptor(Reference(t).at)
    ensures Reference(t).LayoutPanic? ==> r == Result.Panic(17)
    ensures r.Success? ==> (exists fs ::
                              Admissible(Group(fs)) && t == Render(Group(fs)) && ValidInputs(fs,args) &&
                              WellTyped(TypeOf(Group(fs)),Items(Decoded(fs,args))) && out == Body(TypeOf(Group(fs)),Items(Decoded(fs,args))))
  {
    out := [];
    var plan := Layout(t);
    if plan.BadLayout? { r := InvalidDescriptor(plan.at); return; }
    if plan.LayoutPanic? { r := Result.Panic(17); return; }
    var fs := LayoutWitness(t);
    out,r := TuplePlan(plan,t,args,fs);
  }
}
