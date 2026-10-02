// SPDX-License-Identifier: MIT
include "Memory.dfy"
include "../raw-template/Connection.dfy"
include "../loop-engine/Engine.dfy"
module BytecodeApplyRawSuccessfulBindings {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import I = BytecodeApplyRawInputs
  import R = BytecodeApplyRawAdmission
  import L = BytecodeApplyRawLoopState
  import V = BytecodeApplySuccessfulRawLoopEngine
  import D = BytecodeApplyRawLoopBindings
  import O = BytecodeIotaOutput
  import H = BytecodeApplyTemplateMemory
  import A = BytecodeApplyAllocationMemory
  import P = BytecodeApplyRawSuccessfulOutput
  function Selector(filter: bool): Word { if filter then 2005396296 else 3983393726 }
  function Prefix(data: seq<Byte>,filter: bool): seq<Word> { [Selector(filter),518]+R.Fields(data)+[96] }
  lemma Group(fields: seq<Word>,selector: Word,mode: Word,n: Word,kept: Word,ptr: Word,index: Word)
    requires |fields| == 7
    ensures ([selector,518]+fields+[96])+[5526,fields[0],fields[1],fields[2],fields[3],fields[4],fields[5],fields[6],mode,128,n,kept,ptr,index] ==
            [selector,518]+fields+[96,5526]+fields+[mode,128,n,kept,ptr,index]
    ensures [selector,518]+fields+[96,5526]+fields+[mode,128,n,kept,ptr,index] ==
            [selector,518,fields[0],fields[1],fields[2],fields[3],fields[4],fields[5],fields[6],96,5526,fields[0],fields[1],fields[2],fields[3],fields[4],fields[5],fields[6],mode,128,n,kept,ptr,index]
  {
    var lhs := ([selector,518]+fields+[96])+[5526,fields[0],fields[1],fields[2],fields[3],fields[4],fields[5],fields[6],mode,128,n,kept,ptr,index];
    var grouped := [selector,518]+fields+[96,5526]+fields+[mode,128,n,kept,ptr,index];
    var flat := [selector,518,fields[0],fields[1],fields[2],fields[3],fields[4],fields[5],fields[6],96,5526,fields[0],fields[1],fields[2],fields[3],fields[4],fields[5],fields[6],mode,128,n,kept,ptr,index];
    forall j: int {:trigger lhs[j]} | 0 <= j < 24
      ensures lhs[j] == grouped[j] && grouped[j] == flat[j]
    { if 2 <= j < 9 { assert lhs[j] == fields[j-2]; } else if 11 <= j < 18 { assert grouped[j] == fields[j-11]; } }
  }
  lemma Stack(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,index: Word)
    requires L.Receipts(data,filter,receipts) && index <= L.N(data)
    ensures V.Stack(data,filter,receipts,Prefix(data,filter),5526,index) == [Selector(filter),518]+R.Fields(data)+[96,5526]+R.Fields(data)+[if filter then 1 else 0,128,L.N(data),L.Kept(data,filter,receipts,index),O.Extent(L.N(data)),index]
    ensures V.Stack(data,filter,receipts,Prefix(data,filter),5526,index) == [Selector(filter),518,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),96,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),if filter then 1 else 0,128,L.N(data),L.Kept(data,filter,receipts,index),O.Extent(L.N(data)),index]
  {
    hide G.BitAnd();
    D.StackShape(data,filter,receipts,Prefix(data,filter),5526,index);
    Group(R.Fields(data),Selector(filter),if filter then 1 else 0,L.N(data),L.Kept(data,filter,receipts,index),O.Extent(L.N(data)),index);
  }
  lemma Initial(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>)
    requires L.Receipts(data,filter,receipts)
    ensures L.Kept(data,filter,receipts,0) == 0
    ensures L.Initial(data) == H.Complete(A.Heap(L.N(data)),O.Extent(L.N(data)),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data)
  { hide G.BitAnd(); hide L.Heap(); }
  lemma Final(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>)
    requires L.Receipts(data,filter,receipts)
    ensures P.Final(data,filter,receipts) == (if filter then Store(L.Heap(data,filter,receipts,L.N(data)),128,32*L.Kept(data,filter,receipts,L.N(data))) else L.Heap(data,filter,receipts,L.N(data)))
  { hide G.BitAnd(); hide L.Heap(); }
}
