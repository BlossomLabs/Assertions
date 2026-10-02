// SPDX-License-Identifier: MIT
// Generic serializer geometry, supporting aligned and unaligned free pointers.
// Native verification pending; fitting representations remain explicit.
include "Memory.dfy"
module OperationsDynamicReturnMemory {
  import opened OperationsCodeMachine
  import M = OperationsCodeMemory
  predicate Layout(mem: seq<Byte>,body: seq<Byte>,p: Word,f: Word) {
    M.Fits(body) && p>=96 && p+32+|body|<=|mem| && f>=p+32+|body|
    && f+128+|body|<Modulus()
    && Load(mem,p)==|body| && Load(mem,64)==f
    && mem[p+32..p+32+|body|]==body
  }
  function Head(mem: seq<Byte>,body: seq<Byte>,p: Word,f: Word): seq<Byte>
    requires Layout(mem,body,p,f)
  { Store(mem,f,32) }
  function Length(mem: seq<Byte>,body: seq<Byte>,p: Word,f: Word): seq<Byte>
    requires Layout(mem,body,p,f)
  { Store(Head(mem,body,p,f),f+32,|body|) }
  function Payload(mem: seq<Byte>,body: seq<Byte>,p: Word,f: Word): seq<Byte>
    requires Layout(mem,body,p,f)
  { CopyMemory(Length(mem,body,p,f),f+64,p+32,|body|) }
  function Final(mem: seq<Byte>,body: seq<Byte>,p: Word,f: Word): seq<Byte>
    requires Layout(mem,body,p,f)
  { Store(Payload(mem,body,p,f),f+64+|body|,0) }
  lemma ReturnBounds(mem: seq<Byte>,body: seq<Byte>,p: Word,f: Word)
    requires Layout(mem,body,p,f)
    ensures |Final(mem,body,p,f)|>=f+64+Round32(|body|)
    ensures Round32(f+96+|body|)<Modulus()
  {
    M.RoundedBound(|body|); M.RoundedBound(f+96+|body|);
    M.StoreExtent(Payload(mem,body,p,f),f+64+|body|,0);
  }
  function ActualReturn(mem: seq<Byte>,body: seq<Byte>,p: Word,f: Word): seq<Byte>
    requires Layout(mem,body,p,f)
    requires |Final(mem,body,p,f)|>=f+64+Round32(|body|)
  { Final(mem,body,p,f)[f..f+64+Round32(|body|)] }
  lemma ExactSource(mem: seq<Byte>,body: seq<Byte>,p: Word,f: Word)
    requires Layout(mem,body,p,f)
    ensures Length(mem,body,p,f)[p+32..p+32+|body|]==body
    ensures Payload(mem,body,p,f)[f+64..f+64+|body|]==body
    ensures Load(Head(mem,body,p,f),p)==|body|
    ensures Load(Final(mem,body,p,f),64)==f
  {
    var n:=|body|;
    M.StoreSliceFrame(mem,f,32,p+32,n);
    M.StoreSliceFrame(Head(mem,body,p,f),f+32,n,p+32,n);
    M.CopyPayload(Length(mem,body,p,f),f+64,p+32,n);
    StoreFrame(mem,f,32,p);
    StoreFrame(mem,f,32,64);
    StoreFrame(Head(mem,body,p,f),f+32,n,64);
    M.CopySliceFrame(Length(mem,body,p,f),f+64,p+32,n,64,32);
    StoreFrame(Payload(mem,body,p,f),f+64+n,0,64);
    assert Grow(Final(mem,body,p,f),96)==Final(mem,body,p,f);
  }
  lemma ExactReturn(mem: seq<Byte>,body: seq<Byte>,p: Word,f: Word)
    requires Layout(mem,body,p,f)
    ensures |Final(mem,body,p,f)|>=f+64+Round32(|body|)
    ensures ActualReturn(mem,body,p,f)==M.Canonical(body)
  {
    var n:=|body|;
    ReturnBounds(mem,body,p,f); ExactSource(mem,body,p,f);
    StoreLoad(mem,f,32);
    M.StoreSliceFrame(Head(mem,body,p,f),f+32,n,f,32);
    StoreLoad(Head(mem,body,p,f),f+32,n);
    M.CopySliceFrame(Length(mem,body,p,f),f+64,p+32,n,f,32);
    M.CopySliceFrame(Length(mem,body,p,f),f+64,p+32,n,f+32,32);
    M.StoreSliceFrame(Payload(mem,body,p,f),f+64+n,0,f,32);
    M.StoreSliceFrame(Payload(mem,body,p,f),f+64+n,0,f+32,32);
    M.StoreSliceFrame(Payload(mem,body,p,f),f+64+n,0,f+64,n);
    StoreLoad(Payload(mem,body,p,f),f+64+n,0); M.EncodeZero(32);
    assert Final(mem,body,p,f)[f..f+32]==Encode(32,32);
    assert Final(mem,body,p,f)[f+32..f+64]==Encode(n,32);
    assert Final(mem,body,p,f)[f+64..f+64+n]==body;
    assert Final(mem,body,p,f)[f+64+n..f+64+Round32(n)]==seq(Round32(n)-n,i => 0);
    M.SplitFour(Final(mem,body,p,f),f,f+32,f+64,f+64+n,f+64+Round32(n));
  }
}
