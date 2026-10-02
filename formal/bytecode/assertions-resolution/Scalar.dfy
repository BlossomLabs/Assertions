// SPDX-License-Identifier: MIT
include "../scans/Scalar.dfy"
module AssertionsConstraintScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import P = BytecodeScanScalar
  lemma ErrorHeaders()
    ensures S.ShiftLeft(1938191283,225) == 0xe70ce76600000000000000000000000000000000000000000000000000000000
    ensures S.ShiftLeft(693780933,224) == 0x295a41c500000000000000000000000000000000000000000000000000000000
  {
    reveal S.ShiftLeft();
    var first: G.Word := 1938191283;
    var firstBits: bv256 := 1938191283;
    var firstHeader: bv256 := 0xe70ce76600000000000000000000000000000000000000000000000000000000;
    P.Narrow(first);
    assert (first as bv32) == (firstBits as bv32);
    assert (first as bv256) == firstBits;
    assert firstBits << 225 == firstHeader;
    P.ShiftDefinition(first,225);
    assert (firstHeader as nat) == 0xe70ce76600000000000000000000000000000000000000000000000000000000;
    var second: G.Word := 693780933;
    var secondBits: bv256 := 693780933;
    var secondHeader: bv256 := 0x295a41c500000000000000000000000000000000000000000000000000000000;
    P.Narrow(second);
    assert (second as bv32) == (secondBits as bv32);
    assert (second as bv256) == secondBits;
    assert secondBits << 224 == secondHeader;
    P.ShiftDefinition(second,224);
    assert (secondHeader as nat) == 0x295a41c500000000000000000000000000000000000000000000000000000000;
  }
}
