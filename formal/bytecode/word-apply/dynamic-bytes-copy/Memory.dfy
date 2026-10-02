// SPDX-License-Identifier: MIT
// Generic actual dynamic-bytes ABI copy: header, MCOPY, zero padding.
include "../../copy/Execution.dfy"
include "../../scans/Representation.dfy"
include "../store-bytes/Frame.dfy"
include "../callback-receipt/Rounding.dfy"
module BytecodeApplyDynamicBytesCopyMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  import F = BytecodeApplyStoreByteFrame
  import A = BytecodeApplyCallbackReceiptRounding
  function Bound(): nat { 0x400000000000000000 }
  predicate Fits(mem: seq<S.Byte>,src: S.Word,dst: S.Word,length: S.Word,payload: seq<S.Byte>) {
    |mem|%32 == 0 && |mem| < Bound() && 96 <= src &&
    (src as nat)+32+length <= |mem| && (src as nat)+32+length <= dst &&
    (dst as nat)+96+length < Bound() && S.Load(mem,src) == length &&
    |payload| == length && mem[src+32..src+32+length] == payload
  }
  function End(dst: S.Word,length: S.Word): S.Word
    requires (dst as nat)+96+length < Bound()
  { dst+32+S.Round32(length) }
  function Bytes(length: S.Word,payload: seq<S.Byte>): seq<S.Byte>
    requires |payload| == length
  { G.Encode(length,32)+payload+seq(S.Round32(length)-length,i => 0) }
  lemma ZeroBytes(width: nat)
    ensures G.Encode(0,width) == seq(width,i => 0)
    decreases width
  {
    if width > 0 {
      ZeroBytes(width-1);
      assert seq(width-1,i => 0)+[0] == seq(width,i => 0);
    }
  }
  function Stage(mem: seq<S.Byte>,src: S.Word,dst: S.Word,length: S.Word,payload: seq<S.Byte>,k: nat): seq<S.Byte>
    requires Fits(mem,src,dst,length,payload) && k <= 3
    ensures |Stage(mem,src,dst,length,payload,k)| >= |mem|
    decreases k
  {
    if k == 0 then mem
    else if k == 1 then S.Store(mem,dst,length)
    else if k == 2 then
      C.MemorySize(Stage(mem,src,dst,length,payload,1),dst+32,src+32,length);
      C.Memory(Stage(mem,src,dst,length,payload,1),dst+32,src+32,length)
    else S.Store(Stage(mem,src,dst,length,payload,2),dst+32+length,0)
  }
  lemma Sizes(mem: seq<S.Byte>,src: S.Word,dst: S.Word,length: S.Word,payload: seq<S.Byte>,k: nat)
    requires Fits(mem,src,dst,length,payload) && k <= 3
    ensures |Stage(mem,src,dst,length,payload,k)| < Bound() && |Stage(mem,src,dst,length,payload,k)|%32 == 0
    ensures k >= 1 ==> dst+32 <= |Stage(mem,src,dst,length,payload,k)|
    ensures k >= 2 ==> dst+32+length <= |Stage(mem,src,dst,length,payload,k)|
    ensures k == 3 ==> End(dst,length) <= |Stage(mem,src,dst,length,payload,k)|
    ensures |Bytes(length,payload)| == 32+S.Round32(length)
    decreases k
  {
    C.Rounded(length);C.Rounded(dst+64+length);
    if k > 0 {
      Sizes(mem,src,dst,length,payload,k-1);
      var prior := Stage(mem,src,dst,length,payload,k-1);
      if k == 2 { C.MemorySize(prior,dst+32,src+32,length); }
      else { R.StoredWord(prior,if k == 1 then dst else dst+32+length,if k == 1 then length else 0); }
    }
  }
  lemma Original(mem: seq<S.Byte>,src: S.Word,dst: S.Word,length: S.Word,payload: seq<S.Byte>,k: nat,j: nat)
    requires Fits(mem,src,dst,length,payload) && k <= 3 && j < |mem| && j < dst
    ensures Stage(mem,src,dst,length,payload,k)[j] == mem[j]
    decreases k
  {
    Sizes(mem,src,dst,length,payload,k);
    if k > 0 {
      Original(mem,src,dst,length,payload,k-1,j);
      var prior := Stage(mem,src,dst,length,payload,k-1);
      if k == 2 { C.MemoryFrame(prior,dst+32,src+32,length,j); }
      else { F.Outside(prior,if k == 1 then dst else dst+32+length,if k == 1 then length else 0,j); }
    }
  }
  lemma Headers(mem: seq<S.Byte>,src: S.Word,dst: S.Word,length: S.Word,payload: seq<S.Byte>,k: nat)
    requires Fits(mem,src,dst,length,payload) && k <= 3
    ensures S.Load(Stage(mem,src,dst,length,payload,k),src) == length
    ensures S.Load(Stage(mem,src,dst,length,payload,k),64) == S.Load(mem,64)
    ensures Stage(mem,src,dst,length,payload,k)[src+32..src+32+length] == payload
  {
    Sizes(mem,src,dst,length,payload,k);
    var after := Stage(mem,src,dst,length,payload,k);
    forall j: int {:trigger after[j]} | 64 <= j < 96 || src <= j < src+32+length
      ensures after[j] == mem[j]
    { Original(mem,src,dst,length,payload,k,j); }
    assert after[src..src+32] == mem[src..src+32];
    assert after[64..96] == mem[64..96];
    G.LoadProjection(after,src);G.LoadProjection(mem,src);
    G.LoadProjection(after,64);G.LoadProjection(mem,64);
  }
  lemma Output(mem: seq<S.Byte>,src: S.Word,dst: S.Word,length: S.Word,payload: seq<S.Byte>)
    requires Fits(mem,src,dst,length,payload)
    ensures Stage(mem,src,dst,length,payload,3)[dst..End(dst,length)] == Bytes(length,payload)
  {
    hide S.BitNot();hide G.BitAnd();
    Sizes(mem,src,dst,length,payload,3);Headers(mem,src,dst,length,payload,1);
    var first := Stage(mem,src,dst,length,payload,1);
    var copied := Stage(mem,src,dst,length,payload,2);
    var after := Stage(mem,src,dst,length,payload,3);
    assert first[dst..dst+32] == G.Encode(length,32);
    R.StoredWord(copied,dst+32+length,0);
    ZeroBytes(32);
    forall j: int {:trigger after[j]} | dst <= j < End(dst,length)
      ensures after[j] == Bytes(length,payload)[j-dst]
    {
      if j < dst+32+length {
        F.Outside(copied,dst+32+length,0,j);
        if j < dst+32 { C.MemoryFrame(first,dst+32,src+32,length,j); }
        else { C.MemoryValue(first,dst+32,src+32,length,j-dst-32); }
      }
    }
  }
  lemma Round(length: S.Word)
    requires length+96 < Bound()
    ensures G.BitAnd(length+31,S.BitNot(31)) == S.Round32(length)
  { hide G.BitAnd();hide S.BitNot();A.Round(length); }
}
