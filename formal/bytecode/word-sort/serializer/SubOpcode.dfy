// SPDX-License-Identifier: MIT
include "../../scans/Machine.dfy"
module BytecodeSortBytesReturnSubOpcode {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  lemma Step(code: seq<S.Byte>, destinations: set<nat>, prefix: seq<S.Word>, mem: seq<S.Byte>, n: S.Word, extent: S.Word, value: S.Word, data: seq<S.Byte>)
    requires |code| > 496 && code[496] == 0x03 && |prefix| <= 1022 && n < 0x800000000000000 && extent < 0x40000000000000000
    ensures S.Step(code,destinations,S.Running(496,prefix+[extent,extent+64+n*32],mem),value,data) == S.Running(497,prefix+[64+n*32],mem)
  { reveal S.Step(); assert S.Fetch(code,496) == S.Op(0x03,497,0); assert (extent+64+n*32+G.Modulus()-extent)%G.Modulus() == 64+n*32; }
}
