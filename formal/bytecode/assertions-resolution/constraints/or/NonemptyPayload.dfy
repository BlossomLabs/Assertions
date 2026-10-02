// SPDX-License-Identifier: MIT
// Original wire reference bytes survive the actual child decoder heap image.
include "NonemptyBounds.dfy"
module AssertionsConstraintOrNonemptyPayload {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import B = BytecodeCopyMemory
  import N = AssertionsConstraintOrNonemptyMemory
  import U = AssertionsConstraintOrNonemptyBounds
  import F = SharedFoundationMemoryFramesV3
  import X = SharedFoundationStoreExtent
  type Word = S.Word
  type Byte = S.Byte
  lemma {:isolate_assertions} Payload(mem: seq<Byte>, free: Word, kind: Word, source: Word, length: Word, slot: Word)
    requires |mem|%32 == 0 && |mem| <= free+32 && 128 <= free && free%32 == 0
    requires 96 <= slot && slot+32 <= free
    requires 96 <= source && source+length <= free && source+length <= |mem|
    requires (free as nat)+128+S.Round32(length) < G.Modulus()
    ensures N.Construct(mem,free,kind,source,length,slot)[free+96..free+96+length] == mem[source..source+length]
  {
    hide S.Store(); hide B.Memory(); hide S.Load();
    B.Rounded(length);
    var m0 := S.Store(mem,64,free+64);
    var m1 := S.Store(m0,free,kind);
    var m2 := S.Store(m1,64,N.NextFree(free,length));
    var m3 := S.Store(m2,free+64,length);
    var m4 := B.Memory(m3,free+96,source,length);
    var m5 := S.Store(m4,free+96+length,0);
    var m6 := S.Store(m5,free+32,free+64);
    var result := S.Store(m6,slot,free);
    F.StoreSpanFrame(mem,64,free+64,source,length);
    X.Length(mem,64,free+64);
    F.StoreSpanFrame(m0,free,kind,source,length);
    X.Length(m0,free,kind);
    F.StoreSpanFrame(m1,64,N.NextFree(free,length),source,length);
    X.Length(m1,64,N.NextFree(free,length));
    F.StoreSpanFrame(m2,free+64,length,source,length);
    X.Length(m2,free+64,length);
    B.MemorySize(m3,free+96,source,length);
    var left := m4[free+96..free+96+length];
    var right := m3[source..source+length];
    forall i {:trigger left[i]} | 0 <= i < length
      ensures left[i] == right[i]
    {
      B.MemoryValue(m3,free+96,source,length,i);
      assert left[i] == m4[free+96+i];
      assert right[i] == m3[source+i];
    }
    assert left == right;
    F.StoreSpanFrame(m4,free+96+length,0,free+96,length);
    X.Length(m4,free+96+length,0);
    F.StoreSpanFrame(m5,free+32,free+64,free+96,length);
    X.Length(m5,free+32,free+64);
    F.StoreSpanFrame(m6,slot,free,free+96,length);
  }
}
