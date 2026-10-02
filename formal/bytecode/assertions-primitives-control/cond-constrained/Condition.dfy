// SPDX-License-Identifier: MIT
// Constrained RAW condition resolution and actual first-word physical composition.
include "Heap.dfy"
include "../CondFirstWord.generated.dfy"
module AssertionsCondConstrainedCondition {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import R = AssertionsConstrainedRawConnection
  import B = AssertionsConstrainedRawBefore
  import L = AssertionsConstraintLoopSpec
  import N = AssertionsControlCondFirstWord
  import W = AssertionsCondFirstWord
  import H = AssertionsCondConstrainedHeap
  import F = AssertionsGatherLoopFrame
  import D = AssertionsGatherCallerSpec
  import Q = AssertionsPrimitiveExternalLift
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) {
    R.Matches(code,1770) && N.Matches(code) && W.Matches(code)
  }
  function Destinations(ret: Word): set<nat> {
    R.Destinations(1770)+N.Destinations(ret)+W.Destinations(1783)
  }
  ghost method Run(code: seq<Byte>, ret: Word, condition: Word, then_: Word, else_: Word,
                   assertion: Word, bytesRelative: Word, constraintsRelative: Word,
                   length: Word, free: Word, cs: seq<L.Constraint>, prefix: seq<Word>,
                   mem: seq<Byte>, self: Word, value: Word, data: seq<Byte>,
                   returned: seq<Byte>, cursor: nat, observations: seq<A.Observation>)
    returns (frame: E.Frame, frames: seq<E.Frame>)
    requires Matches(code) && |prefix| <= 939
    requires R.Admitted(1770,condition,assertion,0,0,bytesRelative,constraintsRelative,
                        length,free,cs,prefix+[ret,condition,then_,else_,0],mem,data)
    requires 1783 < |code| && code[1783] == 0x5b
    ensures Q.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(3393,prefix+[ret,condition,then_,else_,0,
                                                        1770,condition,assertion,0,0],mem),returned,cursor)
    ensures frames[|frames|-1] == frame
    ensures frame.returned == returned && frame.cursor == cursor
    ensures length < 32 ==> frame == E.Frame(S.Reverted(W.Error(length)),returned,cursor)
    ensures length >= 32 ==> frame.state.Running? && frame.state.pc == 1783 &&
                             frame.state.stack == prefix+[ret,condition,then_,else_,free,0,0,
                                                          H.First(data[B.PayloadOffset(condition,bytesRelative)..B.PayloadOffset(condition,bytesRelative)+length])]
    ensures length >= 32 ==> L.Heap(frame.state.memory,free,
                                    data[B.PayloadOffset(condition,bytesRelative)..B.PayloadOffset(condition,bytesRelative)+length],
                                    L.Free(free+32+S.Round32(length),cs,|cs|))
  {
    hide S.DataWord(); hide S.Window(); hide G.Decode();
    var state, resolved := R.Run(code,Destinations(ret),1770,condition,assertion,0,0,
                                 bytesRelative,constraintsRelative,length,free,cs,prefix+[ret,condition,then_,else_,0],
                                 mem,self,value,data,returned,cursor,observations);
    assert (prefix+[ret,condition,then_,else_,0])+[1770,condition,assertion,0,0] == prefix+[ret,condition,then_,else_,0,1770,condition,assertion,0,0];
    frames := resolved;
    assert frames[0] == E.Frame(S.Running(3393,prefix+[ret,condition,then_,else_,0,1770,condition,assertion,0,0],mem),returned,cursor);
    var bytes := data[B.PayloadOffset(condition,bytesRelative)..B.PayloadOffset(condition,bytesRelative)+length];
    var finalFree := L.Free(free+32+S.Round32(length),cs,|cs|);
    var word := H.First(bytes);
    assert L.Heap(state.memory,free,bytes,finalFree);
    assert |bytes| == length;
    assert cs[..|cs|] == cs;
    assert finalFree == free+32+S.Round32(length)+L.Cost(cs);
    assert (free as nat)+32+S.Round32(length)+L.Cost(cs)+160 < 0x10000000000000000;
    assert finalFree+96 < G.Modulus();
    assert 128 <= finalFree;
    if length >= 32 { L.PhysicalWord(state.memory,free,bytes,finalFree,0); }
    var next, states := N.Run(code,ret,condition,then_,else_,free,length,word,
                              finalFree,prefix,state.memory,value,data);
    var part := F.Lift(code,N.Destinations(ret),Destinations(ret),self,value,data,
                       observations,states,returned,cursor);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part);
    frames := frames+part[1..];
    // The frozen scanned inventory establishes that the physical caller return is real.
    reveal D.RuntimeDestinations();
    reveal D.Chunk3();
    H.FirstWordHeap(code,1783,prefix+[ret,condition,then_,else_,free,0,0],
                    state.memory,free,bytes,finalFree);
    frame,part := W.Run(code,1783,prefix+[ret,condition,then_,else_,free,0,0],
                        state.memory,free,length,word,finalFree,data,returned,cursor,self,value,observations);
    F.Widen(code,W.Destinations(1783),Destinations(ret),self,value,data,observations,part);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part);
    frames := frames+part[1..];
  }
}
