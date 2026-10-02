// SPDX-License-Identifier: MIT
// Development pure memory bridge; no machine-step equality is assumed.
include "Machine.dfy"
include "../../scans/Machine.dfy"
include "../../copy/Memory.dfy"
module OperationsSerializerMemoryTranslation {
  import A = OperationsCodeMachine
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  lemma Round(n: nat)
    ensures A.Round32(n)==S.Round32(n)
  {}
  lemma RoundMonotone(n: nat,m: nat)
    requires n<=m
    ensures A.Round32(n)<=A.Round32(m)
  {}
  lemma RoundedFixed(n: nat)
    requires n%32==0
    ensures A.Round32(n)==n
  {}
  lemma GrowAligned(mem: seq<A.Byte>,n: nat)
    requires |mem|%32==0
    ensures A.Grow(mem,n)==S.Expand(mem,n)
    ensures A.Grow(mem,n)==G.Grow(mem,A.Round32(n))
    ensures |A.Grow(mem,n)|%32==0
  {
    Round(n);
    RoundedFixed(|mem|);
    if |mem|>=n { RoundMonotone(n,|mem|); }
  }
  lemma GrowLiteralRounded(mem: seq<A.Byte>,n: nat)
    requires n%32==0
    ensures A.Grow(mem,n)==G.Grow(mem,n)
  { RoundedFixed(n); }
  lemma Encode(n: nat,width: nat)
    ensures A.Encode(n,width)==G.Encode(n,width)
    decreases width
  { if width>0 { Encode(n/256,width-1); } }
  lemma Decode(bytes: seq<A.Byte>)
    ensures A.Decode(bytes)==G.Decode(bytes)
    decreases |bytes|
  { if |bytes|>0 { Decode(bytes[..|bytes|-1]); } }
  lemma Store(mem: seq<A.Byte>,offset: A.Word,value: A.Word)
    requires |mem|%32==0 && |mem|<A.Modulus()
    requires A.Round32((offset as nat)+32)<A.Modulus()
    ensures A.Store(mem,offset,value)==S.Store(mem,offset,value)
    ensures |A.Store(mem,offset,value)|%32==0
    ensures |A.Store(mem,offset,value)|<A.Modulus()
  {
    GrowAligned(mem,(offset as nat)+32);
    var expanded:=A.Grow(mem,(offset as nat)+32);
    assert |expanded|>=offset+32;
    assert G.Grow(expanded,(offset as nat)+32)==expanded;
    Encode(value,32);
  }
  lemma Load(mem: seq<A.Byte>,offset: A.Word)
    requires |mem|<A.Modulus()
    requires A.Round32((offset as nat)+32)<A.Modulus()
    ensures A.Load(mem,offset)==S.Load(mem,offset)
  {
    var a:=A.Grow(mem,(offset as nat)+32);
    var g:=G.Grow(mem,(offset as nat)+32);
    forall i: nat {:trigger a[offset+i]} | i<32
      ensures a[offset+i]==g[offset+i]
    { if offset+i<|mem| {} else {} }
    assert a[offset..offset+32]==g[offset..offset+32];
    Decode(a[offset..offset+32]);
    assert A.Modulus()==G.Modulus();
  }
  lemma WindowSlice(mem: seq<A.Byte>,offset: nat,width: nat)
    requires offset+width<=|mem|
    ensures S.Window(mem,offset,width)==mem[offset..offset+width]
  {
    forall i: nat | i<width
      ensures S.Window(mem,offset,width)[i]==mem[offset..offset+width][i]
    {}
  }
  lemma Copy(mem: seq<A.Byte>,dst: A.Word,src: A.Word,count: A.Word)
    requires |mem|%32==0 && |mem|<A.Modulus()
    requires count==0 || A.Round32((if dst>=src then dst as nat else src as nat)+count)<A.Modulus()
    ensures A.CopyMemory(mem,dst,src,count)==C.Memory(mem,dst,src,count)
    ensures |A.CopyMemory(mem,dst,src,count)|%32==0
    ensures |A.CopyMemory(mem,dst,src,count)|<A.Modulus()
  {
    if count>0 {
      var end:=(if dst>=src then dst as nat else src as nat)+count;
      assert end==(if dst+count>src+count then dst+count else src+count);
      GrowAligned(mem,end);
      var expanded:=A.Grow(mem,end);
      assert dst+count<=|expanded| && src+count<=|expanded|;
      WindowSlice(expanded,src,count);
      GrowAligned(expanded,(dst as nat)+count);
      assert A.Grow(expanded,(dst as nat)+count)==expanded;
      assert S.Expand(expanded,(dst as nat)+count)==expanded;
    }
  }
}
