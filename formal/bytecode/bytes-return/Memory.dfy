// SPDX-License-Identifier: MIT
// Physical dynamic ABI serializer memory, with fitting footprints explicit.
include "../iota/Output.dfy"
include "../copy/Execution.dfy"
module BytecodeAlignedBytesReturnMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import O = BytecodeIotaOutput
  import C = BytecodeCopyMemory
  import M = BytecodeCopyMachine
  type Byte = S.Byte
  type Word = S.Word
  function Heap(n: nat, payload: seq<Byte>): seq<Byte>
    requires n < 0x800000000000000 && |payload| == n*32
  {
    seq(64,j => 0)+G.Encode(O.Extent(n),32)+seq(32,j => 0)+G.Encode(n*32,32)+payload
  }
  function Bytes(n: nat, payload: seq<Byte>): seq<Byte>
    requires n < 0x800000000000000 && |payload| == n*32
  { G.Encode(32,32)+G.Encode(n*32,32)+payload }
  function Stage(n: nat, payload: seq<Byte>, k: nat): seq<Byte>
    requires n < 0x800000000000000 && |payload| == n*32 && k <= 4
  {
    Heap(n,payload)+(if k >= 1 then G.Encode(32,32) else [])+
    (if k >= 2 then G.Encode(n*32,32) else [])+
    (if k >= 3 then payload else [])+
    (if k >= 4 then seq(32,j => 0) else [])
  }
  lemma Sizes(n: nat, payload: seq<Byte>, k: nat)
    requires n < 0x800000000000000 && |payload| == n*32 && k <= 4
    ensures |payload| == n*32 && |Bytes(n,payload)| == 64+n*32
    ensures |Stage(n,payload,k)| == O.Extent(n)+(if k >= 1 then 32 else 0)+(if k >= 2 then 32 else 0)+(if k >= 3 then n*32 else 0)+(if k >= 4 then 32 else 0)
    ensures S.Round32(|Stage(n,payload,k)|) == |Stage(n,payload,k)|
  {}
  lemma Headers(n: nat, payload: seq<Byte>, k: nat)
    requires n < 0x800000000000000 && |payload| == n*32 && k <= 4
    ensures S.Load(Stage(n,payload,k),64) == O.Extent(n)
    ensures S.Load(Stage(n,payload,k),128) == n*32
    ensures Stage(n,payload,k)[..O.Extent(n)] == Heap(n,payload)
  {
    assert Heap(n,payload)[64..96] == G.Encode(O.Extent(n),32);
    assert Heap(n,payload)[128..160] == G.Encode(n*32,32);
    G.RoundTrip(O.Extent(n),32); G.RoundTrip(n*32,32);
    assert Stage(n,payload,k)[64..96] == Heap(n,payload)[64..96];
    assert Stage(n,payload,k)[128..160] == Heap(n,payload)[128..160];
  }
  lemma FirstStore(n: nat, payload: seq<Byte>)
    requires n < 0x800000000000000 && |payload| == n*32
    ensures S.Store(Stage(n,payload,0),O.Extent(n),32) == Stage(n,payload,1)
  {
    Sizes(n,payload,0); Sizes(n,payload,1);
    assert S.Expand(Stage(n,payload,0),O.Extent(n)+32) == Stage(n,payload,0)+seq(32,j => 0);
  }
  lemma SecondStore(n: nat, payload: seq<Byte>)
    requires n < 0x800000000000000 && |payload| == n*32
    ensures S.Store(Stage(n,payload,1),O.Extent(n)+32,n*32) == Stage(n,payload,2)
  {
    Sizes(n,payload,1); Sizes(n,payload,2);
    assert S.Expand(Stage(n,payload,1),O.Extent(n)+64) == Stage(n,payload,1)+seq(32,j => 0);
  }
  lemma Copy(n: nat, payload: seq<Byte>)
    requires n < 0x800000000000000 && |payload| == n*32
    ensures C.Memory(Stage(n,payload,2),O.Extent(n)+64,160,n*32) == Stage(n,payload,3)
  {
    Sizes(n,payload,2); Sizes(n,payload,3);
    if n == 0 { C.ZeroLength(Stage(n,payload,2),O.Extent(n)+64,160,[]); }
    else {
      var after := C.Memory(Stage(n,payload,2),O.Extent(n)+64,160,n*32);
      C.MemorySize(Stage(n,payload,2),O.Extent(n)+64,160,n*32);
      assert |after| == |Stage(n,payload,3)|;
      forall j: nat {:trigger after[j]} | j < |after|
        ensures after[j] == Stage(n,payload,3)[j]
      {
        if j < O.Extent(n)+64 { C.MemoryFrame(Stage(n,payload,2),O.Extent(n)+64,160,n*32,j); }
        else {
          C.MemoryValue(Stage(n,payload,2),O.Extent(n)+64,160,n*32,j-(O.Extent(n)+64));
          assert Stage(n,payload,2)[160+j-(O.Extent(n)+64)] == payload[j-(O.Extent(n)+64)];
        }
      }
    }
  }
  lemma FinalStore(n: nat, payload: seq<Byte>)
    requires n < 0x800000000000000 && |payload| == n*32
    ensures S.Store(Stage(n,payload,3),O.Extent(n)+64+n*32,0) == Stage(n,payload,4)
  {
    Sizes(n,payload,3); Sizes(n,payload,4);
    O.ZeroEncoding(32);
    assert S.Expand(Stage(n,payload,3),O.Extent(n)+96+n*32) == Stage(n,payload,3)+seq(32,j => 0);
  }
  lemma ActualCopy(code: seq<Byte>, n: nat, payload: seq<Byte>, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires |code| > 20967 && code[20967] == 0x5e
    requires n < 0x800000000000000 && |payload| == n*32 && |prefix| <= 1021
    ensures M.Step(code,{},S.Running(20967,prefix+[n*32,160,O.Extent(n)+64],Stage(n,payload,2)),value,data) == S.Running(20968,prefix,Stage(n,payload,3))
  {
    Sizes(n,payload,2); Sizes(n,payload,3); Copy(n,payload);
    M.MemoryStep(code,20967,prefix,Stage(n,payload,2),O.Extent(n)+64,160,n*32,value,data);
  }
  lemma Return(code: seq<Byte>, n: nat, payload: seq<Byte>, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires |code| > 498 && code[498] == 0xf3
    requires n < 0x800000000000000 && |payload| == n*32 && |prefix| <= 1022
    ensures M.Step(code,{},S.Running(498,prefix+[64+n*32,O.Extent(n)],Stage(n,payload,4)),value,data) == S.Returned(Bytes(n,payload))
  {
    Sizes(n,payload,4);
    M.Delegate(code,{},S.Running(498,prefix+[64+n*32,O.Extent(n)],Stage(n,payload,4)),value,data);
    reveal S.Step();
    assert G.Grow(Stage(n,payload,4),O.Extent(n)+64+n*32) == Stage(n,payload,4);
    assert Stage(n,payload,4)[O.Extent(n)..O.Extent(n)+64+n*32] == Bytes(n,payload);
  }
}
