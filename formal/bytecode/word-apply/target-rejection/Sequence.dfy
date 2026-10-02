// SPDX-License-Identifier: MIT
include "../../scans/Machine.dfy"
module BytecodeApplyTargetErrorSequence {
  import S = BytecodeScanMachine
  lemma Append(prefix: seq<S.Word>,tail: seq<S.Word>,a: S.Word,b: S.Word)
    ensures prefix+(tail+[a,b]) == (prefix+tail)+[a,b]
  {}
  lemma One(prefix: seq<S.Word>,tail: seq<S.Word>,a: S.Word)
    ensures prefix+(tail+[a]) == (prefix+tail)+[a]
  {}
  lemma ThreeOne(prefix: seq<S.Word>,a0: S.Word,a1: S.Word,a2: S.Word)
    ensures (prefix+[a0,a1])+[a2] == prefix+[a0,a1,a2]
  {
    var lhs := (prefix+[a0,a1])+[a2]; var rhs := prefix+[a0,a1,a2];
    assert |lhs| == |rhs|;
    forall index: nat | index < |lhs|
      ensures lhs[index] == rhs[index]
    {
      if index < |prefix| {}
      else {
        if index == |prefix|+0 { assert lhs[index] == a0; assert rhs[index] == a0; }
        else if index == |prefix|+1 { assert lhs[index] == a1; assert rhs[index] == a1; }
        else if index == |prefix|+2 { assert lhs[index] == a2; assert rhs[index] == a2; }
        else { assert false; }
      }
    }
  }
  lemma FourPair(prefix: seq<S.Word>,a0: S.Word,a1: S.Word,a2: S.Word,a3: S.Word)
    ensures (prefix+[a0,a1])+[a2,a3] == prefix+[a0,a1,a2,a3]
  {
    var lhs := (prefix+[a0,a1])+[a2,a3]; var rhs := prefix+[a0,a1,a2,a3];
    assert |lhs| == |rhs|;
    forall index: nat | index < |lhs|
      ensures lhs[index] == rhs[index]
    {
      if index < |prefix| {}
      else {
        if index == |prefix|+0 { assert lhs[index] == a0; assert rhs[index] == a0; }
        else if index == |prefix|+1 { assert lhs[index] == a1; assert rhs[index] == a1; }
        else if index == |prefix|+2 { assert lhs[index] == a2; assert rhs[index] == a2; }
        else if index == |prefix|+3 { assert lhs[index] == a3; assert rhs[index] == a3; }
        else { assert false; }
      }
    }
  }
  lemma FourOne(prefix: seq<S.Word>,a0: S.Word,a1: S.Word,a2: S.Word,a3: S.Word)
    ensures (prefix+[a0,a1,a2])+[a3] == prefix+[a0,a1,a2,a3]
  {
    var lhs := (prefix+[a0,a1,a2])+[a3]; var rhs := prefix+[a0,a1,a2,a3];
    assert |lhs| == |rhs|;
    forall index: nat | index < |lhs|
      ensures lhs[index] == rhs[index]
    {
      if index < |prefix| {}
      else {
        if index == |prefix|+0 { assert lhs[index] == a0; assert rhs[index] == a0; }
        else if index == |prefix|+1 { assert lhs[index] == a1; assert rhs[index] == a1; }
        else if index == |prefix|+2 { assert lhs[index] == a2; assert rhs[index] == a2; }
        else if index == |prefix|+3 { assert lhs[index] == a3; assert rhs[index] == a3; }
        else { assert false; }
      }
    }
  }
  lemma FivePair(prefix: seq<S.Word>,a0: S.Word,a1: S.Word,a2: S.Word,a3: S.Word,a4: S.Word)
    ensures (prefix+[a0,a1,a2])+[a3,a4] == prefix+[a0,a1,a2,a3,a4]
  {
    var lhs := (prefix+[a0,a1,a2])+[a3,a4]; var rhs := prefix+[a0,a1,a2,a3,a4];
    assert |lhs| == |rhs|;
    forall index: nat | index < |lhs|
      ensures lhs[index] == rhs[index]
    {
      if index < |prefix| {}
      else {
        if index == |prefix|+0 { assert lhs[index] == a0; assert rhs[index] == a0; }
        else if index == |prefix|+1 { assert lhs[index] == a1; assert rhs[index] == a1; }
        else if index == |prefix|+2 { assert lhs[index] == a2; assert rhs[index] == a2; }
        else if index == |prefix|+3 { assert lhs[index] == a3; assert rhs[index] == a3; }
        else if index == |prefix|+4 { assert lhs[index] == a4; assert rhs[index] == a4; }
        else { assert false; }
      }
    }
  }
}
