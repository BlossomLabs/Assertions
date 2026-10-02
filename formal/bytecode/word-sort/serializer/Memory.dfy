// SPDX-License-Identifier: MIT
// Generic aligned bytes RETURN for an arbitrary reached rounded heap and output buffer.
include "../../copy/Execution.dfy"
module BytecodeSortBytesReturnMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import M = BytecodeCopyMachine
  type Byte = S.Byte
  type Word = S.Word
  predicate Base(mem: seq<Byte>, n: nat, payload: seq<Byte>) {
    n < 0x800000000000000 && |payload| == n*32 && 96 <= |mem| < 0x40000000000000000 && S.Round32(|mem|) == |mem|
  }
  predicate Admitted(mem: seq<Byte>, n: nat, out: Word, payload: seq<Byte>) {
    Base(mem,n,payload) && 96 <= out && out+32+n*32 <= |mem| && S.Load(mem,64) == |mem| && S.Load(mem,out) == n*32 && mem[out+32..out+32+n*32] == payload
  }
  function Bytes(n: nat, payload: seq<Byte>): seq<Byte>
    requires n < 0x800000000000000 && |payload| == n*32
  { G.Encode(32,32)+G.Encode(n*32,32)+payload }
  function Stage(mem: seq<Byte>, n: nat, payload: seq<Byte>, k: nat): seq<Byte>
    requires Base(mem,n,payload) && k <= 4
  {
    mem+(if k >= 1 then G.Encode(32,32) else [])+(if k >= 2 then G.Encode(n*32,32) else [])+(if k >= 3 then payload else [])+(if k >= 4 then seq(32,j => 0) else [])
  }
  lemma Sizes(mem: seq<Byte>, n: nat, payload: seq<Byte>, k: nat)
    requires Base(mem,n,payload) && k <= 4
    ensures |Bytes(n,payload)| == 64+n*32
    ensures |Stage(mem,n,payload,k)| == |mem|+(if k >= 1 then 32 else 0)+(if k >= 2 then 32 else 0)+(if k >= 3 then n*32 else 0)+(if k >= 4 then 32 else 0)
    ensures S.Round32(|Stage(mem,n,payload,k)|) == |Stage(mem,n,payload,k)|
    ensures Stage(mem,n,payload,k)[..|mem|] == mem
  {}
  lemma Headers(mem: seq<Byte>, n: nat, out: Word, payload: seq<Byte>, k: nat)
    requires Admitted(mem,n,out,payload) && k <= 4
    ensures S.Load(Stage(mem,n,payload,k),64) == |mem| && S.Load(Stage(mem,n,payload,k),out) == n*32
  {
    Sizes(mem,n,payload,k);
    var stage := Stage(mem,n,payload,k);
    G.LoadProjection(mem,64); G.LoadProjection(stage,64);
    G.LoadProjection(mem,out); G.LoadProjection(stage,out);
    assert G.Grow(mem,96) == mem && G.Grow(stage,96) == stage;
    assert G.Grow(mem,out+32) == mem && G.Grow(stage,out+32) == stage;
    assert stage[64..96] == mem[64..96] && stage[out..out+32] == mem[out..out+32];
  }
  lemma FirstStore(mem: seq<Byte>, n: nat, payload: seq<Byte>)
    requires Base(mem,n,payload)
    ensures S.Store(Stage(mem,n,payload,0),|mem|,32) == Stage(mem,n,payload,1)
  {
    Sizes(mem,n,payload,0); Sizes(mem,n,payload,1);
    assert S.Expand(mem,|mem|+32) == mem+seq(32,j => 0);
  }
  lemma SecondStore(mem: seq<Byte>, n: nat, payload: seq<Byte>)
    requires Base(mem,n,payload)
    ensures S.Store(Stage(mem,n,payload,1),|mem|+32,n*32) == Stage(mem,n,payload,2)
  {
    Sizes(mem,n,payload,1); Sizes(mem,n,payload,2);
    assert S.Expand(Stage(mem,n,payload,1),|mem|+64) == Stage(mem,n,payload,1)+seq(32,j => 0);
  }
  lemma Copy(mem: seq<Byte>, n: nat, out: Word, payload: seq<Byte>)
    requires Admitted(mem,n,out,payload)
    ensures C.Memory(Stage(mem,n,payload,2),|mem|+64,out+32,n*32) == Stage(mem,n,payload,3)
  {
    Sizes(mem,n,payload,2); Sizes(mem,n,payload,3);
    if n == 0 { C.ZeroLength(Stage(mem,n,payload,2),|mem|+64,out+32,[]); }
    else {
      var before := Stage(mem,n,payload,2);
      var after := C.Memory(before,|mem|+64,out+32,n*32);
      C.MemorySize(before,|mem|+64,out+32,n*32);
      assert |after| == |Stage(mem,n,payload,3)|;
      forall j: nat {:trigger after[j]} | j < |after|
        ensures after[j] == Stage(mem,n,payload,3)[j]
      {
        if j < |mem|+64 { C.MemoryFrame(before,|mem|+64,out+32,n*32,j); }
        else {
          C.MemoryValue(before,|mem|+64,out+32,n*32,j-(|mem|+64));
          assert before[out+32+j-(|mem|+64)] == mem[out+32+j-(|mem|+64)];
          assert mem[out+32+j-(|mem|+64)] == payload[j-(|mem|+64)];
        }
      }
    }
  }
  lemma ZeroEncoding(width: nat)
    ensures G.Encode(0,width) == seq(width,j => 0)
    decreases width
  {
    if width > 0 {
      ZeroEncoding(width-1);
      assert seq(width,j => 0) == seq(width-1,j => 0)+[0];
    }
  }
  lemma FinalStore(mem: seq<Byte>, n: nat, payload: seq<Byte>)
    requires Base(mem,n,payload)
    ensures S.Store(Stage(mem,n,payload,3),|mem|+64+n*32,0) == Stage(mem,n,payload,4)
  {
    Sizes(mem,n,payload,3); Sizes(mem,n,payload,4);
    ZeroEncoding(32);
    assert S.Expand(Stage(mem,n,payload,3),|mem|+96+n*32) == Stage(mem,n,payload,3)+seq(32,j => 0);
  }
  lemma ActualCopy(code: seq<Byte>, mem: seq<Byte>, n: nat, out: Word, payload: seq<Byte>, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires |code| > 20967 && code[20967] == 0x5e && Admitted(mem,n,out,payload) && |prefix| <= 1021
    ensures M.Step(code,{},S.Running(20967,prefix+[n*32,out+32,|mem|+64],Stage(mem,n,payload,2)),value,data) == S.Running(20968,prefix,Stage(mem,n,payload,3))
  {
    Sizes(mem,n,payload,2); Sizes(mem,n,payload,3); Copy(mem,n,out,payload);
    M.MemoryStep(code,20967,prefix,Stage(mem,n,payload,2),|mem|+64,out+32,n*32,value,data);
  }
  lemma Return(code: seq<Byte>, mem: seq<Byte>, n: nat, payload: seq<Byte>, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires |code| > 498 && code[498] == 0xf3 && Base(mem,n,payload) && |prefix| <= 1022
    ensures M.Step(code,{},S.Running(498,prefix+[64+n*32,|mem|],Stage(mem,n,payload,4)),value,data) == S.Returned(Bytes(n,payload))
  {
    Sizes(mem,n,payload,4);
    M.Delegate(code,{},S.Running(498,prefix+[64+n*32,|mem|],Stage(mem,n,payload,4)),value,data);
    reveal S.Step();
    assert G.Grow(Stage(mem,n,payload,4),|mem|+64+n*32) == Stage(mem,n,payload,4);
    assert Stage(mem,n,payload,4)[|mem|..|mem|+64+n*32] == Bytes(n,payload);
  }
}
