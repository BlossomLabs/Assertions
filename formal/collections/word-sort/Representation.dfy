// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsWordSortRepresentation {
  import opened AbiFrames
  import opened CollectionsWordSortModel
  import W = CollectionsWordMemoryModel
  import WC = CollectionsWordMemoryConnection
  import Core = CollectionsSortModel
  import R = CollectionsSortRanges
  import C = CollectionsSortConnection

  lemma Update(keys: seq<nat>,ids: seq<nat>,payload: seq<Byte>,index: nat,id: nat)
    requires Represents(keys,ids,payload) && index < |ids| && W.Fits(Key(keys,id))
    ensures Represents(keys,ids[index:=id],W.Store(payload,32*index,Key(keys,id)))
  {
    WC.Assignment(payload,index,Key(keys,id));
    forall j | 0 <= j < |ids|
      ensures W.Words(W.Store(payload,32*index,Key(keys,id)))[j] == Key(keys,(ids[index:=id])[j])
    {}
  }

  ghost method Read(memory: seq<Byte>,base: nat,payload: seq<Byte>,keys: seq<nat>,ids: seq<nat>,index: nat) returns (value: nat)
    requires W.Fits(|memory|) && W.Frame(memory,base,payload)
    requires Represents(keys,ids,payload) && index < |ids|
    ensures value == Key(keys,ids[index]) && W.Fits(value)
  {
    value := WC.Read(memory,base,payload,index);
  }

  ghost method Write(memory: seq<Byte>,base: nat,other: nat,payload: seq<Byte>,scratch: seq<Byte>,keys: seq<nat>,ids: seq<nat>,index: nat,id: nat)
    returns (after: seq<Byte>,changed: seq<Byte>)
    requires Buffers(memory,base,other,payload,scratch)
    requires Represents(keys,ids,scratch) && index < |ids| && W.Fits(Key(keys,id))
    ensures Buffers(after,base,other,payload,changed)
    ensures |after| == |memory| && |changed| == |scratch|
    ensures Represents(keys,ids[index:=id],changed)
    ensures after[..other+32] == memory[..other+32]
    ensures after[other+32+|scratch|..] == memory[other+32+|scratch|..]
  {
    after := WC.Write(memory,other,scratch,index,Key(keys,id));
    changed := W.Store(scratch,32*index,Key(keys,id));
    var address := other+32+32*index;
    WC.DisjointFrame(memory,address,Key(keys,id),base,payload);
    WC.Outside(memory,address,Key(keys,id),0,other+32);
    WC.Outside(memory,address,Key(keys,id),other+32+|scratch|,|memory|);
    Update(keys,ids,scratch,index,id);
  }

  lemma Initial(payload: seq<Byte>)
    requires |payload| % 32 == 0
    ensures Represents(W.Words(payload),Core.Range(0,|payload|/32),payload)
  {}

  lemma Order(keys: seq<nat>)
    ensures Core.Order(|keys|,(a: nat,b: nat) => Le(keys,a,b))
  {}

  lemma Counters(n: nat,width: nat,start: nat)
    requires W.Fits(32*n) && 0 < width < n && start < n
    ensures W.Fits(width*2) && W.Fits(start+width) && W.Fits(start+2*width)
    ensures W.Fits(n)
  {}

  lemma ZeroRead(bytes: seq<Byte>)
    requires forall i :: 0 <= i < |bytes| ==> bytes[i] == 0
    ensures ReadNat(bytes) == 0
    decreases |bytes|
  {
    if |bytes| > 0 { ZeroRead(bytes[..|bytes|-1]); }
  }

  lemma Scratch(keys: seq<nat>,size: nat)
    ensures Represents(keys,seq(size,i => |keys|),Zeros(32*size))
  {
    forall i | 0 <= i < size
      ensures W.Words(Zeros(32*size))[i] == Key(keys,|keys|)
    { ZeroRead(Zeros(32*size)[32*i..32*i+32]); }
  }
  lemma Increment(n: nat,index: nat)
    requires W.Fits(32*n) && index < n
    ensures W.Fits(index+1)
  {}

  lemma Advance(block: nat,width: nat)
    ensures block*(2*width)+2*width == (block+1)*(2*width)
  {}

  lemma OldBlock(a: seq<nat>,b: seq<nat>,width: nat,block: nat,j: nat)
    requires width > 0 && j < block && j*(2*width) < |a|
    requires |a| == |b| && block*(2*width) <= |a|
    requires a[..block*(2*width)] == b[..block*(2*width)]
    ensures var lo := j*(2*width); var hi := Core.Min(lo+2*width,|a|); a[lo..hi] == b[lo..hi]
  {
    R.Scale(j+1,block,2*width);
    var lo := j*(2*width); var hi := Core.Min(lo+2*width,|a|);
    assert lo+2*width == (j+1)*(2*width);
    C.Prefix(a,b,block*(2*width),lo,hi);
  }

  lemma Finished(n: nat,le: (nat,nat)->bool,ids: seq<nat>,width: nat)
    requires |ids| == n && width > 0 && width >= n && Core.Runs(n,le,ids,width)
    ensures Core.Sorted(le,ids)
  {
    if n > 0 {
      reveal Core.Runs();
      assert 0*width < n && Core.Min(0+width,n) == n;
      assert Core.Sorted(le,ids[0..Core.Min(width,n)]);
      assert ids[0..n] == ids;
    }
  }
}
