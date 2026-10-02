// SPDX-License-Identifier: MIT
// Navigation raw-return assembly under the full AST gate; Assertions.sol SHA-256: 8fa122e5e5750ca115c66898c22186e076eac9d95e7c91c228928a5b09ad273a
include "../../abi/construction/Memory.dfy"

module NavigationReturnSource {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiConstructionMemory

  // The allocator supplies disjoint, nonwrapping output memory of this size.
  // Its previous contents are arbitrary: every returned byte is overwritten.
  ghost method DynamicReturn(data: seq<Byte>, pos: nat, size: nat, initialMemory: seq<Byte>)
    returns (out: seq<Byte>)
    requires pos+size <= |data| && size%32 == 0 && Uint(|data|) && Uint(32+size)
    requires |initialMemory| == 32+size
    ensures out == Word(32)+data[pos..pos+size]
  {
    out := Store(initialMemory,0,32);
    var i: nat := 0;
    while i < size
      invariant 0 <= i <= size && i%32 == 0
      invariant |out| == 32+size
      invariant out[..32] == Word(32)
      invariant out[32..32+i] == data[pos..pos+i]
      decreases size-i
    {
      assert i+32 <= size;
      var word := ReadNat(data[pos+i..pos+i+32]);
      BytesNatRoundTrip(data[pos+i..pos+i+32]);
      assert Uint(word) && Word(word) == data[pos+i..pos+i+32];
      var previous := out;
      out := Store(out,32+i,word);
      assert out[..32+i] == previous[..32+i];
      assert out[32..32+i+32] == previous[32..32+i]+data[pos+i..pos+i+32];
      assert data[pos..pos+i+32] == data[pos..pos+i]+data[pos+i..pos+i+32];
      assert Uint(i+32);
      i := i+32;
    }
    assert out == out[..32]+out[32..];
  }

  ghost method StaticReturn(data: seq<Byte>, pos: nat, size: nat) returns (out: seq<Byte>)
    requires pos+size <= |data| && Uint(|data|)
    ensures out == data[pos..pos+size]
  { out := data[pos..pos+size]; }
}
