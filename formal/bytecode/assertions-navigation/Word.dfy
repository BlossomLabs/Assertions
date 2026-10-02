// SPDX-License-Identifier: MIT
include "../scans/ErrorBytes.dfy"
module AssertionsNavigationWord {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanErrorBytes
  import R = BytecodeScanRepresentation
  type Word = S.Word
  type Byte = S.Byte
  function ErrorMemory(mem: seq<Byte>, free: Word, index: Word, length: Word): seq<Byte>
    requires (free as nat)+68 < G.Modulus()
  {
    S.Store(S.Store(S.Store(mem,free,3586884662*0x100000000000000000000000000000000000000000000000000000000),free+4,index),free+36,length)
  }
  lemma ErrorBytes(mem: seq<Byte>, free: Word, index: Word, length: Word)
    requires |mem|%32 == 0 && (free as nat)+96 < G.Modulus()
    ensures ErrorMemory(mem,free,index,length)[free..free+68] ==
            G.Encode(3586884662,4)+G.Encode(index,32)+G.Encode(length,32)
    ensures |ErrorMemory(mem,free,index,length)|%32 == 0
  {
    var header: Word := 3586884662*0x100000000000000000000000000000000000000000000000000000000;
    E.PhysicalError(mem,free,3586884662,header,index);
    var first := S.Store(S.Store(mem,free,header),free+4,index);
    R.StoredWord(mem,free,header);
    R.StoredWord(S.Store(mem,free,header),free+4,index);
    R.StoredWord(first,free+36,length);
    var expanded := S.Expand(first,(free as nat)+68);
    assert expanded[..|first|] == first;
    assert expanded[free..free+36] == first[free..free+36];
    assert S.Store(first,free+36,length)[free..free+68] ==
           S.Store(first,free+36,length)[free..free+36]+S.Store(first,free+36,length)[free+36..free+68];
  }
}
