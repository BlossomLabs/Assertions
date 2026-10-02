// SPDX-License-Identifier: MIT
// One real array-loop iteration: offset store, bytes MCOPY/padding, and scalar advances.
include "Head.generated.dfy"
include "Tail.generated.dfy"
include "Connection.dfy"
include "ArrayMemory.dfy"
include "../../gather-composition/Frame.dfy"
module AssertionsGatherArrayIteration {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import L = AssertionsPrimitiveExternalLift
  import D = AssertionsGatherArraySpec
  import M = AssertionsGatherArrayMemory
  import H = AssertionsGatherArrayHead
  import T = AssertionsGatherArrayTail
  import B = AssertionsGatherBytesSpec
  import BC = AssertionsGatherBytesConnection
  import BE = AssertionsGatherBytesEncoder
  import F = AssertionsGatherLoopFrame
  import DS = AssertionsGatherCallerSpec
  type Word = S.Word
  type Byte = S.Byte
  predicate Heap(mem: seq<Byte>, arrayBase: Word, base: Word, tail: Word, head: Word,
                 count: Word, source: Word, index: Word, ptr: Word, length: Word) {
    D.LoopHeap(mem,arrayBase,base,tail,head,count,source,index) && index < count &&
    S.Load(mem,source) == ptr && M.Object(mem,base,ptr,length) && tail+96+S.Round32(length) < 0x10000000000000000
  }
  predicate Matches(code: seq<Byte>, ret: Word) { H.Matches(code,ret) && T.Matches(code,ret) && BE.Matches(code,17382) }
  function Destinations(ret: Word): set<nat> { H.Destinations(ret)+T.Destinations(ret)+BE.Destinations(17382) }
  lemma Labels()
    ensures 17382 in DS.RuntimeDestinations()
  { reveal DS.RuntimeDestinations(); reveal DS.Chunk28(); }
  lemma HeadImage(mem: seq<Byte>, arrayBase: Word, base: Word, tail: Word, head: Word,
                  count: Word, source: Word, index: Word)
    requires D.LoopHeap(mem,arrayBase,base,tail,head,count,source,index)
    ensures H.Memory1(mem,base,tail,head,count) == D.Slot(mem,base,tail,head)
  { D.LoopWords(mem,arrayBase,base,tail,head,count,source,index); }
  ghost method Run(code: seq<Byte>, ret: Word, arrayBase: Word, base: Word, tail: Word, head: Word,
                   count: Word, source: Word, index: Word, ptr: Word, length: Word,
                   prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>, returned: seq<Byte>, cursor: nat,
                   self: Word, value: Word, observations: seq<A.Observation>) returns (frame: E.Frame, frames: seq<E.Frame>)
    requires Matches(code,ret) && ret in DS.RuntimeDestinations() && |prefix| <= 940
    requires Heap(mem,arrayBase,base,tail,head,count,source,index,ptr,length)
    requires B.Heap(D.Slot(mem,base,tail,head),tail,ptr,length)
    ensures L.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(17354,prefix+[ret,arrayBase,base,0,tail,head,count,source,index],mem),returned,cursor)
    ensures frames[|frames|-1] == frame
    ensures frame == E.Frame(S.Running(17354,prefix+[ret,arrayBase,base,0,B.End(tail,length),head+32,count,source+32,index+1],B.Image(D.Slot(mem,base,tail,head),tail,ptr,length)),returned,cursor)
    ensures D.LoopHeap(frame.state.memory,arrayBase,base,B.End(tail,length),head+32,count,source+32,index+1)
  {
    Labels(); HeadImage(mem,arrayBase,base,tail,head,count,source,index);
    M.After(mem,arrayBase,base,tail,head,count,source,index,ptr,length);
    reveal H.Admitted(); reveal T.Admitted(); reveal BE.Admitted();
    var prepared := D.Slot(mem,base,tail,head);
    var state,states := H.Run(code,ret,arrayBase,base,tail,head,count,source,index,ptr,0,prefix,mem,data,value);
    frames := F.Lift(code,H.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    var helperPrefix := prefix+[ret,arrayBase,base,0,tail,head,count,source,index];
    var part: seq<E.Frame>;
    frame,part := BC.Run(code,Destinations(ret),17382,tail,ptr,length,helperPrefix,prepared,data,returned,cursor,self,value,observations);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    var image := B.Image(prepared,tail,ptr,length);
    var next := B.End(tail,length);
    assert D.LoopHeap(image,arrayBase,base,next,head,count,source,index);
    state,states := T.Run(code,ret,arrayBase,base,tail,head,count,source,index,ptr,next,prefix,image,data,value);
    part := F.Lift(code,T.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    frame := E.Frame(state,returned,cursor);
  }
}
