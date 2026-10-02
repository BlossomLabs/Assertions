// SPDX-License-Identifier: MIT
// Private finite-resource footprint for the actual one-child OR memory image.
include "NonemptyMemory.dfy"
include "NonemptyRound.dfy"
include "../../../../foundations/v1/StoreExtent.dfy"
module AssertionsConstraintOrNonemptyBounds {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import B = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  import N = AssertionsConstraintOrNonemptyMemory
  import A = AssertionsConstraintOrNonemptyRound
  import X = SharedFoundationStoreExtent
  type Word = S.Word
  type Byte = S.Byte
  lemma {:isolate_assertions} Size(mem: seq<Byte>, free: Word, kind: Word, source: Word, length: Word, slot: Word)
    requires |mem|%32 == 0 && |mem| <= free+32 && 128 <= free && free%32 == 0
    requires 96 <= slot && slot+32 <= free && source+length <= free
    requires (free as nat)+128+S.Round32(length) < G.Modulus()
    ensures |N.Construct(mem,free,kind,source,length,slot)| == N.NextFree(free,length)+32
  {
    hide S.Store();
    hide B.Memory();
    hide S.Load();
    hide S.Round32();
    A.Aligned(0);
    A.Aligned(96);
    A.Aligned(free);
    A.Aligned(free+32);
    A.Aligned(free+64);
    A.Aligned(free+96);
    A.Aligned(free+128);
    A.Add(free+96,length);
    A.Add(free+128,length);
    B.RoundedMonotone(slot+32,free);
    B.Rounded(length);
    var m0 := S.Store(mem,64,free+64);
    var m1 := S.Store(m0,free,kind);
    var m2 := S.Store(m1,64,N.NextFree(free,length));
    var m3 := S.Store(m2,free+64,length);
    var m4 := B.Memory(m3,free+96,source,length);
    var m5 := S.Store(m4,free+96+length,0);
    var m6 := S.Store(m5,free+32,free+64);
    X.Length(mem,64,free+64);
    X.Aligned(mem,64,free+64);
    assert |m0| <= free+32;
    X.Length(m0,free,kind);
    X.Aligned(m0,free,kind);
    assert |m1| == free+32;
    X.Length(m1,64,N.NextFree(free,length));
    X.Aligned(m1,64,N.NextFree(free,length));
    assert |m2| == free+32;
    X.Length(m2,free+64,length);
    X.Aligned(m2,free+64,length);
    assert |m3| == free+96;
    B.MemorySize(m3,free+96,source,length);
    assert S.Round32(free+96+length) == free+96+S.Round32(length);
    assert |m4| == N.NextFree(free,length);
    X.Length(m4,free+96+length,0);
    X.Aligned(m4,free+96+length,0);
    assert S.Round32(free+128+length) == free+128+S.Round32(length);
    assert |m5| == N.NextFree(free,length)+32;
    X.Length(m5,free+32,free+64);
    X.Aligned(m5,free+32,free+64);
    assert |m6| == |m5|;
    X.Length(m6,slot,free);
    X.Aligned(m6,slot,free);
  }
}
