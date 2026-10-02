// SPDX-License-Identifier: MIT
// Initial source-byte copy and trailing zero store, before scratch allocation.
include "../../copy/Machine.dfy"
include "../../scans/Representation.dfy"
module BytecodeSortCopyAllocationMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeCopyMemory
  import I = BytecodeCopyMachine
  import R = BytecodeScanRepresentation
  type Byte = S.Byte
  type Word = S.Word
  predicate Fits(n: Word, offset: Word, data: seq<Byte>) {
    n < 0x800000000000000 && |data| < 0x10000000000000000 && offset+n*32 <= |data|
  }
  function Head(n: Word): seq<Byte>
    requires n < 0x800000000000000
  { S.Store(S.Store(S.Store([],64,128),64,160+n*32),128,n*32) }
  function Copied(n: Word, offset: Word, data: seq<Byte>): seq<Byte>
    requires Fits(n,offset,data)
  { M.Calldata(Head(n),160,offset,n*32,data) }
  function Tail(n: Word, offset: Word, data: seq<Byte>): seq<Byte>
    requires Fits(n,offset,data)
  { S.Store(Copied(n,offset,data),160+n*32,0) }
  lemma HeadFrame(n: Word)
    requires n < 0x800000000000000
    ensures |Head(n)| == 160
    ensures S.Load(Head(n),64) == 160+n*32 && S.Load(Head(n),128) == n*32
  {
    R.StoredWord([],64,128);
    R.StoredWord(S.Store([],64,128),64,160+n*32);
    R.StoredWord(S.Store(S.Store([],64,128),64,160+n*32),128,n*32);
    R.StoredFrame(S.Store(S.Store([],64,128),64,160+n*32),128,n*32,64);
  }
  lemma CopiedFrame(n: Word, offset: Word, data: seq<Byte>)
    requires Fits(n,offset,data)
    ensures |Copied(n,offset,data)| == 160+n*32
    ensures Copied(n,offset,data)[..160] == Head(n)
    ensures Copied(n,offset,data)[160..] == data[offset..offset+n*32]
    ensures S.Load(Copied(n,offset,data),64) == 160+n*32
  {
    HeadFrame(n);
    M.Size(Head(n),160,S.Window(data,offset,n*32));
    assert S.Round32(160+n*32) == 160+n*32;
    M.Frame(Head(n),160,S.Window(data,offset,n*32));
    M.Span(Head(n),160,S.Window(data,offset,n*32));
    assert S.Window(data,offset,n*32) == data[offset..offset+n*32];
    assert Copied(n,offset,data)[..160] == Head(n);
    assert G.Grow(Copied(n,offset,data),96) == Copied(n,offset,data);
    assert G.Grow(Head(n),96) == Head(n);
    assert Copied(n,offset,data)[64..96] == Head(n)[64..96];
    G.LoadProjection(Copied(n,offset,data),64);
    G.LoadProjection(Head(n),64);
  }
  lemma TailFrame(n: Word, offset: Word, data: seq<Byte>)
    requires Fits(n,offset,data)
    ensures |Tail(n,offset,data)| == 192+n*32
    ensures Tail(n,offset,data)[..160+n*32] == Copied(n,offset,data)
    ensures Tail(n,offset,data)[160+n*32..] == G.Encode(0,32)
    ensures S.Load(Tail(n,offset,data),64) == 160+n*32
    ensures S.Load(Tail(n,offset,data),128) == n*32
  {
    CopiedFrame(n,offset,data);
    R.StoredWord(Copied(n,offset,data),160+n*32,0);
    R.StoredFrame(Copied(n,offset,data),160+n*32,0,64);
    R.StoredFrame(Copied(n,offset,data),160+n*32,0,128);
    HeadFrame(n);
    assert G.Grow(Copied(n,offset,data),160) == Copied(n,offset,data);
    assert G.Grow(Head(n),160) == Head(n);
    assert Copied(n,offset,data)[128..160] == Head(n)[128..160];
    G.LoadProjection(Copied(n,offset,data),128);
    G.LoadProjection(Head(n),128);
  }
  lemma ActualCopy(code: seq<Byte>, n: Word, offset: Word, data: seq<Byte>, prefix: seq<Word>, value: Word)
    requires Fits(n,offset,data) && |prefix| <= 1021
    requires |code| > 3510 && code[3510] == 0x37
    ensures I.Step(code,{},S.Running(3510,prefix+[n*32,offset,160],Head(n)),value,data) ==
            S.Running(3511,prefix,Copied(n,offset,data))
  {
    HeadFrame(n);
    assert S.Round32(160+n*32) == 160+n*32;
    I.CalldataStep(code,3510,prefix,Head(n),160,offset,n*32,value,data);
  }
}
