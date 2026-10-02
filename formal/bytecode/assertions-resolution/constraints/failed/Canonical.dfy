// SPDX-License-Identifier: MIT
// Entire physical error image equals independently defined canonical ABI bytes.
include "CanonicalMemory.dfy"
include "Serialization.dfy"
module AssertionsConstraintFailedCanonical {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import T = AssertionsConstraintFailedHeap
  import D = AssertionsConstraintFailedBlobSpec
  import M = AssertionsConstraintFailedBlobMemory
  import H = AssertionsConstraintFailedHeads
  import Q = AssertionsConstraintSequences
  import C = AssertionsConstraintFailedCanonicalMemory
  import F = AssertionsConstraintFailedSerialization
  import P = AssertionsConstraintFailedSpec
  type Word = S.Word
  type Byte = S.Byte
  lemma {:isolate_assertions} Image(mem: seq<Byte>, free: Word, assertion: Word, assertionLength: Word,
              reference: Word, referenceLength: Word, entry: Word, param: Word, index: Word, kind: Word, actual: Word)
    requires T.Heap(mem,free,assertion,assertionLength,reference,referenceLength) && kind <= 8
    requires free+4 <= |mem| && mem[free..free+4] == G.Encode(0xdeb9f2af,4)
    ensures F.Image(mem,free,assertion,assertionLength,reference,referenceLength,entry,param,index,kind,actual)
      [free..free+292+S.Round32(assertionLength)+S.Round32(referenceLength)] ==
      P.Error(mem[assertion+32..assertion+32+assertionLength],entry,param,index,kind,actual,
              mem[reference+32..reference+32+referenceLength])
  {
    T.Start(mem,free,assertion,assertionLength,reference,referenceLength);
    var m1 := S.Store(mem,free+4,224);
    C.AppendStore(mem,free,free+4,224);
    C.StoreSpan(mem,free+4,224,assertion+32,assertionLength);
    C.StoreSpan(mem,free+4,224,reference+32,referenceLength);
    assert m1[free..free+36] == G.Encode(0xdeb9f2af,4)+G.Encode(224,32);
    M.Built(m1,free+228,assertion,assertionLength);
    var m2 := D.Image(m1,free+228,assertion,assertionLength);
    C.Blob(m1,free+228,assertion,assertionLength);
    C.BlobFrame(m1,free+228,assertion,assertionLength,free,36);
    var assertionBytes := mem[assertion+32..assertion+32+assertionLength];
    var referenceBytes := mem[reference+32..reference+32+referenceLength];
    assert m2[free+228..free+260+S.Round32(assertionLength)] == P.Blob(assertionBytes);
    T.First(mem,free,assertion,assertionLength,reference,referenceLength);
    C.Heads(m2,free,entry,param,index,kind,actual,assertionLength);
    var m3 := H.Image(m2,free,entry,param,index,kind,actual,assertionLength);
    var second := free+260+S.Round32(assertionLength);
    assert m3[free+228..second] == m2[free+228..second];
    T.Heads(mem,free,assertion,assertionLength,reference,referenceLength,entry,param,index,kind,actual);
    forall i: nat {:trigger m3[reference+32+i]} | i < referenceLength
      ensures m3[reference+32+i] == mem[reference+32+i]
    {}
    Q.Span(m3,mem,reference+32,reference+32,referenceLength);
    M.Built(m3,second,reference,referenceLength);
    var m4 := D.Image(m3,second,reference,referenceLength);
    C.Blob(m3,second,reference,referenceLength);
    C.BlobFrame(m3,second,reference,referenceLength,free,second-free);
    assert m4[free..second] == m3[free..free+228]+m3[free+228..second];
    assert m4[free..second+32+S.Round32(referenceLength)] ==
      m4[free..second]+m4[second..second+32+S.Round32(referenceLength)];
  }
}
