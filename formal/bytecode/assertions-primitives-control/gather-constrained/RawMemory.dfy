// SPDX-License-Identifier: MIT
// A RAW bytes allocation preserves an arbitrary prior byte window above scratch space.
include "../../assertions-resolution/constraints/DecoderMemory.dfy"
module AssertionsGatherConstrainedRawMemory {
  import S = BytecodeScanMachine
  import P = AssertionsRawResolveMemory
  import H = AssertionsConstraintDecoderMemory
  import C = BytecodeCopyMemory
  type Word = S.Word
  type Byte = S.Byte
  lemma Window(mem: seq<Byte>, free: Word, offset: Word, length: Word, data: seq<Byte>, start: Word, size: nat)
    requires P.Fits(mem,free,offset,length,data)
    requires 96 <= start && (start as nat)+size <= free && (start as nat)+size <= |mem|
    ensures P.Construct(mem,free,offset,length,data)[start..start+size] == mem[start..start+size]
  {
    var reserved := S.Store(mem,64,free+32+S.Round32(length));
    H.StoreSuffix(mem,64,free+32+S.Round32(length),start,size);
    var header := S.Store(reserved,free,length);
    P.StorePrefix(reserved,free,length,start,size);
    var copied := C.Calldata(header,free+32,offset,length,data);
    C.Frame(header,free+32,S.Window(data,offset,length));
    C.Size(header,free+32,S.Window(data,offset,length));
    forall i {:trigger copied[start+i]} | 0 <= i < size
      ensures copied[start+i] == header[start+i]
    {}
    assert copied[start..start+size] == header[start..start+size];
    P.StorePrefix(copied,free+32+length,0,start,size);
  }
}
