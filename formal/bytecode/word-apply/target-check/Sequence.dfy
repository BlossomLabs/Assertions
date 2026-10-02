// SPDX-License-Identifier: MIT
include "../../scans/Machine.dfy"
module BytecodeApplyTargetSequence {
  import S = BytecodeScanMachine
  lemma Append(prefix: seq<S.Word>, a: S.Word, b: S.Word, c: S.Word)
    ensures prefix+[a,b,c] == (prefix+[a,b])+[c]
  {
    var flat := prefix+[a,b,c];
    var grouped := (prefix+[a,b])+[c];
    assert |flat| == |grouped|;
    forall i: nat | i < |flat|
      ensures flat[i] == grouped[i]
    {
      if i < |prefix| {}
      else if i == |prefix| {}
      else if i == |prefix|+1 {}
      else { assert i == |prefix|+2; }
    }
  }
}
