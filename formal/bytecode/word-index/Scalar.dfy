// SPDX-License-Identifier: MIT
include "../scans/Machine.dfy"
module BytecodeIndexScalar {
  import M = BytecodeScanMachine
  import G = BytecodeGetterMachine
  lemma ShiftDefinition(a: G.Word, amount: G.Word)
    ensures G.Shift(a,amount) == (if amount >= 256 then 0 else ((a as bv256) << (amount as nat)) as nat)
  { reveal G.Shift(); }
  lemma Narrow(a: G.Word)
    requires a < 0x100000000
    ensures (a as bv256) == ((a as bv32) as bv256)
  {}
  lemma DecoderLimit()
    ensures M.ShiftLeft(1,64) == 0x10000000000000000
  {
    reveal M.ShiftLeft();
    var a: G.Word := 1;
    var amount: G.Word := 64;
    Narrow(a); Narrow(amount);
    assert (a as bv256) == (1 as bv256);
    assert (amount as bv256) == (64 as bv256);
    ShiftDefinition(a,amount);
    assert ((a as bv256) << (amount as nat)) == (0x10000000000000000 as bv256);
  }
  lemma ErrorSelectors()
    ensures M.ShiftLeft(0xa949d285,224) == 0xa949d28500000000000000000000000000000000000000000000000000000000
    ensures M.ShiftLeft(0x4e487b71,224) == 0x4e487b7100000000000000000000000000000000000000000000000000000000
  {
    reveal M.ShiftLeft();
    var amount: G.Word := 224;
    var shiftAmount: bv256 := 224;
    Narrow(amount);
    assert (amount as bv256) == shiftAmount;
    var input0: G.Word := 0xa949d285;
    var bits0: bv256 := 0xa949d285;
    var header0: bv256 := 0xa949d28500000000000000000000000000000000000000000000000000000000;
    Narrow(input0);
    assert (input0 as bv32) == (bits0 as bv32);
    assert (input0 as bv256) == bits0;
    assert bits0 << (amount as nat) == header0;
    assert (header0 as nat) == 0xa949d28500000000000000000000000000000000000000000000000000000000;
    ShiftDefinition(input0,amount);
    assert G.Shift(input0,amount) == (header0 as nat);
    var input1: G.Word := 0x4e487b71;
    var bits1: bv256 := 0x4e487b71;
    var header1: bv256 := 0x4e487b7100000000000000000000000000000000000000000000000000000000;
    Narrow(input1);
    assert (input1 as bv32) == (bits1 as bv32);
    assert (input1 as bv256) == bits1;
    assert bits1 << (amount as nat) == header1;
    assert (header1 as nat) == 0x4e487b7100000000000000000000000000000000000000000000000000000000;
    ShiftDefinition(input1,amount);
    assert G.Shift(input1,amount) == (header1 as nat);
  }
}
