// SPDX-License-Identifier: MIT
// Independent monotonicity of the actually consumed nonnegative decimal digits.
include "../decimal-loop/Loop.dfy"
module BytecodeCollectionsDecimalNumber {
  import D = BytecodeCollectionsDecimalLoop
  import G = BytecodeGetterMachine
  lemma Nonnegative(data: seq<G.Byte>,offset: G.Word,start: nat,stop: nat)
    requires start <= stop
    requires forall i {:trigger D.DataByte(data,offset,i)} :: start <= i < stop ==> D.Digit(D.DataByte(data,offset,i))
    ensures D.Number(data,offset,start,stop) >= 0
    decreases stop-start
  {
    if start < stop {
      Nonnegative(data,offset,start,stop-1);
      D.NumberExtend(data,offset,start,stop-1);
      assert D.Digit(D.DataByte(data,offset,stop-1));
    }
  }
  lemma PrefixBound(data: seq<G.Byte>,offset: G.Word,start: nat,middle: nat,stop: nat)
    requires start <= middle <= stop
    requires forall i {:trigger D.DataByte(data,offset,i)} :: start <= i < stop ==> D.Digit(D.DataByte(data,offset,i))
    ensures D.Number(data,offset,start,middle) <= D.Number(data,offset,start,stop)
    decreases stop-middle
  {
    if middle < stop {
      PrefixBound(data,offset,start,middle,stop-1);
      Nonnegative(data,offset,start,stop-1);
      D.NumberExtend(data,offset,start,stop-1);
      assert D.Digit(D.DataByte(data,offset,stop-1));
    }
  }
}
