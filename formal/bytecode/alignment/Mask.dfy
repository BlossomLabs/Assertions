// SPDX-License-Identifier: MIT
include "Scalar.dfy"
module BytecodeWordLengthMask {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeWordAlignmentScalar
  lemma Narrow(a: G.Word)
    requires a < 0x10000000000000000
    ensures (a as bv256) == ((a as bv64) as bv256)
  {}
  lemma Concat(high: bv59,low: bv5)
    ensures ((((high as bv64) << 5) | (low as bv64)) as nat) == (high as nat)*32+(low as nat)
  {}
  lemma Unique(n: nat, high: nat, low: nat)
    requires n*32+31 == high*32+low && low < 32
    ensures high == n && low == 31
  {}
  lemma Masked(bits: bv64, high: bv59, low: bv5)
    requires bits == (((high as bv64) << 5) | (low as bv64))
    ensures (bits & !31) == ((high as bv64) << 5)
  {}
  lemma BitAndDef(a: G.Word,b: G.Word)
    ensures G.BitAnd(a,b) == (((a as bv256) & (b as bv256)) as nat)
  {}
  lemma HighValue(bits: bv64,high: bv59)
    requires bits == ((high as bv64) << 5)
    ensures (bits as nat) == (high as nat)*32
  { Concat(high,0); }
  lemma Bridge(a: G.Word,bits: bv64)
    requires (a as bv256) == (bits as bv256)
    ensures G.BitAnd(a,S.BitNot(31)) == ((bits & !31) as nat)
  {
    SC.Not31();
    var mask: G.Word := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0;
    var pattern: bv256 := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0;
    assert (mask as bv256) == pattern;
    assert pattern == !(31 as bv256);
    assert ((bits as bv256) & pattern) == ((bits & !31) as bv256);
    assert (((bits & !31) as bv256) as nat) == ((bits & !31) as nat);
    assert ((a as bv256) & (S.BitNot(31) as bv256)) == ((bits & !31) as bv256);
    BitAndDef(a,S.BitNot(31));
  }
  lemma Mask(n: nat)
    requires n < 0x800000000000000
    ensures G.BitAnd(n*32+31,S.BitNot(31)) == n*32
  {
    var a: G.Word := n*32+31;
    Narrow(a);
    var bits := a as bv64;
    var high: bv59 := (bits >> 5) as bv59;
    var low: bv5 := (bits & 31) as bv5;
    Concat(high,low);
    assert bits == (((high as bv64) << 5) | (low as bv64));
    assert a == (high as nat)*32+(low as nat);
    assert 0 <= (low as nat) < 32;
    Unique(n,high as nat,low as nat);
    var masked := bits & !31;
    Masked(bits,high,low);
    HighValue(masked,high);
    assert (high as nat) == n;
    Bridge(a,bits);
  }
}
