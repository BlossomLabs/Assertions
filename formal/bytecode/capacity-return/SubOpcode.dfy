// SPDX-License-Identifier: MIT
// Actual serializer end-minus-start subtraction, isolated from heap definitions.
include "../scans/Machine.dfy"
module BytecodeCapacityReturnSubOpcode {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  lemma Step(code: seq<S.Byte>, destinations: set<nat>, prefix: seq<S.Word>, mem: seq<S.Byte>, capacity: S.Word, n: S.Word, value: S.Word, data: seq<S.Byte>)
    requires |code| > 496 && code[496] == 0x03
    requires |prefix| <= 1022 && n <= capacity < 0x800000000000000
    ensures S.Step(code,destinations,S.Running(496,prefix+[160+capacity*32,224+capacity*32+n*32],mem),value,data) == S.Running(497,prefix+[64+n*32],mem)
  {
    reveal S.Step();
    assert S.Fetch(code,496) == S.Op(0x03,497,0);
    assert (224+capacity*32+n*32+G.Modulus()-(160+capacity*32))%G.Modulus() == 64+n*32;
  }
}
