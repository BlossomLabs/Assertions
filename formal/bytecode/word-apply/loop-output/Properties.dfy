// SPDX-License-Identifier: MIT
include "Memory.dfy"
module BytecodeApplyRawLoopOutputProperties {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import I = BytecodeApplyRawInputs
  import L = BytecodeApplyRawLoopState
  import C = BytecodeApplyCallbackSuccessMemory
  import O = BytecodeIotaOutput
  import A = BytecodeApplyAllocationMemory
  import M = BytecodeApplyRawLoopOutputMemory
  lemma HeapWords(data: seq<S.Byte>,filter: bool,receipts: seq<seq<S.Byte>>,index: S.Word)
    requires L.Receipts(data,filter,receipts) && index <= L.N(data)
    ensures S.Load(L.Heap(data,filter,receipts,index),128) == I.SourceLength(data)
    ensures forall slot: S.Word {:trigger S.Load(L.Heap(data,filter,receipts,index),160+32*slot)} :: slot < L.Kept(data,filter,receipts,index) ==> S.Load(L.Heap(data,filter,receipts,index),160+32*slot) == L.Selected(data,filter,receipts,index)[slot]
    decreases index
  {
    hide G.BitAnd();
    if index == 0 {
      M.InitialLoad(data,128);
      O.Header(L.N(data),0);
      assert I.SourceLength(data) == 32*L.N(data);
    } else {
      var prior := index-1;
      HeapWords(data,filter,receipts,prior);
      var mem := L.Heap(data,filter,receipts,prior);
      var kept := L.Kept(data,filter,receipts,prior);
      var returned := receipts[prior];
      M.ProtectedWord(mem,data,prior,kept,filter,returned,128);
      forall slot: S.Word | slot < L.Kept(data,filter,receipts,index)
        ensures S.Load(L.Heap(data,filter,receipts,index),160+32*slot) == L.Selected(data,filter,receipts,index)[slot]
      {
        if slot < kept {
          assert slot < prior;
          assert 160+32*slot+32 <= 160+32*(if filter then kept else prior);
          M.ProtectedWord(mem,data,prior,kept,filter,returned,160+32*slot);
          assert L.Selected(data,filter,receipts,index)[slot] == L.Selected(data,filter,receipts,prior)[slot];
        } else {
          assert !filter || C.Result(returned) != 0;
          assert slot == kept;
          assert !filter ==> kept == prior;
          M.WrittenWord(mem,data,prior,kept,filter,returned);
          assert L.Selected(data,filter,receipts,index)[slot] == (if filter then L.Original(data,prior) else C.Result(returned));
        }
      }
    }
  }
}
