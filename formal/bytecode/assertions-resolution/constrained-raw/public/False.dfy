// SPDX-License-Identifier: MIT
// Exact public RAW resolver first false constraint emits canonical ConstraintFailed after arbitrary prior Holds.
include "Prefix.generated.dfy"
include "../False.dfy"
include "../../raw/public/Execution.dfy"
module AssertionsConstrainedPublicFalse {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import R = AssertionsRawResolveMachine
  import Q = AssertionsRawResolveFrame
  import U = AssertionsRawPublicExecution
  import W = AssertionsConstraintLoopFrames
  import L = AssertionsConstraintLoopSpec
  import J = AssertionsConstraintSpec
  import P = AssertionsConstrainedPublicPrefix
  import B = AssertionsConstrainedRawBefore
  import C = AssertionsConstrainedRawFalse
  import F = AssertionsConstraintFirstFalse
  import ZP = AssertionsConstraintFailedSpec
  import H = BytecodeScanRepresentation
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Matches(code: seq<Byte>) { P.Matches(code) && C.Matches(code,1017) }
  function Destinations(): set<nat> { P.Destinations()+C.Destinations(1017) }
  function Base(relative: Word, constraintsRelative: Word): Word
    requires (relative as nat)+constraintsRelative+36 < G.Modulus()
  { relative+constraintsRelative+36 }
  predicate Admitted(relative: Word, bytesRelative: Word, constraintsRelative: Word, length: Word,
                     cs: seq<L.Constraint>, bad: nat, data: seq<Byte>) {
    |cs|*32 <= length && P.Admitted(relative,bytesRelative,constraintsRelative,length,|cs|,data) &&
    L.Layout(data,Base(relative,constraintsRelative),cs) &&
    548+S.Round32(length)+2*L.Cost(cs) < 0x10000000000000000 &&
    F.First(data[P.Offset(relative,bytesRelative)..P.Offset(relative,bytesRelative)+length],data,Base(relative,constraintsRelative),cs,bad)
  }
  function Reference(data: seq<Byte>, base: Word, cs: seq<L.Constraint>, bad: nat): seq<Byte>
    requires L.Layout(data,base,cs) && bad < |cs|
  {
    assert (base as nat)+cs[bad].position+cs[bad].referenceRelative+32+cs[bad].length <= |data|;
    assert (base as nat)+cs[bad].position+cs[bad].referenceRelative+32 < G.Modulus();
    assert L.Payload(base,cs[bad]) == base+cs[bad].position+cs[bad].referenceRelative+32;
    data[L.Payload(base,cs[bad])..L.Payload(base,cs[bad])+cs[bad].length]
  }
  lemma ReturnCertified()
    ensures 1017 in B.FullRuntimeDestinations()
  { reveal B.FullRuntimeDestinations(); reveal B.DestinationsChunk1(); }
  lemma {:isolate_assertions} Caller(relative: Word, bytesRelative: Word, constraintsRelative: Word, length: Word,
                                     cs: seq<L.Constraint>, bad: nat, data: seq<Byte>)
    requires Admitted(relative,bytesRelative,constraintsRelative,length,cs,bad,data)
    ensures C.Admitted(1017,P.Pointer(relative),128,0,0,0,bytesRelative,constraintsRelative,length,160,cs,bad,
                       [531209010,285,P.Pointer(relative),0],P.Prepared(),data)
  {
    ReturnCertified();
    H.StoredWord([],64,128);
    H.StoredWord(S.Store([],64,128),64,160);
    H.StoredFrame(S.Store(S.Store([],64,128),64,160),128,0,64);
    H.StoredWord(S.Store(S.Store([],64,128),64,160),128,0);
    assert |P.Prepared()| == 160 && |P.Prepared()|%32 == 0;
    assert S.Load(P.Prepared(),128) == 0 && S.Load(P.Prepared(),64) == 160;
    assert S.Round32(0) == 0;

  }
  ghost method {:isolate_assertions} Run(code: seq<Byte>, relative: Word, bytesRelative: Word,
                                         constraintsRelative: Word, length: Word, cs: seq<L.Constraint>, bad: nat, self: Word,
                                         data: seq<Byte>, observations: seq<M.Observation>) returns (frames: seq<E.Frame>)
    requires Matches(code) && Admitted(relative,bytesRelative,constraintsRelative,length,cs,bad,data)
    ensures Q.Trace(code,Destinations(),self,0,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(0,[],[]),[],0)
    ensures var bytes := data[P.Offset(relative,bytesRelative)..P.Offset(relative,bytesRelative)+length];
            frames[|frames|-1] == E.Frame(S.Reverted(ZP.Error([],0,0,bad,cs[bad].kind,L.Actual(bytes,bad),Reference(data,Base(relative,constraintsRelative),cs,bad))),[],0)
  {
    hide F.Verdict();
    hide ZP.Error();
    assert C.Base(P.Pointer(relative),constraintsRelative) == Base(relative,constraintsRelative);
    assert B.PayloadOffset(P.Pointer(relative),bytesRelative) == P.Offset(relative,bytesRelative);
    reveal Matches();
    var state, prefixStates := P.Run(code,relative,bytesRelative,constraintsRelative,length,|cs|,data);
    R.WidenTrace(code,P.Destinations(),Destinations(),0,data,prefixStates);
    U.LiftTrace(code,Destinations(),[],0,self,0,data,observations,prefixStates);
    frames := Q.Lift(prefixStates,[],0);
    Caller(relative,bytesRelative,constraintsRelative,length,cs,bad,data);
    assert state == S.Running(3393,[531209010,285,P.Pointer(relative),0]+[1017,P.Pointer(relative),128,0,0],P.Prepared());
    var body := C.Run(code,Destinations(),1017,P.Pointer(relative),128,0,0,0,bytesRelative,constraintsRelative,length,160,cs,bad,
                       [531209010,285,P.Pointer(relative),0],P.Prepared(),self,0,data,[],0,observations);
    assert frames[|frames|-1] == E.Frame(state,[],0);
    assert body[0] == E.Frame(state,[],0);
    W.Join(code,Destinations(),self,0,data,observations,frames,body);
    frames := frames+body[1..];
  }
}
