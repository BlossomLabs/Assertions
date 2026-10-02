// SPDX-License-Identifier: MIT
// Ground ConstraintFailed selector shift, isolated from physical state contexts.
include "../../../scans/Scalar.dfy"
module AssertionsConstraintFailedSelectorScalar {
  import G = BytecodeGetterMachine
  import S = BytecodeScanMachine
  import P = BytecodeScanScalar
  lemma Selector()
    ensures S.ShiftLeft(0xdeb9f2af,224) == 0xdeb9f2af00000000000000000000000000000000000000000000000000000000
  {
    P.Narrow(0xdeb9f2af);
    P.ShiftDefinition(0xdeb9f2af,224);
    assert (0xdeb9f2af as bv256) << 224 == 0xdeb9f2af00000000000000000000000000000000000000000000000000000000;
    reveal S.ShiftLeft();
  }
}
