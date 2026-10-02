// SPDX-License-Identifier: MIT
// Complete sortWords AST gate; memory merge loop lowering.
include "Representation.dfy"
module CollectionsWordSortSource {
  import opened AbiFrames
  import opened CollectionsWordSortModel
  import opened CollectionsSortModel
  import W = CollectionsWordMemoryModel
  import Rep = CollectionsWordSortRepresentation
  import C = CollectionsSortConnection
  import R = CollectionsSortRanges
  import MP = CollectionsSortMerge

  function Unaligned(): seq<Byte>
    ensures |Unaligned()| == 4
  { [0xa9,0x49,0xd2,0x85] }

  ghost method MergeRange(keys: seq<nat>,before: seq<Byte>,base: nat,other: nat,payload: seq<Byte>,scratchBytes: seq<Byte>,source: seq<nat>,initial: seq<nat>,start: nat,middle: nat,end: nat)
    returns (memory: seq<Byte>,changed: seq<Byte>,scratch: seq<nat>)
    requires Buffers(before,base,other,payload,scratchBytes)
    requires Represents(keys,source,payload) && Represents(keys,initial,scratchBytes)
    requires |initial| == |source| && start <= middle <= end <= |source|
    ensures Buffers(memory,base,other,payload,changed) && Represents(keys,scratch,changed)
    ensures |memory| == |before|
    ensures memory[..other+32] == before[..other+32]
    ensures memory[other+32+|scratchBytes|..] == before[other+32+|scratchBytes|..]
    ensures |scratch| == |source| && scratch[..start] == initial[..start] && scratch[end..] == initial[end..]
    ensures scratch[start..end] == Merge((x: nat,y: nat) => Le(keys,x,y),source[start..middle],source[middle..end])
    ensures multiset(scratch[start..end]) == multiset(source[start..end])
  {
    scratch := initial; memory := before; changed := scratchBytes;
    var le := (x: nat,y: nat) => Le(keys,x,y);
    var a := start; var b := middle;
    var dest := start;
    while (dest < end)
      invariant start <= a <= middle <= b <= end
      invariant start <= dest <= end && (a-start)+(b-middle) == dest-start
      invariant |scratch| == |source| && scratch[..start] == initial[..start] && scratch[end..] == initial[end..]
      invariant scratch[start..dest]+Merge(le,source[a..middle],source[b..end]) == Merge(le,source[start..middle],source[middle..end])
      invariant Buffers(memory,base,other,payload,changed) && Represents(keys,scratch,changed)
      invariant |memory| == |before|
      invariant memory[..other+32] == before[..other+32]
      invariant memory[other+32+|scratchBytes|..] == before[other+32+|scratchBytes|..]
      decreases end-dest
    {
      var takeA := (b == end);
      if ((a < middle) && (b < end)) {
        var av := Rep.Read(memory,base,payload,keys,source,a);
        var bv := Rep.Read(memory,base,payload,keys,source,b);
        takeA := av <= bv;
      }
      if (a == middle) { takeA := false; }
      var prefix := scratch[start..dest];
      var value: nat;
      var selected := if takeA then a else b;
      if takeA {
        assert a < middle;
        value := source[a];
        assert source[a..middle] == [source[a]]+source[a+1..middle];
        assert Merge(le,source[a..middle],source[b..end]) == [value]+Merge(le,source[a+1..middle],source[b..end]);
        Rep.Increment(|source|,a);
        a := a+1;
      } else {
        assert b < end;
        value := source[b];
        assert source[b..end] == [source[b]]+source[b+1..end];
        assert Merge(le,source[a..middle],source[b..end]) == [value]+Merge(le,source[a..middle],source[b+1..end]);
        Rep.Increment(|source|,b);
        b := b+1;
      }
      var word := Rep.Read(memory,base,payload,keys,source,selected);
      assert word == Key(keys,value);
      memory,changed := Rep.Write(memory,base,other,payload,changed,keys,scratch,dest,value);
      C.Write(scratch,start,dest,end,value);
      scratch := scratch[dest := value];
      Rep.Increment(|source|,dest);
      dest := dest+1;
    }
    assert a == middle && b == end;
    MP.Permutation(le,source[start..middle],source[middle..end]);
    assert source[start..end] == source[start..middle]+source[middle..end];
  }

