// SPDX-License-Identifier: MIT
include "Static.generated.dfy"
include "Dynamic.generated.dfy"

module AbiExactOutcomeCached {
  import Exact = AbiExactOutcomeSpec
  import AbiExactOutcomeStatic
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import AbiConnectionSource
  import opened AbiDynamicSemantics
  import opened AbiExactOutcomeDynamic

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
    ensures r == Exact.Validate(s,v)
  {
    if dynamic { r := ValidateDynamic(t,v,s); }
    else { r := AbiExactOutcomeStatic.ValidateStatic(t,v,words,s); }
  }

}
