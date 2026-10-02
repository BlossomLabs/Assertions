// SPDX-License-Identifier: MIT
include "../../iota/AllocationScalar.dfy"
include "../../alignment/Mask.dfy"
module BytecodeApplyAllocationMaskOpcode {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeIotaAllocationScalar
  import AM = BytecodeWordLengthMask
  lemma Step(code: seq<S.Byte>, destinations: set<nat>, prefix: seq<S.Word>, mem: seq<S.Byte>, n: S.Word, value: S.Word, data: seq<S.Byte>)
    requires |code| > 12288 && code[12288] == 0x16
    requires |prefix| <= 1022 && n < 0x800000000000000
    ensures S.Step(code,destinations,S.Running(12288,prefix+[n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0],mem),value,data) == S.Running(12289,prefix+[n*32],mem)
  {
    SC.Not31();
    AM.Mask(n);
    SC.BitAndCommute(S.BitNot(31),n*32+31);
    reveal S.Step();
    assert S.Fetch(code,12288) == S.Op(0x16,12289,0);
  }
}
