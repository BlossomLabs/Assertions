// SPDX-License-Identifier: MIT
include "../address-kernel/Mask.dfy"
include "../../opcode-kernels/And.dfy"
module BytecodeApplyCallbackPackMask {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = BytecodeApplyAddressMask
  import O = BytecodeOpcodeAnd
  lemma At(code: seq<S.Byte>,destinations: set<nat>,prefix: seq<S.Word>,mem: seq<S.Byte>,target: S.Word,value: S.Word,data: seq<S.Byte>)
    requires |code| > 16922 && code[16922] == 0x16 && |prefix| <= 1022 && target < A.Bound()
    ensures S.Step(code,destinations,S.Running(16922,prefix+[target,0xffffffffffffffffffffffffffffffffffffffff],mem),value,data) == S.Running(16923,prefix+[target],mem)
  {
    hide G.BitAnd(); A.Canonical(target);
    O.Step(code,destinations,16922,prefix,mem,target,0xffffffffffffffffffffffffffffffffffffffff,value,data);
  }
}
