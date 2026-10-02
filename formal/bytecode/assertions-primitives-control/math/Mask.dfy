// SPDX-License-Identifier: MIT
// Independent low-five-bit allocation rounding, using constructive uint64 casts.
include "../../assertions-navigation/Shift.dfy"
module AssertionsPrimitiveLowMask {
  import G = BytecodeGetterMachine
  import S = BytecodeScanMachine
  import W = AssertionsNavigationShift
  import C = AssertionsNavigationConversion
  import P = BytecodeScanScalar
  lemma Nat5(value: nat)
    requires value < 32
    ensures (value as bv5) as nat == value
  {}
  function Joined(high: bv59, low: bv5): bv64 { ((high as bv64)<<5) | (low as bv64) }
  lemma Join5(high: bv59, low: bv5)
    ensures ((((high as bv64)<<5)|(low as bv64)) as nat) == 32*(high as nat)+(low as nat)
  {}
  lemma Widen59(bits: bv59)
    ensures ((bits as bv64) as nat) == (bits as nat)
  {}
  lemma Nat59(value: nat)
    requires value < 0x800000000000000
    ensures (value as bv59) as nat == value
  {
    C.Nat64(value);
    var wide := value as bv64;
    assert wide < 0x800000000000000;
    assert ((wide as bv59) as bv64) == wide;
    Widen59(wide as bv59);
  }
  lemma MaskJoin(high: bv59, low: bv5)
    ensures (((Joined(high,low) as bv256)&0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0)) == ((high as bv256)<<5)
  {}
  lemma Complement31()
    ensures S.BitNot(31) == G.Modulus()-32
  {
    P.Narrow(31);
    assert !(31 as bv256) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0;
  }
  lemma MaskConstant()
    ensures ((G.Modulus()-32) as bv256) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0
  {
    Complement31();
    W.Inverse256(!(31 as bv256));
    assert !(31 as bv256) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0;
  }
  lemma AndDefinition(a: G.Word, b: G.Word)
    ensures G.BitAnd(a,b) == (((a as bv256)&(b as bv256)) as nat)
  { reveal G.BitAnd(); }
  lemma AndBridge(value: G.Word, bits: bv256, result: G.Word)
    requires ((value as bv256)&0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0) == bits && result == (bits as nat)
    ensures G.BitAnd(value,G.Modulus()-32) == result
  {
    hide G.BitAnd();
    var mask: G.Word := G.Modulus()-32;
    MaskConstant();
    var computed := (value as bv256)&(mask as bv256);
    assert computed == bits;
    W.NatEquality(computed,bits);
    AndDefinition(value,mask);
  }
  lemma Mask(value: G.Word)
    requires value < 0x10000000000000000
    ensures G.BitAnd(value,G.Modulus()-32) == value/32*32
  {
    hide G.BitAnd();
    var quotient := value/32;
    var remainder := value%32;
    assert quotient*32 <= value;
    var result: G.Word := quotient*32;
    Nat59(quotient);
    Nat5(remainder);
    Join5(quotient as bv59,remainder as bv5);
    assert ((quotient as bv59) as nat) == quotient;
    assert ((remainder as bv5) as nat) == remainder;
    assert value == 32*quotient+remainder;
    var bits := (((quotient as bv59) as bv64)<<5) | ((remainder as bv5) as bv64);
    assert (bits as nat) == value;
    C.Inverse64(bits);
    assert (value as bv64) == bits;
    W.SmallInput(value); W.SmallInput(quotient); W.Nat64(quotient);
    MaskJoin(quotient as bv59,remainder as bv5);
    W.Widen(quotient as bv64);
    assert ((quotient as bv59) as bv256) == ((quotient as bv64) as bv256);
    W.BitStride(quotient as bv64,5);
    var shifted := (quotient as bv256)<<5;
    assert ((value as bv256)&0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0) == shifted;
    W.NatEquality(shifted,((quotient as bv64) as bv256)<<5);
    W.FixedBitStride(quotient as bv64);
    assert (shifted as nat) == quotient*32;
    AndBridge(value,shifted,result);
  }
  lemma Rounded(length: G.Word)
    requires length+31 < 0x10000000000000000
    ensures G.BitAnd(length+31,G.Modulus()-32) == S.Round32(length)
  { Mask(length+31); }
}
