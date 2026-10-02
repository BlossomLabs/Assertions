// SPDX-License-Identifier: MIT
// The first malformed non-OR leaf reverts after all preceding predicates hold.
include "Current.dfy"
include "Tail.dfy"
module AssertionsConstraintFirstError {
  import S = BytecodeScanMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import Q = AssertionsRawResolveFrame
  import W = AssertionsConstraintLoopFrames
  import I = AssertionsConstraintInit
  import L = AssertionsConstraintLoopSpec
  import J = AssertionsConstraintSpec
  import C = AssertionsConstraintCurrent
  import T = AssertionsConstraintFirstErrorTail
  type Word = S.Word
  type Byte = S.Byte
  function Verdict(bytes: seq<Byte>, data: seq<Byte>, base: Word, c: L.Constraint, index: nat): J.Verdict
    requires (index+1)*32 <= |bytes|
    requires c.kind <= 8 && c.kind != 6
    requires L.Payload(base,c) < 0x10000000000000000
  { J.Judge(c.kind,c.length,L.Actual(bytes,index),S.DataWord(data,L.Payload(base,c)),S.DataWord(data,L.Payload(base,c)+32)) }
  predicate First(bytes: seq<Byte>, data: seq<Byte>, base: Word, cs: seq<L.Constraint>, bad: nat)
    requires L.Layout(data,base,cs) && |cs|*32 <= |bytes|
  {
    bad < |cs| && Verdict(bytes,data,base,cs[bad],bad) in {J.BadData,J.BadRange} &&
    forall i {:trigger cs[i]} :: 0 <= i < bad ==> Verdict(bytes,data,base,cs[i],i) == J.Holds
  }
  ghost method {:isolate_assertions} Run(code: seq<Byte>, ret: Word, base: Word, cs: seq<L.Constraint>, bad: nat,
                                         ptr: Word, bytes: seq<Byte>, initial: Word, assertion: Word, entry: Word, param: Word,
                                         prefix: seq<Word>, mem: seq<Byte>, self: Word, value: Word, data: seq<Byte>,
                                         observations: seq<M.Observation>, returned: seq<Byte>, cursor: nat)
    returns (frames: seq<E.Frame>)
    requires C.Matches(code,ret) && T.Matches(code,ret) && |prefix| <= 950
    requires L.Layout(data,base,cs) && |cs|*32 <= |bytes| && First(bytes,data,base,cs,bad)
    requires (initial as nat)+L.Cost(cs)+160 < 0x10000000000000000 && L.Heap(mem,ptr,bytes,initial)
    ensures Q.Trace(code,C.Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(7580,prefix+[ret,base,|cs|,ptr,assertion,entry,param],mem),returned,cursor)
    ensures frames[|frames|-1] == E.Frame(S.Reverted(J.Error(Verdict(bytes,data,base,cs[bad],bad),entry,param,bad,cs[bad].length)),returned,cursor)
  {
    C.Binding(code,ret);
    var count: Word := |cs|;
    var length: Word := |bytes|;
    assert I.Admitted(ret,base,count,ptr,length,assertion,entry,param,0,0,0,0,0,prefix,mem,data);
    var state, states := I.Run(code,ret,base,count,ptr,length,assertion,entry,param,0,0,0,0,0,prefix,mem,data,value);
    W.LiftRaw(code,I.Destinations(ret),C.Destinations(ret),self,value,data,observations,returned,cursor,states);
    frames := Q.Lift(states,returned,cursor);
    var current := mem;
    var index: nat := 0;
    assert L.Free(initial,cs,0) == initial;
    while index < bad
      invariant index <= bad && L.Heap(current,ptr,bytes,L.Free(initial,cs,index))
      invariant Q.Trace(code,C.Destinations(ret),self,value,data,observations,frames)
      invariant frames[0] == E.Frame(S.Running(7580,prefix+[ret,base,count,ptr,assertion,entry,param],mem),returned,cursor)
      invariant frames[|frames|-1] == E.Frame(S.Running(7660,C.Stack(ret,base,count,ptr,length,assertion,entry,param,index,prefix),current),returned,cursor)
      decreases bad-index
    {
      assert Verdict(bytes,data,base,cs[index],index) == J.Holds;
      var next, segment := C.Iteration(code,ret,base,cs,index,ptr,bytes,initial,assertion,entry,param,prefix,current,self,value,data,observations,returned,cursor);
      W.Join(code,C.Destinations(ret),self,value,data,observations,frames,segment);
      frames := frames+segment[1..];
      current := next;
      index := index+1;
    }
    var terminal, output, tail := T.Iteration(code,ret,base,cs,bad,ptr,bytes,initial,assertion,entry,param,prefix,current,self,value,data,observations,returned,cursor);
    W.Join(code,C.Destinations(ret),self,value,data,observations,frames,tail);
    frames := frames+tail[1..];
  }
}
