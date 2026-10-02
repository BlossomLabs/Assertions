// SPDX-License-Identifier: MIT
include "Properties.dfy"
module CollectionsWordApplyMemory {
  import opened AbiFrames
  import opened CollectionsWordApplyModel
  import P = CollectionsWordApplyProperties
  import W = CollectionsWordWindowsModel
  import WP = CollectionsWordWindowsProperties
  import Source = CollectionsWordWindowsSource
  import Mem = CollectionsWordMemoryModel
  import Memory = CollectionsWordMemoryConnection
  import Call = CollectionsWordCallSource
  import Calls = CollectionsWordCallModel
  lemma SameOffsets(offsets: seq<nat>,a: nat,b: nat)
    ensures |W.ElementWrites(offsets,a)| == |W.ElementWrites(offsets,b)|
    ensures forall i :: 0 <= i < |offsets| ==> W.ElementWrites(offsets,a)[i].offset == W.ElementWrites(offsets,b)[i].offset
  {}
  ghost method Stamp(k: Config,index: nat,memory: seq<Byte>,base: nat,previous: seq<W.Write>) returns (after: seq<Byte>,data: seq<Byte>)
    requires Static(k) && index < Count(k) && Mem.Fits(|memory|)
    requires Mem.Frame(memory,base,W.Patch(k.template,previous))
    requires previous == [] || (|previous| == |k.offsets| && (forall j :: 0 <= j < |previous| ==> previous[j].offset == k.offsets[j]))
    ensures |after| == |memory| && data == Data(k,index)
    ensures Mem.Frame(after,base,data)
    ensures after[..base+32] == memory[..base+32] && after[base+32+|k.template|..] == memory[base+32+|k.template|..]
  {
    var elem := Call.DomainElement(Calls.Words,index,k.subject);
    data := Data(k,index);
    WP.Empty(W.Patch(k.template,previous));
    after := Source.StampElements(memory,base,W.Patch(k.template,previous),[],k.offsets,elem);
    assert []+W.ElementWrites(k.offsets,elem) == W.ElementWrites(k.offsets,elem);
    assert Mem.Frame(after,base,W.Patch(W.Patch(k.template,previous),W.ElementWrites(k.offsets,elem)));
    if previous == [] { WP.Empty(k.template); }
    else { WP.Overwrite(k.template,previous,W.ElementWrites(k.offsets,elem)); }
  }
  ghost method Append(memory: seq<Byte>,base: nat,payload: seq<Byte>,values: seq<nat>,value: nat) returns (after: seq<Byte>,updated: seq<Byte>)
    requires Mem.Fits(|memory|) && Mem.Frame(memory,base,payload) && Mem.Fits(value)
    requires 32*(|values|+1) <= |payload| && payload[..32*|values|] == Bytes(values)
    ensures updated == Mem.Store(payload,32*|values|,value) && |updated| == |payload|
    ensures |after| == |memory| && Mem.Frame(after,base,updated)
    ensures updated[..32*(|values|+1)] == Bytes(values+[value])
    ensures after[..base+32] == memory[..base+32] && after[base+32+|payload|..] == memory[base+32+|payload|..]
  {
    after := Memory.Write(memory,base,payload,|values|,value);
    updated := Mem.Store(payload,32*|values|,value);
    P.BytesAppend(values,value);
    assert updated[..32*(|values|+1)] == payload[..32*|values|]+Word(value);
  }
  lemma Shrink(memory: seq<Byte>,base: nat,payload: seq<Byte>,kept: nat)
    requires Mem.Fits(|memory|) && Mem.Frame(memory,base,payload) && 32*kept <= |payload|
    ensures Mem.Frame(Mem.Store(memory,base,32*kept),base,payload[..32*kept])
    ensures Mem.Store(memory,base,32*kept)[..base] == memory[..base]
    ensures Mem.Store(memory,base,32*kept)[base+32..] == memory[base+32..]
  {
    Memory.Outside(memory,base,32*kept,base+32,|memory|);
    assert memory[base+32..base+32+32*kept] == payload[..32*kept];
  }
}
