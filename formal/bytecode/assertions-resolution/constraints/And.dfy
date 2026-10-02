// SPDX-License-Identifier: MIT
// Stack-order bridge for the actual allocator's mask-first AND.
include "../../getters/Machine.dfy"
module AssertionsConstraintAnd {
  import G = BytecodeGetterMachine
  lemma Commute(a: G.Word, b: G.Word)
    ensures G.BitAnd(a,b) == G.BitAnd(b,a)
  { reveal G.BitAnd(); }
}
