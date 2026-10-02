// SPDX-License-Identifier: MIT
// Exact positive doubled-width quotient used by the reached overflow guard.
include "../../scans/Machine.dfy"
module BytecodeSortMul2SwapScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  lemma Cancel(width: S.Word)
    requires 0 < width < 0x1000000000000000
    ensures ((2*width)%G.Modulus())/width == 2
  {
    assert 2*width < G.Modulus();
    assert (2*width)/width == 2;
  }
}
