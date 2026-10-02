// SPDX-License-Identifier: MIT
// Actual AND/NOT rounding for the full admitted (<2^64) code length domain.
include "Machine.dfy"
include "ConstantMask.generated.dfy"
module OperationsCodeRoundMask {
  import G = OperationsCodeMachine
  import WC = OperationsAccountWordConversion
  import CM = OperationsCodeConstantMask
  lemma Narrow(a: G.Word)
    requires a < 0x20000000000000000
    ensures (a as bv256) == ((a as bv65) as bv256)
  {}
  lemma Concat(high: bv60,low: bv5)
    ensures ((((high as bv65) << 5) | (low as bv65)) as nat) == (high as nat)*32+(low as nat)
  {}
  lemma Masked(bits: bv65,high: bv60,low: bv5)
    requires bits == (((high as bv65) << 5) | (low as bv65))
    ensures (bits & !31) == ((high as bv65) << 5)
  {}
  lemma HighValue(bits: bv65,high: bv60)
    requires bits == ((high as bv65) << 5)
    ensures (bits as nat) == (high as nat)*32
  { Concat(high,0); }
  lemma Unique(a: nat,high: nat,low: nat)
    requires a == high*32+low && low<32
    ensures high == a/32
  {}
  lemma BitAndDef(a: G.Word,b: G.Word)
    ensures G.BitAnd(a,b) == (((a as bv256) & (b as bv256)) as nat)
  { reveal G.BitAnd(); }
  lemma MaskLiteral()
    ensures (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 as bv256)==0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0
  {}
  lemma ConstantDefinition(a: G.Word)
    ensures G.BitAnd(a,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0)
         == (((a as bv256) & (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 as bv256)) as nat)
  {
    hide CM.Mask256();
    CM.MaskNat256(); CM.BitsMask256();
    WC.Inverse256(CM.Mask256());
    var mask: G.Word := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0;
    assert (mask as bv256)==CM.Mask256();
    BitAndDef(a,mask);
    NatEquality((a as bv256) & (mask as bv256),(a as bv256) & CM.Mask256());
    MaskLiteral();
    NatEquality((a as bv256) & CM.Mask256(),(a as bv256) & (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 as bv256));
  }
  lemma NatEquality(lhs: bv256,rhs: bv256)
    requires lhs==rhs
    ensures (lhs as nat)==(rhs as nat)
  {}
  lemma WidenMask(bits: bv65)
    ensures ((bits as bv256) & !(31 as bv256))==((bits & !31) as bv256)
  {}
  lemma WidenNat(bits: bv65)
    ensures ((bits as bv256) as nat)==(bits as nat)
  {}
  lemma Bridge(a: G.Word,bits: bv65)
    requires (a as bv256) == (bits as bv256)
    ensures G.BitAnd(a,G.Modulus()-32) == ((bits & !31) as nat)
  {
    var mask: G.Word := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0;
    var pattern: bv256 := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0;
    assert mask == G.Modulus()-32;
    assert pattern == !(31 as bv256);
    WidenMask(bits);
    assert ((bits as bv256) & pattern) == ((bits & !31) as bv256);
    WidenNat(bits & !31);
    assert (((bits & !31) as bv256) as nat) == ((bits & !31) as nat);
    NatEquality((a as bv256) & pattern,(bits & !31) as bv256);
    ConstantDefinition(a);
  }
  lemma Exact(n: nat)
    requires n < 0x10000000000000000
    ensures G.BitAnd(n+31,G.Modulus()-32) == G.Round32(n)
  {
    var a: G.Word := n+31;
    Narrow(a);
    var bits := a as bv65;
    var high: bv60 := (bits >> 5) as bv60;
    var low: bv5 := (bits & 31) as bv5;
    Concat(high,low);
    assert bits == (((high as bv65) << 5) | (low as bv65));
    assert a == (high as nat)*32+(low as nat);
    Unique(a,high as nat,low as nat);
    var masked := bits & !31;
    Masked(bits,high,low);
    HighValue(masked,high);
    Bridge(a,bits);
  }
}
