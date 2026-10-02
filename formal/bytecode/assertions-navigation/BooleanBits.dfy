// SPDX-License-Identifier: MIT
include "../scans/Machine.dfy"
module AssertionsNavigationBooleanBits {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  lemma And(left: S.Word,right: S.Word)
    requires left <= 1 && right <= 1
    ensures G.BitAnd(left,right) == (if left == 1 && right == 1 then 1 else 0)
  {
    if left == 0 { assert (left as bv256) == 0; }
    else { assert (left as bv256) == 1; }
    if right == 0 { assert (right as bv256) == 0; }
    else { assert (right as bv256) == 1; }
    reveal G.BitAnd();
  }
  lemma Or(left: S.Word,right: S.Word)
    requires left <= 1 && right <= 1
    ensures G.BitOr(left,right) == (if left == 1 || right == 1 then 1 else 0)
  {
    if left == 0 { assert (left as bv256) == 0; }
    else { assert (left as bv256) == 1; }
    if right == 0 { assert (right as bv256) == 0; }
    else { assert (right as bv256) == 1; }
    reveal G.BitOr();
  }
}
