// SPDX-License-Identifier: MIT
// Dynamic wrapper body from the restricted AST translator. Solidity SHA256: 485f0d49f35528cc4c9be7767c631be6903ff57b5cb95bcbb25d6cd04ce5fed6
include "Body.generated.dfy"

module AbiDynamicValidation {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiBytesSource
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import AbiParserSource
  import opened AbiConnectionModel
  import AbiConnectionSource
  import opened AbiDynamicSemantics
  import opened AbiDynamicSource

  datatype ValidationResult = Accepted(dynamic: bool) | DescriptorFailure(at: nat)
                            | ValueFailure(at: nat) | CheckedPanic(code: nat)

  ghost method ValidateDynamic(t: seq<Byte>, v: seq<Byte>, s: Descriptor) returns (r: Outcome)
    requires Uint(|t|) && Uint(|v|)
    requires Admissible(s) && Dyn(s) && t == Render(s)
    ensures WellFormed(TypeOf(s))
    ensures r.Panic? ==> r.code == 17 && !CursorRoom(s,|v|)
    ensures !r.Panic? ==> r.Ok? == Validate(TypeOf(s),v).Parsed?
    ensures r.Ok? ==> r == Ok(0)
  {
    ModelType(s);
    // solc AST 1179 @ 23505:51:0
    var tmp23 := ReadWord(v,0);
    if !tmp23.Ok? { r := tmp23; return; }
    if !((tmp23.used == 32)) {
      r := Invalid(0); return;
    }
    // solc AST 1193 @ 23566:55:0
    var tmp24 := FullBody(t,0,|t|,v,32,s);
    if !tmp24.Ok? { r := tmp24; return; }
    var tmp25: int := 32 + tmp24.used;
    if !Uint(tmp25) { r := Panic(17); return; }
    var end: int := tmp25;
    // solc AST 1202 @ 23631:43:0
    if !((end == |v|)) {
      r := Invalid(end); return;
    }
    r := Ok(0);
  }

  // Actual noncached validate dispatch: the source parser supplies the entire
  // descriptor witness. Malformed descriptors and parser arithmetic failures
  // are represented too, rather than excluded as entrypoint assumptions.
  ghost method ValidateValue(t: seq<Byte>, v: seq<Byte>) returns (r: ValidationResult)
    requires Uint(|t|) && Uint(|v|)
    ensures Whole(t).BadDescriptor? ==> r == DescriptorFailure(Whole(t).at)
    ensures Whole(t).ArithmeticPanic? ==> r == CheckedPanic(17)
    ensures Whole(t).Shaped? ==> WellFormed(TypeOf(Whole(t).syntax))
    ensures Whole(t).Shaped? ==> !r.DescriptorFailure?
    ensures Whole(t).Shaped? && r.CheckedPanic? ==> r.code == 17 && !CursorRoom(Whole(t).syntax,|v|)
    ensures Whole(t).Shaped? && !r.CheckedPanic? ==> r.Accepted? == Validate(TypeOf(Whole(t).syntax),v).Parsed?
    ensures r.Accepted? ==> Whole(t).Shaped? && r.dynamic == Whole(t).dynamic
    ensures r.Accepted? ==> exists value :: WellTyped(TypeOf(Whole(t).syntax),value) &&
                                            Fits(TypeOf(Whole(t).syntax),value) && Encode(TypeOf(Whole(t).syntax),value) == v
  {
    var shape := AbiParserSource.Shape(t);
    if shape.BadDescriptor? { r := DescriptorFailure(shape.at); return; }
    if shape.ArithmeticPanic? { r := CheckedPanic(17); return; }
    var result: Outcome;
    if shape.dynamic { result := ValidateDynamic(t,v,shape.syntax); }
    else { result := AbiConnectionSource.ValidateStatic(t,v,shape.words,shape.syntax); }
    AcceptedIffCanonical(TypeOf(shape.syntax),v);
    r := if result.Panic? then CheckedPanic(result.code) else
    if result.Invalid? then ValueFailure(result.offset) else Accepted(shape.dynamic);
  }

  ghost method CanonicalAcceptance(t: seq<Byte>, v: seq<Byte>) returns (r: ValidationResult)
    requires Uint(|t|) && Uint(|v|)
    requires Whole(t).Shaped? && CursorRoom(Whole(t).syntax,|v|)
    ensures WellFormed(TypeOf(Whole(t).syntax))
    ensures !r.CheckedPanic? && !r.DescriptorFailure?
    ensures r.Accepted? <==> exists value :: WellTyped(TypeOf(Whole(t).syntax),value) &&
                                             Fits(TypeOf(Whole(t).syntax),value) && Encode(TypeOf(Whole(t).syntax),value) == v
  {
    r := ValidateValue(t,v);
    AcceptedIffCanonical(TypeOf(Whole(t).syntax),v);
  }
  // An explicit input-size arithmetic budget discharges all zero-copy cursor
  // premises, without a nesting, tuple-arity, array-count or loop-unrolling cap.
  ghost method ResourceBoundedAcceptance(t: seq<Byte>, v: seq<Byte>) returns (r: ValidationResult)
    requires Uint(|t|) && Uint(|v|)
    requires Uint(|v|+32*0x100000000*|t|) && Whole(t).Shaped?
    ensures WellFormed(TypeOf(Whole(t).syntax))
    ensures !r.CheckedPanic? && !r.DescriptorFailure?
    ensures r.Accepted? <==> exists value :: WellTyped(TypeOf(Whole(t).syntax),value) &&
                                             Fits(TypeOf(Whole(t).syntax),value) && Encode(TypeOf(Whole(t).syntax),value) == v
  {
    var shape := AbiParserSource.Shape(t);
    RoomFromText(shape.syntax,|v|);
    r := CanonicalAcceptance(t,v);
  }

}
