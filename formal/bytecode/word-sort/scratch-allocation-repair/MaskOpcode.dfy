// SPDX-License-Identifier: MIT
include "../../iota/AllocationScalar.dfy"
include "../../alignment/Mask.dfy"
include "../../opcode-kernels/And.dfy"
module BytecodeSortScratchAllocationMaskOpcode {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeIotaAllocationScalar
  import A = BytecodeOpcodeAnd
  import AM = BytecodeWordLengthMask
  lemma Step(code: seq<S.Byte>, destinations: set<nat>, prefix: seq<S.Word>, mem: seq<S.Byte>, n: S.Word, value: S.Word, data: seq<S.Byte>)
    requires |code| > 3579 && code[3579] == 0x16
    requires |prefix| <= 1022 && n < 0x800000000000000
    ensures S.Step(code,destinations,S.Running(3579,prefix+[n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0],mem),value,data) == S.Running(3580,prefix+[n*32],mem)
  {
    SC.Not31();
    AM.Mask(n);
    SC.BitAndCommute(S.BitNot(31),n*32+31);
    A.Step(code,destinations,3579,prefix,mem,n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0,value,data);
  }
}
