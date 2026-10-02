// SPDX-License-Identifier: MIT
// Arithmetic and exact uint32 bound used by typeShape's suffix acceptance.
include "Conversion.dfy"
include "../getters/Machine.dfy"
module AssertionsNavigationArraySizeMath {
  import G = BytecodeGetterMachine
  import C = AssertionsNavigationConversion
  lemma Widen(bits: bv32)
    ensures ((bits as bv256) as nat) == (bits as nat)
  {}
  lemma Inverse(bits: bv256)
    ensures ((bits as nat) as bv256) == bits
  {}
  lemma OrBits(left: bv32,right: bv32)
    ensures ((left as bv256) | (right as bv256)) == ((left | right) as bv256)
  {}
  lemma OrDefinition(left: G.Word,right: G.Word)
    ensures G.BitOr(left,right) == (((left as bv256) | (right as bv256)) as nat)
  { reveal G.BitOr(); }
  lemma OrBridge(left: G.Word,right: G.Word,bits: bv256,result: G.Word)
    requires bits == ((left as bv256) | (right as bv256)) && (bits as nat) == result
    ensures G.BitOr(left,right) == result
  { OrDefinition(left,right); }
  lemma OrBound(left: G.Word,right: G.Word)
    requires left <= 4294967295 && right <= 4294967295
    ensures G.BitOr(left,right) <= 4294967295
  {
    hide G.BitOr();
    C.Nat32(left); C.Nat32(right);
    var a := left as bv32; var b := right as bv32;
    Widen(a); Widen(b); Widen(a | b);
    Inverse(a as bv256); Inverse(b as bv256);
    assert (a as bv256) == (left as bv256);
    assert (b as bv256) == (right as bv256);
    OrBits(a,b);
    var joined := a | b;
    var result: G.Word := joined as nat;
    assert result <= 4294967295;
    assert (((a as bv256) | (b as bv256)) as nat) == result;
    OrBridge(left,right,joined as bv256,result);
  }
  opaque function Product(left: G.Word,right: G.Word): G.Word {
    ((left as nat)*(right as nat))%G.Modulus()
  }
  lemma ProductNatural(left: G.Word,right: G.Word)
    requires left*right <= 4294967295
    ensures Product(left,right) == left*right
    ensures Product(left,right) <= 4294967295
  {
    assert left*right == (left as nat)*(right as nat);
    assert 0 <= left*right < G.Modulus();
    assert ((left as nat)*(right as nat))%G.Modulus() == left*right;
    reveal Product();
  }
  lemma ProductStep(left: G.Word,right: G.Word)
    ensures Product(left,right) == ((right as nat)*(left as nat))%G.Modulus()
  { reveal Product(); }
  lemma ProductDivide(left: nat,right: nat)
    requires left > 0
    ensures (left*right)/left == right
  {
    var quotient := (left*right)/left;
    var remainder := (left*right)%left;
    assert left*right == quotient*left+remainder;
    assert 0 <= remainder < left;
    if quotient < right {
      assert quotient+1 <= right;
      assert left*quotient+remainder < left*(quotient+1);
      assert left*(quotient+1) <= left*right;
      assert false;
    }
    if quotient > right {
      assert right+1 <= quotient;
      assert left*right < left*(right+1);
      assert left*(right+1) <= left*quotient;
      assert false;
    }
  }
}
