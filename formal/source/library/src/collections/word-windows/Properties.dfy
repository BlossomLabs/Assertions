// SPDX-License-Identifier: MIT
include "Model.dfy"
include "../../foundations/SourceSequenceCellV4.dfy"
module CollectionsWordWindowsProperties {
  import opened AbiFrames
  import Cell = SourceSequenceCellV4
  import opened CollectionsWordWindowsModel
  import Mem = CollectionsWordMemoryModel
  lemma ScanFacts(n: nat,offsets: seq<nat>,j: nat)
    requires j <= |offsets|
    ensures Scan(n,offsets,j).Accepted? == (forall k :: j <= k < |offsets| ==> InBounds(n,offsets[k]))
    ensures Scan(n,offsets,j).Rejected? ==> j <= Scan(n,offsets,j).index < |offsets|
    ensures Scan(n,offsets,j).Rejected? ==> Scan(n,offsets,j).stage == 2 && Scan(n,offsets,j).offset == offsets[Scan(n,offsets,j).index] && !InBounds(n,Scan(n,offsets,j).offset)
    ensures Scan(n,offsets,j).Rejected? ==> (forall k :: j <= k < Scan(n,offsets,j).index ==> InBounds(n,offsets[k]))
    decreases |offsets|-j
  { if j < |offsets| && InBounds(n,offsets[j]) { ScanFacts(n,offsets,j+1); } }
  lemma Empty(original: seq<Byte>)
    ensures Patch(original,[]) == original
  { assert forall i :: 0 <= i < |original| ==> Patch(original,[])[i] == original[i]; }
  lemma Append(original: seq<Byte>,writes: seq<Write>,w: Write)
    requires InBounds(|original|,w.offset)
    ensures Patch(original,writes+[w]) == Mem.Store(Patch(original,writes),w.offset,w.value)
  {
    var prefix := Patch(original,writes);
    var after := Mem.Store(prefix,w.offset,w.value);
    assert (writes+[w])[..|writes|] == writes;
    forall i | 0 <= i < |original| ensures Patch(original,writes+[w])[i] == after[i]
    {
      Cell.Cell(prefix,w.offset,Word(w.value),i);
      if i < w.offset { assert after[i] == prefix[i]; }
      else if i < w.offset+32 { assert after[i] == Word(w.value)[i-w.offset]; }
      else { assert after[i] == prefix[i]; }
    }
  }
  lemma Outside(original: seq<Byte>,writes: seq<Write>,i: nat)
    requires i < |original|
    requires forall j :: 0 <= j < |writes| ==> i < writes[j].offset || writes[j].offset+32 <= i
    ensures Patch(original,writes)[i] == original[i]
    decreases |writes|
  {
    if |writes| > 0 {
      Outside(original,writes[..|writes|-1],i);
    }
  }
  lemma Last(original: seq<Byte>,writes: seq<Write>,i: nat,j: nat)
    requires i < |original| && j < |writes|
    requires writes[j].offset <= i < writes[j].offset+32
    requires forall k :: j < k < |writes| ==> i < writes[k].offset || writes[k].offset+32 <= i
    ensures Patch(original,writes)[i] == Word(writes[j].value)[i-writes[j].offset]
    decreases |writes|
  {
    if j < |writes|-1 { Last(original,writes[..|writes|-1],i,j); }
  }
  lemma ByteOverwrite(original: seq<Byte>,previous: seq<Write>,next: seq<Write>,i: nat)
    requires |previous| == |next| && i < |original|
    requires forall j :: 0 <= j < |previous| ==> previous[j].offset == next[j].offset
    ensures Patch(Patch(original,previous),next)[i] == Patch(original,next)[i]
  {
    var j := |next|;
    while j > 0 && !(next[j-1].offset <= i < next[j-1].offset+32)
      invariant 0 <= j <= |next|
      invariant forall k :: j <= k < |next| ==> i < next[k].offset || next[k].offset+32 <= i
      decreases j
    { j := j-1; }
    if j > 0 {
      Last(original,next,i,j-1); Last(Patch(original,previous),next,i,j-1);
    } else {
      assert forall k :: 0 <= k < |previous| ==> i < previous[k].offset || previous[k].offset+32 <= i;
      Outside(original,previous,i); Outside(original,next,i); Outside(Patch(original,previous),next,i);
    }
  }
  lemma Overwrite(original: seq<Byte>,previous: seq<Write>,next: seq<Write>)
    requires |previous| == |next|
    requires forall j :: 0 <= j < |previous| ==> previous[j].offset == next[j].offset
    ensures Patch(Patch(original,previous),next) == Patch(original,next)
  {
    forall i | 0 <= i < |original|
      ensures Patch(Patch(original,previous),next)[i] == Patch(original,next)[i]
    { ByteOverwrite(original,previous,next,i); }
  }

}
