// SPDX-License-Identifier: MIT
include "../../scans/Scalar.dfy"
module BytecodeUnzipErrorScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeScanScalar
  lemma InvalidLaneSelector()
    ensures S.ShiftLeft(0x1c133803,224) == 0x1c13380300000000000000000000000000000000000000000000000000000000
  {
    reveal S.ShiftLeft();
    var amount: G.Word := 224;
    var input: G.Word := 0x1c133803;
    var bits: bv256 := 0x1c133803;
    var header: bv256 := 0x1c13380300000000000000000000000000000000000000000000000000000000;
    SC.Narrow(amount); SC.Narrow(input);
    assert (input as bv256) == bits;
    assert bits << (amount as nat) == header;
    assert (header as nat) == 0x1c13380300000000000000000000000000000000000000000000000000000000;
    SC.ShiftDefinition(input,amount);
  }
}
