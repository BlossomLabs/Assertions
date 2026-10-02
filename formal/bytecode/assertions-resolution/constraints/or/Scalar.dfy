// SPDX-License-Identifier: MIT
// Ground selector arithmetic isolated from physical state-transition contexts.
include "../../../scans/Scalar.dfy"
module AssertionsConstraintOrScalar {
  import G = BytecodeGetterMachine
  import S = BytecodeScanMachine
  import P = BytecodeScanScalar
  lemma Selector()
    ensures S.ShiftLeft(0x3f9bbb3b,226) == 0xfe6eecec00000000000000000000000000000000000000000000000000000000
  {
    P.Narrow(0x3f9bbb3b);
    P.ShiftDefinition(0x3f9bbb3b,226);
    assert (0x3f9bbb3b as bv256) << 226 == 0xfe6eecec00000000000000000000000000000000000000000000000000000000;
    reveal S.ShiftLeft();
  }
}
