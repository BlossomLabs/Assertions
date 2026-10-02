// SPDX-License-Identifier: MIT
include "../windows/Inputs.dfy"
module BytecodeApplyFirstInvalidWindow {
  import S = BytecodeScanMachine
  import W = BytecodeApplyWindowInputs
  ghost method Find(templateLength: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>) returns (bad: S.Word)
    requires W.Represented(templateLength,arrayOffset,count,data) && templateLength >= 32
    requires !W.Valid(templateLength,arrayOffset,count,data)
    ensures bad < count && W.At(arrayOffset,bad,data) > templateLength-32
    ensures forall j: nat :: j < bad ==> W.At(arrayOffset,j,data) <= templateLength-32
  {
    bad := 0;
    while bad < count && W.At(arrayOffset,bad,data) <= templateLength-32
      invariant bad <= count
      invariant forall j: nat :: j < bad ==> W.At(arrayOffset,j,data) <= templateLength-32
      decreases count-bad
    { bad := bad+1; }
    if bad == count { assert W.Valid(templateLength,arrayOffset,count,data); }
  }
}
