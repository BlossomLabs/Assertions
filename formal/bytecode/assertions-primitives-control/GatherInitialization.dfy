// SPDX-License-Identifier: MIT
// Unbounded physical zero-element-pointer initialization in gather's allocation.
include "GatherFill.generated.dfy"
include "GatherFillLast.generated.dfy"
module AssertionsGatherInitialization {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import R = BytecodeScanRepresentation
  import F = AssertionsControlGatherFill
  import L = AssertionsControlGatherFillLast
  function Slot(free: Word, index: nat): Word { ((free as nat)+32+index*32)%G.Modulus() }
  predicate Heap(mem: seq<Byte>, free: Word, count: Word) {
    |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && 128 <= free && free+32+count*32 < G.Modulus() && Round32(free+32+count*32) < G.Modulus() && free+32 <= |mem| && Load(mem,free) == count && Load(mem,64) == free+32+count*32
  }
  predicate Done(mem: seq<Byte>, free: Word, index: nat) {
    free+32+index*32 <= |mem| &&
    forall j {:trigger Load(mem,Slot(free,j))} :: 0 <= j < index ==> Load(mem,Slot(free,j)) == 96
  }
  lemma StorePointer(mem: seq<Byte>, free: Word, count: Word, index: nat)
    requires Heap(mem,free,count) && index < count && Done(mem,free,index)
    ensures Heap(Store(mem,Slot(free,index),96),free,count)
    ensures Done(Store(mem,Slot(free,index),96),free,index+1)
  {
    var slot := Slot(free,index);
    assert slot == free+32+index*32;
    R.StoredWord(mem,slot,96);
    R.StoredFrame(mem,slot,96,free);
    R.StoredFrame(mem,slot,96,64);
    assert slot+32 <= free+32+count*32;
    assert Round32(slot+32) <= Round32(free+32+count*32);
    forall j {:trigger Load(Store(mem,slot,96),Slot(free,j))} | 0 <= j < index+1
      ensures Load(Store(mem,slot,96),Slot(free,j)) == 96
    {
      if j < index {
        assert Slot(free,j) == free+32+j*32;
        assert Slot(free,j)+32 <= slot;
        assert Slot(free,j)+32 <= |mem|;
        R.StoredFrame(mem,slot,96,Slot(free,j));
      }
    }
  }
  ghost method Run(code: seq<Byte>, ret: Word, args: Word, count: Word, free: Word, prefix: seq<Word>, initial: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>, mem: seq<Byte>)
    requires F.Matches(code) && L.Matches(code)
    requires Heap(initial,free,count) && 0 < count <= 0xffffffffffffffff && |prefix| <= 980
    ensures state == Running(2454,prefix+[ret,args,count,96,free,0,Slot(free,count)],mem)
    ensures Heap(mem,free,count) && Done(mem,free,count)
    ensures E.Trace(code,F.Destinations(ret)+L.Destinations(ret),value,data,trace)
    ensures trace[0] == Running(2435,prefix+[ret,args,count,96,free,count,Slot(free,0)],initial) && trace[|trace|-1] == state
  {
    mem := initial;
    var index: nat := 0;
    state := Running(2435,prefix+[ret,args,count,96,free,count,Slot(free,0)],mem);
    trace := [state];
    while index < count
      invariant 0 <= index <= count && Heap(mem,free,count) && Done(mem,free,index)
      invariant E.Trace(code,F.Destinations(ret)+L.Destinations(ret),value,data,trace)
      invariant trace[0] == Running(2435,prefix+[ret,args,count,96,free,count,Slot(free,0)],initial) && trace[|trace|-1] == state
      invariant index < count ==> state == Running(2435,prefix+[ret,args,count,96,free,count-index,Slot(free,index)],mem)
      invariant index == count ==> state == Running(2454,prefix+[ret,args,count,96,free,0,Slot(free,count)],mem)
      decreases count-index
    {
      var remain: Word := count-index;
      var slot := Slot(free,index);
      assert slot == free+32+index*32;
      var part: seq<State>;
      if remain > 1 {
        state,part := F.Run(code,ret,args,0,0,slot,count,remain,free,prefix,mem,value,data);
        assert F.Memory1(ret,args,0,0,slot,count,remain,free,prefix,mem) == Store(mem,slot,96);
        E.WidenTrace(code,F.Destinations(ret),F.Destinations(ret)+L.Destinations(ret),value,data,part);
      } else {
        state,part := L.Run(code,ret,args,0,0,slot,count,remain,free,prefix,mem,value,data);
        assert L.Memory1(ret,args,0,0,slot,count,remain,free,prefix,mem) == Store(mem,slot,96);
        E.WidenTrace(code,L.Destinations(ret),F.Destinations(ret)+L.Destinations(ret),value,data,part);
      }
      StorePointer(mem,free,count,index);
      mem := Store(mem,slot,96);
      E.Join(code,F.Destinations(ret)+L.Destinations(ret),value,data,trace,part);
      trace := trace+part[1..];
      index := index+1;
    }
  }
}
