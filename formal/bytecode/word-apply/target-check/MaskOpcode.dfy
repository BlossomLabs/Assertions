// SPDX-License-Identifier: MIT
include "../address-kernel/Mask.dfy"
include "../../opcode-kernels/And.dfy"
module BytecodeApplyTargetMaskOpcode {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = BytecodeApplyAddressMask
  import O = BytecodeOpcodeAnd
  lemma Step(code: seq<S.Byte>, destinations: set<nat>, prefix: seq<S.Word>, mem: seq<S.Byte>, target: S.Word, value: S.Word, data: seq<S.Byte>)
    requires |code| > 15869 && code[15869] == 0x16
    requires |prefix| <= 1022 && target < A.Bound()
    ensures S.Step(code,destinations,S.Running(15869,prefix+[target,0xffffffffffffffffffffffffffffffffffffffff],mem),value,data) == S.Running(15870,prefix+[target],mem)
  {
    hide G.BitAnd();
    A.Canonical(target);
    O.Step(code,destinations,15869,prefix,mem,target,0xffffffffffffffffffffffffffffffffffffffff,value,data);
  }
}
