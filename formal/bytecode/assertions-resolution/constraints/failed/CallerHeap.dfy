// SPDX-License-Identifier: MIT
// Discharge the serializer's heap and selector premises from the exact false caller.
include "Caller.generated.dfy"
include "CanonicalMemory.dfy"
include "../../../scans/ErrorBytes.dfy"
module AssertionsConstraintFailedCallerHeap {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import E = BytecodeScanErrorBytes
  import M = AssertionsConstraintFailedBlobMemory
  import Q = AssertionsConstraintSequences
  import C = AssertionsConstraintFailedCanonicalMemory
  import T = AssertionsConstraintFailedHeap
  import A = AssertionsConstraintFailedCaller
  type Word = S.Word
  type Byte = S.Byte
  lemma {:isolate_assertions} Prepared(mem: seq<Byte>, free: Word, assertion: Word, assertionLength: Word,
                 reference: Word, referenceLength: Word)
    requires T.Heap(mem,free,assertion,assertionLength,reference,referenceLength)
    ensures T.Heap(A.Image(mem,free),free,assertion,assertionLength,reference,referenceLength)
    ensures A.Image(mem,free)[free..free+4] == G.Encode(0xdeb9f2af,4)
    ensures A.Image(mem,free)[assertion+32..assertion+32+assertionLength] == mem[assertion+32..assertion+32+assertionLength]
    ensures A.Image(mem,free)[reference+32..reference+32+referenceLength] == mem[reference+32..reference+32+referenceLength]
  {
    var header: Word := 0xdeb9f2af00000000000000000000000000000000000000000000000000000000;
    var output := A.Image(mem,free);
    R.StoredWord(mem,free,header);
    var bound := if |mem| < free then |mem| else free;
    forall j: nat {:trigger output[j]} | j < bound
      ensures output[j] == mem[j]
    { M.StorePoint(mem,free,header,j); }
    T.PrefixLoad(mem,output,bound,assertion);
    T.PrefixLoad(mem,output,bound,reference);
    T.PrefixLoad(mem,output,bound,64);
    G.WordPower();
    E.ShiftedPrefix(0xdeb9f2af,28);
    assert G.Pow256(28) == 0x100000000000000000000000000000000000000000000000000000000;
    assert output[free..free+4] == G.Encode(header,32)[..4];
    C.StoreSpan(mem,free,header,assertion+32,assertionLength);
    C.StoreSpan(mem,free,header,reference+32,referenceLength);
  }
}
