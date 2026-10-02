// SPDX-License-Identifier: MIT
// Constructive memory admission for both physical dynamic ABI byte encoders.
include "Start.generated.dfy"
include "Heads.generated.dfy"
include "BlobMemory.dfy"
module AssertionsConstraintFailedHeap {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import C = BytecodeCopyMemory
  import Q = AssertionsConstraintSequences
  import D = AssertionsConstraintFailedBlobSpec
  import M = AssertionsConstraintFailedBlobMemory
  import H = AssertionsConstraintFailedHeads
  type Word = S.Word
  type Byte = S.Byte
  predicate Heap(mem: seq<Byte>, free: Word, assertion: Word, assertionLength: Word,
                 reference: Word, referenceLength: Word) {
    |mem|%32 == 0 && 96 <= |mem| <= free+32 && free >= 128 && free%32 == 0 &&
    (free as nat)+356+S.Round32(assertionLength)+S.Round32(referenceLength) < 0x10000000000000000 &&
    assertion+32+assertionLength <= |mem| && reference+32+referenceLength <= |mem| &&
    assertion+32+assertionLength <= free && reference+32+referenceLength <= free &&
    S.Load(mem,assertion) == assertionLength && S.Load(mem,reference) == referenceLength && S.Load(mem,64) == free
  }
  lemma Store(mem: seq<Byte>, dst: Word, value: Word, bound: nat, ceiling: nat)
    requires |mem|%32 == 0 && bound <= |mem| && bound <= dst
    requires |mem| <= ceiling && dst+32 <= ceiling && ceiling%32 == 0
    ensures |S.Store(mem,dst,value)|%32 == 0 && |mem| <= |S.Store(mem,dst,value)| <= ceiling
    ensures forall j: nat {:trigger S.Store(mem,dst,value)[j]} :: j < bound ==> S.Store(mem,dst,value)[j] == mem[j]
  {
    R.StoredWord(mem,dst,value); C.Rounded((dst as nat)+32);
    assert S.Round32((dst as nat)+32) <= ceiling;
    forall j: nat {:trigger S.Store(mem,dst,value)[j]} | j < bound
      ensures S.Store(mem,dst,value)[j] == mem[j]
    { M.StorePoint(mem,dst,value,j); }
  }
  lemma PrefixLoad(original: seq<Byte>, output: seq<Byte>, bound: nat, pointer: Word)
    requires bound <= |original| && bound <= |output| && pointer+32 <= bound
    requires forall j: nat {:trigger output[j]} :: j < bound ==> output[j] == original[j]
    ensures S.Load(output,pointer) == S.Load(original,pointer)
  {
    forall j: nat {:trigger output[pointer+j]} | j < 32
      ensures output[pointer+j] == original[pointer+j]
    {}
    Q.Span(output,original,pointer,pointer,32);
    assert G.Grow(original,pointer+32) == original;
    assert G.Grow(output,pointer+32) == output;
  }
  lemma Start(mem: seq<Byte>, free: Word, assertion: Word, assertionLength: Word,
              reference: Word, referenceLength: Word)
    requires Heap(mem,free,assertion,assertionLength,reference,referenceLength)
    ensures D.Heap(S.Store(mem,free+4,224),free+228,assertion,assertionLength)
    ensures forall j: nat {:trigger S.Store(mem,free+4,224)[j]} :: j < |mem| && j < free+4 ==> S.Store(mem,free+4,224)[j] == mem[j]
  {
    var bound := if |mem| < free+4 then |mem| else free+4;
    Store(mem,free+4,224,bound,free+64);
    PrefixLoad(mem,S.Store(mem,free+4,224),bound,assertion);
  }
  lemma {:isolate_assertions} First(mem: seq<Byte>, free: Word, assertion: Word, assertionLength: Word,
                                    reference: Word, referenceLength: Word)
    requires Heap(mem,free,assertion,assertionLength,reference,referenceLength)
    ensures D.Heap(S.Store(mem,free+4,224),free+228,assertion,assertionLength)
    ensures var m1 := S.Store(mem,free+4,224); var m2 := D.Image(m1,free+228,assertion,assertionLength);
                                               |m2|%32 == 0 && free+260+S.Round32(assertionLength) <= |m2| <= free+324+S.Round32(assertionLength)
    ensures var m1 := S.Store(mem,free+4,224); var m2 := D.Image(m1,free+228,assertion,assertionLength);
                                               forall j: nat {:trigger m2[j]} :: j < |mem| && j < free+4 ==> m2[j] == mem[j]
  {
    Start(mem,free,assertion,assertionLength,reference,referenceLength);
    var m1 := S.Store(mem,free+4,224); M.Built(m1,free+228,assertion,assertionLength);
  }
  lemma {:isolate_assertions} HeadStores(mem: seq<Byte>, free: Word, entry: Word, param: Word, index: Word,
                                         kind: Word, actual: Word, assertionLength: Word, bound: nat)
    requires |mem|%32 == 0 && free+228 <= |mem|
    requires (free as nat)+356+S.Round32(assertionLength) < G.Modulus()
    requires bound <= free+4 && bound <= |mem|
    ensures |H.Image(mem,free,entry,param,index,kind,actual,assertionLength)| == |mem|
    ensures |H.Image(mem,free,entry,param,index,kind,actual,assertionLength)|%32 == 0
    ensures forall j: nat {:trigger H.Image(mem,free,entry,param,index,kind,actual,assertionLength)[j]} ::
              j < bound ==> H.Image(mem,free,entry,param,index,kind,actual,assertionLength)[j] == mem[j]
  {
    var s1 := S.Store(mem,free+36,entry); Store(mem,free+36,entry,bound,|mem|);
    var s2 := S.Store(s1,free+68,param); Store(s1,free+68,param,bound,|mem|);
    var s3 := S.Store(s2,free+100,index); Store(s2,free+100,index,bound,|mem|);
    var s4 := S.Store(s3,free+132,kind); Store(s3,free+132,kind,bound,|mem|);
    var s5 := S.Store(s4,free+164,actual); Store(s4,free+164,actual,bound,|mem|);
    var s6 := S.Store(s5,free+196,256+S.Round32(assertionLength)); Store(s5,free+196,256+S.Round32(assertionLength),bound,|mem|);
    forall j: nat {:trigger s6[j]} | j < bound
      ensures s6[j] == mem[j]
    { assert s6[j] == s5[j] == s4[j] == s3[j] == s2[j] == s1[j] == mem[j]; }
  }
  lemma {:isolate_assertions} Heads(mem: seq<Byte>, free: Word, assertion: Word, assertionLength: Word,
                                    reference: Word, referenceLength: Word, entry: Word, param: Word, index: Word, kind: Word, actual: Word)
    requires Heap(mem,free,assertion,assertionLength,reference,referenceLength)
    ensures D.Heap(S.Store(mem,free+4,224),free+228,assertion,assertionLength)
    ensures var m1 := S.Store(mem,free+4,224); var m2 := D.Image(m1,free+228,assertion,assertionLength);
                                               var m3 := H.Image(m2,free,entry,param,index,kind,actual,assertionLength);
                                               D.Heap(m3,free+260+S.Round32(assertionLength),reference,referenceLength)
    ensures var m1 := S.Store(mem,free+4,224); var m2 := D.Image(m1,free+228,assertion,assertionLength);
                                               var m3 := H.Image(m2,free,entry,param,index,kind,actual,assertionLength);
                                               forall j: nat {:trigger m3[j]} :: j < |mem| && j < free+4 ==> m3[j] == mem[j]
  {
    First(mem,free,assertion,assertionLength,reference,referenceLength);
    var m1 := S.Store(mem,free+4,224); var m2 := D.Image(m1,free+228,assertion,assertionLength);
    var bound := if |mem| < free+4 then |mem| else free+4;
    HeadStores(m2,free,entry,param,index,kind,actual,assertionLength,bound);
    var image := H.Image(m2,free,entry,param,index,kind,actual,assertionLength);
    forall j: nat {:trigger image[j]} | j < |mem| && j < free+4
      ensures image[j] == mem[j]
    { assert image[j] == m2[j] == mem[j]; }
    PrefixLoad(mem,image,bound,reference);
  }
  lemma {:isolate_assertions} Last(mem: seq<Byte>, free: Word, assertion: Word, assertionLength: Word,
                                   reference: Word, referenceLength: Word, entry: Word, param: Word, index: Word, kind: Word, actual: Word)
    requires Heap(mem,free,assertion,assertionLength,reference,referenceLength)
    ensures D.Heap(S.Store(mem,free+4,224),free+228,assertion,assertionLength)
    ensures var m1 := S.Store(mem,free+4,224); var m2 := D.Image(m1,free+228,assertion,assertionLength);
                                               var m3 := H.Image(m2,free,entry,param,index,kind,actual,assertionLength);
                                               D.Heap(m3,free+260+S.Round32(assertionLength),reference,referenceLength)
    ensures var m1 := S.Store(mem,free+4,224); var m2 := D.Image(m1,free+228,assertion,assertionLength);
                                               var m3 := H.Image(m2,free,entry,param,index,kind,actual,assertionLength);
                                               var m4 := D.Image(m3,free+260+S.Round32(assertionLength),reference,referenceLength);
                                               |m4|%32 == 0 && free+292+S.Round32(assertionLength)+S.Round32(referenceLength) <= |m4| < 0x10000000000000000 && S.Load(m4,64) == free
    ensures var m1 := S.Store(mem,free+4,224); var m2 := D.Image(m1,free+228,assertion,assertionLength);
                                               var m3 := H.Image(m2,free,entry,param,index,kind,actual,assertionLength);
                                               var m4 := D.Image(m3,free+260+S.Round32(assertionLength),reference,referenceLength);
                                               forall j: nat {:trigger m4[j]} :: j < |mem| && j < free+4 ==> m4[j] == mem[j]
  {
    Heads(mem,free,assertion,assertionLength,reference,referenceLength,entry,param,index,kind,actual);
    var m1 := S.Store(mem,free+4,224); var m2 := D.Image(m1,free+228,assertion,assertionLength);
    var m3 := H.Image(m2,free,entry,param,index,kind,actual,assertionLength);
    var dst := free+260+S.Round32(assertionLength); M.Built(m3,dst,reference,referenceLength);
    var m4 := D.Image(m3,dst,reference,referenceLength);
    forall j: nat {:trigger m4[j]} | j < |mem| && j < free+4
      ensures m4[j] == mem[j]
    { assert m4[j] == m3[j] == mem[j]; }
    var bound := if |mem| < free+4 then |mem| else free+4;
    PrefixLoad(mem,m4,bound,64);
  }
  // Instantiate the independently proved serializer prefix frame for a caller selector.
  lemma Selector(original: seq<Byte>, output: seq<Byte>, free: Word)
    requires free+4 <= |original| && free+4 <= |output|
    requires original[free..free+4] == G.Encode(0xdeb9f2af,4)
    requires forall j: nat {:trigger output[j]} :: j < |original| && j < free+4 ==> output[j] == original[j]
    ensures output[free..free+4] == G.Encode(0xdeb9f2af,4)
  {
    forall i: nat {:trigger output[free+i]} | i < 4
      ensures output[free+i] == original[free+i]
    {}
    Q.Span(output,original,free,free,4);
  }
}
