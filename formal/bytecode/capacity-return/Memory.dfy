// SPDX-License-Identifier: MIT
// Physical dynamic ABI serializer memory, with fitting footprints explicit.
include "../iota/Output.dfy"
include "../copy/Execution.dfy"
module BytecodeCapacityBytesReturnMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import O = BytecodeIotaOutput
  import C = BytecodeCopyMemory
  import M = BytecodeCopyMachine
  type Byte = S.Byte
  type Word = S.Word
  function Heap(capacity: nat, n: nat, payload: seq<Byte>): seq<Byte>
    requires n <= capacity < 0x800000000000000 && |payload| == n*32
  {
    seq(64,j => 0)+G.Encode(O.Extent(capacity),32)+seq(32,j => 0)+G.Encode(n*32,32)+payload+seq((capacity-n)*32,j => 0)
  }
  function Bytes(capacity: nat, n: nat, payload: seq<Byte>): seq<Byte>
    requires n <= capacity < 0x800000000000000 && |payload| == n*32
  { G.Encode(32,32)+G.Encode(n*32,32)+payload }
  function Stage(capacity: nat, n: nat, payload: seq<Byte>, k: nat): seq<Byte>
    requires n <= capacity < 0x800000000000000 && |payload| == n*32 && k <= 4
  {
    Heap(capacity,n,payload)+(if k >= 1 then G.Encode(32,32) else [])+
    (if k >= 2 then G.Encode(n*32,32) else [])+
    (if k >= 3 then payload else [])+
    (if k >= 4 then seq(32,j => 0) else [])
  }
  lemma Sizes(capacity: nat, n: nat, payload: seq<Byte>, k: nat)
    requires n <= capacity < 0x800000000000000 && |payload| == n*32 && k <= 4
    ensures |payload| == n*32 && |Bytes(capacity,n,payload)| == 64+n*32
    ensures |Stage(capacity,n,payload,k)| == O.Extent(capacity)+(if k >= 1 then 32 else 0)+(if k >= 2 then 32 else 0)+(if k >= 3 then n*32 else 0)+(if k >= 4 then 32 else 0)
    ensures S.Round32(|Stage(capacity,n,payload,k)|) == |Stage(capacity,n,payload,k)|
  {}
  lemma Headers(capacity: nat, n: nat, payload: seq<Byte>, k: nat)
    requires n <= capacity < 0x800000000000000 && |payload| == n*32 && k <= 4
    ensures S.Load(Stage(capacity,n,payload,k),64) == O.Extent(capacity)
    ensures S.Load(Stage(capacity,n,payload,k),128) == n*32
    ensures Stage(capacity,n,payload,k)[..O.Extent(capacity)] == Heap(capacity,n,payload)
  {
    assert Heap(capacity,n,payload)[64..96] == G.Encode(O.Extent(capacity),32);
    assert Heap(capacity,n,payload)[128..160] == G.Encode(n*32,32);
    G.RoundTrip(O.Extent(capacity),32); G.RoundTrip(n*32,32);
    assert Stage(capacity,n,payload,k)[64..96] == Heap(capacity,n,payload)[64..96];
    assert Stage(capacity,n,payload,k)[128..160] == Heap(capacity,n,payload)[128..160];
  }
  lemma FirstStore(capacity: nat, n: nat, payload: seq<Byte>)
    requires n <= capacity < 0x800000000000000 && |payload| == n*32
    ensures S.Store(Stage(capacity,n,payload,0),O.Extent(capacity),32) == Stage(capacity,n,payload,1)
  {
    Sizes(capacity,n,payload,0); Sizes(capacity,n,payload,1);
    assert S.Expand(Stage(capacity,n,payload,0),O.Extent(capacity)+32) == Stage(capacity,n,payload,0)+seq(32,j => 0);
  }
  lemma SecondStore(capacity: nat, n: nat, payload: seq<Byte>)
    requires n <= capacity < 0x800000000000000 && |payload| == n*32
    ensures S.Store(Stage(capacity,n,payload,1),O.Extent(capacity)+32,n*32) == Stage(capacity,n,payload,2)
  {
    Sizes(capacity,n,payload,1); Sizes(capacity,n,payload,2);
    assert S.Expand(Stage(capacity,n,payload,1),O.Extent(capacity)+64) == Stage(capacity,n,payload,1)+seq(32,j => 0);
  }
  lemma Copy(capacity: nat, n: nat, payload: seq<Byte>)
    requires n <= capacity < 0x800000000000000 && |payload| == n*32
    ensures C.Memory(Stage(capacity,n,payload,2),O.Extent(capacity)+64,160,n*32) == Stage(capacity,n,payload,3)
  {
    Sizes(capacity,n,payload,2); Sizes(capacity,n,payload,3);
    if n == 0 { C.ZeroLength(Stage(capacity,n,payload,2),O.Extent(capacity)+64,160,[]); }
    else {
      var after := C.Memory(Stage(capacity,n,payload,2),O.Extent(capacity)+64,160,n*32);
      C.MemorySize(Stage(capacity,n,payload,2),O.Extent(capacity)+64,160,n*32);
      assert |after| == |Stage(capacity,n,payload,3)|;
      forall j: nat {:trigger after[j]} | j < |after|
        ensures after[j] == Stage(capacity,n,payload,3)[j]
      {
        if j < O.Extent(capacity)+64 { C.MemoryFrame(Stage(capacity,n,payload,2),O.Extent(capacity)+64,160,n*32,j); }
        else {
          C.MemoryValue(Stage(capacity,n,payload,2),O.Extent(capacity)+64,160,n*32,j-(O.Extent(capacity)+64));
          assert Stage(capacity,n,payload,2)[160+j-(O.Extent(capacity)+64)] == payload[j-(O.Extent(capacity)+64)];
        }
      }
    }
  }
  lemma FinalStore(capacity: nat, n: nat, payload: seq<Byte>)
    requires n <= capacity < 0x800000000000000 && |payload| == n*32
    ensures S.Store(Stage(capacity,n,payload,3),O.Extent(capacity)+64+n*32,0) == Stage(capacity,n,payload,4)
  {
    Sizes(capacity,n,payload,3); Sizes(capacity,n,payload,4);
    O.ZeroEncoding(32);
    assert S.Expand(Stage(capacity,n,payload,3),O.Extent(capacity)+96+n*32) == Stage(capacity,n,payload,3)+seq(32,j => 0);
  }
  lemma ActualCopy(code: seq<Byte>, capacity: nat, n: nat, payload: seq<Byte>, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires |code| > 20967 && code[20967] == 0x5e
    requires n <= capacity < 0x800000000000000 && |payload| == n*32 && |prefix| <= 1021
    ensures M.Step(code,{},S.Running(20967,prefix+[n*32,160,O.Extent(capacity)+64],Stage(capacity,n,payload,2)),value,data) == S.Running(20968,prefix,Stage(capacity,n,payload,3))
  {
    Sizes(capacity,n,payload,2); Sizes(capacity,n,payload,3); Copy(capacity,n,payload);
    M.MemoryStep(code,20967,prefix,Stage(capacity,n,payload,2),O.Extent(capacity)+64,160,n*32,value,data);
  }
  lemma Return(code: seq<Byte>, capacity: nat, n: nat, payload: seq<Byte>, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires |code| > 498 && code[498] == 0xf3
    requires n <= capacity < 0x800000000000000 && |payload| == n*32 && |prefix| <= 1022
    ensures M.Step(code,{},S.Running(498,prefix+[64+n*32,O.Extent(capacity)],Stage(capacity,n,payload,4)),value,data) == S.Returned(Bytes(capacity,n,payload))
  {
    Sizes(capacity,n,payload,4);
    M.Delegate(code,{},S.Running(498,prefix+[64+n*32,O.Extent(capacity)],Stage(capacity,n,payload,4)),value,data);
    reveal S.Step();
    assert G.Grow(Stage(capacity,n,payload,4),O.Extent(capacity)+64+n*32) == Stage(capacity,n,payload,4);
    assert Stage(capacity,n,payload,4)[O.Extent(capacity)..O.Extent(capacity)+64+n*32] == Bytes(capacity,n,payload);
  }
}
