// SPDX-License-Identifier: MIT
// Exact fixed WrongCallbackResult packet over arbitrary caller-local memory.
include "../../scans/ErrorBytes.dfy"
include "../store-bytes/Frame.dfy"
module BytecodeApplyWrongCallbackMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import E = BytecodeScanErrorBytes
  import F = BytecodeApplyStoreByteFrame
  function Selector(): S.Word { 0x24448a11 }
  function Header(): S.Word { 0x24448a1100000000000000000000000000000000000000000000000000000000 }
  predicate Fits(mem: seq<S.Byte>,free: S.Word) {
    96 <= |mem| < G.Modulus() && |mem|%32 == 0 && 96 <= free && (free as nat)+160 < G.Modulus() && S.Load(mem,64) == free
  }
  function Packet(operation: S.Word,index: S.Word,target: S.Word): seq<S.Byte>
  { G.Encode(Selector(),4)+G.Encode(operation,32)+G.Encode(index,32)+G.Encode(0,32)+G.Encode(target,32) }
  function Stage(mem: seq<S.Byte>,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,k: nat): seq<S.Byte>
    requires Fits(mem,free) && k <= 5
    decreases k
  {
    if k == 0 then mem
    else S.Store(Stage(mem,free,operation,index,target,k-1),
                 if k == 1 then free else free+4+32*(k-2),
                 if k == 1 then Header() else if k == 2 then operation else if k == 3 then index else if k == 4 then 0 else target)
  }
  lemma Layout(mem: seq<S.Byte>,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,k: nat)
    requires Fits(mem,free) && k <= 5
    ensures |Stage(mem,free,operation,index,target,k)|%32 == 0
    ensures |Stage(mem,free,operation,index,target,k)| >= |mem|
    ensures k > 0 ==> |Stage(mem,free,operation,index,target,k)| >= free+(if k == 1 then 32 else 4+32*(k-1))
    ensures S.Load(Stage(mem,free,operation,index,target,k),64) == free
    decreases k
  {
    if k > 0 {
      Layout(mem,free,operation,index,target,k-1);
      var prior := Stage(mem,free,operation,index,target,k-1);
      var offset: S.Word := if k == 1 then free else free+4+32*(k-2);
      var datum: S.Word := if k == 1 then Header() else if k == 2 then operation else if k == 3 then index else if k == 4 then 0 else target;
      R.StoredWord(prior,offset,datum);
      R.StoredFrame(prior,offset,datum,64);
    }
  }
  lemma Prefix(mem: seq<S.Byte>,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,k: nat,j: nat)
    requires Fits(mem,free) && 2 <= k <= 5 && free <= j < free+4+32*(k-1)
    ensures Stage(mem,free,operation,index,target,5)[j] == Stage(mem,free,operation,index,target,k)[j]
    decreases 5-k
  {
    Layout(mem,free,operation,index,target,k);
    var current := Stage(mem,free,operation,index,target,k);
    if k < 5 {
      var offset: S.Word := free+4+32*(k-1);
      var datum: S.Word := if k == 2 then index else if k == 3 then 0 else target;
      F.Outside(current,offset,datum,j);
      Prefix(mem,free,operation,index,target,k+1,j);
    }
  }
  lemma Bytes(mem: seq<S.Byte>,free: S.Word,operation: S.Word,index: S.Word,target: S.Word)
    requires Fits(mem,free)
    ensures Stage(mem,free,operation,index,target,5)[free..free+132] == Packet(operation,index,target)
  {
    Layout(mem,free,operation,index,target,5);
    E.PhysicalError(mem,free,Selector(),Header(),operation);
    var first := Stage(mem,free,operation,index,target,2);
    var second := Stage(mem,free,operation,index,target,3);
    var third := Stage(mem,free,operation,index,target,4);
    var last := Stage(mem,free,operation,index,target,5);
    R.StoredWord(first,free+36,index);
    R.StoredWord(second,free+68,0);
    R.StoredWord(third,free+100,target);
    forall j: int {:trigger last[j]} | free <= j < free+132
      ensures last[j] == Packet(operation,index,target)[j-free]
    {
      if j < free+36 { Prefix(mem,free,operation,index,target,2,j); }
      else if j < free+68 { Prefix(mem,free,operation,index,target,3,j); }
      else if j < free+100 { Prefix(mem,free,operation,index,target,4,j); }
    }
  }
}
