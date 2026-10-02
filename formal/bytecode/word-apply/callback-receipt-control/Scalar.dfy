// SPDX-License-Identifier: MIT
include "../callback-receipt/Memory.dfy"
include "../callback-receipt/Rounding.dfy"
include "../callback-success/Scalar.dfy"
include "../../opcode-kernels/And.dfy"
module BytecodeApplyCallbackReceiptScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import H = BytecodeApplyCallbackReceiptMemory
  import R = BytecodeApplyCallbackReceiptRounding
  import O = BytecodeOpcodeAnd
  import CS = BytecodeApplyCallbackSuccessScalar
  function Extent(returned: seq<S.Byte>): S.Word
    requires |returned|+256 < H.Bound()
  { 32+S.Round32(|returned|) }
  lemma Rounded(returned: seq<S.Byte>)
    requires |returned|+256 < H.Bound()
    ensures S.Round32(|returned|+32) == Extent(returned)
    ensures G.BitAnd(|returned|+63,S.BitNot(31)) == Extent(returned)
    ensures |returned|+32 <= Extent(returned) < |returned|+64
  {
    hide G.BitAnd();
    R.Round(|returned|+32);
  }
  lemma At(code: seq<S.Byte>,destinations: set<nat>,prefix: seq<S.Word>,mem: seq<S.Byte>,value: S.Word,data: seq<S.Byte>,returned: seq<S.Byte>)
    requires |code| > 16972 && code[16972] == 0x16 && |prefix| <= 1022
    requires |returned|+256 < H.Bound()
    ensures S.Step(code,destinations,S.Running(16972,prefix+[0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0,|returned|+63],mem),value,data) == S.Running(16973,prefix+[Extent(returned)],mem)
  {
    hide G.BitAnd();
    Rounded(returned);
    O.Step(code,destinations,16972,prefix,mem,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0,|returned|+63,value,data);
    CS.Not31();
  }
}
