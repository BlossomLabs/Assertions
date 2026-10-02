// SPDX-License-Identifier: MIT
// Discharge the physical leaf representation premises from the decoder layout.
include "DecoderMemory.dfy"
include "../Spec.dfy"
module AssertionsConstraintDecoderFacts {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import P = AssertionsConstraintDecoderMemory
  import A = AssertionsRawResolveMemory
  import R = BytecodeScanRepresentation
  import C = BytecodeCopyMemory
  import L = AssertionsConstraintSpec
  type Word = S.Word
  type Byte = S.Byte
  lemma SliceWord(mem: seq<Byte>, position: Word, data: seq<Byte>, offset: Word)
    requires (position as nat)+32 <= |mem| && (offset as nat)+32 <= |data|
    requires mem[position..position+32] == data[offset..offset+32]
    ensures S.Load(mem,position) == S.DataWord(data,offset)
  {
    R.WindowFits(data,offset,32);
    assert G.Grow(mem,(position as nat)+32) == mem;
  }
  lemma {:isolate_assertions} LeafMemory(mem: seq<Byte>, free: Word, kind: Word, offset: Word, length: Word, data: seq<Byte>)
    requires P.Fits(mem,free,offset,length,data)
    ensures L.Memory(P.Construct(mem,free,kind,offset,length,data),free,free+64,
                     P.NextFree(free,length),kind,length,S.DataWord(data,offset),S.DataWord(data,offset+32))
  {
    P.Built(mem,free,kind,offset,length,data);
    var output := P.Construct(mem,free,kind,offset,length,data);
    if length in {32,64} {
      assert output[free+96..free+128] == data[offset..offset+32];
      SliceWord(output,free+96,data,offset);
      if length == 64 {
        assert output[free+128..free+160] == data[offset+32..offset+64];
        SliceWord(output,free+128,data,offset+32);
      }
    }
  }
  lemma OldWord(mem: seq<Byte>, free: Word, kind: Word, offset: Word, length: Word, data: seq<Byte>, other: Word)
    requires P.Fits(mem,free,offset,length,data)
    requires 96 <= other && (other as nat)+32 <= free && (other as nat)+32 <= |mem|
    ensures S.Load(P.Construct(mem,free,kind,offset,length,data),other) == S.Load(mem,other)
  {
    P.RecordFits(mem,free,kind,offset,length,data);
    var first := S.Store(mem,64,free+64);
    R.StoredFrame(mem,64,free+64,other);
    var record := S.Store(first,free,kind);
    R.StoredFrame(first,free,kind,other);
    var reserved := S.Store(record,64,P.NextFree(free,length));
    R.StoredFrame(record,64,P.NextFree(free,length),other);
    var header := S.Store(reserved,free+64,length);
    R.StoredFrame(reserved,free+64,length,other);
    var copied := C.Calldata(header,free+96,offset,length,data);
    A.CopyFrame(header,free+96,offset,length,data,other);
    R.StoredFrame(copied,free+96+length,0,other);
    var payload := A.Construct(record,free+64,offset,length,data);
    R.StoredFrame(payload,free+32,free+64,other);
  }
  lemma OldBytes(mem: seq<Byte>, free: Word, kind: Word, offset: Word, length: Word, data: seq<Byte>, start: Word, size: nat)
    requires P.Fits(mem,free,offset,length,data)
    requires 96 <= start && (start as nat)+size <= free && (start as nat)+size <= |mem|
    ensures P.Construct(mem,free,kind,offset,length,data)[start..start+size] == mem[start..start+size]
  {
    P.RecordFits(mem,free,kind,offset,length,data);
    var first := S.Store(mem,64,free+64);
    P.StoreSuffix(mem,64,free+64,start,size);
    R.StoredWord(mem,64,free+64);
    var record := S.Store(first,free,kind);
    A.StorePrefix(first,free,kind,start,size);
    R.StoredWord(first,free,kind);
    var reserved := S.Store(record,64,P.NextFree(free,length));
    P.StoreSuffix(record,64,P.NextFree(free,length),start,size);
    var header := S.Store(reserved,free+64,length);
    A.StorePrefix(reserved,free+64,length,start,size);
    var copied := C.Calldata(header,free+96,offset,length,data);
    C.Frame(header,free+96,S.Window(data,offset,length));
    C.Size(header,free+96,S.Window(data,offset,length));
    forall i {:trigger copied[start+i]} | 0 <= i < size
      ensures copied[start+i] == header[start+i]
    {}
    assert copied[start..start+size] == header[start..start+size];
    A.StorePrefix(copied,free+96+length,0,start,size);
    var payload := A.Construct(record,free+64,offset,length,data);
    A.StorePrefix(payload,free+32,free+64,start,size);
  }
}
