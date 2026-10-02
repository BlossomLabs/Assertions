// SPDX-License-Identifier: MIT
// Auxiliary completion has no external-observation meaning.
include "../loop-engine/State.dfy"
module BytecodeApplyRawLoopPrefixCompletion {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import L = BytecodeApplyRawLoopState
  import H = BytecodeApplyCallbackSuccessMemory
  import D = BytecodeApplyRawLoopBindings
  predicate Successful(data: seq<Byte>,filter: bool,actual: seq<seq<Byte>>) {
    L.Fits(data) && |actual| <= L.N(data) &&
    forall j: int {:trigger actual[j]} :: 0 <= j < |actual| ==> |actual[j]| == 32 && (!filter || H.Result(actual[j]) <= 1)
  }
  function Complete(data: seq<Byte>,filter: bool,actual: seq<seq<Byte>>): seq<seq<Byte>>
    requires Successful(data,filter,actual)
    ensures |Complete(data,filter,actual)| == L.N(data)
    ensures Complete(data,filter,actual)[..|actual|] == actual
  { seq(L.N(data),j requires 0 <= j < L.N(data) => if j < |actual| then actual[j] else G.Encode(0,32)) }
  lemma ZeroResult()
    ensures H.Result(G.Encode(0,32)) == 0
  {
    R.WordProjection(G.Encode(0,32),0);
    G.RoundTrip(0,32);
    assert G.Encode(0,32)[0..32] == G.Encode(0,32);
  }
  lemma Admits(data: seq<Byte>,filter: bool,actual: seq<seq<Byte>>)
    requires Successful(data,filter,actual)
    ensures L.Receipts(data,filter,Complete(data,filter,actual))
  {
    ZeroResult();
    var completed := Complete(data,filter,actual);
    forall j: int {:trigger completed[j]} | 0 <= j < |completed|
      ensures |completed[j]| == 32 && (!filter || H.Result(completed[j]) <= 1)
    {
      if j >= |actual| { assert completed[j] == G.Encode(0,32); }
      else {
        assert completed[j] == actual[j];
        assert |actual[j]| == 32;
        assert !filter || H.Result(actual[j]) <= 1;
      }
    }
  }
  lemma Independent(data: seq<Byte>,filter: bool,left: seq<seq<Byte>>,right: seq<seq<Byte>>,index: Word)
    requires L.Receipts(data,filter,left) && L.Receipts(data,filter,right) && index <= L.N(data)
    requires left[..index] == right[..index]
    ensures L.Kept(data,filter,left,index) == L.Kept(data,filter,right,index)
    ensures L.Heap(data,filter,left,index) == L.Heap(data,filter,right,index)
    ensures forall oldReturn: seq<Byte> :: D.Last(oldReturn,left,index) == D.Last(oldReturn,right,index)
    decreases index
  {
    hide L.Heap(); hide L.Kept();
    if index > 0 {
      assert left[..index-1] == right[..index-1];
      assert left[index-1] == right[index-1];
      Independent(data,filter,left,right,index-1);
    }
    reveal L.Kept(); reveal L.Heap();
  }
}
