// SPDX-License-Identifier: MIT
// Complete constrained RAW resolver success with a preserved prior byte window.
include "../../assertions-resolution/constrained-raw/Connection.dfy"
include "ValidatorFrameV2.dfy"
include "RawMemory.dfy"
module AssertionsGatherConstrainedResolverFrameV2 {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import R = AssertionsRawResolveMachine
  import Q = AssertionsRawResolveFrame
  import W = AssertionsConstraintLoopFrames
  import B = AssertionsConstrainedRawBefore
  import A = AssertionsConstrainedRawAfter
  import H = AssertionsConstrainedRawHeap
  import P = AssertionsRawResolveMemory
  import L = AssertionsConstraintLoopSpec
  import C = AssertionsGatherConstrainedValidatorFrameV2
  import F = AssertionsGatherConstrainedRawMemory
  import V = AssertionsConstrainedRawWiden
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Matches(code: seq<Byte>, ret: Word) {
    B.Matches(code,ret) && A.Matches(code,ret) && C.Matches(code,3967)
  }
  function Destinations(ret: Word): set<nat> { B.Destinations(ret)+A.Destinations(ret)+C.Destinations(3967) }
  function Base(paramPointer: Word, relative: Word): Word
    requires (paramPointer as nat)+relative+32 < G.Modulus()
  { paramPointer+relative+32 }
  predicate Admitted(ret: Word, paramPointer: Word, assertion: Word, entry: Word, param: Word,
                     bytesRelative: Word, constraintsRelative: Word, length: Word, free: Word,
                     cs: seq<L.Constraint>, prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>) {
    |prefix| <= 944 && |cs|*32 <= length &&
    B.Admitted(ret,paramPointer,assertion,entry,param,bytesRelative,constraintsRelative,length,|cs|,free,prefix,mem,data) &&
    L.Layout(data,Base(paramPointer,constraintsRelative),cs) &&
    (free as nat)+32+S.Round32(length)+L.Cost(cs)+160 < 0x10000000000000000 &&
    L.Passes(data[B.PayloadOffset(paramPointer,bytesRelative)..B.PayloadOffset(paramPointer,bytesRelative)+length],data,Base(paramPointer,constraintsRelative),cs)
  }
  ghost method {:isolate_assertions} Run(code: seq<Byte>, destinations: set<nat>, ret: Word, paramPointer: Word,
                                         assertion: Word, entry: Word, param: Word, bytesRelative: Word, constraintsRelative: Word,
                                         length: Word, free: Word, cs: seq<L.Constraint>, prefix: seq<Word>, mem: seq<Byte>,
                                         self: Word, value: Word, data: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<M.Observation>, start: Word, size: nat)
    returns (state: S.State, frames: seq<E.Frame>)
    requires Matches(code,ret) && Admitted(ret,paramPointer,assertion,entry,param,bytesRelative,constraintsRelative,length,free,cs,prefix,mem,data)
    requires Destinations(ret) <= destinations
    requires 96 <= start && (start as nat)+size <= free && (start as nat)+size <= |mem|
    ensures Q.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(3393,prefix+[ret,paramPointer,assertion,entry,param],mem),returned,cursor)
    ensures frames[|frames|-1] == E.Frame(state,returned,cursor)
    ensures state.Running? && state.pc == ret && state.stack == prefix+[free]
    ensures (start as nat)+size <= |state.memory|
    ensures state.memory[start..start+size] == mem[start..start+size]
    ensures L.Heap(state.memory,free,data[B.PayloadOffset(paramPointer,bytesRelative)..B.PayloadOffset(paramPointer,bytesRelative)+length],
                   L.Free(free+32+S.Round32(length),cs,|cs|))
  {
    hide P.Construct();
    reveal Matches();
    var count: Word := |cs|;
    var rawState, rawStates := B.Run(code,ret,paramPointer,assertion,entry,param,bytesRelative,constraintsRelative,length,count,free,prefix,mem,data,value);
    W.LiftRaw(code,B.Destinations(ret),destinations,self,value,data,observations,returned,cursor,rawStates);
    frames := Q.Lift(rawStates,returned,cursor);
    H.Prepared(mem,free,B.PayloadOffset(paramPointer,bytesRelative),length,data);
    var bytes := data[B.PayloadOffset(paramPointer,bytesRelative)..B.PayloadOffset(paramPointer,bytesRelative)+length];
    var prepared := P.Construct(mem,free,B.PayloadOffset(paramPointer,bytesRelative),length,data);
    F.Window(mem,free,B.PayloadOffset(paramPointer,bytesRelative),length,data,start,size);
    var initial: Word := free+32+S.Round32(length);
    var validatorPrefix := prefix+[ret,paramPointer,assertion,entry,param,free];
    var output, body := C.Run(code,3967,Base(paramPointer,constraintsRelative),cs,free,bytes,initial,assertion,entry,param,validatorPrefix,prepared,self,value,data,observations,returned,cursor,start,size);
    V.Trace(code,C.Destinations(3967),destinations,self,value,data,observations,body);
    assert rawState == body[0].state;
    W.Join(code,destinations,self,value,data,observations,frames,body);
    frames := frames+body[1..];
    var afterStates := A.Run(code,ret,paramPointer,assertion,entry,param,free,prefix,output,value,data);
    W.LiftRaw(code,A.Destinations(ret),destinations,self,value,data,observations,returned,cursor,afterStates);
    var tail := Q.Lift(afterStates,returned,cursor);
    W.Join(code,destinations,self,value,data,observations,frames,tail);
    frames := frames+tail[1..];
    state := afterStates[|afterStates|-1];
  }
}
