// SPDX-License-Identifier: MIT
// Immutable run fields and template admission across the exact successful physical iteration.
include "../successful-iteration-repair-v2/Memory.dfy"
include "../iteration-result-repair-v3/Memory.dfy"
module BytecodeFoldIterationFrame {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeFoldStampMemoryV2
  import A = BytecodeApplyStampMemory
  import Q = BytecodeFoldSuccessfulIterationMemoryV2
  import P = BytecodeApplyCallbackCopyMemory
  import C = BytecodeFoldCallbackMemoryV2
  import H = BytecodeApplyCallbackSuccessMemory
  import K = BytecodeApplySuccessfulCallMemory
  import R = BytecodeFoldResultMemoryV3
  predicate Fits(mem: seq<Byte>,ptr: Word,free: Word,length: Word,accOffset: Word,arrayOffset: Word,count: Word,data: seq<Byte>,returned: seq<Byte>) {
    M.Fits(mem,ptr,length,accOffset,arrayOffset,count,data) && P.Fits(mem,ptr,free,length) && 320 <= ptr &&
    Load(mem,64) == free && Load(mem,ptr) == length && (free as nat)+96 < G.Modulus() && |returned| == 32
  }
  function Stamped(mem: seq<Byte>,ptr: Word,free: Word,length: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,returned: seq<Byte>): seq<Byte>
    requires Fits(mem,ptr,free,length,accOffset,arrayOffset,count,data,returned)
  { M.Stamped(mem,ptr,length,accOffset,acc,arrayOffset,count,data,word,count) }
  function Complete(mem: seq<Byte>,ptr: Word,free: Word,length: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,returned: seq<Byte>): seq<Byte>
    requires Fits(mem,ptr,free,length,accOffset,arrayOffset,count,data,returned)
  {
    Q.Admission(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned);
    C.Complete(Stamped(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned),ptr,free,length,returned)
  }
  function Next(mem: seq<Byte>,ptr: Word,free: Word,length: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,returned: seq<Byte>): seq<Byte>
    requires Fits(mem,ptr,free,length,accOffset,arrayOffset,count,data,returned)
  { R.Updated(Complete(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned),H.Result(returned)) }
  lemma WordFrame(mem: seq<Byte>,ptr: Word,free: Word,length: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,returned: seq<Byte>,slot: Word)
    requires Fits(mem,ptr,free,length,accOffset,arrayOffset,count,data,returned)
    requires R.Fits(Complete(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned))
    requires 96 <= slot && (slot as nat)+32 <= ptr && ((slot as nat)+32 <= 256 || 288 <= slot)
    ensures Load(Next(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned),slot) == Load(mem,slot)
  {
    Q.Admission(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned);
    M.WordFrame(mem,ptr,length,accOffset,acc,arrayOffset,count,data,word,count,slot);
    var stamped := Stamped(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned);
    C.WordFrame(stamped,ptr,free,length,returned,slot);
    R.Frame(Complete(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned),H.Result(returned),slot);
  }
  lemma Header(mem: seq<Byte>,ptr: Word,free: Word,length: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,returned: seq<Byte>)
    requires Fits(mem,ptr,free,length,accOffset,arrayOffset,count,data,returned)
    requires R.Fits(Complete(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned))
    ensures Load(Next(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned),ptr) == length
  {
    Q.Admission(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned);
    Q.Header(mem,ptr,length,accOffset,acc,arrayOffset,count,data,word);
    var stamped := Stamped(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned);
    C.WordFrame(stamped,ptr,free,length,returned,ptr);
    R.Frame(Complete(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned),H.Result(returned),ptr);
  }
  lemma Fields(mem: seq<Byte>,ptr: Word,free: Word,length: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,returned: seq<Byte>)
    requires Fits(mem,ptr,free,length,accOffset,arrayOffset,count,data,returned)
    requires R.Fits(Complete(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned))
    ensures R.Fits(Next(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned))
    ensures Load(Next(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned),256) == H.Result(returned)
    ensures Load(Next(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned),64) == free+64
    ensures forall j: nat {:trigger Load(Next(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned),96+32*j)} :: j < 7 && j != 5 ==> Load(Next(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned),96+32*j) == Load(mem,96+32*j)
  {
    Q.Admission(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned);
    var stamped := Stamped(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned);
    var complete := Complete(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned);
    C.Bounds(stamped,ptr,free,length,returned);
    R.Fields(complete,H.Result(returned)); R.Frame(complete,H.Result(returned),64);
    forall j: nat | j < 7 && j != 5
      ensures Load(Next(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned),96+32*j) == Load(mem,96+32*j)
    { WordFrame(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned,96+32*j); }
  }
  lemma Readmission(mem: seq<Byte>,ptr: Word,free: Word,length: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,returned: seq<Byte>,nextReturned: seq<Byte>)
    requires Fits(mem,ptr,free,length,accOffset,arrayOffset,count,data,returned) && |nextReturned| == 32
    requires R.Fits(Complete(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned))
    ensures Fits(Next(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned),ptr,free+64,length,accOffset,arrayOffset,count,data,nextReturned)
  {
    Fields(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned);
    Header(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned);
    Q.Admission(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned);
    var stamped := Stamped(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned);
    C.Bounds(stamped,ptr,free,length,returned);
    K.Fits(stamped,ptr,free,length);
    H.Bounds(P.Packed(stamped,ptr,free,length),free,returned);
    M.Extent(mem,ptr,length,accOffset,acc,arrayOffset,count,data,word,count);
    var complete := Complete(mem,ptr,free,length,accOffset,acc,arrayOffset,count,data,word,returned);
    R.Fields(complete,H.Result(returned));
  }
}
