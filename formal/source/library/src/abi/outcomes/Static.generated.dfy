// SPDX-License-Identifier: MIT
// Source-derived connection helpers; Solidity SHA256: 485f0d49f35528cc4c9be7767c631be6903ff57b5cb95bcbb25d6cd04ce5fed6
include "Spec.dfy"

module AbiExactOutcomeStatic {
  import Exact = AbiExactOutcomeSpec
  import AbiConnectionSource
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiBytesSource
  import opened AbiWordSemantics
  import opened AbiCursorSemantics
  import opened AbiCursorSource
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import AbiParserSource
  import opened AbiTupleWords
  import opened AbiTupleSemantics
  import AbiTupleSource
  import opened AbiConnectionModel
  import opened AbiConnectionStatic
  import opened AbiConnectionDescriptor

  ghost method LengthGuard(length: nat, words: nat) returns (ok: bool)
    ensures ok == (length == 32*words)
  { AbiConnectionSource.ExactWordLength(length,words); ok := (((length % 32) == 0) && (words == (length / 32))); }

  ghost method ValidateStatic(t: seq<Byte>, v: seq<Byte>, words: nat, s: Descriptor) returns (r: Outcome)
    requires Uint(|t|) && Uint(|v|)
    requires Good(s) && !Dyn(s) && Render(s) == t && words == Width(s)
    ensures WellFormed(TypeOf(s))
    ensures !r.Panic?
    ensures r.Ok? == Validate(TypeOf(s),v).Parsed?
    ensures r.Ok? <==> exists value :: WellTyped(TypeOf(s),value) &&
                                       Fits(TypeOf(s),value) && Encode(TypeOf(s),value) == v
    ensures r.Ok? ==> r == Ok(0)
    ensures |v| != 32*words ==> r == Invalid(0)
    ensures r == Exact.Validate(s,v)
  {
    ModelType(s);
    var fits := LengthGuard(|v|,words);
    if !fits {
      if Validate(TypeOf(s),v).Parsed? { StaticExtent(TypeOf(s),v); }
      AcceptedIffCanonical(TypeOf(s),v);
      r := Invalid(0); return;
    }
    assert Uint(32*Width(s));
    assert Located(t,0,|t|,s);
    var end: nat; var width: nat;
    end,width,r := AbiTupleSource.CheckWords(t,0,|t|,1,v,0,s);
    RepeatOne(Rules(s));
    StaticValidation(s,v);
  }

}
