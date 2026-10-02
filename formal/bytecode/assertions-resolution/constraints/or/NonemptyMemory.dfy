// SPDX-License-Identifier: MIT
// Private constructive heap image for one in-memory OR child decoder iteration.
include "../../../../foundations/v3/MemoryFrames.dfy"
include "../../../copy/Memory.dfy"
include "../../../scans/Representation.dfy"
module AssertionsConstraintOrNonemptyMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import B = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  import F = SharedFoundationMemoryFramesV3
  type Word = S.Word
  type Byte = S.Byte
  function NextFree(free: Word, length: Word): Word
    requires (free as nat)+96+S.Round32(length) < G.Modulus()
  { free+96+S.Round32(length) }
  function Construct(mem: seq<Byte>, free: Word, kind: Word, source: Word, length: Word, slot: Word): seq<Byte>
    requires (free as nat)+128+S.Round32(length) < G.Modulus()
  {
    var m0 := S.Store(mem,64,free+64);
    var m1 := S.Store(m0,free,kind);
    var m2 := S.Store(m1,64,NextFree(free,length));
    var m3 := S.Store(m2,free+64,length);
    var m4 := B.Memory(m3,free+96,source,length);
    var m5 := S.Store(m4,free+96+length,0);
    var m6 := S.Store(m5,free+32,free+64);
    S.Store(m6,slot,free)
  }
  lemma ByteFrame(mem: seq<Byte>, offset: Word, word: Word, i: nat)
    requires i < |mem| && (i < offset || offset+32 <= i)
    ensures i < |S.Store(mem,offset,word)| && S.Store(mem,offset,word)[i] == mem[i]
  { F.StoreByteFrame(mem,offset,word,i); }
  lemma SourceFrame(mem: seq<Byte>, free: Word, kind: Word, source: Word, length: Word, slot: Word, i: nat)
    requires (free as nat)+128+S.Round32(length) < G.Modulus()
    requires source+length <= free && i < |mem| && i < free
    requires i < 64 || 96 <= i
    requires i < slot || slot+32 <= i
    ensures Construct(mem,free,kind,source,length,slot)[i] == mem[i]
  {
    hide B.Memory();
    hide S.Store();
    hide S.Load();
    B.Rounded(length);
    var m0 := S.Store(mem,64,free+64);
    var m1 := S.Store(m0,free,kind);
    var m2 := S.Store(m1,64,NextFree(free,length));
    var m3 := S.Store(m2,free+64,length);
    var m4 := B.Memory(m3,free+96,source,length);
    var m5 := S.Store(m4,free+96+length,0);
    var m6 := S.Store(m5,free+32,free+64);
    ByteFrame(mem,64,free+64,i);
    ByteFrame(m0,free,kind,i);
    ByteFrame(m1,64,NextFree(free,length),i);
    ByteFrame(m2,free+64,length,i);
    B.MemorySize(m3,free+96,source,length);
    assert |m4| >= |m3| && i < |m4|;
    B.MemoryFrame(m3,free+96,source,length,i);
    ByteFrame(m4,free+96+length,0,i);
    ByteFrame(m5,free+32,free+64,i);
    ByteFrame(m6,slot,free,i);
  }
  lemma CopyWordFrame(mem: seq<Byte>, dst: Word, src: Word, length: Word, other: Word)
    requires other+32 <= |mem| && (other+32 <= dst || dst+length <= other)
    ensures S.Load(B.Memory(mem,dst,src,length),other) == S.Load(mem,other)
  { F.CopyWordFrame(mem,dst,src,length,other); }
  lemma {:isolate_assertions} Fields(mem: seq<Byte>, free: Word, kind: Word, source: Word, length: Word, slot: Word)
    requires |mem|%32 == 0 && 128 <= free && 96 <= slot && slot+32 <= free
    requires (free as nat)+128+S.Round32(length) < G.Modulus()
    ensures |Construct(mem,free,kind,source,length,slot)|%32 == 0
    ensures S.Load(Construct(mem,free,kind,source,length,slot),64) == NextFree(free,length)
    ensures S.Load(Construct(mem,free,kind,source,length,slot),slot) == free
    ensures S.Load(Construct(mem,free,kind,source,length,slot),free) == kind
    ensures S.Load(Construct(mem,free,kind,source,length,slot),free+32) == free+64
    ensures S.Load(Construct(mem,free,kind,source,length,slot),free+64) == length
  {
    hide B.Memory();
    hide S.Store();
    hide S.Load();
    B.Rounded(length);
    var m0 := S.Store(mem,64,free+64);
    var m1 := S.Store(m0,free,kind);
    var m2 := S.Store(m1,64,NextFree(free,length));
    var m3 := S.Store(m2,free+64,length);
    var m4 := B.Memory(m3,free+96,source,length);
    var m5 := S.Store(m4,free+96+length,0);
    var m6 := S.Store(m5,free+32,free+64);
    R.StoredWord(mem,64,free+64);
    R.StoredWord(m0,free,kind);
    R.StoredWord(m1,64,NextFree(free,length));
    R.StoredFrame(m1,64,NextFree(free,length),free);
    R.StoredWord(m2,free+64,length);
    R.StoredFrame(m2,free+64,length,free);
    R.StoredFrame(m2,free+64,length,64);
    B.MemorySize(m3,free+96,source,length);
    CopyWordFrame(m3,free+96,source,length,64);
    CopyWordFrame(m3,free+96,source,length,free);
    CopyWordFrame(m3,free+96,source,length,free+64);
    R.StoredWord(m4,free+96+length,0);
    R.StoredFrame(m4,free+96+length,0,64);
    R.StoredFrame(m4,free+96+length,0,free);
    R.StoredFrame(m4,free+96+length,0,free+64);
    R.StoredWord(m5,free+32,free+64);
    R.StoredFrame(m5,free+32,free+64,64);
    R.StoredFrame(m5,free+32,free+64,free);
    R.StoredFrame(m5,free+32,free+64,free+64);
    R.StoredWord(m6,slot,free);
    R.StoredFrame(m6,slot,free,64);
    R.StoredFrame(m6,slot,free,free);
    R.StoredFrame(m6,slot,free,free+32);
    R.StoredFrame(m6,slot,free,free+64);
  }
}
