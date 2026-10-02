// SPDX-License-Identifier: MIT
// Exact reached PUSH5/PUSH6 literals in typeShape's base-name classification.
include "NameClass.dfy"
include "../scans/Fetch.dfy"
module AssertionsNavigationNamePush {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import K = AssertionsNavigationNameClass
  lemma BytesPush(code: seq<S.Byte>,pc: nat)
    requires pc+6 <= |code| && code[pc] == 100 && code[pc+1..pc+6] == [98,121,116,101,115]
    ensures S.Fetch(code,pc) == S.Op(100,pc+6,0x6279746573)
  {
    R.WindowFits(code,pc+1,5);
    K.Five(code[pc+1..pc+6]);
    assert K.Dynamic(code[pc+1..pc+6]);
  }
  lemma StringPush(code: seq<S.Byte>,pc: nat)
    requires pc+7 <= |code| && code[pc] == 101 && code[pc+1..pc+7] == [115,116,114,105,110,103]
    ensures S.Fetch(code,pc) == S.Op(101,pc+7,0x737472696e67)
  {
    R.WindowFits(code,pc+1,6);
    K.Six(code[pc+1..pc+7]);
    assert K.Dynamic(code[pc+1..pc+7]);
  }
}
