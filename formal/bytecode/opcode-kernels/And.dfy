// SPDX-License-Identifier: MIT
include "../scans/Machine.dfy"
module BytecodeOpcodeAnd {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  lemma Step(code: seq<S.Byte>, destinations: set<nat>, pc: nat, prefix: seq<S.Word>, mem: seq<S.Byte>, a: S.Word, b: S.Word, value: S.Word, data: seq<S.Byte>)
    requires pc < |code| && code[pc] == 0x16 && |prefix| <= 1022
    ensures S.Step(code,destinations,S.Running(pc,prefix+[a,b],mem),value,data) == S.Running(pc+1,prefix+[G.BitAnd(b,a)],mem)
  {
    reveal S.Step();
    assert S.Fetch(code,pc) == S.Op(0x16,pc+1,0);
  }
}
