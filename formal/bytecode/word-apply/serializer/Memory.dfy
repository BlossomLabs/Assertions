// SPDX-License-Identifier: MIT
// Actual shared serializer over arbitrary caller heap and fitting free pointer.
include "../../copy/Execution.dfy"
include "../../scans/Representation.dfy"
module BytecodeApplyBytesReturnMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import M = BytecodeCopyMachine
  import R = BytecodeScanRepresentation
  function Bound(): nat { 0x400000000000000000 }
  predicate Fits(mem: seq<S.Byte>,free: S.Word,n: S.Word,payload: seq<S.Byte>) {
    n < 0x800000000000000 && |payload| == n*32 &&
    160+n*32 <= |mem| < Bound() && |mem|%32 == 0 &&
    160+n*32 <= free && free%32 == 0 && (free as nat)+96+n*32 < Bound() &&
    S.Load(mem,64) == free && S.Load(mem,128) == n*32 && mem[160..160+n*32] == payload
  }
  function Bytes(n: S.Word,payload: seq<S.Byte>): seq<S.Byte>
    requires n < 0x800000000000000 && |payload| == n*32
  { G.Encode(32,32)+G.Encode(n*32,32)+payload }
  function Stage(mem: seq<S.Byte>,free: S.Word,n: S.Word,payload: seq<S.Byte>,k: nat): seq<S.Byte>
    requires Fits(mem,free,n,payload) && k <= 4
    ensures |Stage(mem,free,n,payload,k)| >= |mem|
    ensures k == 4 ==> |Stage(mem,free,n,payload,k)| >= free+96+n*32
    decreases k
  {
    if k == 0 then mem
    else if k == 1 then S.Store(mem,free,32)
    else if k == 2 then S.Store(Stage(mem,free,n,payload,1),free+32,n*32)
    else if k == 3 then
      C.MemorySize(Stage(mem,free,n,payload,2),free+64,160,n*32);
      C.Memory(Stage(mem,free,n,payload,2),free+64,160,n*32)
    else S.Store(Stage(mem,free,n,payload,3),free+64+n*32,0)
  }
  lemma Sizes(mem: seq<S.Byte>,free: S.Word,n: S.Word,payload: seq<S.Byte>,k: nat)
    requires Fits(mem,free,n,payload) && k <= 4
    ensures 160+n*32 <= |Stage(mem,free,n,payload,k)| < Bound()
    ensures |Stage(mem,free,n,payload,k)|%32 == 0
    ensures |Bytes(n,payload)| == 64+n*32
  {
    if k > 0 {
      Sizes(mem,free,n,payload,k-1);
      var prior := Stage(mem,free,n,payload,k-1);
      if k == 3 { C.MemorySize(prior,free+64,160,n*32); }
      else {
        var offset: S.Word := if k == 1 then free else if k == 2 then free+32 else free+64+n*32;
        C.Rounded(offset+32);
      }
    }
  }
  lemma Prefix(mem: seq<S.Byte>,free: S.Word,n: S.Word,payload: seq<S.Byte>,k: nat,j: nat)
    requires Fits(mem,free,n,payload) && k <= 4 && j < |mem| && j < free
    ensures Stage(mem,free,n,payload,k)[j] == mem[j]
    decreases k
  {
    Sizes(mem,free,n,payload,k);
    if k > 0 {
      Prefix(mem,free,n,payload,k-1,j);
      var prior := Stage(mem,free,n,payload,k-1);
      if k == 3 { C.MemoryFrame(prior,free+64,160,n*32,j); }
      else {
        var offset: S.Word := if k == 1 then free else if k == 2 then free+32 else free+64+n*32;
        R.StoredFrame(prior,offset,if k == 1 then 32 else if k == 2 then n*32 else 0,j);
      }
    }
  }
  lemma Headers(mem: seq<S.Byte>,free: S.Word,n: S.Word,payload: seq<S.Byte>,k: nat)
    requires Fits(mem,free,n,payload) && k <= 4
    ensures S.Load(Stage(mem,free,n,payload,k),64) == free
    ensures S.Load(Stage(mem,free,n,payload,k),128) == n*32
    ensures Stage(mem,free,n,payload,k)[160..160+n*32] == payload
  {
    Sizes(mem,free,n,payload,k);
    var after := Stage(mem,free,n,payload,k);
    forall j: int {:trigger after[j]} | 64 <= j < 96 || 128 <= j < 160+n*32
      ensures after[j] == mem[j]
    { Prefix(mem,free,n,payload,k,j); }
    assert after[64..96] == mem[64..96];
    assert after[128..160] == mem[128..160];
    G.LoadProjection(after,64);G.LoadProjection(mem,64);
    G.LoadProjection(after,128);G.LoadProjection(mem,128);
  }
  lemma FirstStore(mem: seq<S.Byte>,free: S.Word,n: S.Word,payload: seq<S.Byte>)
    requires Fits(mem,free,n,payload)
    ensures S.Store(Stage(mem,free,n,payload,0),free,32) == Stage(mem,free,n,payload,1)
  {}
  lemma SecondStore(mem: seq<S.Byte>,free: S.Word,n: S.Word,payload: seq<S.Byte>)
    requires Fits(mem,free,n,payload)
    ensures S.Store(Stage(mem,free,n,payload,1),free+32,n*32) == Stage(mem,free,n,payload,2)
  {}
  lemma FinalStore(mem: seq<S.Byte>,free: S.Word,n: S.Word,payload: seq<S.Byte>)
    requires Fits(mem,free,n,payload)
    ensures S.Store(Stage(mem,free,n,payload,3),free+64+n*32,0) == Stage(mem,free,n,payload,4)
  {}
  lemma ActualCopy(code: seq<S.Byte>,mem: seq<S.Byte>,free: S.Word,n: S.Word,payload: seq<S.Byte>,prefix: seq<S.Word>,value: S.Word,data: seq<S.Byte>)
    requires |code| > 20967 && code[20967] == 0x5e
    requires Fits(mem,free,n,payload) && |prefix| <= 1021
    ensures M.Step(code,{},S.Running(20967,prefix+[n*32,160,free+64],Stage(mem,free,n,payload,2)),value,data) == S.Running(20968,prefix,Stage(mem,free,n,payload,3))
  {
    M.MemoryStep(code,20967,prefix,Stage(mem,free,n,payload,2),free+64,160,n*32,value,data);
  }
  lemma Output(mem: seq<S.Byte>,free: S.Word,n: S.Word,payload: seq<S.Byte>)
    requires Fits(mem,free,n,payload)
    ensures Stage(mem,free,n,payload,4)[free..free+64+n*32] == Bytes(n,payload)
  {
    Sizes(mem,free,n,payload,4);
    Headers(mem,free,n,payload,2);
    var first := Stage(mem,free,n,payload,1);
    var second := Stage(mem,free,n,payload,2);
    var copied := Stage(mem,free,n,payload,3);
    var after := Stage(mem,free,n,payload,4);
    assert first[free..free+32] == G.Encode(32,32);
    assert second[free+32..free+64] == G.Encode(n*32,32);
    forall j: nat | j < 64+n*32
      ensures after[free+j] == Bytes(n,payload)[j]
    {
      R.StoredFrame(copied,free+64+n*32,0,free+j);
      if j < 64 {
        C.MemoryFrame(second,free+64,160,n*32,free+j);
        if j < 32 { R.StoredFrame(first,free+32,n*32,free+j); }
      }
      else { C.MemoryValue(second,free+64,160,n*32,j-64); }
    }
  }
  lemma Return(code: seq<S.Byte>,mem: seq<S.Byte>,free: S.Word,n: S.Word,payload: seq<S.Byte>,prefix: seq<S.Word>,value: S.Word,data: seq<S.Byte>)
    requires |code| > 498 && code[498] == 0xf3
    requires Fits(mem,free,n,payload) && |prefix| <= 1022
    ensures M.Step(code,{},S.Running(498,prefix+[64+n*32,free],Stage(mem,free,n,payload,4)),value,data) == S.Returned(Bytes(n,payload))
  {
    Sizes(mem,free,n,payload,4);Output(mem,free,n,payload);
    M.Delegate(code,{},S.Running(498,prefix+[64+n*32,free],Stage(mem,free,n,payload,4)),value,data);
    reveal S.Step();
  }
}
