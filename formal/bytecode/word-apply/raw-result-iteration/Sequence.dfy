// SPDX-License-Identifier: MIT
include "../../scans/Machine.dfy"
module BytecodeApplyFirstResultStackSequence {
  import S = BytecodeScanMachine
  lemma FieldsTail(prefix: seq<S.Word>,a0: S.Word,a1: S.Word,a2: S.Word,a3: S.Word,a4: S.Word,a5: S.Word,a6: S.Word,a7: S.Word,a8: S.Word,a9: S.Word,a10: S.Word,a11: S.Word,a12: S.Word,a13: S.Word,a14: S.Word,a15: S.Word,a16: S.Word)
    ensures (prefix+[a0])+[a1,a2,a3,a4,a5,a6,a7]+[a8,a9,a10,a11,a12,a13,a14,a15,a16] == prefix+[a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16]
  {
    var lhs := (prefix+[a0])+[a1,a2,a3,a4,a5,a6,a7]+[a8,a9,a10,a11,a12,a13,a14,a15,a16]; var rhs := prefix+[a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16];
    assert |lhs| == |rhs|;
    forall i: nat | i < |lhs|
      ensures lhs[i] == rhs[i]
    {
      if i < |prefix| {}
      else {
        if i == |prefix|+0 { assert lhs[i] == a0; assert rhs[i] == a0; }
        else if i == |prefix|+1 { assert lhs[i] == a1; assert rhs[i] == a1; }
        else if i == |prefix|+2 { assert lhs[i] == a2; assert rhs[i] == a2; }
        else if i == |prefix|+3 { assert lhs[i] == a3; assert rhs[i] == a3; }
        else if i == |prefix|+4 { assert lhs[i] == a4; assert rhs[i] == a4; }
        else if i == |prefix|+5 { assert lhs[i] == a5; assert rhs[i] == a5; }
        else if i == |prefix|+6 { assert lhs[i] == a6; assert rhs[i] == a6; }
        else if i == |prefix|+7 { assert lhs[i] == a7; assert rhs[i] == a7; }
        else if i == |prefix|+8 { assert lhs[i] == a8; assert rhs[i] == a8; }
        else if i == |prefix|+9 { assert lhs[i] == a9; assert rhs[i] == a9; }
        else if i == |prefix|+10 { assert lhs[i] == a10; assert rhs[i] == a10; }
        else if i == |prefix|+11 { assert lhs[i] == a11; assert rhs[i] == a11; }
        else if i == |prefix|+12 { assert lhs[i] == a12; assert rhs[i] == a12; }
        else if i == |prefix|+13 { assert lhs[i] == a13; assert rhs[i] == a13; }
        else if i == |prefix|+14 { assert lhs[i] == a14; assert rhs[i] == a14; }
        else if i == |prefix|+15 { assert lhs[i] == a15; assert rhs[i] == a15; }
        else if i == |prefix|+16 { assert lhs[i] == a16; assert rhs[i] == a16; }
        else { assert false; }
      }
    }
  }
}
