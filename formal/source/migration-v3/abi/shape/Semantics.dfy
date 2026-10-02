// SPDX-License-Identifier: MIT
include "../descriptor/Refinement.dfy"

module AbiShapeSemantics {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiWordSemantics
  import opened AbiByteSemantics
  import opened AbiSuffixSemantics

  // Retain spelling (including leading zeros) separately from ABI meaning.
  datatype Descriptor = Name(text: seq<Byte>) | Group(fields: seq<Descriptor>)
                      | Fixed(element: Descriptor, digits: seq<Byte>) | Dynamic(element: Descriptor)
  datatype ShapeResult = Shaped(end: nat, dynamic: bool, words: nat, syntax: Descriptor)
                       | BadDescriptor(at: nat) | ArithmeticPanic

  function Render(s: Descriptor): seq<Byte>
    decreases s, 1
  {
    match s
    case Name(n) => n
    case Group(fs) => [40]+FieldsText(fs)+[41]
    case Fixed(e,ds) => Render(e)+[91]+ds+[93]
    case Dynamic(e) => Render(e)+[91,93]
  }

  function FieldsText(fs: seq<Descriptor>): seq<Byte>
    decreases fs, 0
  { if |fs| == 0 then [] else Render(fs[0])+(if |fs| == 1 then [] else [44]+FieldsText(fs[1..])) }

  function Dyn(s: Descriptor): bool
    decreases s
  {
    match s
    case Name(n) => n == [98,121,116,101,115] || n == [115,116,114,105,110,103]
    case Group(fs) => exists i :: 0 <= i < |fs| && Dyn(fs[i])
    case Fixed(e,_) => Dyn(e)
    case Dynamic(_) => true
  }

  function Width(s: Descriptor): nat
    decreases s, 1
  {
    if Dyn(s) then 1 else
    match s
    case Name(_) => 1
    case Group(fs) => WidthSum(fs)
    case Fixed(e,ds) => Number(ds)*Width(e)
    case Dynamic(_) => 1
  }

  // Total extension; Good constrains digits before the number is used.
  function Number(ds: seq<Byte>): nat
  { if |ds| == 0 then 0 else 10*Number(ds[..|ds|-1])+(if ds[|ds|-1] >= 48 then ds[|ds|-1]-48 else 0) }

  function WidthSum(fs: seq<Descriptor>): nat
    decreases fs, 0
  { if |fs| == 0 then 0 else Width(fs[0])+WidthSum(fs[1..]) }

  predicate Good(s: Descriptor)
    decreases s
  {
    Uint(Width(s)) &&
    match s
    case Name(n) => |n| > 0 && forall i :: 0 <= i < |n| ==> NameByte(n[i])
    case Group(fs) => |fs| > 0 && forall i :: 0 <= i < |fs| ==> Good(fs[i])
    case Fixed(e,ds) => Good(e) && Digits(ds) && 0 < Number(ds) < 0x100000000 && Width(s) < 0x100000000
    case Dynamic(e) => Good(e)
  }

  lemma NumberStep(ds: seq<Byte>, c: Byte)
    requires 48 <= c <= 57
    ensures Number(ds+[c]) == 10*Number(ds)+c-48
  {
    assert (ds+[c])[..|ds|] == ds;
  }

  lemma DecimalNumber(ds: seq<Byte>)
    requires forall i :: 0 <= i < |ds| ==> 48 <= ds[i] <= 57
    ensures Number(ds) == Decimal(ds)
    decreases |ds|
  { if |ds| > 0 { DecimalNumber(ds[..|ds|-1]); } }

  lemma AppendFields(fs: seq<Descriptor>, s: Descriptor)
    ensures WidthSum(fs+[s]) == WidthSum(fs)+Width(s)
    ensures Dyn(Group(fs+[s])) == (Dyn(Group(fs)) || Dyn(s))
    ensures FieldsText(fs+[s]) == FieldsText(fs)+(if |fs| == 0 then [] else [44])+Render(s)
    ensures (forall i :: 0 <= i < |fs| ==> Good(fs[i])) && Good(s) ==>
              (forall i :: 0 <= i < |fs+[s]| ==> Good((fs+[s])[i]))
    decreases |fs|
  {
    if |fs| > 0 {
      assert (fs+[s])[1..] == fs[1..]+[s];
      AppendFields(fs[1..],s);
    }
  }

  lemma Positive(s: Descriptor)
    requires Good(s)
    ensures Width(s) > 0 && |Render(s)| > 0
    decreases s
  {
    match s
    case Group(fs) => Positive(fs[0]);
    case Fixed(e,ds) => Positive(e);
    case Dynamic(e) => Positive(e);
    case _ =>
  }

  // Same-width big-endian decoding is injective. The calldata-word projection
  // itself uses the existing trusted nonwrapping memory interpretation.
  lemma NameComparison(n: seq<Byte>)
    requires |n| == 5 || |n| == 6
    ensures (ReadNat(n) == (if |n| == 5 then 0x6279746573 else 0x737472696e67)) == Dyn(Name(n))
  {
    BytesNatRoundTrip(n);
    NatBytesRoundTrip(0x6279746573,5);
    NatBytesRoundTrip(0x737472696e67,6);
    if |n| == 5 {
      assert NatBytes(0x6279746573,5) == [98,121,116,101,115];
      if n == [98,121,116,101,115] { assert ReadNat(n) == 0x6279746573; }
    } else {
      assert NatBytes(0x737472696e67,6) == [115,116,114,105,110,103];
      if n == [115,116,114,105,110,103] { assert ReadNat(n) == 0x737472696e67; }
    }
  }
}
