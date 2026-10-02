// SPDX-License-Identifier: MIT
// The RAW resolver's exact allocation supplies the validator's original bytes.
include "../constraints/LoopSpec.dfy"
module AssertionsConstrainedRawHeap {
  import S = BytecodeScanMachine
  import P = AssertionsRawResolveMemory
  import C = BytecodeCopyMemory
  import L = AssertionsConstraintLoopSpec
  type Word = S.Word
  type Byte = S.Byte
  lemma {:isolate_assertions} Prepared(mem: seq<Byte>, free: Word, offset: Word, length: Word, data: seq<Byte>)
    requires P.Fits(mem,free,offset,length,data)
    ensures L.Heap(P.Construct(mem,free,offset,length,data),free,data[offset..offset+length],free+32+S.Round32(length))
  {
    hide P.Construct();
    P.Built(mem,free,offset,length,data);
    C.Rounded(length);
  }
}
