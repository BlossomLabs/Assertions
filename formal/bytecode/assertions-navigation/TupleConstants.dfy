// SPDX-License-Identifier: MIT
// Compiler's ASCII '(' comparison uses NOT(43) followed by modular addition.
include "Constants.dfy"
module AssertionsNavigationTupleConstants {
  import S = BytecodeScanMachine
  import H = AssertionsNavigationHighByte
  import C = AssertionsNavigationConversion
  import W = AssertionsNavigationShift
  import K = AssertionsNavigationConstants
  lemma Widen8(bits: bv8)
    ensures ((bits as bv256) as nat) == (bits as nat)
  {}
  lemma Not43()
    ensures S.BitNot(43) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd4
  {
    hide S.BitNot();
    C.Nat8(43);
    var small: bv8 := 43;
    Widen8(small);
    W.Inverse256(small as bv256);
    var low: nat := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd4;
    H.Nat248(low);
    H.Join256Nat(255,low as bv248);
    var bits := H.Join256(255,low as bv248);
    assert (bits as nat) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd4;
    assert !(small as bv256) == bits;
    K.NotBridge(43,bits,bits as nat);
  }
}
