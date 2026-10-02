// SPDX-License-Identifier: MIT
// The RAW resolver propagates the first malformed leaf's physical error unchanged.
include "Before.generated.dfy"
include "Heap.dfy"
include "Widen.dfy"
include "../constraints/errors/First.dfy"
module AssertionsConstrainedRawError {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import Q = AssertionsRawResolveFrame
  import W = AssertionsConstraintLoopFrames
  import V = AssertionsConstrainedRawWiden
  import B = AssertionsConstrainedRawBefore
  import H = AssertionsConstrainedRawHeap
  import P = AssertionsRawResolveMemory
  import L = AssertionsConstraintLoopSpec
  import J = AssertionsConstraintSpec
  import F = AssertionsConstraintFirstError
  import C = AssertionsConstraintCurrent
  import T = AssertionsConstraintFirstErrorTail
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Matches(code: seq<Byte>, ret: Word) {
    B.Matches(code,ret) && C.Matches(code,3967) && T.Matches(code,3967)
  }
  function Destinations(ret: Word): set<nat> { B.Destinations(ret)+C.Destinations(3967) }
  function Base(pointer: Word, relative: Word): Word
    requires (pointer as nat)+relative+32 < G.Modulus()
  { pointer+relative+32 }
  predicate Admitted(ret: Word, pointer: Word, assertion: Word, entry: Word, param: Word,
                     bytesRelative: Word, constraintsRelative: Word, length: Word, free: Word,
                     cs: seq<L.Constraint>, bad: nat, prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>) {
    |prefix| <= 944 && |cs|*32 <= length &&
    B.Admitted(ret,pointer,assertion,entry,param,bytesRelative,constraintsRelative,length,|cs|,free,prefix,mem,data) &&
    L.Layout(data,Base(pointer,constraintsRelative),cs) &&
    (free as nat)+32+S.Round32(length)+L.Cost(cs)+160 < 0x10000000000000000 &&
    F.First(data[B.PayloadOffset(pointer,bytesRelative)..B.PayloadOffset(pointer,bytesRelative)+length],data,Base(pointer,constraintsRelative),cs,bad)
  }
  ghost method {:isolate_assertions} Run(code: seq<Byte>, destinations: set<nat>, ret: Word, pointer: Word,
                                         assertion: Word, entry: Word, param: Word, bytesRelative: Word, constraintsRelative: Word,
                                         length: Word, free: Word, cs: seq<L.Constraint>, bad: nat, prefix: seq<Word>, mem: seq<Byte>,
                                         self: Word, value: Word, data: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<M.Observation>)
    returns (frames: seq<E.Frame>)
    requires Matches(code,ret) && Admitted(ret,pointer,assertion,entry,param,bytesRelative,constraintsRelative,length,free,cs,bad,prefix,mem,data)
    requires Destinations(ret) <= destinations
    ensures Q.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(3393,prefix+[ret,pointer,assertion,entry,param],mem),returned,cursor)
    ensures var bytes := data[B.PayloadOffset(pointer,bytesRelative)..B.PayloadOffset(pointer,bytesRelative)+length];
            frames[|frames|-1] == E.Frame(S.Reverted(J.Error(F.Verdict(bytes,data,Base(pointer,constraintsRelative),cs[bad],bad),entry,param,bad,cs[bad].length)),returned,cursor)
  {
    hide P.Construct();
    reveal Matches();
    var state, states := B.Run(code,ret,pointer,assertion,entry,param,bytesRelative,constraintsRelative,length,|cs|,free,prefix,mem,data,value);
    W.LiftRaw(code,B.Destinations(ret),destinations,self,value,data,observations,returned,cursor,states);
    frames := Q.Lift(states,returned,cursor);
    H.Prepared(mem,free,B.PayloadOffset(pointer,bytesRelative),length,data);
    var bytes := data[B.PayloadOffset(pointer,bytesRelative)..B.PayloadOffset(pointer,bytesRelative)+length];
    var prepared := P.Construct(mem,free,B.PayloadOffset(pointer,bytesRelative),length,data);
    var initial: Word := free+32+S.Round32(length);
    var body := F.Run(code,3967,Base(pointer,constraintsRelative),cs,bad,free,bytes,initial,assertion,entry,param,
                      prefix+[ret,pointer,assertion,entry,param,free],prepared,self,value,data,observations,returned,cursor);
    V.Trace(code,C.Destinations(3967),destinations,self,value,data,observations,body);
    W.Join(code,destinations,self,value,data,observations,frames,body);
    frames := frames+body[1..];
  }
}
