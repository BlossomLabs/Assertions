// SPDX-License-Identifier: MIT
// Exact compiler array-decoder stride for every admitted uint64 count.
include "../scans/Scalar.dfy"
include "Conversion.dfy"

module AssertionsNavigationShift {
  import G = BytecodeGetterMachine
  import S = BytecodeScanMachine
  import SC = BytecodeScanScalar
  import WC = AssertionsNavigationConversion
  lemma Nat64(count: G.Word)
    requires count < 0x10000000000000000
    ensures ((count as bv64) as nat) == count
  { WC.Nat64(count); }
  lemma Inverse256(bits: bv256)
    ensures ((bits as nat) as bv256) == bits
  {}
  lemma Widen(bits: bv64)
    ensures ((bits as bv256) as int) == (bits as int)
  {}
  lemma FixedBitStride(bits: bv64)
    ensures (((bits as bv256) << 5) as nat) == 32*(bits as nat)
  {}
  lemma FixedShift(bits: bv256,amount: G.Word)
    requires amount == 5
    ensures (bits << (amount as nat)) == (bits << 5)
  {}
  lemma NatEquality(left: bv256,right: bv256)
    requires left == right
    ensures (left as nat) == (right as nat)
  {}
  lemma BitStride(bits: bv64,amount: G.Word)
    requires amount == 5
    ensures (((bits as bv256) << (amount as nat)) as nat) == 32*(bits as nat)
  {
    FixedBitStride(bits);
    FixedShift(bits as bv256,amount);
    NatEquality((bits as bv256) << (amount as nat),(bits as bv256) << 5);
  }
  lemma SmallInput(count: G.Word)
    requires count < 0x10000000000000000
    ensures (count as bv256) == ((count as bv64) as bv256)
  {
    Nat64(count);
    var bits := (count as bv64) as bv256;
    Widen(count as bv64);
    assert (bits as int) == count;
    Inverse256(bits);
  }
  lemma Bridge(input: G.Word, amount: G.Word, bits: bv256, result: G.Word)
    requires amount < 256 && (input as bv256) == bits
    requires result == ((bits << (amount as nat)) as nat)
    ensures S.ShiftLeft(input,amount) == result
  {
    hide G.Shift();
    reveal S.ShiftLeft();
    SC.ShiftDefinition(input,amount);
  }
  lemma Scalar(count: G.Word)
    requires count < 0x10000000000000000
    ensures S.ShiftLeft(count,5) == count*32
    ensures count*32 < 0x200000000000000000
  {
    hide G.Shift();
    var small := count as bv64;
    var wide := small as bv256;
    var amount: G.Word := 5;
    var expected: G.Word := count*32;
    Nat64(count);
    SmallInput(count);
    BitStride(small,amount);
    Bridge(count,amount,wide,expected);
  }
}
