// SPDX-License-Identifier: MIT
// Exact low-160-bit address conversion used by the compiler ABI decoder.
include "../../scans/Scalar.dfy"
include "Conversion.generated.dfy"
module ExpressionsPublicCallAddressMask {
  import G = BytecodeGetterMachine
  import WC = ExpressionsPublicCallWordConversion
  function Bound(): nat { 0x10000000000000000000000000000000000000000 }
  lemma BitBound(bits: bv256)
    ensures (0xffffffffffffffffffffffffffffffffffffffff & bits) < 0x10000000000000000000000000000000000000000
  {}
  lemma NatBound(bits: bv256)
    requires bits < 0x10000000000000000000000000000000000000000
    ensures (bits as nat) < Bound()
  {}
  lemma Definition(a: G.Word,b: G.Word)
    ensures G.BitAnd(a,b) == (((a as bv256) & (b as bv256)) as nat)
  { reveal G.BitAnd(); }
  lemma MaskLiteral()
    ensures (0xffffffffffffffffffffffffffffffffffffffff as bv256) == 0xffffffffffffffffffffffffffffffffffffffff
  {}
  lemma NatEquality(lhs: bv256, rhs: bv256)
    requires lhs == rhs
    ensures (lhs as nat) == (rhs as nat)
  {}
  lemma WordIdentity(a: G.Word)
    ensures ((a as bv256) as nat) == a
  { WC.Nat256(a); }
  lemma NatAtLeast(bits: bv256)
    requires bits >= 0x10000000000000000000000000000000000000000
    ensures (bits as nat) >= Bound()
  {}
  lemma BelowBits(a: G.Word)
    requires a < Bound()
    ensures (a as bv256) < 0x10000000000000000000000000000000000000000
  {
    WordIdentity(a);
    if (a as bv256) >= 0x10000000000000000000000000000000000000000 {
      NatAtLeast(a as bv256);
      assert false;
    }
  }
  lemma LowUnchanged(bits: bv256)
    requires bits < 0x10000000000000000000000000000000000000000
    ensures (0xffffffffffffffffffffffffffffffffffffffff & bits) == bits
  {}
  lemma MaskCast(mask: G.Word)
    requires mask == 0xffffffffffffffffffffffffffffffffffffffff
    ensures (mask as bv256) == 0xffffffffffffffffffffffffffffffffffffffff
  {
    var bits: bv256 := 0xffffffffffffffffffffffffffffffffffffffff;
    WC.Inverse256(bits);
    assert (bits as int) == mask;
  }
  lemma MaskProduct(mask: bv256, bits: bv256)
    requires mask == 0xffffffffffffffffffffffffffffffffffffffff
    requires bits < 0x10000000000000000000000000000000000000000
    ensures (mask & bits) == bits
  { LowUnchanged(bits); }
  lemma NativeBound(a: G.Word)
    ensures G.BitAnd(0xffffffffffffffffffffffffffffffffffffffff,a) < Bound()
  {
    hide G.BitAnd();
    WordIdentity(a);
    MaskLiteral();
    Definition(0xffffffffffffffffffffffffffffffffffffffff,a);
    var bits := a as bv256;
    var masked := (0xffffffffffffffffffffffffffffffffffffffff as bv256) & bits;
    assert masked == (0xffffffffffffffffffffffffffffffffffffffff & bits);
    BitBound(bits);
    NatBound(masked);
  }
  lemma CanonicalMask(a: G.Word, mask: G.Word)
    requires a < Bound() && mask == 0xffffffffffffffffffffffffffffffffffffffff
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
    ensures G.BitAnd(0xffffffffffffffffffffffffffffffffffffffff,a) == a
    ensures G.BitAnd(a,0xffffffffffffffffffffffffffffffffffffffff) == a
  {
    hide G.BitAnd();
    CanonicalMask(a,0xffffffffffffffffffffffffffffffffffffffff);
    Definition(a,0xffffffffffffffffffffffffffffffffffffffff);
    Definition(0xffffffffffffffffffffffffffffffffffffffff,a);
  }
  lemma AcceptedExactly(a: G.Word)
    ensures (G.BitAnd(0xffffffffffffffffffffffffffffffffffffffff,a) == a) <==> a < Bound()
  {
    if a < Bound() { Canonical(a); }
    else { NativeBound(a); }
  }
}
