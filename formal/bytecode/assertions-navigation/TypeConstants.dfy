// SPDX-License-Identifier: MIT
// Compiler's ASCII '(' comparison uses NOT(39) followed by modular addition.
include "Constants.dfy"
module AssertionsNavigationTypeConstants {
  import S = BytecodeScanMachine
  import H = AssertionsNavigationHighByte
  import C = AssertionsNavigationConversion
  import W = AssertionsNavigationShift
  import K = AssertionsNavigationConstants
  lemma Widen8(bits: bv8)
    ensures ((bits as bv256) as nat) == (bits as nat)
  {}
  lemma Not39()
    ensures S.BitNot(39) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd8
  {
    hide S.BitNot();
    C.Nat8(39);
    var small: bv8 := 39;
    Widen8(small);
    W.Inverse256(small as bv256);
    var low: nat := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd8;
    H.Nat248(low);
    H.Join256Nat(255,low as bv248);
    var bits := H.Join256(255,low as bv248);
    assert (bits as nat) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd8;
    assert !(small as bv256) == bits;
    K.NotBridge(39,bits,bits as nat);
  }
}
