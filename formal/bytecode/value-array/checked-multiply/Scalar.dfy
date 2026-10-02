// SPDX-License-Identifier: MIT
include "../../scans/Execution.dfy"
include "../byte-machine/Scalar.dfy"
module BytecodeCollectionsCheckedMultiplyScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import Z = BytecodeCollectionsArrayByteScalar
  lemma ProductQuotient(left: S.Word,right: S.Word)
    requires left*right < G.Modulus()
    ensures right > 0 ==> (left*right)/right == left
  {
    if right > 0 {
      Z.Quotient(left,0,right);
    }
  }
  lemma OneOr(b: S.Word)
    requires b <= 1
    ensures G.BitOr(1,b) == 1 && G.BitOr(b,1) == 1
  {
    reveal G.BitOr();
    if b == 0 {
      assert (1 as bv256)|(0 as bv256) == 1;
      assert (0 as bv256)|(1 as bv256) == 1;
    } else {
      assert b == 1;
      assert (1 as bv256)|(1 as bv256) == 1;
    }
  }
  lemma TruthOr(left: S.Word,right: S.Word)
    ensures G.BitOr(if right == 0 then 1 else 0,if right == 0 && left != 0 then 0 else 1) == 1
  {
    if right == 0 { OneOr(if left == 0 then 1 else 0); }
    else { OneOr(0); }
  }
}
