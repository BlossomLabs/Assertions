// SPDX-License-Identifier: MIT
include "AllocationScalar.dfy"
include "../alignment/Mask.dfy"
module BytecodeIotaMaskOpcode {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SC = BytecodeIotaAllocationScalar
  import AM = BytecodeWordLengthMask
  lemma Opcode(code: seq<S.Byte>, destinations: set<nat>, prefix: seq<S.Word>, mem: seq<S.Byte>, a: S.Word, b: S.Word, value: S.Word, data: seq<S.Byte>)
    requires |code| > 5591 && code[5591] == 0x16 && |prefix| <= 1022
    ensures S.Step(code,destinations,S.Running(5591,prefix+[a,b],mem),value,data) == S.Running(5592,prefix+[G.BitAnd(b,a)],mem)
  {
    reveal S.Step();
    assert S.Fetch(code,5591) == S.Op(0x16,5592,0);
  }
  lemma Step(code: seq<S.Byte>, destinations: set<nat>, prefix: seq<S.Word>, mem: seq<S.Byte>, n: S.Word, value: S.Word, data: seq<S.Byte>)
    requires |code| > 5591 && code[5591] == 0x16
    requires |prefix| <= 1022 && n < 0x800000000000000
    ensures S.Step(code,destinations,S.Running(5591,prefix+[n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0],mem),value,data) == S.Running(5592,prefix+[n*32],mem)
  {
    SC.Not31();
    AM.Mask(n);
    SC.BitAndCommute(S.BitNot(31),n*32+31);
    Opcode(code,destinations,prefix,mem,n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0,value,data);
  }
}
