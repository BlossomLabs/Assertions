// SPDX-License-Identifier: MIT
include "../../scans/Scalar.dfy"
module BytecodeApplyWindowErrorScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeScanScalar
  lemma Selector()
    ensures S.ShiftLeft(218546671,225) == 0x1a0d83de00000000000000000000000000000000000000000000000000000000
  {
    var input: G.Word := 218546671;
    var amount: G.Word := 225;
    var bits: bv256 := 218546671;
    var header: bv256 := 0x1a0d83de00000000000000000000000000000000000000000000000000000000;
    SC.Narrow(input);
    assert (input as bv256) == bits;
    assert bits << 225 == header;
    SC.ShiftDefinition(input,amount);
    reveal S.ShiftLeft();
  }
}
