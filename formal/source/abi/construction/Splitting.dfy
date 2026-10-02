// SPDX-License-Identifier: MIT
include "Pack.generated.dfy"

module AbiConstructionSplitting {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiConnectionModel
  import opened AbiDynamicSemantics

  ghost function Encodings(t: AbiType, vs: seq<Value>): seq<seq<Byte>>
    requires forall i :: 0 <= i < |vs| ==> WellTyped(t,vs[i])
    ensures |Encodings(t,vs)| == |vs|
  { seq(|vs|, i requires 0 <= i < |vs| => Encode(t,vs[i])) }

  lemma EncodingsAppend(t: AbiType, vs: seq<Value>, v: Value)
    requires forall i :: 0 <= i < |vs| ==> WellTyped(t,vs[i])
    requires WellTyped(t,v)
    ensures Encodings(t,vs+[v]) == Encodings(t,vs)+[Encode(t,v)]
  {
    assert Encodings(t,vs+[v])[..|vs|] == Encodings(t,vs);
  }

  lemma PrefixChildren(t: AbiType, vs: seq<Value>, ts: seq<AbiType>, rest: FieldsResult)
    requires forall i :: 0 <= i < |ts| ==> ts[i] == t
    requires TypedList(ts,vs)
    ensures forall i :: 0 <= i < |vs| ==> WellTyped(t,vs[i])
  {}

  lemma ArrayEncodingView(s: Descriptor, encoded: seq<Byte>, count: nat)
    requires Good(s) && WellFormed(TypeOf(s))
    requires |encoded| >= 64 && ReadNat(encoded[..32]) == 32
    requires count == ReadNat(encoded[32..64])
    ensures Types(TypesOf(Copies(s,count))) && Below(Array(TypeOf(s)),TypesOf(Copies(s,count)))
    ensures ListHead(TypesOf(Copies(s,count))) == count*Width(s)*32
    ensures var frame := WalkFrame(Array(TypeOf(s)),TypesOf(Copies(s,count)),encoded[64..]);
            Validate(Array(TypeOf(s)),encoded) ==
            (if frame.Parsed? && 64+frame.used == |encoded| then Parsed(frame.value,|encoded|) else Rejected)
  {
    ArrayTypes(Dynamic(s),count);
    ArrayView(Dynamic(s),encoded,32,count);
    AbiTupleWords.CursorArithmetic(0,Width(s),count);
    assert encoded[32..][..32] == encoded[32..64];
    assert encoded[32..][32..] == encoded[64..];
    var frame := WalkFrame(Array(TypeOf(s)),TypesOf(Copies(s,count)),encoded[64..]);
    assert Walk(Array(TypeOf(s)),encoded[32..]) ==
           (if frame.Rejected? then Rejected else Parsed(frame.value,32+frame.used));
  }
}
