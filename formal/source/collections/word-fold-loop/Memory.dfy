// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsWordFoldLoopMemory {
  import opened AbiFrames
  import opened CollectionsWordFoldLoopModel
  import W = CollectionsWordWindowsModel
  import P = CollectionsWordWindowsProperties
  import Source = CollectionsWordWindowsSource
  import Mem = CollectionsWordMemoryModel
  import Call = CollectionsWordCallSource
  import Calls = CollectionsWordCallModel
  lemma SameOffsets(k: Config,a: nat,b: nat,c: nat,d: nat)
    ensures |Writes(k,a,b)| == |Writes(k,c,d)|
    ensures forall i :: 0 <= i < |Writes(k,a,b)| ==> Writes(k,a,b)[i].offset == Writes(k,c,d)[i].offset
  {
    forall i | 0 <= i < |Writes(k,a,b)|
      ensures Writes(k,a,b)[i].offset == Writes(k,c,d)[i].offset
    { if i > 0 { assert Writes(k,a,b)[i] == W.ElementWrites(k.offsets,b)[i-1]; assert Writes(k,c,d)[i] == W.ElementWrites(k.offsets,d)[i-1]; } }
  }
  ghost method Stamp(k: Config,index: nat,acc: nat,memory: seq<Byte>,base: nat,previous: seq<W.Write>) returns (after: seq<Byte>,data: seq<Byte>)
    requires Static(k) && index < k.count && Mem.Fits(acc) && Mem.Fits(|memory|)
    requires Mem.Frame(memory,base,W.Patch(k.template,previous))
    requires previous == [] || (|previous| == |Writes(k,0,0)| && (forall j :: 0 <= j < |previous| ==> previous[j].offset == Writes(k,0,0)[j].offset))
    ensures |after| == |memory| && data == Data(k,index,acc)
    ensures Mem.Frame(after,base,data)
    ensures after[..base+32] == memory[..base+32] && after[base+32+|k.template|..] == memory[base+32+|k.template|..]
  {
    var elem := Call.DomainElement(k.domain,index,k.subject);
    data := Data(k,index,acc);
    after := Source.StampWindows(memory,base,W.Patch(k.template,previous),k.accOffset,acc,k.offsets,elem);
    if previous == [] { P.Empty(k.template); }
    else {
      SameOffsets(k,0,0,acc,elem);
      P.Overwrite(k.template,previous,Writes(k,acc,elem));
    }
  }
}
