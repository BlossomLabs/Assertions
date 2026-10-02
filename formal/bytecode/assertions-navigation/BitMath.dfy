// SPDX-License-Identifier: MIT
// Generic stack-order bridge for physical bitwise instructions.
include "../getters/Machine.dfy"
module AssertionsNavigationBitMath {
  import G = BytecodeGetterMachine
  lemma Commute(a: G.Word,b: G.Word)
    ensures G.BitAnd(a,b) == G.BitAnd(b,a)
  { reveal G.BitAnd(); }
}
