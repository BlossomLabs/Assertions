// SPDX-License-Identifier: MIT
// Independent in-memory ABI bytes encoding, with physical compiler footprint bounds.
include "../../../copy/Memory.dfy"
include "../../../scans/Representation.dfy"
include "../../math/Mask.dfy"
include "../../gather-composition/CallerElementSpec.dfy"
module AssertionsGatherBytesSpec {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  import B = AssertionsPrimitiveLowMask
  import DS = AssertionsGatherCallerSpec
  type Word = S.Word
  type Byte = S.Byte
  predicate Heap(mem: seq<Byte>, dst: Word, src: Word, length: Word) {
    |mem|%32 == 0 && 96 <= |mem| <= dst+32 && dst%32 == 0 && 128 <= dst &&
    src+32+length <= |mem| && src+32+length <= dst &&
    dst+64+S.Round32(length) < 0x10000000000000000 && S.Load(mem,src) == length
  }
  function End(dst: Word, length: Word): Word
    requires dst+64+S.Round32(length) < 0x10000000000000000
  { dst+32+S.Round32(length) }
  function Header(mem: seq<Byte>, dst: Word, length: Word): seq<Byte> { S.Store(mem,dst,length) }
  function Payload(mem: seq<Byte>, dst: Word, src: Word, length: Word): seq<Byte>
    requires dst+32 < G.Modulus() && src+32 < G.Modulus()
  { C.Memory(Header(mem,dst,length),dst+32,src+32,length) }
  function Image(mem: seq<Byte>, dst: Word, src: Word, length: Word): seq<Byte>
    requires Heap(mem,dst,src,length)
  { S.Store(Payload(mem,dst,src,length),dst+32+length,0) }
  predicate Value(mem: seq<Byte>, output: seq<Byte>, dst: Word, src: Word, length: Word)
    requires Heap(mem,dst,src,length)
  {
    dst+32+S.Round32(length) <= |output| &&
    output[dst..dst+32] == G.Encode(length,32) &&
    output[dst+32..dst+32+length] == mem[src+32..src+32+length] &&
    forall p: nat {:trigger output[p]} :: dst+32+length <= p < dst+32+S.Round32(length) ==> output[p] == 0
  }
  lemma Bounds(mem: seq<Byte>, dst: Word, src: Word, length: Word)
    requires Heap(mem,dst,src,length)
    ensures length+31 < 0x10000000000000000 && src+32 < G.Modulus() && dst+32+length < G.Modulus()
    ensures End(dst,length) < G.Modulus() && |mem| < G.Modulus()
  { C.Rounded(length); }
  lemma Allocation(length: Word)
    requires length+31 < 0x10000000000000000
    ensures S.BitNot(31) == G.Modulus()-32
    ensures G.BitAnd(G.Modulus()-32,length+31) == S.Round32(length)
    ensures G.BitAnd(length+31,G.Modulus()-32) == S.Round32(length)
  {
    hide G.BitAnd();
    B.Complement31(); B.Rounded(length);
    assert G.BitAnd(G.Modulus()-32,length+31) == G.BitAnd(length+31,G.Modulus()-32) by { reveal G.BitAnd(); }
  }
}
