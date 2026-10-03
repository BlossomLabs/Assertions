// SPDX-License-Identifier: MIT
include "EvmValues.dfy"
include "../source/abi/Frames.dfy"

// Independent ABI equations specify what the reusable EVM serializer must mean.
module EvmEncoding {
  import V = EvmValues
  import F = AbiFrames
  import D = Int
  import U256
  import ByteUtils
  import A = EvmArithmetic
  import Arrays

  function {:fuel F.Pow256, 34} Add(a: nat, b: nat): nat
    ensures Add(a,b) == (a+b) % F.Pow256(32)
  { assert F.Pow256(32) == D.TWO_256; V.Add(a,b) }

  function {:fuel F.Pow256, 34} Mul(a: nat, b: nat): nat
    ensures Mul(a,b) == (a*b) % F.Pow256(32)
  { assert F.Pow256(32) == D.TWO_256; V.Mul(a,b) }

  function Load(data: seq<V.Byte>, address: nat): V.Word
    requires address+32 <= |data|
    ensures Load(data,address) == F.ReadNat(data[address..address+32])
  { LoadSame(data,address); V.Load(data,address) }

  function Store(data: seq<V.Byte>, address: nat, value: nat): seq<V.Byte>
    requires address+32 <= |data|
    ensures Store(data,address,value) == data[..address]+F.Word(value)+data[address+32..]
    ensures |Store(data,address,value)| == |data|
  {
    WordSameWrapped(value);
    var result := Arrays.Copy(V.Serialize(value),data,address);
    var expected := data[..address]+F.Word(value)+data[address+32..];
    assert result == expected by {
      forall i | 0 <= i < |data|
        ensures result[i] == expected[i]
      {
        if i < address { assert result[i] == data[i]; }
        else if i < address+32 { assert result[i] == V.Serialize(value)[i-address]; }
        else { assert result[i] == data[i]; }
      }
    }
    result
  }

  lemma NatBytesModulo(n: nat, width: nat)
    ensures F.NatBytes(n,width) == F.NatBytes(n % F.Pow256(width),width)
    decreases width
  {
    if width > 0 {
      NatBytesModulo(n/256,width-1);
      A.ModuloByteStep(n,F.Pow256(width-1));
      assert (n % F.Pow256(width))/256 == (n/256) % F.Pow256(width-1);
      assert (n % F.Pow256(width)) % 256 == n % 256;
    }
  }

  lemma ReadSame(data: seq<V.Byte>)
    ensures F.ReadNat(data) == D.FromBytes(V.Bytes(data))
    decreases |data|
  {
    if |data| > 0 {
      var n := |data|-1;
      ReadSame(data[..n]);
      V.BytesSlice(data,0,n);
    }
  }

  lemma {:fuel F.Pow256, 34} WordSame(n: nat)
    requires n < D.TWO_256
    ensures V.Serialize(n) == F.Word(n)
  {
    assert n % D.TWO_256 == n;
    var encoded := U256.ToBytes(n as D.u256);
    U256.BytesValue(n as D.u256);
    assert D.FromBytes(encoded) == n;
    assert V.Serialize(n) == V.Naturals(encoded);
    V.BytesInverse(encoded);
    assert V.Bytes(V.Serialize(n)) == encoded;
    ReadSame(V.Serialize(n));
    assert F.ReadNat(V.Serialize(n)) == D.FromBytes(encoded);
    assert F.ReadNat(V.Serialize(n)) == n;
    F.BytesNatRoundTrip(V.Serialize(n));
  }

  lemma {:fuel F.Pow256, 34} WordSameWrapped(n: nat)
    ensures V.Serialize(n) == F.Word(n)
  {
    var normalized := n % D.TWO_256;
    assert normalized % D.TWO_256 == normalized;
    assert V.Serialize(n) == V.Serialize(normalized);
    WordSame(normalized);
    NatBytesModulo(n,32);
    assert F.Pow256(32) == D.TWO_256;
    assert F.Word(n) == F.Word(normalized);
    assert V.Serialize(n) == F.Word(n);
  }

  lemma LoadSame(data: seq<V.Byte>, address: nat)
    requires address+32 <= |data|
    ensures V.Load(data,address) == F.ReadNat(data[address..address+32])
  {
    V.BytesSlice(data,address,address+32);
    ReadSame(data[address..address+32]);
    ByteUtils.FullWordValue(V.Bytes(data),address);
  }
}
