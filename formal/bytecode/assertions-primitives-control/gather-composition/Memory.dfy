// SPDX-License-Identifier: MIT
// Prefix preservation and allocation facts for one physical gather iteration.
include "../Preparation.dfy"
include "../../assertions-resolution/raw/Memory.dfy"
module AssertionsGatherLoopMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import P = AssertionsPrimitivePreparation
  import B = AssertionsRawResolveMemory
  import C = BytecodeCopyMemory
  type Byte = S.Byte
  type Word = S.Word
  lemma StoredRegion(mem: seq<Byte>, offset: Word, word: Word, start: Word, size: nat)
    requires start+size <= |mem| && (offset+32 <= start || start+size <= offset)
    ensures S.Store(mem,offset,word)[start..start+size] == mem[start..start+size]
  {
    var expanded := S.Expand(mem,offset+32);
    assert expanded[..|mem|] == mem;
    var stored := S.Store(mem,offset,word);
    forall i {:trigger stored[start+i]} | 0 <= i < size
      ensures stored[start+i] == mem[start+i]
    {}
    var left := stored[start..start+size];
    var right := mem[start..start+size];
    forall i {:trigger left[i]} | 0 <= i < |left|
      ensures left[i] == right[i]
    { assert stored[start+i] == mem[start+i]; }
    assert left == right;
  }
  lemma Prepared(mem: seq<Byte>, free: Word)
    requires |mem|%32 == 0 && 96 <= |mem| <= free+32 && free%32 == 0 && 128 <= free && free+64 < 0x10000000000000000
    ensures S.Load(P.EmptyAssertion(mem,free),64) == free+32
    ensures S.Load(P.EmptyAssertion(mem,free),free) == 0
    ensures |P.EmptyAssertion(mem,free)|%32 == 0 && 96 <= |P.EmptyAssertion(mem,free)| <= free+32
  {
    P.AssertionObject(mem,free);
    assert S.Round32(free+32) == free+32;
  }
  lemma PreparedFrame(mem: seq<Byte>, free: Word, other: Word)
    requires |mem|%32 == 0 && 128 <= other && other+32 <= free && other+32 <= |mem| && free+32 < G.Modulus()
    ensures S.Load(P.EmptyAssertion(mem,free),other) == S.Load(mem,other)
  {
    R.StoredFrame(mem,64,free+32,other);
    R.StoredFrame(S.Store(mem,64,free+32),free,0,other);
  }
  lemma ConstructedFrame(mem: seq<Byte>, free: Word, offset: Word, length: Word, data: seq<Byte>, other: Word)
    requires B.Fits(mem,free,offset,length,data) && 128 <= other && other+32 <= |mem| && other+32 <= free
    ensures S.Load(B.Construct(mem,free,offset,length,data),other) == S.Load(mem,other)
  {
    var reserved := S.Store(mem,64,free+32+S.Round32(length));
    R.StoredFrame(mem,64,free+32+S.Round32(length),other);
    var header := S.Store(reserved,free,length);
    R.StoredFrame(reserved,free,length,other);
    var copied := C.Calldata(header,free+32,offset,length,data);
    B.CopyFrame(header,free+32,offset,length,data,other);
    R.StoredFrame(copied,free+32+length,0,other);
  }
  lemma IterationFrame(mem: seq<Byte>, free: Word, offset: Word, length: Word, data: seq<Byte>, other: Word)
    requires |mem|%32 == 0 && 96 <= |mem| <= free+32 && free%32 == 0 && 128 <= free && free+64 < 0x10000000000000000
    requires B.Fits(P.EmptyAssertion(mem,free),free+32,offset,length,data)
    requires 128 <= other && other+32 <= free && other+32 <= |mem|
    ensures S.Load(B.Construct(P.EmptyAssertion(mem,free),free+32,offset,length,data),other) == S.Load(mem,other)
  {
    Prepared(mem,free); PreparedFrame(mem,free,other);
    ConstructedFrame(P.EmptyAssertion(mem,free),free+32,offset,length,data,other);
  }
  lemma CopiedRegion(mem: seq<Byte>, destination: Word, source: Word, length: Word, data: seq<Byte>, start: Word, size: nat)
    requires start+size <= |mem| && start+size <= destination
    ensures C.Calldata(mem,destination,source,length,data)[start..start+size] == mem[start..start+size]
  {
    C.Frame(mem,destination,S.Window(data,source,length));
    C.Size(mem,destination,S.Window(data,source,length));
    var copied := C.Calldata(mem,destination,source,length,data);
    var left := copied[start..start+size]; var right := mem[start..start+size];
    forall i {:trigger left[i]} | 0 <= i < |left|
      ensures left[i] == right[i]
    {}
    assert left == right;
  }
  lemma IterationRegion(mem: seq<Byte>, free: Word, offset: Word, length: Word, data: seq<Byte>, start: Word, size: nat)
    requires |mem|%32 == 0 && 96 <= |mem| <= free+32 && free%32 == 0 && 128 <= free && free+64 < 0x10000000000000000
    requires B.Fits(P.EmptyAssertion(mem,free),free+32,offset,length,data)
    requires 128 <= start && start+size <= free && start+size <= |mem|
    ensures B.Construct(P.EmptyAssertion(mem,free),free+32,offset,length,data)[start..start+size] == mem[start..start+size]
  {
    var first := S.Store(mem,64,free+32);
    StoredRegion(mem,64,free+32,start,size);
    var prepared := P.EmptyAssertion(mem,free);
    StoredRegion(first,free,0,start,size);
    var reserved := S.Store(prepared,64,free+64+S.Round32(length));
    StoredRegion(prepared,64,free+64+S.Round32(length),start,size);
    var header := S.Store(reserved,free+32,length);
    StoredRegion(reserved,free+32,length,start,size);
    var copied := C.Calldata(header,free+64,offset,length,data);
    CopiedRegion(header,free+64,offset,length,data,start,size);
    StoredRegion(copied,free+64+length,0,start,size);
  }

}
