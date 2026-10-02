// SPDX-License-Identifier: MIT
// Derive generic receipt resources from the reached repeated-iteration heap.
include "../callback-receipt-engine/Memory.dfy"
include "../loop-prefix-repair-v2/ZeroSlot.dfy"
module BytecodeApplyWrongSizeIterationMemory {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeApplyRepeatedIterationMemory
  import H = BytecodeApplyFullCallbackReceiptMemory
  import R = BytecodeApplyRawCallbackMemory
  import I = BytecodeApplyRawInputs
  import L = BytecodeApplyRawLoopState
  import Z = BytecodeApplyRawLoopPrefixZeroSlot
  import B = BytecodeApplyRawIterationBounds
  import O = BytecodeIotaOutput
  import T = BytecodeApplyTemplateMemory
  import RH = BytecodeApplyCallbackReceiptMemory
  lemma StampedAdmission(mem: seq<Byte>,ptr: Word,free: Word,length: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,returned: seq<Byte>)
    requires M.Fits(mem,ptr,free,length,arrayOffset,count,data)
    requires 128 <= |mem| && 160 <= free && free%32 == 0 && Load(mem,96) == 0
    requires free+|returned|+256 < RH.Bound()
    ensures H.Fits(M.Stamped(mem,ptr,free,length,arrayOffset,count,data,word),ptr,free,length,returned)
  {
    hide DataWord(); hide ShiftRight(); hide G.BitAnd(); hide M.Stamped();
    M.StampFacts(mem,ptr,free,length,arrayOffset,count,data,word);
    R.StampLoad(mem,ptr,length,arrayOffset,count,data,word,count,96);
    reveal M.Stamped();
  }
  lemma RawAdmission(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,index: Word,returned: seq<Byte>)
    requires L.Receipts(data,filter,receipts) && index < L.N(data)
    requires B.Free(L.N(data),I.TemplateLength(data),index)+|returned|+256 < RH.Bound()
    ensures var mem := L.Heap(data,filter,receipts,index);
      var ptr: Word := O.Extent(L.N(data));
      var free := B.Free(L.N(data),I.TemplateLength(data),index);
      H.Fits(M.Stamped(mem,ptr,free,I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index)),ptr,free,I.TemplateLength(data),returned)
    ensures 128 <= |L.Heap(data,filter,receipts,index)|
    ensures Load(L.Heap(data,filter,receipts,index),96) == 0
    ensures 160 <= B.Free(L.N(data),I.TemplateLength(data),index) && B.Free(L.N(data),I.TemplateLength(data),index)%32 == 0
  {
    hide DataWord(); hide ShiftRight(); hide G.BitAnd(); hide L.Heap(); hide L.Original(); hide M.Stamped();
    var n := L.N(data); var mem := L.Heap(data,filter,receipts,index);
    var ptr: Word := O.Extent(n); var length := I.TemplateLength(data);
    var free := B.Free(n,length,index);
    Z.Heap(data,filter,receipts,index);
    B.Allocation(n,length,index); T.Arithmetic(ptr,length);
    StampedAdmission(mem,ptr,free,length,I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index),returned);
  }
}
