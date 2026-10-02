// SPDX-License-Identifier: MIT
include "../scans/Scalar.dfy"
module BytecodeWordAlignmentScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeScanScalar
  lemma Not31()
    ensures S.BitNot(31) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0
  {
    var input: G.Word := 31;
    SC.Narrow(input);
    var bits: bv256 := 31;
    assert (input as bv256) == bits;
    assert !bits == (0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0 as bv256);
    assert (!bits as nat) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0;
  }
}
