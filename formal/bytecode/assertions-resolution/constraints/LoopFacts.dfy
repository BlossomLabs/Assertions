// SPDX-License-Identifier: MIT
// Link the independent array specification to the concrete decoder and heap.
include "LoopSpec.dfy"
include "DecoderFacts.dfy"
include "Decoder.generated.dfy"
module AssertionsConstraintLoopFacts {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import P = AssertionsConstraintDecoderMemory
  import D = AssertionsConstraintDecoder
  import F = AssertionsConstraintDecoderFacts
  import L = AssertionsConstraintLoopSpec
  type Word = S.Word
  type Byte = S.Byte
  lemma Item(data: seq<Byte>, base: Word, cs: seq<L.Constraint>, index: nat)
    requires L.Layout(data,base,cs) && index < |cs|
    ensures cs[index].kind <= 8 && cs[index].kind != 6
    ensures (base as nat)+cs[index].position+64 <= |data|
    ensures (base as nat)+cs[index].position+cs[index].referenceRelative+32+cs[index].length <= |data|
    ensures L.Position(base,cs[index]) == base+cs[index].position
    ensures L.Payload(base,cs[index]) == D.PayloadOffset(L.Position(base,cs[index]),cs[index].referenceRelative)
    ensures S.DataWord(data,base+index*32) == cs[index].position
    ensures S.DataWord(data,L.Position(base,cs[index])) == cs[index].kind
    ensures S.DataWord(data,L.Position(base,cs[index])+32) == cs[index].referenceRelative
    ensures S.DataWord(data,L.Position(base,cs[index])+cs[index].referenceRelative) == cs[index].length
  {}
  lemma DecoderAdmission(data: seq<Byte>, base: Word, cs: seq<L.Constraint>, index: nat,
                         mem: seq<Byte>, pointer: Word, bytes: seq<Byte>, initial: Word, prefix: seq<Word>)
    requires L.Layout(data,base,cs) && index < |cs| && |prefix| <= 980
    requires (initial as nat)+L.Cost(cs)+160 < 0x10000000000000000
    requires L.Heap(mem,pointer,bytes,L.Free(initial,cs,index))
    ensures D.Admitted(7723,L.Position(base,cs[index]),cs[index].kind,cs[index].referenceRelative,
                       cs[index].length,L.Free(initial,cs,index),prefix,mem,data)
    ensures P.Fits(mem,L.Free(initial,cs,index),L.Payload(base,cs[index]),cs[index].length,data)
  {
    Item(data,base,cs,index);
    L.FreeStep(initial,cs,index);
  }
  lemma {:isolate_assertions} AfterHeap(mem: seq<Byte>, pointer: Word, bytes: seq<Byte>, free: Word,
                                        kind: Word, offset: Word, length: Word, data: seq<Byte>)
    requires L.Heap(mem,pointer,bytes,free) && P.Fits(mem,free,offset,length,data)
    ensures L.Heap(P.Construct(mem,free,kind,offset,length,data),pointer,bytes,P.NextFree(free,length))
  {
    hide P.Construct();
    P.Built(mem,free,kind,offset,length,data);
    F.OldWord(mem,free,kind,offset,length,data,pointer);
    F.OldBytes(mem,free,kind,offset,length,data,pointer+32,|bytes|);
    C.Rounded(length);
    assert S.Round32(length)%32 == 0;
  }
}
