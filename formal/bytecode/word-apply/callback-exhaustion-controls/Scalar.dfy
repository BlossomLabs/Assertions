// SPDX-License-Identifier: MIT
include "../callback-out-of-gas-return-repair-v3/Memory.dfy"
include "../../external-calls/Execution.dfy"
module BytecodeApplyCallbackExhaustionScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = BytecodeApplyAddressMask
  import W = BytecodeApplyWrongCallbackScalar
  import O = BytecodeApplyCallbackOutOfGasReturnMemory
  function Difference(length: S.Word): S.Word { (4+G.Modulus()-length)%G.Modulus() }
  opaque function Masked(head: S.Word): S.Word { G.BitAnd(head,W.HighMask()) }
  predicate Fits(mem: seq<S.Byte>,receipt: S.Word,length: S.Word,head: S.Word) {
    |mem|%32 == 0 && |mem| < G.Modulus() && (receipt as nat)+64 < G.Modulus() &&
    (receipt as nat)+32 <= |mem| && S.Load(mem,receipt) == length &&
    (length == 4 ==> (receipt as nat)+64 <= |mem| && S.Load(mem,receipt+32) == head)
  }
  lemma Arithmetic(length: S.Word)
    ensures Difference(length) == 0 <==> length == 4
  {
    if length <= 4 { assert 0 <= 4-length < G.Modulus(); }
    else { assert 0 < 4+G.Modulus()-length < G.Modulus(); }
  }
  lemma Bounds(mem: seq<S.Byte>,receipt: S.Word,length: S.Word,head: S.Word)
    requires Fits(mem,receipt,length,head)
    ensures S.Expand(mem,receipt+32) == mem
    ensures length == 4 ==> S.Expand(mem,receipt+64) == mem
  {
    assert S.Round32(receipt+32) <= |mem|;
    if length == 4 { assert S.Round32(receipt+64) <= |mem|; }
  }
  lemma ZeroMask()
    ensures Masked(0) == 0
  {
    hide G.BitAnd(); reveal Masked(); A.Definition(0,W.HighMask());
    assert (0 as bv256) == 0;
  }
  lemma Projection(head: S.Word)
    ensures Masked(head) == G.BitAnd(head,W.HighMask())
  { reveal Masked(); }
}
