// SPDX-License-Identifier: MIT
// Connect the exact physical bytes encoder to independent bytes/zero padding and world-frame semantics.
include "Blob.generated.dfy"
include "BlobMemory.dfy"
include "../../../assertions-primitives-control/ExternalLift.dfy"
module AssertionsConstraintFailedBlobConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import D = AssertionsConstraintFailedBlobSpec
  import B = AssertionsConstraintFailedBlobEncoder
  import M = AssertionsConstraintFailedBlobMemory
  import R = AssertionsRawResolveMachine
  import F = AssertionsRawResolveFrame
  import L = AssertionsPrimitiveExternalLift
  type Word = S.Word
  type Byte = S.Byte
  lemma Normalize(mem: seq<Byte>, dst: Word, src: Word, length: Word)
    requires D.Heap(mem,dst,src,length)
    ensures B.Memory3(mem,dst,src,length) == D.Image(mem,dst,src,length)
  { D.Bounds(mem,dst,src,length); }
  lemma Lift(code: seq<Byte>, destinations: set<nat>, self: Word, value: Word,
             data: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<A.Observation>, states: seq<S.State>)
    requires R.Trace(code,destinations,value,data,states)
    requires forall i {:trigger states[i]} :: 0 <= i < |states|-1 ==> F.Local(code,states[i])
    requires F.Local(code,states[|states|-1])
    ensures L.Trace(code,destinations,self,value,data,observations,F.Lift(states,returned,cursor))
    ensures F.Lift(states,returned,cursor)[0] == E.Frame(states[0],returned,cursor)
    ensures F.Lift(states,returned,cursor)[|states|-1] == E.Frame(states[|states|-1],returned,cursor)
  {
    forall i {:trigger states[i]} | 0 <= i < |states|
      ensures F.Local(code,states[i])
    { if i == |states|-1 {} }
    F.LiftTrace(code,destinations,returned,cursor,self,value,data,observations,states);
  }
  ghost method Run(code: seq<Byte>, destinations: set<nat>, ret: Word, dst: Word, src: Word, length: Word,
                   prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>, returned: seq<Byte>, cursor: nat,
                   self: Word, value: Word, observations: seq<A.Observation>) returns (frame: E.Frame, frames: seq<E.Frame>)
    requires D.Heap(mem,dst,src,length) && B.Matches(code,ret) && B.Admitted(ret,dst,src,length,prefix,mem,data,value)
    requires B.Destinations(ret) <= destinations
    ensures L.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(17270,prefix+[ret,dst,src],mem),returned,cursor)
    ensures frames[|frames|-1] == frame
    ensures frame == E.Frame(S.Running(ret,prefix+[D.End(dst,length)],D.Image(mem,dst,src,length)),returned,cursor)
    ensures D.Value(mem,frame.state.memory,dst,src,length)
    ensures |frame.state.memory|%32 == 0 && |frame.state.memory| <= D.End(dst,length)+64
    ensures forall j: nat {:trigger frame.state.memory[j]} :: j < |mem| && j < dst ==> frame.state.memory[j] == mem[j]
  {
    Normalize(mem,dst,src,length); M.Built(mem,dst,src,length);
    var state,states := B.Run(code,ret,dst,src,length,prefix,mem,data,value);
    R.WidenTrace(code,B.Destinations(ret),destinations,value,data,states);
    assert F.Local(code,state) by { reveal B.Matches(); reveal B.Admitted(); }
    Lift(code,destinations,self,value,data,returned,cursor,observations,states);
    frames := F.Lift(states,returned,cursor); frame := E.Frame(state,returned,cursor);
  }
}
