// SPDX-License-Identifier: MIT
include "../../scans/Scalar.dfy"
module BytecodeZipErrorScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeScanScalar
  lemma WordCountMismatchHalfSelector()
    ensures S.ShiftLeft(0x0d8831b5,225) == 0x1b10636a00000000000000000000000000000000000000000000000000000000
  {
    reveal S.ShiftLeft();
    var amount: G.Word := 225;
    var input: G.Word := 0x0d8831b5;
    var bits: bv256 := 0x0d8831b5;
    var header: bv256 := 0x1b10636a00000000000000000000000000000000000000000000000000000000;
    SC.Narrow(amount); SC.Narrow(input);
    assert (input as bv256) == bits;
    assert bits << (amount as nat) == header;
    assert (header as nat) == 0x1b10636a00000000000000000000000000000000000000000000000000000000;
    SC.ShiftDefinition(input,amount);
  }
  lemma WordCountMismatchSelector()
    ensures S.ShiftLeft(0x1b10636a,224) == 0x1b10636a00000000000000000000000000000000000000000000000000000000
  {
    reveal S.ShiftLeft();
    var amount: G.Word := 224;
    var input: G.Word := 0x1b10636a;
    var bits: bv256 := 0x1b10636a;
    var header: bv256 := 0x1b10636a00000000000000000000000000000000000000000000000000000000;
    SC.Narrow(amount); SC.Narrow(input);
    assert (input as bv256) == bits;
    assert bits << (amount as nat) == header;
    assert (header as nat) == 0x1b10636a00000000000000000000000000000000000000000000000000000000;
    SC.ShiftDefinition(input,amount);
  }
}