  ghost method Pass(keys: seq<nat>,before: seq<Byte>,base: nat,other: nat,payload: seq<Byte>,scratchBytes: seq<Byte>,source: seq<nat>,initial: seq<nat>,width: nat)
    returns (memory: seq<Byte>,changed: seq<Byte>,scratch: seq<nat>)
    requires Buffers(before,base,other,payload,scratchBytes)
    requires Represents(keys,source,payload) && Represents(keys,initial,scratchBytes)
    requires 0 < width < |source| && |initial| == |source|
    ensures Buffers(memory,base,other,payload,changed) && Represents(keys,scratch,changed)
    ensures |memory| == |before|
    ensures |scratch| == |source| && multiset(scratch) == multiset(source)
    ensures var le := (x: nat,y: nat) => Le(keys,x,y); Order(|source|,le) && Runs(|source|,le,source,width) ==> Runs(|source|,le,scratch,2*width)
  {
    var n := |source|;
    var le := (x: nat,y: nat) => Le(keys,x,y);
    memory := before; changed := scratchBytes;
    scratch := initial;
    var start: nat := 0; var block: nat := 0;
    while start < n
      invariant start == block*(2*width) && |scratch| == n
      invariant multiset(scratch[..Min(start,n)]) == multiset(source[..Min(start,n)])
      invariant Order(n,le) && Runs(n,le,source,width) ==>
                  (forall j: nat :: j < block && j*(2*width) < n ==>
                                      var lo := j*(2*width); var hi := Min(lo+2*width,n);
                                                             Sorted(le,scratch[lo..hi]) && multiset(scratch[lo..hi]) == multiset(Range(lo,hi-lo)))
      invariant Buffers(memory,base,other,payload,changed) && Represents(keys,scratch,changed)
      invariant |memory| == |before|
      decreases n-start
    {
      Rep.Counters(n,width,start);
      var middle := Min(start+width,n); var end := Min(start+2*width,n);
      var previous := scratch;
      memory,changed,scratch := MergeRange(keys,memory,base,other,payload,changed,source,scratch,start,middle,end);
      assert scratch[..end] == scratch[..start]+scratch[start..end];
      assert source[..end] == source[..start]+source[start..end];
      if Order(n,le) && Runs(n,le,source,width) {
        R.Block(n,le,source,width,block);
        forall j: nat | j < block && j*(2*width) < n
          ensures var lo := j*(2*width); var hi := Min(lo+2*width,n); scratch[lo..hi] == previous[lo..hi]
        {
          Rep.OldBlock(scratch,previous,width,block,j);
        }

      }
      Rep.Advance(block,width);
      start := start+2*width; block := block+1;
    }
    assert Min(start,n) == n && scratch[..n] == scratch && source[..n] == source;
    if Order(n,le) && Runs(n,le,source,width) {
      reveal Runs();
      forall j: nat | j*(2*width) < n
        ensures var lo := j*(2*width); var hi := Min(lo+2*width,n);
                                       Sorted(le,scratch[lo..hi]) && multiset(scratch[lo..hi]) == multiset(Range(lo,hi-lo))
      {
        if j >= block { R.Scale(block,j,2*width); assert false; }
      }
    }
  }


  ghost method SortWords(input: seq<Byte>,before: seq<Byte>,inputBase: nat,scratchBase: nat)
    returns (rejected: bool,memory: seq<Byte>,base: nat,payload: seq<Byte>,ids: seq<nat>)
    requires |input| % 32 == 0 ==> Buffers(before,inputBase,scratchBase,input,Zeros(|input|))
    ensures rejected == (|input| % 32 != 0)
    ensures rejected ==> memory == before && payload == [] && ids == []
    ensures !rejected ==> |memory| == |before| && W.Frame(memory,base,payload)
    ensures !rejected ==> Represents(W.Words(input),ids,payload)
    ensures !rejected ==> |ids| == |input|/32 && multiset(ids) == multiset(Range(0,|input|/32))
    ensures !rejected ==> Well(|input|/32,ids)
    ensures !rejected ==> (forall i :: 0 <= i < |ids| ==> ids[i] < |input|/32)
    ensures !rejected ==> (forall i,j :: 0 <= i < j < |ids| ==>
                                           W.Words(input)[ids[i]] <= W.Words(input)[ids[j]] &&
                                           (W.Words(input)[ids[i]] == W.Words(input)[ids[j]] ==> ids[i] < ids[j]))
  {
    memory := before; base := inputBase; payload := []; ids := [];
    if |input| % 32 != 0 { rejected := true; return; }
    rejected := false;
    payload := input;
    var n := |input|/32;
    var keys := W.Words(input);
    var le := (x: nat,y: nat) => Le(keys,x,y);
    ids := Range(0,n);
    var other := scratchBase;
    var scratchBytes := Zeros(|input|);
    var scratch: seq<nat> := seq(n,i => |keys|);
    var width: nat := 1;
    Rep.Initial(input); Rep.Scratch(keys,n); Rep.Order(keys);
    R.Initial(n,le);
    while width < n
      invariant width > 0 && |ids| == n && |scratch| == n
      invariant multiset(ids) == multiset(Range(0,n)) && Runs(n,le,ids,width)
      invariant Represents(keys,ids,payload) && Represents(keys,scratch,scratchBytes)
      invariant Buffers(memory,base,other,payload,scratchBytes)
      invariant |memory| == |before|
      decreases n-width
    {
      Rep.Counters(n,width,0);
      var previousIds := ids;
      var previousBytes := payload;
      memory,scratchBytes,scratch := Pass(keys,memory,base,other,payload,scratchBytes,ids,scratch,width);
      var previous := base;
      base := other; other := previous;
      payload := scratchBytes; scratchBytes := previousBytes;
      ids := scratch; scratch := previousIds;
      width := width*2;
    }
    Rep.Finished(n,le,ids,width);
    R.Verdict(n,le,ids);
  }
}
