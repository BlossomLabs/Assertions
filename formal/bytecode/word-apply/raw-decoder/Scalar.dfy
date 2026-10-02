// SPDX-License-Identifier: MIT
// Connect the address compiler's actual AND operand order to canonical admission.
include "../address-kernel/Mask.dfy"
include "../../iota/AllocationScalar.dfy"
module BytecodeApplyRawScalar {
  import G = BytecodeGetterMachine
  import A = BytecodeApplyAddressMask
  import C = BytecodeIotaAllocationScalar
  lemma Address(target: G.Word)
    ensures (G.BitAnd(target,0xffffffffffffffffffffffffffffffffffffffff) == target) <==> target < A.Bound()
    ensures G.BitAnd(target,0xffffffffffffffffffffffffffffffffffffffff) < A.Bound()
  {
    hide G.BitAnd();
    C.BitAndCommute(target,0xffffffffffffffffffffffffffffffffffffffff);
    A.AcceptedExactly(target);
    A.NativeBound(target);
  }
}
