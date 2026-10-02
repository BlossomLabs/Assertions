// SPDX-License-Identifier: MIT
// Independent scalar and physical memory facts used by Assertions primitives.
include "../scans/ErrorBytes.dfy"
include "../scans/Scalar.dfy"
module AssertionsPrimitiveScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import E = BytecodeScanErrorBytes
  import Q = BytecodeScanScalar

  function AddressLimit(): nat { 0x10000000000000000000000000000000000000000 }
  function Inside(length: S.Word, index: S.Word): bool {
    -((length/32) as int) <= G.Signed(index) < (length/32) as int
  }
  function Wanted(length: S.Word, index: S.Word): S.Word {
    if G.Signed(index) < 0 then ((length/32 as nat)+(index as nat))%G.Modulus() else index
  }
  function WordOffset(ptr: S.Word, length: S.Word, index: S.Word): S.Word {
    ((ptr as nat)+32+(Wanted(length,index) as nat)*32)%G.Modulus()
  }
  lemma IndexFacts(length: S.Word, index: S.Word)
    requires Inside(length,index)
    ensures Wanted(length,index) < length/32
    ensures G.Signed(index) >= 0 ==> Wanted(length,index) == G.Signed(index)
    ensures G.Signed(index) < 0 ==> Wanted(length,index) == length/32+G.Signed(index)
    ensures G.Signed(index) < 0 ==> G.Modulus()/2 < index && index+length/32 >= G.Modulus()
  {
    if G.Signed(index) < 0 {
      assert index >= G.Modulus()/2;
      assert length/32 < G.Modulus()/2;
      assert G.Modulus() <= index+length/32 < G.Modulus()+length/32;
      assert (index+length/32)%G.Modulus() == index+length/32-G.Modulus();
    }
  }
  lemma OffsetFacts(ptr: S.Word, length: S.Word, index: S.Word, mem: seq<S.Byte>)
    requires Inside(length,index) && (ptr as nat)+32+(length as nat) <= |mem| < G.Modulus()
    ensures WordOffset(ptr,length,index) == ptr+32+Wanted(length,index)*32
    ensures WordOffset(ptr,length,index)+32 <= |mem|
  {
    IndexFacts(length,index);
    assert Wanted(length,index)*32+32 <= length;
  }
  // The specification uses the reviewed mathematical word projection, shared
  // with opcode semantics; it does not invoke the candidate address helper.
  opaque predicate CleanAddress(word: S.Word) { S.ShiftRight(word,160) == 0 }
  lemma ZeroBits(bits: bv256)
    ensures ((bits as nat) == 0) == (bits == 0)
  {}
  lemma AddressShift(word: S.Word)
    ensures (S.ShiftRight(word,160) == 0) == CleanAddress(word)
  {
    reveal CleanAddress();
  }

  lemma Selectors()
    ensures S.ShiftLeft(1793442331,225) == 0xd5cb843600000000000000000000000000000000000000000000000000000000
    ensures S.ShiftLeft(1472173131,224) == 0x57bf944b00000000000000000000000000000000000000000000000000000000
    ensures S.ShiftLeft(1,255) == G.Modulus()/2
  {
    reveal S.ShiftLeft();
    Q.Narrow(1793442331); Q.Narrow(1472173131);
    Q.Narrow(1);
    assert (1 as bv256) << 255 == 0x8000000000000000000000000000000000000000000000000000000000000000;
    Q.ShiftDefinition(1,255);
    var a: bv256 := 1793442331;
    var b: bv256 := 1472173131;
    assert (1793442331 as bv256) == a;
    assert (1472173131 as bv256) == b;
    assert a << 225 == 0xd5cb843600000000000000000000000000000000000000000000000000000000;
    assert b << 224 == 0x57bf944b00000000000000000000000000000000000000000000000000000000;
    assert ((a << 225) as nat) == 0xd5cb843600000000000000000000000000000000000000000000000000000000;
    assert ((b << 224) as nat) == 0x57bf944b00000000000000000000000000000000000000000000000000000000;
    Q.ShiftDefinition(1793442331,225);
    Q.ShiftDefinition(1472173131,224);
  }

  lemma ExpansionIdentity(mem: seq<S.Byte>, end: nat)
    requires |mem| % 32 == 0 && end <= |mem|
    ensures S.Expand(mem,end) == mem
  {
    assert S.Round32(end) <= |mem|;
  }

  lemma TwoWordError(mem: seq<S.Byte>, free: S.Word, selector: S.Word, header: S.Word, first: S.Word, second: S.Word)
    requires |mem| % 32 == 0 && (free as nat)+68 < G.Modulus()
    requires header == (selector as nat)*0x100000000000000000000000000000000000000000000000000000000
    ensures S.Store(S.Store(S.Store(mem,free,header),free+4,first),free+36,second)[free..free+68] == G.Encode(selector,4)+G.Encode(first,32)+G.Encode(second,32)
  {
    E.PhysicalError(mem,free,selector,header,first);
    var before := S.Store(S.Store(mem,free,header),free+4,first);
    R.StoredWord(before,free+36,second);
    var after := S.Store(before,free+36,second);
    assert after[free..free+36] == before[free..free+36];
    assert after[free+36..free+68] == G.Encode(second,32);
    assert after[free..free+68] == after[free..free+36]+after[free+36..free+68];
  }
}
