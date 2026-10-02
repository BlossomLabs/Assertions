// SPDX-License-Identifier: MIT
include "../../scans/Machine.dfy"
module BytecodeApplyReturnSubOpcode {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  lemma Step(code: seq<S.Byte>,destinations: set<nat>,prefix: seq<S.Word>,mem: seq<S.Byte>,free: S.Word,n: S.Word,value: S.Word,data: seq<S.Byte>)
    requires |code| > 496 && code[496] == 0x03 && |prefix| <= 1022
    requires (free as nat)+96+n*32 < G.Modulus()
    ensures S.Step(code,destinations,S.Running(496,prefix+[free,free+64+n*32],mem),value,data) == S.Running(497,prefix+[64+n*32],mem)
  {
    reveal S.Step();
    assert S.Fetch(code,496) == S.Op(0x03,497,0);
    assert (free+64+n*32+G.Modulus()-free)%G.Modulus() == 64+n*32;
  }
}
