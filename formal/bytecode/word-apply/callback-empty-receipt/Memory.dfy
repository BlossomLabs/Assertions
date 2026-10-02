// SPDX-License-Identifier: MIT
// Actual Solidity empty bytes pointer and unchanged caller-local heap.
include "../../external-calls/Execution.dfy"
include "../callback-result-error/Memory.dfy"
module BytecodeApplyEmptyReceiptMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import H = BytecodeApplyWrongCallbackMemory
  predicate Fits(mem: seq<S.Byte>,free: S.Word) {
    128 <= |mem| < G.Modulus() && |mem|%32 == 0 && 160 <= free
    && free+160 < G.Modulus() && S.Load(mem,64) == free && S.Load(mem,96) == 0
  }
  lemma Header(mem: seq<S.Byte>,free: S.Word)
    requires Fits(mem,free)
    ensures 96+32 <= |mem| && S.Load(mem,96) == 0
    ensures H.Fits(mem,free)
  {}
}
