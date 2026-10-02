// SPDX-License-Identifier: MIT
// Exact compiled AND-with-NOT31 receipt rounding within the admitted resource bound.
include "Memory.dfy"
include "../../alignment/Mask.dfy"
include "../word-conversion/Conversion.generated.dfy"
module BytecodeApplyCallbackReceiptRounding {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = BytecodeWordAlignmentScalar
  import AM = BytecodeWordLengthMask
  import M = BytecodeApplyCallbackReceiptMemory
  import WC = BytecodeApplyWordConversion
  lemma Narrow(a: S.Word)
    requires a < 0x100000000000000000000
    ensures (a as bv256) == ((a as bv80) as bv256)
  {}
  lemma Concat(high: bv75,low: bv5)
    ensures ((((high as bv80) << 5) | (low as bv80)) as nat) == (high as nat)*32+(low as nat)
  {}
  lemma Masked(bits: bv80,high: bv75,low: bv5)
    requires bits == (((high as bv80) << 5) | (low as bv80))
    ensures (bits & !31) == ((high as bv80) << 5)
  {}
  lemma HighValue(bits: bv80,high: bv75)
    requires bits == ((high as bv80) << 5)
    ensures (bits as nat) == (high as nat)*32
  { Concat(high,0); }
  lemma NatEquality(lhs: bv256,rhs: bv256)
    requires lhs == rhs
    ensures (lhs as nat) == (rhs as nat)
  {}
  lemma WideNat(bits: bv80)
    ensures ((bits as bv256) as nat) == (bits as nat)
  {}
  opaque function NotBits(bits: bv256): bv256 { !bits }
  lemma NotProjection(a: S.Word)
    ensures S.BitNot(a) == (NotBits(a as bv256) as nat)
  { reveal NotBits(); }
  lemma NotInverse(a: S.Word)
    ensures (S.BitNot(a) as bv256) == NotBits(a as bv256)
  {
    hide S.BitNot();
    NotProjection(a);
    WC.Inverse256(NotBits(a as bv256));
  }
  lemma Not31Bits(a: S.Word)
    requires a == 31
    ensures NotBits(a as bv256) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0
  { reveal NotBits(); }
  opaque function Packed(bits: bv80): bv80 { bits & !31 }
  lemma PackedProjection(bits: bv80,high: bv75,low: bv5)
    requires bits == (((high as bv80) << 5) | (low as bv80))
    ensures Packed(bits) == ((high as bv80) << 5)
  { reveal Packed(); Masked(bits,high,low); }
  lemma WidePacked(bits: bv80)
    ensures ((bits as bv256) & !(31 as bv256)) == (Packed(bits) as bv256)
  { reveal Packed(); }
  lemma MaskLiteral(a: S.Word)
    requires a == 31
    ensures (S.BitNot(a) as bv256) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0
  {
    hide S.BitNot();
    NotInverse(a);
    Not31Bits(a);
  }
  lemma {:autoRevealDependencies false} Bridge(a: S.Word,bits: bv80)
    requires (a as bv256) == (bits as bv256)
    ensures G.BitAnd(a,S.BitNot(31)) == (Packed(bits) as nat)
  {
    hide G.BitAnd();
    hide S.BitNot();
    A.Not31();
    var pattern: bv256 := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0;
    MaskLiteral(31);
    assert (S.BitNot(31) as bv256) == pattern;
    assert pattern == !(31 as bv256);
    WidePacked(bits);
    AM.BitAndDef(a,S.BitNot(31));
    NatEquality((a as bv256) & (S.BitNot(31) as bv256),Packed(bits) as bv256);
    WideNat(Packed(bits));
  }
  lemma Round(length: S.Word)
    requires length+31 < M.Bound()
    ensures G.BitAnd(length+31,S.BitNot(31)) == S.Round32(length)
  {
    hide G.BitAnd();
    var a: S.Word := length+31;
    Narrow(a);
    var bits := a as bv80;
    var high: bv75 := (bits >> 5) as bv75;
    var low: bv5 := (bits & 31) as bv5;
    Concat(high,low);
    assert bits == (((high as bv80) << 5) | (low as bv80));
    assert a == (high as nat)*32+(low as nat);
    assert 0 <= (low as nat) < 32;
    assert (high as nat) == (length+31)/32;
    var masked := Packed(bits);
    PackedProjection(bits,high,low);
    HighValue(masked,high);
    Bridge(a,bits);
  }
}
