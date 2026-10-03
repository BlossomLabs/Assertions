// SPDX-License-Identifier: MIT
include "../../../proof-tools/dafnyevm/src/dafny/util/int.dfy"

// These equations specify ABI bytes independently of interpreter conversion.
module AbiEncoding {
  import opened Int
  const Modulus: int := 115792089237316195423570985008687907853269984665640564039457584007913129639936
  const SignedLimit: int := 57896044618658097711785492504343953926634992332820282019728792003956564819968

  function Power(width: nat): int
    ensures Power(width) > 0
    decreases width
  { if width == 0 then 1 else 256 * Power(width-1) }

  function Bytes(value: int, width: nat): (result: seq<u8>)
    requires 0 <= value < Power(width)
    ensures |result| == width
    decreases width
  {
    if width == 0 then []
    else Bytes(value / 256, width-1) + [(value % 256) as u8]
  }

  function Value(data: seq<u8>): int
    decreases |data|
  {
    if |data| == 0 then 0
    else 256 * Value(data[..|data|-1]) + data[|data|-1] as int
  }

  lemma RoundTrip(value: int, width: nat)
    requires 0 <= value < Power(width)
    ensures Value(Bytes(value,width)) == value
    decreases width
  {
    if width > 0 {
      RoundTrip(value/256,width-1);
      assert Bytes(value,width)[..width-1] == Bytes(value/256,width-1);
    }
  }

  lemma {:fuel Power, 34} WordWidth()
    ensures Power(32) == Modulus
  {}

  function Word(value: int): seq<u8>
    requires 0 <= value < Modulus
    ensures |Word(value)| == 32
  { WordWidth(); Bytes(value,32) }

  function TwosComplement(value: int): int
    requires -SignedLimit <= value < SignedLimit
    ensures 0 <= TwosComplement(value) < Modulus
  { if value < 0 then value + Modulus else value }

  function Panic11(): seq<u8>
  { [0x4e,0x48,0x7b,0x71] + Word(17) }

  function AddCall(signed: bool, a: int, b: int): seq<u8>
    requires signed ==> -SignedLimit <= a < SignedLimit && -SignedLimit <= b < SignedLimit
    requires !signed ==> 0 <= a < Modulus && 0 <= b < Modulus
  {
    (if signed then [0xa5,0xf3,0xc2,0x3b] else [0x77,0x16,0x02,0xf7]) +
    Word(if signed then TwosComplement(a) else a) +
    Word(if signed then TwosComplement(b) else b)
  }
}
