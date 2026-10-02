// SPDX-License-Identifier: MIT
// Source 485f0d49f35528cc4c9be7767c631be6903ff57b5cb95bcbb25d6cd04ce5fed6; branch structure bound by construction/generate.py.
include "Context.generated.dfy"

module AbiConstructionComponent {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import opened AbiConnectionStatic
  import opened AbiTupleWords
  import opened AbiTupleSemantics
  import AbiTupleSource
  import opened AbiDynamicSemantics
  import opened AbiDynamicValidation
  import opened AbiConstructionValidation
  import opened AbiConstructionContext

  ghost method Component(t: seq<Byte>, value: seq<Byte>, index: nat, dynamic: bool, words: nat, s: Descriptor)
    returns (r: Result)
    requires Uint(|t|) && Uint(|value|) && Uint(index)
    requires Admissible(s) && t == Render(s) && dynamic == Dyn(s) && words == Width(s)
    ensures WellFormed(TypeOf(s))
    ensures r.Panic? ==> r.code == 17 && (!Uint(32*words) || !CursorRoom(s,|value|))
    ensures !r.Panic? ==> r.Success? == Validate(TypeOf(s),value).Parsed?
    ensures r.InvalidComponentEnvelope? ==> (r.index == index && r.length == |value| &&
                                             r.head == (if |value| >= 32 then ReadNat(value[..32]) else 0))
    ensures r.InvalidComponentLength? ==> r.index == index && r.expected == 32*words && r.actual == |value|
    ensures r.InvalidComponentValue? ==> r.index == index
    ensures !r.InvalidValue? && !r.InvalidCallbackResult? && !r.InvalidDescriptor? && !r.ComponentCountMismatch?
  {
    ModelType(s);
    if dynamic {
      var head := if |value| >= 32 then ReadNat(value[..32]) else 0;
      if |value| < 64 || |value| % 32 != 0 || head != 32 {
        if Validate(TypeOf(s),value).Parsed? { CanonicalEnvelope(s,value); }
        r := InvalidComponentEnvelope(index,|value|,head); return;
      }
    } else {
      var required := (words * 32);
      if !Uint(required) { r := AbiConstructionContext.Panic(17); return; }
      if |value| != required {
        if Validate(TypeOf(s),value).Parsed? {
          ValidationSound(TypeOf(s),value);
          StaticFootprint(TypeOf(s),Validate(TypeOf(s),value).value);
        }
        r := InvalidComponentLength(index,required,|value|); return;
      }
    }
    var c := Context(ComponentKind,0,index,0,0);
    var raw: Outcome;
    if dynamic { raw := ValidateDynamic(t,value,s); }
    else {
      StaticValidation(s,value);
      var end: nat; var width: nat;
      end,width,raw := AbiTupleSource.CheckWords(t,0,|t|,1,value,0,s);
      RepeatOne(Rules(s));
    }
    r := Route(raw,c);
  }
}
