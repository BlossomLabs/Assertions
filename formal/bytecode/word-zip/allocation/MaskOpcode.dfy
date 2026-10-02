// SPDX-License-Identifier: MIT
include "../../iota/AllocationScalar.dfy"
include "../../alignment/Mask.dfy"
module BytecodeZipAllocationMaskOpcode {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeIotaAllocationScalar
  import AM = BytecodeWordLengthMask
  lemma Step(code: seq<S.Byte>, destinations: set<nat>, prefix: seq<S.Word>, mem: seq<S.Byte>, n: S.Word, value: S.Word, data: seq<S.Byte>)
    requires |code| > 2062 && code[2062] == 0x16
    requires |prefix| <= 1022 && n < 0x800000000000000
    ensures S.Step(code,destinations,S.Running(2062,prefix+[n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0],mem),value,data) == S.Running(2063,prefix+[n*32],mem)
  {
    SC.Not31();
    AM.Mask(n);
    SC.BitAndCommute(S.BitNot(31),n*32+31);
    reveal S.Step();
    assert S.Fetch(code,2062) == S.Op(0x16,2063,0);
  }
}
