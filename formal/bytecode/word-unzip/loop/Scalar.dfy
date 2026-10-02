// SPDX-License-Identifier: MIT
include "../../scans/Scalar.dfy"
module BytecodeUnzipLoopScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeScanScalar
  lemma Not0()
    ensures S.BitNot(0) == G.Modulus()-1
  {
    var input: G.Word := 0;
    SC.Narrow(input);
    var bits: bv256 := 0;
    assert (input as bv256) == bits;
    assert !bits == (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff as bv256);
    assert (!bits as nat) == G.Modulus()-1;
  }
}
