// SPDX-License-Identifier: MIT
// Exact physical code-copy and dynamic bytes return stages. Native checks pending.
include "Machine.dfy"
module OperationsCodeMemory {
  import opened OperationsCodeMachine

  predicate Fits(body: seq<Byte>) { |body| < 0x10000000000000000 }
  function SourceHeader(body: seq<Byte>): seq<Byte>
    requires Fits(body)
  { Store(Store([],64,160+|body|),128,|body|) }
  function Source(body: seq<Byte>): seq<Byte>
    requires Fits(body)
  { CopyCode(SourceHeader(body),160,body,0,|body|) }
  function Head(body: seq<Byte>): seq<Byte>
    requires Fits(body)
  { Store(Source(body),160+|body|,32) }
  function Length(body: seq<Byte>): seq<Byte>
    requires Fits(body)
  { Store(Head(body),192+|body|,|body|) }
  function Payload(body: seq<Byte>): seq<Byte>
    requires Fits(body)
  { CopyMemory(Length(body),224+|body|,160,|body|) }
  function Final(body: seq<Byte>): seq<Byte>
    requires Fits(body)
  { Store(Payload(body),224+2*|body|,0) }
  function Canonical(body: seq<Byte>): seq<Byte>
  { Encode(32,32)+Encode(|body|,32)+body+seq(Round32(|body|)-|body|,i => 0) }

  lemma RoundedBound(n: nat)
    ensures n <= Round32(n) < n+32
  { assert n+31==32*((n+31)/32)+(n+31)%32; }
  lemma StoreExtent(mem: seq<Byte>,offset: nat,value: Word)
    ensures |Store(mem,offset,value)|>=offset+32
    ensures |Store(mem,offset,value)|>=|mem|
  {}
  lemma StoreOverwrite(mem: seq<Byte>,offset: nat,first: Word,last: Word)
    ensures Store(Store(mem,offset,first),offset,last)==Store(mem,offset,last)
  {
    var expanded:=Grow(mem,offset+32);
    assert |Store(mem,offset,first)|==|expanded|;
    assert Grow(Store(mem,offset,first),offset+32)==Store(mem,offset,first);
  }
  lemma ActualSourceHeader(body: seq<Byte>)
    requires Fits(body)
    ensures Store(Store(Store([],64,128),64,160+|body|),128,|body|)==SourceHeader(body)
  { StoreOverwrite([],64,128,160+|body|); }
  lemma CodeSliceFrame(mem: seq<Byte>,dest: nat,body: seq<Byte>,start: nat,size: nat)
    requires start+size<=|mem|
    requires start+size<=dest || dest+|body|<=start
    ensures |CopyCode(mem,dest,body,0,|body|)|>=|mem|
    ensures CopyCode(mem,dest,body,0,|body|)[start..start+size]==mem[start..start+size]
  { if |body|>0 { assert Grow(mem,dest+|body|)[..|mem|]==mem; } }
  lemma StoreSliceFrame(mem: seq<Byte>,offset: nat,value: Word,start: nat,count: nat)
    requires start+count<=|mem|
    requires start+count<=offset || offset+32<=start
    ensures Store(mem,offset,value)[start..start+count]==mem[start..start+count]
  { var expanded:=Grow(mem,offset+32); assert expanded[..|mem|]==mem; }
  lemma CodePayload(mem: seq<Byte>,dest: nat,body: seq<Byte>)
    requires |body|>0 || dest<=|mem|
    ensures |CopyCode(mem,dest,body,0,|body|)|>=dest+|body|
    ensures CopyCode(mem,dest,body,0,|body|)[dest..dest+|body|]==body
  { if |body|>0 { assert seq(|body|,i => if 0<=i<|body| then body[i] else 0)==body; } }
  lemma CopyPayload(mem: seq<Byte>,dest: nat,source: nat,count: nat)
    requires source+count<=|mem|
    requires count>0 || dest<=|mem|
    ensures |CopyMemory(mem,dest,source,count)|>=dest+count
    ensures CopyMemory(mem,dest,source,count)[dest..dest+count]==mem[source..source+count]
  { if count>0 { var extent:=if dest+count>source+count then dest+count else source+count;
                 assert Grow(mem,extent)[..|mem|]==mem; } }
  lemma CopySliceFrame(mem: seq<Byte>,dest: nat,source: nat,count: nat,start: nat,size: nat)
    requires start+size<=|mem|
    requires start+size<=dest || dest+count<=start
    ensures |CopyMemory(mem,dest,source,count)|>=|mem|
    ensures CopyMemory(mem,dest,source,count)[start..start+size]==mem[start..start+size]
  { if count>0 { var extent:=if dest+count>source+count then dest+count else source+count;
                 assert Grow(mem,extent)[..|mem|]==mem; } }
  lemma EncodeZero(width: nat)
    ensures Encode(0,width)==seq(width,i => 0)
    decreases width
  { if width>0 { EncodeZero(width-1); } }
  lemma ReturnBounds(body: seq<Byte>)
    requires Fits(body)
    ensures |Final(body)|>=224+|body|+Round32(|body|)
  { RoundedBound(|body|); StoreExtent(Payload(body),224+2*|body|,0); }
  function ActualReturn(body: seq<Byte>): seq<Byte>
    requires Fits(body)
    requires |Final(body)|>=224+|body|+Round32(|body|)
  { Final(body)[160+|body|..224+|body|+Round32(|body|)] }

