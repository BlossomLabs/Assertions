// SPDX-License-Identifier: MIT
include "../alignment/Mask.dfy"
include "../iota/AllocationScalar.dfy"
module BytecodeIotaReturnMaskOpcode {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import AM = BytecodeWordLengthMask
  import SC = BytecodeIotaAllocationScalar
  lemma Value(n: S.Word)
    requires n < 0x800000000000000
    ensures G.BitAnd(n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0) == n*32
  { SC.Not31(); AM.Mask(n); }
  lemma Step(code: seq<S.Byte>, destinations: set<nat>, prefix: seq<S.Word>, mem: seq<S.Byte>, n: S.Word, value: S.Word, data: seq<S.Byte>)
    requires |code| > 20985 && code[20985] == 0x16
    requires |prefix| <= 1022 && n < 0x800000000000000
    ensures S.Step(code,destinations,S.Running(20985,prefix+[0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0,n*32+31],mem),value,data) == S.Running(20986,prefix+[n*32],mem)
  {
    Value(n);
    SC.BitAndCommute(n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0);
    reveal S.Step();
    assert S.Fetch(code,20985) == S.Op(0x16,20986,0);
  }
}
