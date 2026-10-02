// SPDX-License-Identifier: MIT
include "../../scans/Machine.dfy"
module BytecodeApplyRawCallbackStackSequence {
  import S = BytecodeScanMachine
  lemma Group(prefix: seq<S.Word>,fields: seq<S.Word>,tail: seq<S.Word>,result: S.Word)
    ensures ((prefix+fields+[96])+[5526]+fields+tail)+[result] == prefix+fields+[96,5526]+fields+(tail+[result])
  {
    var lhs := ((prefix+fields+[96])+[5526]+fields+tail)+[result];
    var rhs := prefix+fields+[96,5526]+fields+(tail+[result]);
    assert |lhs| == |rhs|;
    forall i: nat | i < |lhs|
      ensures lhs[i] == rhs[i]
    {
      if i < |prefix| {}
      else if i < |prefix|+|fields| {}
      else if i == |prefix|+|fields| { assert lhs[i] == 96; assert rhs[i] == 96; }
      else if i == |prefix|+|fields|+1 { assert lhs[i] == 5526; assert rhs[i] == 5526; }
      else if i < |prefix|+2*|fields|+2 {}
      else if i < |prefix|+2*|fields|+2+|tail| {}
      else { assert lhs[i] == result; assert rhs[i] == result; }
    }
  }
  lemma Nine(a0: S.Word,a1: S.Word,a2: S.Word,a3: S.Word,a4: S.Word,a5: S.Word,a6: S.Word,a7: S.Word,a8: S.Word)
    ensures [a0,a1,a2,a3,a4,a5,a6,a7]+[a8] == [a0,a1,a2,a3,a4,a5,a6,a7,a8]
  {
    var lhs := [a0,a1,a2,a3,a4,a5,a6,a7]+[a8];
    var rhs := [a0,a1,a2,a3,a4,a5,a6,a7,a8];
    forall i: nat | i < 9
      ensures lhs[i] == rhs[i]
    {
      if i == 0 {} else if i == 1 {} else if i == 2 {} else if i == 3 {}
      else if i == 4 {} else if i == 5 {} else if i == 6 {} else if i == 7 {}
      else { assert i == 8; }
    }
  }
}
