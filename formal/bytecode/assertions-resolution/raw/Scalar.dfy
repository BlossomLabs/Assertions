// SPDX-License-Identifier: MIT
include "../../scans/DecoderScalar.dfy"
module AssertionsRawResolveScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import P = BytecodeScanScalar
  lemma ComplementThirty()
    ensures S.BitNot(30) == G.Modulus()-31
  {
    var input: G.Word := 30;
    var bits: bv256 := 30;
    var complement: bv256 := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe1;
    P.Narrow(input);
    assert (input as bv32) == (bits as bv32);
    assert (input as bv256) == bits;
    assert !bits == complement;
    assert (complement as nat) == G.Modulus()-31;
  }
  lemma ZeroShift()
    ensures S.ShiftLeft(0,5) == 0
  {
    reveal S.ShiftLeft();
    P.ShiftDefinition(0,5);
    assert (0 as bv256) << 5 == 0;
  }
}
