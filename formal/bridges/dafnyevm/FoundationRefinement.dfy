// SPDX-License-Identifier: MIT
include "../../foundations/EvmEncoding.dfy"
include "../../foundations/EvmScalarValues.dfy"

// Original declarative equations remain independent of interpreter execution.
module EvmFoundationRefinement {
  import V = EvmValues
  import S = EvmScalarValues
  import F = AbiFrames
  import E = EvmEncoding
  import D = Int
  import Arrays

  ghost function ReadReference(data: seq<V.Byte>): V.Word
    decreases |data|
  { if |data| == 0 then 0 else (ReadReference(data[..|data|-1])*256+data[|data|-1]) % D.TWO_256 }

  lemma ReadPreserved(data: seq<V.Byte>)
    ensures V.Read(data) == ReadReference(data)
    decreases |data|
  {
    if |data| > 0 { ReadPreserved(data[..|data|-1]); }
  }

  lemma SignedPreserved(w: V.Word)
    ensures V.Signed(w) == (if w < D.TWO_255 then w as int else w as int-D.TWO_256)
  {}

  lemma TruncPreserved(a: int, b: int)
    ensures S.Trunc(a,b) == (if b == 0 then 0 else if (a < 0) != (b < 0) then -(S.Abs(a)/S.Abs(b)) else S.Abs(a)/S.Abs(b))
    ensures S.Rem(a,b) == a-S.Trunc(a,b)*b
  {
    if b != 0 { D.RemainderMatchesDivision(a,b); }
  }

  lemma BitwisePreserved(a: int, b: int)
    requires S.Word(a) && S.Word(b)
    ensures S.And(a,b) == (((a as bv256)&(b as bv256)) as int)
    ensures S.Or(a,b) == (((a as bv256)|(b as bv256)) as int)
    ensures S.Xor(a,b) == (((a as bv256)^(b as bv256)) as int)
  {}

  lemma AddPreserved(a: nat, b: nat)
    ensures V.Add(a,b) == (a+b) % D.TWO_256
  {}

  lemma MulPreserved(a: nat, b: nat)
    ensures V.Mul(a,b) == (a*b) % D.TWO_256
  {
    var q := a/D.TWO_256;
    var r := a%D.TWO_256;
    var t := b/D.TWO_256;
    var u := b%D.TWO_256;
    assert a*b == (q*t*D.TWO_256+q*u+t*r)*D.TWO_256+r*u;
  }

  lemma CopyPreserved<T>(memory: seq<T>, address: nat, data: seq<T>)
    requires address+|data| <= |memory|
    ensures Arrays.Copy(data,memory,address) == memory[..address]+data+memory[address+|data|..]
  {
    var result := Arrays.Copy(data,memory,address);
    var expected := memory[..address]+data+memory[address+|data|..];
    forall i | 0 <= i < |memory|
      ensures result[i] == expected[i]
    {
      if i < address { assert result[i] == memory[i]; }
      else if i < address+|data| { assert result[i] == data[i-address]; }
      else { assert result[i] == memory[i]; }
    }
  }

  lemma StorePreserved(memory: seq<F.Byte>, address: nat, value: nat)
    requires address+32 <= |memory|
    ensures Arrays.Copy(V.Serialize(value),memory,address) == memory[..address]+F.Word(value)+memory[address+32..]
  {
    E.WordSameWrapped(value);
    CopyPreserved(memory,address,V.Serialize(value));
  }
}
