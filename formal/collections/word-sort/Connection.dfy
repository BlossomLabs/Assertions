// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
module CollectionsWordSortConnection {
  import opened AbiFrames
  import opened CollectionsWordSortModel
  import S = CollectionsWordSortSource
  import W = CollectionsWordMemoryModel
  import C = CollectionsSortModel
  import MP = CollectionsSortMerge
  function Values(keys: seq<nat>,ids: seq<nat>): seq<nat>
    ensures |Values(keys,ids)| == |ids|
    decreases |ids|
  { if |ids| == 0 then [] else [Key(keys,ids[0])]+Values(keys,ids[1..]) }
  lemma ValueAt(keys: seq<nat>,ids: seq<nat>,i: nat)
    requires i < |ids|
    ensures Values(keys,ids)[i] == Key(keys,ids[i])
    decreases i
  { if i > 0 { ValueAt(keys,ids[1..],i-1); } }
  lemma Join(keys: seq<nat>,a: seq<nat>,b: seq<nat>)
    ensures Values(keys,a+b) == Values(keys,a)+Values(keys,b)
    decreases |a|
  {
    if |a| > 0 {
      assert (a+b)[0] == a[0];
      assert (a+b)[1..] == a[1..]+b;
      Join(keys,a[1..],b);
      assert Values(keys,a+b) == [Key(keys,a[0])]+Values(keys,a[1..]+b);
      assert Values(keys,a) == [Key(keys,a[0])]+Values(keys,a[1..]);
    } else { assert a == []; assert a+b == b; assert Values(keys,a) == []; }
  }
  lemma Remove(a: seq<nat>,b: seq<nat>,i: nat)
    requires |a| > 0 && i < |b| && a[0] == b[i] && multiset(a) == multiset(b)
    ensures multiset(a[1..]) == multiset(b[..i]+b[i+1..])
  {
    assert a == [a[0]]+a[1..];
    assert b == b[..i]+[b[i]]+b[i+1..];
    forall x: nat
      ensures multiset(a[1..])[x] == multiset(b[..i]+b[i+1..])[x]
    {
      assert multiset(a)[x] == multiset(a[1..])[x]+(if x == a[0] then 1 else 0);
      assert multiset(b)[x] == multiset(b[..i])[x]+(if x == b[i] then 1 else 0)+multiset(b[i+1..])[x];
      assert multiset(b[..i]+b[i+1..])[x] == multiset(b[..i])[x]+multiset(b[i+1..])[x];
    }
  }
  lemma Permutation(keys: seq<nat>,a: seq<nat>,b: seq<nat>)
    requires multiset(a) == multiset(b)
    ensures multiset(Values(keys,a)) == multiset(Values(keys,b))
    decreases |a|
  {
    if |a| > 0 {
      assert a[0] in a;
      MP.SameMember(a,b,a[0]);
      assert a[0] in b;
      var i :| 0 <= i < |b| && b[i] == a[0];
      assert b == b[..i]+[b[i]]+b[i+1..];
      assert a == [a[0]]+a[1..];
      Remove(a,b,i);
      Permutation(keys,a[1..],b[..i]+b[i+1..]);
      Join(keys,b[..i],[b[i]]+b[i+1..]);
      Join(keys,b[..i],b[i+1..]);
      assert Values(keys,a) == [Key(keys,a[0])]+Values(keys,a[1..]);
      assert Values(keys,[b[i]]+b[i+1..]) == [Key(keys,b[i])]+Values(keys,b[i+1..]);
      assert b == b[..i]+([b[i]]+b[i+1..]);
      assert Values(keys,b) == Values(keys,b[..i])+Values(keys,[b[i]]+b[i+1..]);
      assert Values(keys,b) == Values(keys,b[..i])+[Key(keys,b[i])]+Values(keys,b[i+1..]);
      forall x: nat
        ensures multiset(Values(keys,a))[x] == multiset(Values(keys,b))[x]
      {
        assert multiset(Values(keys,a))[x] == (if x == Key(keys,a[0]) then 1 else 0)+multiset(Values(keys,a[1..]))[x];
        assert multiset(Values(keys,b))[x] == multiset(Values(keys,b[..i]))[x]+(if x == Key(keys,b[i]) then 1 else 0)+multiset(Values(keys,b[i+1..]))[x];
        assert multiset(Values(keys,b[..i]+b[i+1..]))[x] == multiset(Values(keys,b[..i]))[x]+multiset(Values(keys,b[i+1..]))[x];
      }
    } else {
      assert |multiset(a)| == |a| && |multiset(b)| == |b|;
      assert a == [] && b == [];
      assert Values(keys,a) == [] && Values(keys,b) == [];
    }
  }
  lemma Decoded(keys: seq<nat>,ids: seq<nat>,payload: seq<Byte>)
    requires Represents(keys,ids,payload)
    ensures W.Words(payload) == Values(keys,ids)
  {
    forall i | 0 <= i < |ids| ensures W.Words(payload)[i] == Values(keys,ids)[i]
    { ValueAt(keys,ids,i); }
  }
  lemma Original(keys: seq<nat>)
    ensures Values(keys,C.Range(0,|keys|)) == keys
  {
    forall i | 0 <= i < |keys| ensures Values(keys,C.Range(0,|keys|))[i] == keys[i]
    { ValueAt(keys,C.Range(0,|keys|),i); }
  }

  datatype Outcome = Failure(reason: seq<Byte>) | Success(payload: seq<Byte>,memory: seq<Byte>,base: nat,ids: seq<nat>)
  ghost method Run(input: seq<Byte>,before: seq<Byte>,base: nat,other: nat) returns (out: Outcome)
    requires W.Fits(|input|)
    requires |input| % 32 == 0 ==> Buffers(before,base,other,input,Zeros(|input|))
    ensures out.Failure? <==> |input| % 32 != 0
    ensures out.Failure? ==> out.reason == S.Unaligned()+Word(|input|)
    ensures out.Success? ==> |out.payload| == |input| && W.Frame(out.memory,out.base,out.payload)
    ensures out.Success? ==> multiset(W.Words(out.payload)) == multiset(W.Words(input))
    ensures out.Success? ==> (forall i,j :: 0 <= i < j < |input|/32 ==> W.Words(out.payload)[i] <= W.Words(out.payload)[j])
    ensures out.Success? ==> |out.ids| == |input|/32 && multiset(out.ids) == multiset(C.Range(0,|input|/32))
    ensures out.Success? ==> (forall i,j :: 0 <= i < j < |out.ids| ==>
                                              W.Words(out.payload)[i] == W.Words(out.payload)[j] ==> out.ids[i] < out.ids[j])
  {
    var rejected,memory,at,payload,ids := S.SortWords(input,before,base,other);
    if rejected { out := Failure(S.Unaligned()+Word(|input|)); }
    else {
      var keys := W.Words(input);
      Decoded(keys,ids,payload); Original(keys);
      Permutation(keys,ids,C.Range(0,|keys|));
      out := Success(payload,memory,at,ids);
    }
  }
}
