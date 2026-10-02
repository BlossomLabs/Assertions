// SPDX-License-Identifier: MIT
// Exact public resolver success for independent arbitrary non-OR constraint arrays.
include "Prefix.generated.dfy"
include "Return.dfy"
include "../Connection.dfy"
module AssertionsConstrainedPublicConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import R = AssertionsRawResolveMachine
  import Q = AssertionsRawResolveFrame
  import U = AssertionsRawPublicExecution
  import W = AssertionsConstraintLoopFrames
  import L = AssertionsConstraintLoopSpec
  import P = AssertionsConstrainedPublicPrefix
  import T = AssertionsConstrainedPublicReturn
  import B = AssertionsConstrainedRawBefore
  import C = AssertionsConstrainedRawConnection
  import F = BytecodeScanRepresentation
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Matches(code: seq<Byte>) { P.Matches(code) && C.Matches(code,1017) && T.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+C.Destinations(1017) }
  function Base(relative: Word, constraintsRelative: Word): Word
    requires (relative as nat)+constraintsRelative+36 < G.Modulus()
  { relative+constraintsRelative+36 }
  predicate Admitted(relative: Word, bytesRelative: Word, constraintsRelative: Word, length: Word,
                     cs: seq<L.Constraint>, data: seq<Byte>) {
    |cs|*32 <= length && P.Admitted(relative,bytesRelative,constraintsRelative,length,|cs|,data) &&
    L.Layout(data,Base(relative,constraintsRelative),cs) &&
    352+S.Round32(length)+L.Cost(cs) < 0x10000000000000000 &&
    L.Passes(data[P.Offset(relative,bytesRelative)..P.Offset(relative,bytesRelative)+length],data,Base(relative,constraintsRelative),cs)
  }
  lemma ReturnCertified()
    ensures 1017 in B.FullRuntimeDestinations()
  { reveal B.FullRuntimeDestinations(); reveal B.DestinationsChunk1(); }
  lemma {:isolate_assertions} Caller(relative: Word, bytesRelative: Word, constraintsRelative: Word, length: Word,
                                     cs: seq<L.Constraint>, data: seq<Byte>)
    requires Admitted(relative,bytesRelative,constraintsRelative,length,cs,data)
    ensures C.Admitted(1017,P.Pointer(relative),128,0,0,bytesRelative,constraintsRelative,length,160,cs,
                       [531209010,285,P.Pointer(relative),0],P.Prepared(),data)
  {
    ReturnCertified();
    F.StoredWord([],64,128);
    F.StoredWord(S.Store([],64,128),64,160);
    F.StoredFrame(S.Store(S.Store([],64,128),64,160),128,0,64);
  }
  ghost method {:isolate_assertions} Run(code: seq<Byte>, relative: Word, bytesRelative: Word,
                                         constraintsRelative: Word, length: Word, cs: seq<L.Constraint>, self: Word, data: seq<Byte>, observations: seq<M.Observation>)
    returns (frames: seq<E.Frame>)
    requires Matches(code) && Admitted(relative,bytesRelative,constraintsRelative,length,cs,data)
    ensures Q.Trace(code,Destinations(),self,0,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(0,[],[]),[],0)
    ensures frames[|frames|-1] == E.Frame(S.Returned(data[P.Offset(relative,bytesRelative)..P.Offset(relative,bytesRelative)+length]),[],0)
  {
    reveal Matches();
    var initial, prefixStates := P.Run(code,relative,bytesRelative,constraintsRelative,length,|cs|,data);
    R.WidenTrace(code,P.Destinations(),Destinations(),0,data,prefixStates);
    U.LiftTrace(code,Destinations(),[],0,self,0,data,observations,prefixStates);
    frames := Q.Lift(prefixStates,[],0);
    Caller(relative,bytesRelative,constraintsRelative,length,cs,data);
    var state, body := C.Run(code,Destinations(),1017,P.Pointer(relative),128,0,0,bytesRelative,constraintsRelative,length,160,cs,
                             [531209010,285,P.Pointer(relative),0],P.Prepared(),self,0,data,[],0,observations);
    W.Join(code,Destinations(),self,0,data,observations,frames,body);
    frames := frames+body[1..];
    var bytes := data[P.Offset(relative,bytesRelative)..P.Offset(relative,bytesRelative)+length];
    var tailStates := T.Run(code,160,bytes,L.Free(192+S.Round32(length),cs,|cs|),[531209010,285,P.Pointer(relative)],state.memory,data);
    R.WidenTrace(code,{},Destinations(),0,data,tailStates);
    U.LiftTrace(code,Destinations(),[],0,self,0,data,observations,tailStates);
    var tail := Q.Lift(tailStates,[],0);
    W.Join(code,Destinations(),self,0,data,observations,frames,tail);
    frames := frames+tail[1..];
  }
}
