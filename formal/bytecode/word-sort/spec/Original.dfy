// SPDX-License-Identifier: MIT
// Independent stable unsigned sorting of original occurrence IDs and byte blocks.
include "../../../collections/sort-core/Connection.dfy"
include "../../scans/Representation.dfy"
module BytecodeWordSortOriginalSpec {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import M = CollectionsSortModel
  import C = CollectionsSortConnection
  predicate Fits(data: seq<Byte>, start: Word, count: nat) {
    count < 0x800000000000000 && |data| < 0x10000000000000000 && start+count*32 <= |data|
  }
  function Values(data: seq<Byte>, start: Word, count: nat): seq<Word>
    requires Fits(data,start,count)
  { seq(count,i requires 0 <= i < count => DataWord(data,start+i*32)) }
  function Keys(values: seq<Word>): seq<nat> { seq(|values|,i requires 0 <= i < |values| => values[i] as nat) }
  predicate Bounds(count: nat, ids: seq<nat>) { forall i :: 0 <= i < |ids| ==> ids[i] < count }
  predicate Sorted(values: seq<Word>, ids: seq<nat>)
    requires Bounds(|values|,ids)
  { forall i,j :: 0 <= i < j < |ids| ==> values[ids[i]] <= values[ids[j]] && (values[ids[i]] == values[ids[j]] ==> ids[i] < ids[j]) }
  function Payload(data: seq<Byte>, start: Word, count: nat, ids: seq<nat>): seq<Byte>
    requires Fits(data,start,count) && Bounds(count,ids)
  { seq(|ids|*32,j requires 0 <= j < |ids|*32 => data[start+ids[j/32]*32+j%32]) }
  function Encoded(data: seq<Byte>, start: Word, count: nat, ids: seq<nat>): seq<Byte>
    requires Fits(data,start,count) && Bounds(count,ids)
  { seq(|ids|*32,j requires 0 <= j < |ids|*32 => G.Encode(Values(data,start,count)[ids[j/32]],32)[j%32]) }
  lemma EncodeDecode(bytes: seq<Byte>)
    ensures G.Encode(G.Decode(bytes),|bytes|) == bytes
    decreases |bytes|
  {
    if |bytes| > 0 {
      EncodeDecode(bytes[..|bytes|-1]);
      assert G.Decode(bytes)/256 == G.Decode(bytes[..|bytes|-1]);
      assert G.Decode(bytes)%256 == bytes[|bytes|-1];
      assert bytes == bytes[..|bytes|-1]+[bytes[|bytes|-1]];
    }
  }
  lemma OriginalBytes(data: seq<Byte>, start: Word, count: nat, ids: seq<nat>)
    requires Fits(data,start,count) && Bounds(count,ids)
    ensures Encoded(data,start,count,ids) == Payload(data,start,count,ids)
  {
    var bytes := Encoded(data,start,count,ids);
    forall j: nat {:trigger bytes[j]} | j < |ids|*32
      ensures bytes[j] == Payload(data,start,count,ids)[j]
    {
      var offset: Word := start+ids[j/32]*32;
      R.WordProjection(data,offset);
      EncodeDecode(data[offset..offset+32]);
      assert Values(data,start,count)[ids[j/32]] == DataWord(data,offset);
      assert G.Encode(DataWord(data,offset),32) == data[offset..offset+32];
    }
  }
  ghost method Sort(values: seq<Word>) returns (ids: seq<nat>)
    ensures |ids| == |values| && multiset(ids) == multiset(M.Range(0,|values|))
    ensures Bounds(|values|,ids) && Sorted(values,ids)
    ensures forall i,j :: 0 <= i < j < |ids| ==> ids[i] != ids[j]
  {
    ids := C.SortKeys(Keys(values));
    forall i: nat | 0 <= i < |ids| ensures ids[i] < |values|
    { assert ids[i] < |Keys(values)|; }
    forall i,j | 0 <= i < j < |ids|
      ensures values[ids[i]] <= values[ids[j]] && (values[ids[i]] == values[ids[j]] ==> ids[i] < ids[j])
    { assert Keys(values)[ids[i]] == values[ids[i]] && Keys(values)[ids[j]] == values[ids[j]]; }
  }
  ghost method SortOriginal(data: seq<Byte>, start: Word, count: nat)
    returns (ids: seq<nat>, payload: seq<Byte>)
    requires Fits(data,start,count)
    ensures |ids| == count && multiset(ids) == multiset(M.Range(0,count))
    ensures Bounds(count,ids) && Sorted(Values(data,start,count),ids)
    ensures payload == Payload(data,start,count,ids) && |payload| == count*32
    ensures payload == Encoded(data,start,count,ids)
  {
    ids := Sort(Values(data,start,count));
    OriginalBytes(data,start,count,ids);
    payload := Payload(data,start,count,ids);
  }
}
