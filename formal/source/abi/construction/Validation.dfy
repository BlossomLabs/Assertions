// SPDX-License-Identifier: MIT
include "../layout/Soundness.dfy"

module AbiConstructionValidation {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import AbiConnectionSource
  import opened AbiDynamicSemantics
  import opened AbiDynamicValidation

  // The cached overload's real caller contract: the cached shape belongs to
  // this descriptor. It does not promise to defend against forged cache data.
  ghost method CachedValidate(t: seq<Byte>, v: seq<Byte>, s: Descriptor, dynamic: bool, words: nat)
    returns (r: Outcome)
    requires Uint(|t|) && Uint(|v|)
    requires Admissible(s) && t == Render(s) && dynamic == Dyn(s) && words == Width(s)
    ensures WellFormed(TypeOf(s))
    ensures r.Panic? ==> r.code == 17 && !CursorRoom(s,|v|)
    ensures !r.Panic? ==> r.Ok? == Validate(TypeOf(s),v).Parsed?
    ensures r.Ok? ==> r == Ok(0)
  {
    if dynamic { r := ValidateDynamic(t,v,s); }
    else { r := AbiConnectionSource.ValidateStatic(t,v,words,s); }
  }

  lemma CanonicalEnvelope(s: Descriptor, v: seq<Byte>)
    requires Good(s) && Dyn(s)
    requires Uint(|v|) && WellFormed(TypeOf(s)) && Validate(TypeOf(s),v).Parsed?
    ensures |v| >= 64 && |v| % 32 == 0 && ReadNat(v[..32]) == 32
  {
    ModelType(s);
    ValidationSound(TypeOf(s),v);
    var value := Validate(TypeOf(s),v).value;
    BodiesAreFrames(TypeOf(s),value);
    assert v == Encode(TypeOf(s),value);
    assert |Body(TypeOf(s),value)| > 0 && |Body(TypeOf(s),value)| % 32 == 0;
    assert |Body(TypeOf(s),value)| >= 32;
  }
}
