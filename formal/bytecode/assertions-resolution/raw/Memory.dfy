// SPDX-License-Identifier: MIT
// Independent physical bytes-value construction for a raw resolver operand.
include "Machine.dfy"
include "../../scans/Representation.dfy"
module AssertionsRawResolveMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  type Word = S.Word
  type Byte = S.Byte
  predicate Fits(mem: seq<Byte>, free: Word, offset: Word, length: Word, data: seq<Byte>) {
    |mem|%32 == 0 && 96 <= |mem| <= free && free%32 == 0 && free >= 128 &&
    (free as nat)+S.Round32(length)+64 < 0x10000000000000000 &&
    |data| < 0x10000000000000000 && (offset as nat)+length <= |data|
  }
  function Construct(mem: seq<Byte>, free: Word, offset: Word, length: Word, data: seq<Byte>): seq<Byte>
    requires Fits(mem,free,offset,length,data)
  {
    var reservedMem := S.Store(mem,64,free+32+S.Round32(length));
    var header := S.Store(reservedMem,free,length);
    var copied := C.Calldata(header,free+32,offset,length,data);
    S.Store(copied,free+32+length,0)
  }
  lemma StorePrefix(mem: seq<Byte>, offset: Word, word: Word, start: Word, size: nat)
    requires (start as nat)+size <= |mem| && (start as nat)+size <= offset
    ensures S.Store(mem,offset,word)[start..start+size] == mem[start..start+size]
  {
    var expanded := S.Expand(mem,(offset as nat)+32);
    assert expanded[..|mem|] == mem;
  }
  lemma CopyFrame(mem: seq<Byte>, destination: Word, source: Word, length: Word, data: seq<Byte>, other: Word)
    requires (other as nat)+32 <= |mem|
    requires (other as nat)+32 <= destination || (destination as nat)+length <= other
    ensures S.Load(C.Calldata(mem,destination,source,length,data),other) == S.Load(mem,other)
  {
    C.Frame(mem,destination,S.Window(data,source,length));
    C.Size(mem,destination,S.Window(data,source,length));
    var copied := C.Calldata(mem,destination,source,length,data);
    forall i {:trigger copied[other+i]} | 0 <= i < 32
      ensures copied[other+i] == mem[other+i]
    {}
    assert copied[other..other+32] == mem[other..other+32];
    assert G.Grow(copied,(other as nat)+32) == copied;
    assert G.Grow(mem,(other as nat)+32) == mem;
  }
  lemma Built(mem: seq<Byte>, free: Word, offset: Word, length: Word, data: seq<Byte>)
    requires Fits(mem,free,offset,length,data)
    ensures S.Load(Construct(mem,free,offset,length,data),free) == length
    ensures S.Load(Construct(mem,free,offset,length,data),64) == free+32+S.Round32(length)
    ensures Construct(mem,free,offset,length,data)[free+32..free+32+length] == data[offset..offset+length]
    ensures |Construct(mem,free,offset,length,data)|%32 == 0
    ensures free+32+length <= |Construct(mem,free,offset,length,data)| <= free+S.Round32(length)+64
    ensures |Construct(mem,free,offset,length,data)| < 0x10000000000000000
  {
    C.Rounded(length);
    C.Rounded((free as nat)+32+length);
    C.Rounded((free as nat)+64+length);
    assert S.Round32((free as nat)+32+length) == free+32+S.Round32(length);
    assert S.Round32((free as nat)+64+length) == free+64+S.Round32(length);
    var reservedMem := S.Store(mem,64,free+32+S.Round32(length));
    R.StoredWord(mem,64,free+32+S.Round32(length));
    var header := S.Store(reservedMem,free,length);
    R.StoredWord(reservedMem,free,length);
    R.StoredFrame(reservedMem,free,length,64);
    var copied := C.Calldata(header,free+32,offset,length,data);
    C.Size(header,free+32,S.Window(data,offset,length));
    CopyFrame(header,free+32,offset,length,data,free);
    CopyFrame(header,free+32,offset,length,data,64);
    R.StoredFrame(copied,free+32+length,0,free);
    R.StoredFrame(copied,free+32+length,0,64);
    R.WindowFits(data,offset,length);
    forall i {:trigger copied[free+32+i]} | 0 <= i < length
      ensures copied[free+32+i] == data[offset+i]
    { C.CalldataValue(header,free+32,offset,length,data,i); }
    assert copied[free+32..free+32+length] == data[offset..offset+length];
    StorePrefix(copied,free+32+length,0,free+32,length);
    R.StoredWord(copied,free+32+length,0);
  }
}
