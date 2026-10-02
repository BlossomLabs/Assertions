// SPDX-License-Identifier: MIT
include "../../iota/AllocationScalar.dfy"
include "../../alignment/Mask.dfy"
module BytecodeReverseAllocationMaskOpcode {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeIotaAllocationScalar
  import AM = BytecodeWordLengthMask
  lemma Step(code: seq<S.Byte>, destinations: set<nat>, prefix: seq<S.Word>, mem: seq<S.Byte>, n: S.Word, value: S.Word, data: seq<S.Byte>)
    requires |code| > 5814 && code[5814] == 0x16
    requires |prefix| <= 1022 && n < 0x800000000000000
    ensures S.Step(code,destinations,S.Running(5814,prefix+[n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0],mem),value,data) == S.Running(5815,prefix+[n*32],mem)
  {
    SC.Not31();
    AM.Mask(n);
    SC.BitAndCommute(S.BitNot(31),n*32+31);
    reveal S.Step();
    assert S.Fetch(code,5814) == S.Op(0x16,5815,0);
  }
}
