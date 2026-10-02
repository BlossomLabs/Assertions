// SPDX-License-Identifier: MIT
include "../../scans/Scalar.dfy"
include "../../assertions-navigation/Shift.dfy"
module AssertionsConstraintDecoderScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import P = BytecodeScanScalar
  import H = AssertionsNavigationShift
  lemma Complements()
    ensures S.BitNot(31) == G.Modulus()-32 && S.BitNot(62) == G.Modulus()-63
  {
    P.Narrow(31);P.Narrow(62);
    assert !(31 as bv256) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0;
    assert !(62 as bv256) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc1;
  }
  lemma BoolOr(a: G.Word,b: G.Word)
    requires a in {0,1} && b in {0,1}
    ensures G.BitOr(a,b) == (if a != 0 || b != 0 then 1 else 0)
  {
    P.Narrow(a);P.Narrow(b);
    if a==0 { if b==0 {} else {} }
    else { if b==0 {} else {} }
  }
  lemma Join5(hi: bv59,lo: bv5)
    ensures ((((hi as bv64) << 5) | (lo as bv64)) as nat) == 32*(hi as nat)+(lo as nat)
  {}
  lemma Widen59(bits: bv59)
    ensures ((bits as bv64) as nat) == (bits as nat)
  {}
  lemma Masked64(bits: bv64)
    ensures ((bits & 0xffffffffffffffe0) as nat)%32 == 0
    ensures ((bits & 0xffffffffffffffe0) as nat) <= (bits as nat) < ((bits & 0xffffffffffffffe0) as nat)+32
  {
    var hi := (bits >> 5) as bv59;
    var lo := (bits & 31) as bv5;
    var masked := bits & 0xffffffffffffffe0;
    assert bits == ((hi as bv64) << 5) | (lo as bv64);
    assert masked == (hi as bv64) << 5;
    assert (masked as bv256) == (hi as bv256) << 5;
    Join5(hi,lo); Widen59(hi);
    H.FixedBitStride(hi as bv64);H.Widen(masked);
    assert (masked as nat) == 32*(hi as nat);
    assert (bits as nat) == 32*(hi as nat)+(lo as nat);
  }
  lemma {:isolate_assertions} BitsBridge(value: G.Word)
    requires value < 0x10000000000000000
    ensures G.BitAnd(value,G.Modulus()-32) == ((value as bv64 & 0xffffffffffffffe0) as nat)
  {
    hide G.BitAnd();
    var mask: bv256 := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0;
    var masked := value as bv64 & 0xffffffffffffffe0;
    H.SmallInput(value);H.Widen(masked);H.Inverse256(mask);
    assert (mask as nat) == G.Modulus()-32;
    assert ((value as bv256) & mask) == (masked as bv256);
    assert G.BitAnd(value,G.Modulus()-32) == (masked as bv256) as nat by { reveal G.BitAnd(); }
  }
  lemma {:isolate_assertions} MaskBounds(value: G.Word)
    requires value < 0x10000000000000000
    ensures G.BitAnd(value,G.Modulus()-32) <= value < G.BitAnd(value,G.Modulus()-32)+32
    ensures G.BitAnd(value,G.Modulus()-32)%32 == 0
  {
    hide G.BitAnd();
    H.Nat64(value);BitsBridge(value);Masked64(value as bv64);
  }
  lemma MaskRounded(length: G.Word)
    requires length+31 < 0x10000000000000000
    ensures G.BitAnd(length+31,G.Modulus()-32) == S.Round32(length)
  {
    hide G.BitAnd();
    MaskBounds(length+31);
    var rounded := G.BitAnd(length+31,G.Modulus()-32);
    assert length <= rounded <= length+31 && rounded%32 == 0;
    assert rounded == ((length+31)/32)*32;
  }
}
