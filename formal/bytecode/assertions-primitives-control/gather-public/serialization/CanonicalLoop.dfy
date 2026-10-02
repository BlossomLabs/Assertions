// SPDX-License-Identifier: MIT
// Unbounded physical array-serializer loop; count-index is the termination rank.
include "IterationValue.dfy"
include "Done.generated.dfy"
include "Work.dfy"
include "Encoded.dfy"
module AssertionsGatherArrayCanonicalLoop {
  import P = AssertionsGatherArrayEncoded
  import I = AssertionsGatherArrayIteration
  import V = AssertionsGatherArrayIterationValue
  import Q = AssertionsGatherArrayDone
  import D = AssertionsGatherArraySpec
  import W = AssertionsGatherArrayWork
  import M = AssertionsGatherArrayMemory
  import B = AssertionsGatherBytesSpec
  import F = AssertionsGatherLoopFrame
  import E = BytecodeExternalMachine
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = AssertionsExternalMachine
  import L = AssertionsPrimitiveExternalLift
  import DS = AssertionsGatherCallerSpec
  type Word = S.Word
  type Byte = S.Byte
  function Destinations(ret: Word): set<nat> { I.Destinations(ret)+Q.Destinations(ret) }
  ghost method Run(code: seq<Byte>, ret: Word, arrayBase: Word, base: Word, firstTail: Word,
                   values: seq<seq<Byte>>, pointers: seq<Word>, prefix: seq<Word>, initial: seq<Byte>,
                   data: seq<Byte>, returned: seq<Byte>, cursor: nat, self: Word, value: Word, observations: seq<A.Observation>)
    returns (frame: E.Frame, frames: seq<E.Frame>, tail: Word)
    requires I.Matches(code,ret) && Q.Matches(code,ret) && ret in DS.RuntimeDestinations() && |prefix| <= 940
    requires W.Budget(base,values) && W.Sources(initial,arrayBase,base,values,pointers)
    requires firstTail == W.Position(base,values,0)
    requires D.LoopHeap(initial,arrayBase,base,firstTail,base+64,|values|,arrayBase+32,0)
    ensures L.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(17354,prefix+[ret,arrayBase,base,0,firstTail,base+64,|values|,arrayBase+32,0],initial),returned,cursor)
    ensures frames[|frames|-1] == frame && frame.state.Running? && frame.state == S.Running(ret,prefix+[tail],frame.state.memory)
    ensures frame.returned == returned && frame.cursor == cursor
    ensures tail == W.Position(base,values,|values|)
    ensures W.Sources(frame.state.memory,arrayBase,base,values,pointers)
    ensures P.Done(frame.state.memory,base,values,|values|)
    ensures |initial| <= |frame.state.memory|
    ensures forall p: nat {:trigger frame.state.memory[p]} :: p < |initial| && p < base+64 ==> frame.state.memory[p] == initial[p]
    ensures |frame.state.memory|%32 == 0 && |frame.state.memory| <= tail+32
  {
    var count: Word := |values|;
    var index: Word := 0;
    var head: Word := base+64;
    var source: Word := arrayBase+32;
    tail := firstTail;
    frame := E.Frame(S.Running(17354,prefix+[ret,arrayBase,base,0,tail,head,count,source,index],initial),returned,cursor);
    frames := [frame];
    var mem := initial; P.Empty(mem,base,values);
    while index < count
      invariant index <= count && count == |values|
      invariant D.LoopHeap(mem,arrayBase,base,tail,head,count,source,index)
      invariant W.Sources(mem,arrayBase,base,values,pointers)
      invariant P.Done(mem,base,values,index)
      invariant |initial| <= |mem|
      invariant forall p: nat {:trigger mem[p]} :: p < |initial| && p < base+64 ==> mem[p] == initial[p]
      invariant tail == W.Position(base,values,index)
      invariant L.Trace(code,Destinations(ret),self,value,data,observations,frames)
      invariant frames[0] == E.Frame(S.Running(17354,prefix+[ret,arrayBase,base,0,firstTail,base+64,count,arrayBase+32,0],initial),returned,cursor)
      invariant frames[|frames|-1] == frame && frame == E.Frame(S.Running(17354,prefix+[ret,arrayBase,base,0,tail,head,count,source,index],mem),returned,cursor)
      decreases count-index
    {
      W.Positions(base,values,index); W.Source(mem,arrayBase,base,values,pointers,index);
      var ptr := pointers[index]; var length: Word := |values[index]|;
      M.Prepared(mem,arrayBase,base,tail,head,count,source,index,ptr,length);
      var before := mem; var previousTail := tail;
      var part: seq<E.Frame>;
      frame,part := V.Run(code,ret,arrayBase,base,tail,head,count,source,index,ptr,length,prefix,mem,data,returned,cursor,self,value,observations);
      F.Widen(code,I.Destinations(ret),Destinations(ret),self,value,data,observations,part);
      F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
      mem := frame.state.memory;
      forall p: nat {:trigger mem[p]} | p < |initial| && p < base+64
        ensures mem[p] == initial[p]
      {}
      P.Produced(mem,base,values,index,previousTail,B.End(previousTail,length));
      P.Advance(before,mem,base,values,index,previousTail,head);
      W.Preserved(before,mem,arrayBase,base,values,pointers);
      tail := B.End(previousTail,length); head := head+32; source := source+32; index := index+1;
    }
    reveal Q.Admitted();
    var state,states := Q.Run(code,ret,arrayBase,base,tail,head,count,source,index,0,0,prefix,mem,data,value);
    var part := F.Lift(code,Q.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    frame := E.Frame(state,returned,cursor);
  }
}
