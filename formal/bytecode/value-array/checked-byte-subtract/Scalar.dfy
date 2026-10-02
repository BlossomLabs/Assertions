// SPDX-License-Identifier: MIT
// Exact low8-bit machine mask, arbitrary full256-bit input words.
include "../../scans/DecoderScalar.dfy"
include "../../word-apply/word-conversion/Conversion.generated.dfy"
module BytecodeCollectionsCheckedByteSubtractScalar {
  import G = BytecodeGetterMachine
  import S = BytecodeScanMachine
  import WC = BytecodeApplyWordConversion
  function Bound(): nat { 256 }
  lemma BitBound(bits: bv256)
    ensures (255 & bits) < 256
  {}
  lemma NatBound(bits: bv256)
    requires bits < 256
    ensures (bits as nat) < Bound()
  {}
  lemma Definition(a: G.Word,b: G.Word)
    ensures G.BitAnd(a,b) == (((a as bv256) & (b as bv256)) as nat)
  {}
  lemma MaskLiteral()
    ensures (255 as bv256) == 255
  {}
  lemma NatEquality(lhs: bv256, rhs: bv256)
    requires lhs == rhs
    ensures (lhs as nat) == (rhs as nat)
  {}
  lemma WordIdentity(a: G.Word)
    ensures ((a as bv256) as nat) == a
  { WC.Nat256(a); }
  lemma NatAtLeast(bits: bv256)
    requires bits >= 256
    ensures (bits as nat) >= Bound()
  {}
  lemma BelowBits(a: G.Word)
    requires a < Bound()
    ensures (a as bv256) < 256
  {
    WordIdentity(a);
    if (a as bv256) >= 256 {
      NatAtLeast(a as bv256);
      assert false;
    }
  }
  lemma LowUnchanged(bits: bv256)
    requires bits < 256
    ensures (255 & bits) == bits
  {}
  lemma MaskCast(mask: G.Word)
    requires mask == 255
    ensures (mask as bv256) == 255
  {
    var bits: bv256 := 255;
    WC.Inverse256(bits);
    assert (bits as int) == mask;
  }
  lemma MaskProduct(mask: bv256, bits: bv256)
    requires mask == 255
    requires bits < 256
    ensures (mask & bits) == bits
  { LowUnchanged(bits); }
  lemma MaskedBound(bits: bv256)
    ensures (((255 as bv256)&bits) as nat) < Bound()
  {
    MaskLiteral();
    BitBound(bits);
    NatBound((255 as bv256)&bits);
  }
  lemma NativeBound(a: G.Word)
    ensures G.BitAnd(255,a) < Bound()
  {
    hide G.BitAnd();
    Definition(255,a);
    MaskedBound(a as bv256);
  }
  lemma CanonicalMask(a: G.Word, mask: G.Word)
    requires a < Bound() && mask == 255
    ensures G.BitAnd(mask,a) == a
  {
    hide G.BitAnd();
    BelowBits(a);
    WordIdentity(a);
    MaskLiteral();
    Definition(mask,a);
    LowUnchanged(a as bv256);
    MaskCast(mask);
    MaskProduct(mask as bv256,a as bv256);
    var masked := (mask as bv256) & (a as bv256);
    NatEquality(masked,a as bv256);
  }
  lemma Canonical(a: G.Word)
    requires a < Bound()
    ensures G.BitAnd(255,a) == a
  {
    hide G.BitAnd();
    CanonicalMask(a,255);
  }
  lemma AcceptedExactly(a: G.Word)
    ensures (G.BitAnd(255,a) == a) <==> a < Bound()
  {
    if a < Bound() { LowDefinition(a);Canonical(a); }
    else { NativeBound(a); }
  }
  opaque function Low(a: G.Word): G.Word
    ensures Low(a) < Bound()
  { NativeBound(a);G.BitAnd(255,a) }
  lemma LowDefinition(a: G.Word)
    ensures Low(a) == G.BitAnd(255,a)
  { hide G.BitAnd();reveal Low(); }
  lemma MaskCommutes(bits: bv256)
    ensures ((bits&(255 as bv256)) as nat) == (((255 as bv256)&bits) as nat)
  {
    assert bits&(255 as bv256) == (255 as bv256)&bits;
    NatEquality(bits&(255 as bv256),(255 as bv256)&bits);
  }
  lemma Reverse(a: G.Word)
    ensures G.BitAnd(a,255) == Low(a)
  {
    hide G.BitAnd();hide Low();
    Definition(a,255);Definition(255,a);
    MaskCommutes(a as bv256);
    LowDefinition(a);
  }
  lemma ByteIdentity(a: G.Word)
    requires a < Bound()
    ensures Low(a) == a
  { LowDefinition(a);Canonical(a); }
}
