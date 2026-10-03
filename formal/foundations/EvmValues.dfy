// SPDX-License-Identifier: MIT
include "../../proof-tools/dafnyevm/src/dafny/util/bytes.dfy"
include "../../proof-tools/dafnyevm/src/dafny/core/memory.dfy"

// Representation adapters preserve the source library's mathematical domains.
module EvmValues {
  import D = Int
  import U256
  import I256
  import W = Word
  import Arrays
  import Memory

  type Byte = b: nat | b < 256 witness 0
  type Word = w: nat | w < D.TWO_256 witness 0

  function Bytes(data: seq<Byte>): seq<D.u8>
    ensures |Bytes(data)| == |data|
    ensures forall i :: 0 <= i < |data| ==> Bytes(data)[i] as nat == data[i]
  { seq(|data|, i requires 0 <= i < |data| => data[i] as D.u8) }

  function Naturals(data: seq<D.u8>): seq<Byte>
    ensures |Naturals(data)| == |data|
    ensures forall i :: 0 <= i < |data| ==> Naturals(data)[i] == data[i] as nat
  { seq(|data|, i requires 0 <= i < |data| => data[i] as nat) }

  lemma BytesSlice(data: seq<Byte>, lo: nat, hi: nat)
    requires lo <= hi <= |data|
    ensures Bytes(data[lo..hi]) == Bytes(data)[lo..hi]
  {
    forall i | 0 <= i < hi-lo
      ensures Bytes(data[lo..hi])[i] == Bytes(data)[lo..hi][i]
    {}
  }

  lemma BytesInverse(data: seq<D.u8>)
    ensures Bytes(Naturals(data)) == data
  {
    forall i | 0 <= i < |data|
      ensures Bytes(Naturals(data))[i] == data[i]
    {}
  }

  function Read(data: seq<Byte>): Word
    ensures |data| == 0 ==> Read(data) == 0
    ensures |data| > 0 ==> Read(data) == (Read(data[..|data|-1])*256+data[|data|-1]) % D.TWO_256
    decreases |data|
  {
    if |data| > 0 then
      BytesSlice(data,0,|data|-1);
      assert D.FromBytes(Bytes(data)) == D.FromBytes(Bytes(data[..|data|-1]))*256+data[|data|-1];
      (D.FromBytes(Bytes(data)) % D.TWO_256) as Word
    else 0
  }

  function Serialize(n: nat): seq<Byte>
    ensures |Serialize(n)| == 32
  { Naturals(U256.ToBytes((n % D.TWO_256) as D.u256)) }

  function Signed(w: Word): int { W.asI256(w as D.u256) as int }
  function Add(a: nat, b: nat): nat
    ensures Add(a,b) == (a+b) % D.TWO_256
  {
    U256.Add((a % D.TWO_256) as D.u256,(b % D.TWO_256) as D.u256) as nat
  }
  function Mul(a: nat, b: nat): nat
    ensures Mul(a,b) == (a*b) % D.TWO_256
  {
    var q := a/D.TWO_256; var r := a%D.TWO_256;
                          var t := b/D.TWO_256; var u := b%D.TWO_256;
                                                assert a*b == (q*t*D.TWO_256+q*u+t*r)*D.TWO_256+r*u;
                                                U256.Mul((a % D.TWO_256) as D.u256,(b % D.TWO_256) as D.u256) as nat
  }
  function Load(data: seq<Byte>, address: nat): Word
    requires address+32 <= |data|
  { Memory.ReadUint256(Memory.Memory(Bytes(data)),address) as nat }
  function Store(data: seq<Byte>, address: nat, value: nat): seq<Byte>
    requires address+32 <= |data|
    ensures |Store(data,address,value)| == |data|
  { Naturals(Memory.WriteUint256(Memory.Memory(Bytes(data)),address,(value % D.TWO_256) as D.u256).contents) }
}
