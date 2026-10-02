// SPDX-License-Identifier: MIT
// Reuse the checked full uint256 address-mask identity without calldata expansion.
include "../../word-apply/raw-decoder/Scalar.dfy"
module BytecodeFoldRawScalar {
  import G = BytecodeGetterMachine
  import A = BytecodeApplyRawScalar
  lemma Address(target: G.Word)
    ensures (G.BitAnd(target,0xffffffffffffffffffffffffffffffffffffffff) == target) <==> target < 0x10000000000000000000000000000000000000000
    ensures G.BitAnd(target,0xffffffffffffffffffffffffffffffffffffffff) < 0x10000000000000000000000000000000000000000
  {
    hide G.BitAnd();
    A.Address(target);
  }
}
