// SPDX-License-Identifier: MIT
include "Encoding.dfy"
include "../../../proof-tools/dafnyevm/src/dafny/util/bytes.dfy"
include "../../../proof-tools/dafnyevm/src/dafny/shift-facts.dfy"

module AbiBridge {
  import opened Int
  import AbiEncoding
  import ByteUtils
  import U256
  import ShiftFacts

  lemma Value(data: seq<u8>)
    ensures Int.FromBytes(data) == AbiEncoding.Value(data)
    decreases |data|
  {
    if |data| > 0 { Value(data[..|data|-1]); }
  }

  lemma FullWord(data: seq<u8>, offset: nat, value: int)
    requires offset+32 <= |data|
    requires 0 <= value < AbiEncoding.Modulus
    requires data[offset..offset+32] == AbiEncoding.Word(value)
    ensures ByteUtils.ReadUint256(data,offset) as int == value
  {
    AbiEncoding.WordWidth();
    Value(data[offset..offset+32]);
    AbiEncoding.RoundTrip(value,32);
    ByteUtils.FullWordValue(data,offset);
  }

  lemma Injective(left: seq<u8>, right: seq<u8>)
    requires |left| == |right|
    requires AbiEncoding.Value(left) == AbiEncoding.Value(right)
    ensures left == right
    decreases |left|
  {
    if |left| > 0 {
      var n := |left|-1;
      assert left[n] as int == AbiEncoding.Value(left)%256;
      assert right[n] as int == AbiEncoding.Value(right)%256;
      assert AbiEncoding.Value(left[..n]) == AbiEncoding.Value(left)/256;
      assert AbiEncoding.Value(right[..n]) == AbiEncoding.Value(right)/256;
      Injective(left[..n],right[..n]);
      assert left == left[..n]+[left[n]];
      assert right == right[..n]+[right[n]];
    }
  }

  lemma Word(word: u256)
    ensures U256.ToBytes(word) == AbiEncoding.Word(word as int)
  {
    AbiEncoding.WordWidth();
    U256.BytesValue(word);
    Value(U256.ToBytes(word));
    AbiEncoding.RoundTrip(word as int,32);
    Injective(U256.ToBytes(word),AbiEncoding.Word(word as int));
  }

  lemma Bound(data: seq<u8>)
    ensures 0 <= AbiEncoding.Value(data) < AbiEncoding.Power(|data|)
    decreases |data|
  {
    if |data| > 0 { Bound(data[..|data|-1]); }
  }

  lemma Power(width: nat)
    ensures AbiEncoding.Power(width) == Int.BytePower(width)
    decreases width
  {
    if width > 0 { Power(width-1); }
  }

  lemma {:fuel AbiEncoding.Power, 30} Selector(signed: bool, a: int, b: int)
    requires signed ==> -AbiEncoding.SignedLimit <= a < AbiEncoding.SignedLimit && -AbiEncoding.SignedLimit <= b < AbiEncoding.SignedLimit
    requires !signed ==> 0 <= a < AbiEncoding.Modulus && 0 <= b < AbiEncoding.Modulus
    ensures U256.Shr(ByteUtils.ReadUint256(AbiEncoding.AddCall(signed,a,b),0),224) ==
            (if signed then 0xa5f3c23b else 0x771602f7)
  {
    var data := AbiEncoding.AddCall(signed,a,b);
    var selector: seq<u8> := if signed then [0xa5,0xf3,0xc2,0x3b] else [0x77,0x16,0x02,0xf7];
    var rest := data[4..32];
    assert data[..32] == selector+rest;
    ByteUtils.FullWordValue(data,0);
    Int.FromBytesConcat(selector,rest);
    Value(selector); Value(rest);
    Bound(rest); Power(28);
    assert AbiEncoding.Power(28) == ShiftFacts.Power224;
    assert AbiEncoding.Value(selector) == (if signed then 0xa5f3c23b else 0x771602f7);
    ShiftFacts.HighFourBytes(ByteUtils.ReadUint256(data,0),
                             (if signed then 0xa5f3c23b else 0x771602f7),AbiEncoding.Value(rest) as nat);
  }
}
