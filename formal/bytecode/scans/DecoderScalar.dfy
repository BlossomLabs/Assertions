// SPDX-License-Identifier: MIT
include "Scalar.dfy"
module BytecodeScanDecoderScalar {
  import G = BytecodeGetterMachine
  import M = BytecodeScanMachine
  import S = BytecodeScanScalar
  lemma DecoderLimit()
    ensures M.ShiftLeft(1,64) == 0x10000000000000000
  {
    reveal M.ShiftLeft();
    var a: G.Word := 1;
    var amount: G.Word := 64;
    S.Narrow(a); S.Narrow(amount);
    assert (a as bv256) == (1 as bv256);
    assert (amount as bv256) == (64 as bv256);
    S.ShiftDefinition(a,amount);
    assert ((a as bv256) << (amount as nat)) == (0x10000000000000000 as bv256);
  }
}
