// SPDX-License-Identifier: MIT
// Exact original copy and zero scratch representation after physical allocation.
include "../copy-allocation/Memory.dfy"
include "../memory/Memory.dfy"
module BytecodeSortInitialMemorySizeCandidate {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import D = BytecodeSortCopyAllocationMemory
  import M = BytecodeWordSortMemory
  import O = BytecodeWordSortOriginalSpec
  type Byte = S.Byte
  type Word = S.Word
  function Originals(n: nat): seq<nat> { seq(n,i requires 0 <= i < n => i) }
  function Scratch(n: nat): seq<nat> { seq(n,i requires 0 <= i < n => n) }
  function Header(n: Word, offset: Word, data: seq<Byte>): seq<Byte>
    requires D.Fits(n,offset,data)
  { S.Store(S.Store(D.Tail(n,offset,data),160+n*32,n*32),64,192+2*n*32) }
  function Initialized(n: Word, offset: Word, data: seq<Byte>): seq<Byte>
    requires D.Fits(n,offset,data)
  { C.Calldata(Header(n,offset,data),192+n*32,|data|,n*32,data) }
  lemma ZeroByte(width: nat, index: nat)
    requires index < width
    ensures G.Encode(0,width)[index] == 0
    decreases width
  {
    if index < width-1 { ZeroByte(width-1,index); }
  }
  lemma HeadByte(n: Word, index: nat)
    requires n < 0x800000000000000 && index < 160
    ensures D.Head(n)[index] == (if 64 <= index < 96 then G.Encode(160+n*32,32)[index-64] else if 128 <= index then G.Encode(n*32,32)[index-128] else 0)
  {
    D.HeadFrame(n);
    assert S.Expand([],96) == seq(96,i => 0);
    var first := S.Store([],64,128);
    var free := S.Store(first,64,160+n*32);
    assert |first| == 96 && |free| == 96;
    var expanded := S.Expand(free,160);
    assert expanded == free+seq(64,i => 0);
    assert D.Head(n) == expanded[..128]+G.Encode(n*32,32);
    if index < 64 { assert free[index] == 0; }
    else if index < 96 { assert free[index] == G.Encode(160+n*32,32)[index-64]; }
    else if index < 128 { assert expanded[index] == 0; }
  }
  lemma HeaderFrame(n: Word, offset: Word, data: seq<Byte>)
    requires D.Fits(n,offset,data)
    ensures |Header(n,offset,data)| == 192+n*32
    ensures Header(n,offset,data)[64..96] == G.Encode(192+2*n*32,32)
    ensures Header(n,offset,data)[128..160] == G.Encode(n*32,32)
    ensures Header(n,offset,data)[160..160+n*32] == data[offset..offset+n*32]
    ensures Header(n,offset,data)[160+n*32..] == G.Encode(n*32,32)
    ensures forall i: nat :: i < 192+n*32 && !(64 <= i < 96) && !(128 <= i) ==> Header(n,offset,data)[i] == 0
  {
    D.TailFrame(n,offset,data);
    D.CopiedFrame(n,offset,data);
    assert S.Expand(D.Tail(n,offset,data),192+n*32) == D.Tail(n,offset,data);
    var scratch := S.Store(D.Tail(n,offset,data),160+n*32,n*32);
    assert scratch == D.Copied(n,offset,data)+G.Encode(n*32,32);
    assert S.Expand(scratch,96) == scratch;
    assert Header(n,offset,data) == scratch[..64]+G.Encode(192+2*n*32,32)+scratch[96..];
    assert Header(n,offset,data)[160..160+n*32] == scratch[160..160+n*32];
    assert scratch[160..160+n*32] == data[offset..offset+n*32];
    forall j: nat | j < 32
      ensures D.Copied(n,offset,data)[128+j] == G.Encode(n*32,32)[j]
    { HeadByte(n,128+j); }
    assert D.Copied(n,offset,data)[128..160] == G.Encode(n*32,32);
    forall i: nat | i < 128 && !(64 <= i < 96)
      ensures Header(n,offset,data)[i] == 0
    { HeadByte(n,i); }
  }
  lemma RoundedExtent(count: nat)
    ensures S.Round32(192+count*64) == 192+count*64
  {}
  lemma InitializedSize(n: Word, offset: Word, data: seq<Byte>)
    requires D.Fits(n,offset,data)
    ensures |Initialized(n,offset,data)| == M.Extent(n)
  {
    HeaderFrame(n,offset,data);
    var header := Header(n,offset,data);
    var zeroes := S.Window(data,|data|,n*32);
    assert |zeroes| == n*32;
    RoundedExtent(n);
    C.Size(header,192+n*32,zeroes);
    assert |C.Write(header,192+n*32,zeroes)| == M.Extent(n);
  }
  lemma Connection(n: Word, offset: Word, data: seq<Byte>)
    requires D.Fits(n,offset,data)
    ensures M.Admitted(n,Originals(n),Scratch(n),offset,data)
    ensures Initialized(n,offset,data) == M.Heap(n,Originals(n),Scratch(n),offset,data)
  {
    HeaderFrame(n,offset,data);
    var header := Header(n,offset,data);
    var initial := Initialized(n,offset,data);
    var ids := Originals(n);
    assert M.Base(n,false) == 128 && M.Base(n,true) == 160+n*32;
    assert O.Bounds(n,ids);
    assert M.Admitted(n,ids,Scratch(n),offset,data);
    O.OriginalBytes(data,offset,n,ids);
    C.Size(header,192+n*32,S.Window(data,|data|,n*32));
    C.Frame(header,192+n*32,S.Window(data,|data|,n*32));
    InitializedSize(n,offset,data);
    forall i: nat {:trigger initial[i]} | i < M.Extent(n)
      ensures initial[i] == M.Heap(n,ids,Scratch(n),offset,data)[i]
    {
      if i < 192+n*32 {
        assert initial[i] == header[i];
        if 160 <= i < 160+n*32 {
          M.SlotByte(n,ids,Scratch(n),offset,data,false,(i-160)/32,(i-160)%32);
          assert ids[(i-160)/32] == (i-160)/32;
          assert header[i] == data[offset+i-160];
          assert O.Payload(data,offset,n,ids)[i-160] == data[offset+i-160];
          assert O.Encoded(data,offset,n,ids)[i-160] == header[i];
          assert M.Cell(n,ids[(i-160)/32],offset,data) == O.Values(data,offset,n)[(i-160)/32];
          assert M.Heap(n,ids,Scratch(n),offset,data)[i] == O.Encoded(data,offset,n,ids)[i-160];
        } else if 64 <= i < 96 {
          assert initial[i] == G.Encode(M.Extent(n),32)[i-64];
          assert M.Heap(n,ids,Scratch(n),offset,data)[i] == G.Encode(M.Extent(n),32)[i-64];
        } else if 128 <= i < 160 {
          assert initial[i] == G.Encode(n*32,32)[i-128];
          assert M.Heap(n,ids,Scratch(n),offset,data)[i] == G.Encode(n*32,32)[i-128];
        } else if 160+n*32 <= i {
          assert M.Base(n,true) <= i < M.Base(n,true)+32;
          assert initial[i] == G.Encode(n*32,32)[i-160-n*32];
          reveal M.Heap();
          assert M.Heap(n,ids,Scratch(n),offset,data)[i] == G.Encode(n*32,32)[i-160-n*32];
        } else {
          assert i < 128 && !(64 <= i < 96);
          assert initial[i] == 0;
          reveal M.Heap();
          assert M.Heap(n,ids,Scratch(n),offset,data)[i] == 0;
        }
      } else {
        C.CalldataValue(header,192+n*32,|data|,n*32,data,i-(192+n*32));
        M.SlotByte(n,ids,Scratch(n),offset,data,true,(i-192-n*32)/32,(i-192-n*32)%32);
        assert initial[i] == 0;
        ZeroByte(32,(i-192-n*32)%32);
        assert M.Cell(n,Scratch(n)[(i-192-n*32)/32],offset,data) == 0;
        assert M.Heap(n,ids,Scratch(n),offset,data)[i] == G.Encode(0,32)[(i-192-n*32)%32];
      }
    }
  }
}
