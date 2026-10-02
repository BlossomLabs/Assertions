// SPDX-License-Identifier: MIT
// Dynamic wrapper body from the restricted AST translator. Solidity SHA256: 485f0d49f35528cc4c9be7767c631be6903ff57b5cb95bcbb25d6cd04ce5fed6
include "Body.generated.dfy"

module AbiExactOutcomeDynamic {
  import Exact = AbiExactOutcomeSpec
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
  import opened AbiExactOutcomeSource

  datatype ValidationResult = Accepted(dynamic: bool) | DescriptorFailure(at: nat)
                            | ValueFailure(at: nat) | CheckedPanic(code: nat)

  ghost method ValidateDynamic(t: seq<Byte>, v: seq<Byte>, s: Descriptor) returns (r: Outcome)
    requires Uint(|t|) && Uint(|v|)
    requires Admissible(s) && Dyn(s) && t == Render(s)
    ensures WellFormed(TypeOf(s))
    ensures r.Panic? ==> r.code == 17 && !CursorRoom(s,|v|)
    ensures !r.Panic? ==> r.Ok? == Validate(TypeOf(s),v).Parsed?
    ensures r.Ok? ==> r == Ok(0)
    ensures r == Exact.Validate(s,v)
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

}
