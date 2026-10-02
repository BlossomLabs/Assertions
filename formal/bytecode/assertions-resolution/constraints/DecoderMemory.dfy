// SPDX-License-Identifier: MIT
// Independent memory layout of one decoded calldata Constraint.
include "../raw/Memory.dfy"
module AssertionsConstraintDecoderMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import P = AssertionsRawResolveMemory
  import R = BytecodeScanRepresentation
  import C = BytecodeCopyMemory
  type Word = S.Word
  type Byte = S.Byte
  predicate Fits(mem: seq<Byte>, free: Word, offset: Word, length: Word, data: seq<Byte>) {
    |mem|%32 == 0 && 96 <= |mem| <= (free as nat)+32 && free%32 == 0 && free >= 128 &&
    (free as nat)+S.Round32(length)+256 < 0x10000000000000000 &&
    |data| < 0x10000000000000000 && (offset as nat)+length <= |data|
  }
  function NextFree(free: Word, length: Word): Word
    requires (free as nat)+S.Round32(length)+96 < G.Modulus()
  { free+96+S.Round32(length) }
  function Record(mem: seq<Byte>, free: Word, kind: Word): seq<Byte>
    requires Fits(mem,free,0,0,[])
  { S.Store(S.Store(mem,64,free+64),free,kind) }
  function Construct(mem: seq<Byte>, free: Word, kind: Word, offset: Word, length: Word, data: seq<Byte>): seq<Byte>
    requires Fits(mem,free,offset,length,data)
  {
    RecordFits(mem,free,kind,offset,length,data);
    var record := S.Store(S.Store(mem,64,free+64),free,kind);
    var payload := P.Construct(record,free+64,offset,length,data);
    S.Store(payload,free+32,free+64)
  }
  lemma RecordFits(mem: seq<Byte>, free: Word, kind: Word, offset: Word, length: Word, data: seq<Byte>)
    requires Fits(mem,free,offset,length,data)
    ensures P.Fits(S.Store(S.Store(mem,64,free+64),free,kind),free+64,offset,length,data)
  {
    C.Rounded((free as nat)+32);
    assert S.Round32((free as nat)+32) == free+32;
  }
  lemma StoreSuffix(mem: seq<Byte>, offset: Word, word: Word, start: Word, size: nat)
    requires (start as nat)+size <= |mem| && (offset as nat)+32 <= start
    requires |mem|%32 == 0
    ensures S.Store(mem,offset,word)[start..start+size] == mem[start..start+size]
  {
    C.Rounded(|mem|);
    assert S.Round32(|mem|) == |mem|;
    assert S.Round32((offset as nat)+32) <= |mem|;
    assert S.Expand(mem,(offset as nat)+32) == mem;
    forall i {:trigger S.Store(mem,offset,word)[start+i]} | 0 <= i < size
      ensures S.Store(mem,offset,word)[start+i] == mem[start+i]
    {}
  }
  lemma Built(mem: seq<Byte>, free: Word, kind: Word, offset: Word, length: Word, data: seq<Byte>)
    requires Fits(mem,free,offset,length,data)
    ensures S.Load(Construct(mem,free,kind,offset,length,data),free) == kind
    ensures S.Load(Construct(mem,free,kind,offset,length,data),free+32) == free+64
    ensures S.Load(Construct(mem,free,kind,offset,length,data),free+64) == length
    ensures S.Load(Construct(mem,free,kind,offset,length,data),64) == NextFree(free,length)
    ensures Construct(mem,free,kind,offset,length,data)[free+96..free+96+length] == data[offset..offset+length]
    ensures |Construct(mem,free,kind,offset,length,data)|%32 == 0
    ensures free+96+length <= |Construct(mem,free,kind,offset,length,data)| <= NextFree(free,length)+32
    ensures |Construct(mem,free,kind,offset,length,data)| < 0x10000000000000000
  {
    RecordFits(mem,free,kind,offset,length,data);
    var reservedRecord := S.Store(mem,64,free+64);
    var record := S.Store(reservedRecord,free,kind);
    R.StoredWord(reservedRecord,free,kind);
    P.Built(record,free+64,offset,length,data);
    var reserved := S.Store(record,64,NextFree(free,length));
    R.StoredFrame(record,64,NextFree(free,length),free);
    var header := S.Store(reserved,free+64,length);
    R.StoredFrame(reserved,free+64,length,free);
    var copied := C.Calldata(header,free+96,offset,length,data);
    P.CopyFrame(header,free+96,offset,length,data,free);
    R.StoredFrame(copied,free+96+length,0,free);
    var payload := P.Construct(record,free+64,offset,length,data);
    R.StoredFrame(payload,free+32,free+64,free);
    R.StoredFrame(payload,free+32,free+64,free+64);
    R.StoredFrame(payload,free+32,free+64,64);
    R.StoredWord(payload,free+32,free+64);
    StoreSuffix(payload,free+32,free+64,free+96,length);
  }
}
