// SPDX-License-Identifier: MIT
include "../../scans/Machine.dfy"
module BytecodeApplyCallStackSequence {
  import S = BytecodeScanMachine
  lemma Six(prefix: seq<S.Word>,a: S.Word,b: S.Word,c: S.Word,d: S.Word,e: S.Word,f: S.Word)
    ensures (prefix+[a,b,c,d,e])+[f] == prefix+[a,b,c,d,e,f]
  {
    var left := (prefix+[a,b,c,d,e])+[f];
    var right := prefix+[a,b,c,d,e,f];
    assert |left| == |right|;
    forall i: nat | i < |left|
      ensures left[i] == right[i]
    {
      if i < |prefix| {}
      else if i == |prefix| {}
      else if i == |prefix|+1 {}
      else if i == |prefix|+2 {}
      else if i == |prefix|+3 {}
      else if i == |prefix|+4 {}
      else { assert i == |prefix|+5; }
    }
  }
  lemma One(prefix: seq<S.Word>,tail: seq<S.Word>,word: S.Word)
    ensures (prefix+tail)+[word] == prefix+(tail+[word])
  {
    var left := (prefix+tail)+[word];
    var right := prefix+(tail+[word]);
    assert |left| == |right|;
    forall i: nat | i < |left|
      ensures left[i] == right[i]
    {
      if i < |prefix| {}
      else if i < |prefix|+|tail| {}
      else { assert i == |prefix|+|tail|; }
    }
  }
}
