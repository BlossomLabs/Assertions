// SPDX-License-Identifier: MIT
// Independent byte-span bridge from physical stores/copies to canonical ABI values.
include "BlobMemory.dfy"
include "Heads.generated.dfy"
include "Spec.dfy"
module AssertionsConstraintFailedCanonicalMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import Q = AssertionsConstraintSequences
  import M = AssertionsConstraintFailedBlobMemory
  import D = AssertionsConstraintFailedBlobSpec
  import P = AssertionsConstraintFailedSpec
  import H = AssertionsConstraintFailedHeads
  type Word = S.Word
  type Byte = S.Byte
  lemma StoreSpan(mem: seq<Byte>, dst: Word, value: Word, start: nat, length: nat)
    requires |mem|%32 == 0 && start+length <= |mem|
    requires start+length <= dst || dst+32 <= start
    ensures S.Store(mem,dst,value)[start..start+length] == mem[start..start+length]
  {
    R.StoredWord(mem,dst,value);
    forall i: nat {:trigger S.Store(mem,dst,value)[start+i]} | i < length
      ensures S.Store(mem,dst,value)[start+i] == mem[start+i]
    { M.StoreOutside(mem,dst,value,start+i); }
    Q.Span(S.Store(mem,dst,value),mem,start,start,length);
  }
  lemma AppendStore(mem: seq<Byte>, start: nat, dst: Word, value: Word)
    requires |mem|%32 == 0 && start <= dst <= |mem|
    ensures S.Store(mem,dst,value)[start..dst+32] == mem[start..dst]+G.Encode(value,32)
  {
    R.StoredWord(mem,dst,value);
    StoreSpan(mem,dst,value,start,dst-start);
    assert S.Store(mem,dst,value)[start..dst+32] ==
      S.Store(mem,dst,value)[start..dst]+S.Store(mem,dst,value)[dst..dst+32];
  }
  lemma {:isolate_assertions} Blob(mem: seq<Byte>, dst: Word, src: Word, length: Word)
    requires D.Heap(mem,dst,src,length)
    ensures D.Image(mem,dst,src,length)[dst..dst+32+S.Round32(length)] ==
      P.Blob(mem[src+32..src+32+length])
  {
    M.Built(mem,dst,src,length);
    var image := D.Image(mem,dst,src,length);
    var bytes := mem[src+32..src+32+length];
    assert |bytes| == length;
    var padded := image[dst+32..dst+32+S.Round32(length)];
    assert |padded| == |P.Pad(bytes)|;
    forall i: nat {:trigger padded[i]} | i < |padded|
      ensures padded[i] == P.Pad(bytes)[i]
    {
      if i < length {
        assert image[dst+32..dst+32+length][i] == bytes[i];
        assert P.Pad(bytes)[..length][i] == bytes[i];
      } else {
        assert image[dst+32+i] == 0;
        assert P.Pad(bytes)[i] == 0;
      }
    }
    Q.Extensional(padded,P.Pad(bytes));
    assert image[dst..dst+32+S.Round32(length)] == image[dst..dst+32]+padded;
  }
  lemma BlobFrame(mem: seq<Byte>, dst: Word, src: Word, length: Word, start: nat, span: nat)
    requires D.Heap(mem,dst,src,length)
    requires start+span <= |mem| && start+span <= dst
    ensures D.Image(mem,dst,src,length)[start..start+span] == mem[start..start+span]
  {
    M.Built(mem,dst,src,length);
    forall i: nat {:trigger D.Image(mem,dst,src,length)[start+i]} | i < span
      ensures D.Image(mem,dst,src,length)[start+i] == mem[start+i]
    {}
    Q.Span(D.Image(mem,dst,src,length),mem,start,start,span);
  }
  lemma {:isolate_assertions} Heads(mem: seq<Byte>, free: Word, entry: Word, param: Word, index: Word,
              kind: Word, actual: Word, assertionLength: Word)
    requires |mem|%32 == 0 && free+228 <= |mem|
    requires (free as nat)+356+S.Round32(assertionLength) < G.Modulus()
    requires mem[free..free+36] == G.Encode(0xdeb9f2af,4)+G.Encode(224,32)
    ensures H.Image(mem,free,entry,param,index,kind,actual,assertionLength)[free..free+228] ==
      G.Encode(0xdeb9f2af,4)+G.Encode(224,32)+G.Encode(entry,32)+G.Encode(param,32)+
      G.Encode(index,32)+G.Encode(kind,32)+G.Encode(actual,32)+G.Encode(256+S.Round32(assertionLength),32)
    ensures H.Image(mem,free,entry,param,index,kind,actual,assertionLength)[free+228..] == mem[free+228..]
    ensures |H.Image(mem,free,entry,param,index,kind,actual,assertionLength)| == |mem|
  {
    var s1 := S.Store(mem,free+36,entry); AppendStore(mem,free,free+36,entry); R.StoredWord(mem,free+36,entry);
    var s2 := S.Store(s1,free+68,param); AppendStore(s1,free,free+68,param); R.StoredWord(s1,free+68,param);
    var s3 := S.Store(s2,free+100,index); AppendStore(s2,free,free+100,index); R.StoredWord(s2,free+100,index);
    var s4 := S.Store(s3,free+132,kind); AppendStore(s3,free,free+132,kind); R.StoredWord(s3,free+132,kind);
    var s5 := S.Store(s4,free+164,actual); AppendStore(s4,free,free+164,actual); R.StoredWord(s4,free+164,actual);
    var s6 := S.Store(s5,free+196,256+S.Round32(assertionLength)); AppendStore(s5,free,free+196,256+S.Round32(assertionLength)); R.StoredWord(s5,free+196,256+S.Round32(assertionLength));
    StoreSpan(mem,free+36,entry,free+228,|mem|-(free+228));
    StoreSpan(s1,free+68,param,free+228,|mem|-(free+228));
    StoreSpan(s2,free+100,index,free+228,|mem|-(free+228));
    StoreSpan(s3,free+132,kind,free+228,|mem|-(free+228));
    StoreSpan(s4,free+164,actual,free+228,|mem|-(free+228));
    StoreSpan(s5,free+196,256+S.Round32(assertionLength),free+228,|mem|-(free+228));
    assert |s1| == |mem| && |s2| == |mem| && |s3| == |mem| && |s4| == |mem| && |s5| == |mem| && |s6| == |mem|;
    assert s1[free+228..] == mem[free+228..];
    assert s2[free+228..] == s1[free+228..];
    assert s3[free+228..] == s2[free+228..];
    assert s4[free+228..] == s3[free+228..];
    assert s5[free+228..] == s4[free+228..];
    assert s6[free+228..] == s5[free+228..];
    assert H.Image(mem,free,entry,param,index,kind,actual,assertionLength) == s6;
  }
}