  lemma ExactPayload(body: seq<Byte>)
    requires Fits(body)
    ensures |Source(body)|>=160+|body|
    ensures |Length(body)|>=224+|body|
    ensures Source(body)[160..160+|body|]==body
    ensures Length(body)[160..160+|body|]==body
    ensures Payload(body)[224+|body|..224+2*|body|]==body
  {
    StoreExtent(Store([],64,160+|body|),128,|body|);
    CodePayload(SourceHeader(body),160,body);
    StoreSliceFrame(Source(body),160+|body|,32,160,|body|);
    StoreSliceFrame(Head(body),192+|body|,|body|,160,|body|);
    StoreExtent(Head(body),192+|body|,|body|);
    CopyPayload(Length(body),224+|body|,160,|body|);
  }
  lemma ExactLoads(body: seq<Byte>)
    requires Fits(body)
    ensures Load(Source(body),64)==160+|body|
    ensures Load(Head(body),128)==|body|
    ensures Load(Final(body),64)==160+|body|
  {
    var n:=|body|;
    StoreLoad([],64,160+n);
    StoreFrame(Store([],64,160+n),128,n,64);
    StoreLoad(Store([],64,160+n),128,n);
    CodeSliceFrame(SourceHeader(body),160,body,64,32);
    CodeSliceFrame(SourceHeader(body),160,body,128,32);
    StoreFrame(Source(body),160+n,32,128);
    StoreFrame(Source(body),160+n,32,64);
    StoreFrame(Head(body),192+n,n,64);
    CopySliceFrame(Length(body),224+n,160,n,64,32);
    StoreFrame(Payload(body),224+2*n,0,64);
    assert Grow(Source(body),96)==Source(body);
    assert Grow(Head(body),160)==Head(body);
    assert Grow(Final(body),96)==Final(body);
  }
  lemma SplitFour(bs: seq<Byte>,start: nat,a: nat,b: nat,c: nat,end: nat)
    requires start<=a<=b<=c<=end<=|bs|
    ensures bs[start..end]==bs[start..a]+bs[a..b]+bs[b..c]+bs[c..end]
  {
    assert bs[start..end]==bs[start..a]+bs[a..end];
    assert bs[a..end]==bs[a..b]+bs[b..end];
    assert bs[b..end]==bs[b..c]+bs[c..end];
  }
  lemma ExactReturn(body: seq<Byte>)
    requires Fits(body)
    ensures |Final(body)|>=224+|body|+Round32(|body|)
    ensures ActualReturn(body)==Canonical(body)
  {
    var n:=|body|;
    ReturnBounds(body); ExactPayload(body);
    StoreLoad(Source(body),160+n,32);
    StoreSliceFrame(Head(body),192+n,n,160+n,32);
    StoreLoad(Head(body),192+n,n);
    CopySliceFrame(Length(body),224+n,160,n,160+n,32);
    CopySliceFrame(Length(body),224+n,160,n,192+n,32);
    StoreSliceFrame(Payload(body),224+2*n,0,160+n,32);
    StoreSliceFrame(Payload(body),224+2*n,0,192+n,32);
    StoreSliceFrame(Payload(body),224+2*n,0,224+n,n);
    StoreLoad(Payload(body),224+2*n,0); EncodeZero(32);
    assert Final(body)[160+n..192+n]==Encode(32,32);
    assert Final(body)[192+n..224+n]==Encode(n,32);
    assert Final(body)[224+n..224+2*n]==body;
    assert Final(body)[224+2*n..224+n+Round32(n)]==seq(Round32(n)-n,i => 0);
    SplitFour(Final(body),160+n,192+n,224+n,224+2*n,224+n+Round32(n));
    assert ActualReturn(body)==Final(body)[160+n..192+n]+Final(body)[192+n..224+n]
                               +Final(body)[224+n..224+2*n]+Final(body)[224+2*n..224+n+Round32(n)];
  }
}
