// SPDX-License-Identifier: MIT
// Physical dynamic ABI serializer memory, with fitting footprints explicit.
include "../iota/Output.dfy"
include "../copy/Execution.dfy"
module BytecodeIotaReturnMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import O = BytecodeIotaOutput
  import C = BytecodeCopyMemory
  import M = BytecodeCopyMachine
  type Byte = S.Byte
  type Word = S.Word
  function Payload(n: nat): seq<Byte>
    requires n < 0x800000000000000
  { O.Heap(n,n)[160..] }
  function Bytes(n: nat): seq<Byte>
    requires n < 0x800000000000000
  { G.Encode(32,32)+G.Encode(n*32,32)+Payload(n) }
  function Stage(n: nat, k: nat): seq<Byte>
    requires n < 0x800000000000000 && k <= 4
  {
    O.Heap(n,n)+(if k >= 1 then G.Encode(32,32) else [])+
    (if k >= 2 then G.Encode(n*32,32) else [])+
    (if k >= 3 then Payload(n) else [])+
    (if k >= 4 then seq(32,j => 0) else [])
  }
  lemma Sizes(n: nat, k: nat)
    requires n < 0x800000000000000 && k <= 4
    ensures |Payload(n)| == n*32 && |Bytes(n)| == 64+n*32
    ensures |Stage(n,k)| == O.Extent(n)+(if k >= 1 then 32 else 0)+(if k >= 2 then 32 else 0)+(if k >= 3 then n*32 else 0)+(if k >= 4 then 32 else 0)
    ensures S.Round32(|Stage(n,k)|) == |Stage(n,k)|
  {}
  lemma Headers(n: nat, k: nat)
    requires n < 0x800000000000000 && k <= 4
    ensures S.Load(Stage(n,k),64) == O.Extent(n)
    ensures S.Load(Stage(n,k),128) == n*32
    ensures Stage(n,k)[..O.Extent(n)] == O.Heap(n,n)
  {
    O.Header(n,n);
    assert Stage(n,k)[64..96] == O.Heap(n,n)[64..96];
    assert Stage(n,k)[128..160] == O.Heap(n,n)[128..160];
  }
  lemma FirstStore(n: nat)
    requires n < 0x800000000000000
    ensures S.Store(Stage(n,0),O.Extent(n),32) == Stage(n,1)
  {
    Sizes(n,0); Sizes(n,1);
    assert S.Expand(Stage(n,0),O.Extent(n)+32) == Stage(n,0)+seq(32,j => 0);
  }
  lemma SecondStore(n: nat)
    requires n < 0x800000000000000
    ensures S.Store(Stage(n,1),O.Extent(n)+32,n*32) == Stage(n,2)
  {
    Sizes(n,1); Sizes(n,2);
    assert S.Expand(Stage(n,1),O.Extent(n)+64) == Stage(n,1)+seq(32,j => 0);
  }
  lemma Copy(n: nat)
    requires n < 0x800000000000000
    ensures C.Memory(Stage(n,2),O.Extent(n)+64,160,n*32) == Stage(n,3)
  {
    Sizes(n,2); Sizes(n,3);
    if n == 0 { C.ZeroLength(Stage(n,2),O.Extent(n)+64,160,[]); }
    else {
      var after := C.Memory(Stage(n,2),O.Extent(n)+64,160,n*32);
      C.MemorySize(Stage(n,2),O.Extent(n)+64,160,n*32);
      assert |after| == |Stage(n,3)|;
      forall j: nat {:trigger after[j]} | j < |after|
        ensures after[j] == Stage(n,3)[j]
      {
        if j < O.Extent(n)+64 { C.MemoryFrame(Stage(n,2),O.Extent(n)+64,160,n*32,j); }
        else {
          C.MemoryValue(Stage(n,2),O.Extent(n)+64,160,n*32,j-(O.Extent(n)+64));
          assert Stage(n,2)[160+j-(O.Extent(n)+64)] == Payload(n)[j-(O.Extent(n)+64)];
        }
      }
    }
  }
  lemma FinalStore(n: nat)
    requires n < 0x800000000000000
    ensures S.Store(Stage(n,3),O.Extent(n)+64+n*32,0) == Stage(n,4)
  {
    Sizes(n,3); Sizes(n,4);
    O.ZeroEncoding(32);
    assert S.Expand(Stage(n,3),O.Extent(n)+96+n*32) == Stage(n,3)+seq(32,j => 0);
  }
  lemma ActualCopy(code: seq<Byte>, n: nat, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires |code| > 20967 && code[20967] == 0x5e
    requires n < 0x800000000000000 && |prefix| <= 1021
    ensures M.Step(code,{},S.Running(20967,prefix+[n*32,160,O.Extent(n)+64],Stage(n,2)),value,data) == S.Running(20968,prefix,Stage(n,3))
  {
    Sizes(n,2); Sizes(n,3); Copy(n);
    M.MemoryStep(code,20967,prefix,Stage(n,2),O.Extent(n)+64,160,n*32,value,data);
  }
  lemma Return(code: seq<Byte>, n: nat, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires |code| > 498 && code[498] == 0xf3
    requires n < 0x800000000000000 && |prefix| <= 1022
    ensures M.Step(code,{},S.Running(498,prefix+[64+n*32,O.Extent(n)],Stage(n,4)),value,data) == S.Returned(Bytes(n))
  {
    Sizes(n,4);
    M.Delegate(code,{},S.Running(498,prefix+[64+n*32,O.Extent(n)],Stage(n,4)),value,data);
    reveal S.Step();
    assert G.Grow(Stage(n,4),O.Extent(n)+64+n*32) == Stage(n,4);
    assert Stage(n,4)[O.Extent(n)..O.Extent(n)+64+n*32] == Bytes(n);
  }
}
