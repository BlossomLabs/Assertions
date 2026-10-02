// SPDX-License-Identifier: MIT
// Complete public RAW resolver rejects an overlong constraint table before reading any leaf.
include "Prefix.generated.dfy"
include "../Before.generated.dfy"
include "../../constraints/errors/WordBounds.generated.dfy"
include "../../constraints/LoopFrames.dfy"
include "../../raw/public/Execution.dfy"
module AssertionsConstrainedPublicWordBounds {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import R = AssertionsRawResolveMachine
  import H = AssertionsRawResolveMemory
  import Q = AssertionsRawResolveFrame
  import U = AssertionsRawPublicExecution
  import W = AssertionsConstraintLoopFrames
  import P = AssertionsConstrainedPublicPrefix
  import B = AssertionsConstrainedRawBefore
  import D = AssertionsConstraintWordBounds
  import V = BytecodeScanRepresentation
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Matches(code: seq<Byte>) { P.Matches(code) && B.Matches(code,1017) && D.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+B.Destinations(1017)+D.Destinations() }
  predicate Admitted(relative: Word, bytesRelative: Word, constraintsRelative: Word,
                     length: Word, count: Word, data: seq<Byte>) {
    P.Admitted(relative,bytesRelative,constraintsRelative,length,count,data) &&
    length/32 < count && 352+S.Round32(length) < 0x10000000000000000
  }
  lemma ReturnCertified()
    ensures 1017 in B.FullRuntimeDestinations()
  { reveal B.FullRuntimeDestinations(); reveal B.DestinationsChunk1(); }
  lemma {:isolate_assertions} Caller(relative: Word, bytesRelative: Word, constraintsRelative: Word,
                                     length: Word, count: Word, data: seq<Byte>)
    requires Admitted(relative,bytesRelative,constraintsRelative,length,count,data)
    ensures B.Admitted(1017,P.Pointer(relative),128,0,0,bytesRelative,constraintsRelative,length,count,160,
                       [531209010,285,P.Pointer(relative),0],P.Prepared(),data)
  {
    ReturnCertified();
    V.StoredWord([],64,128);
    V.StoredWord(S.Store([],64,128),64,160);
    V.StoredFrame(S.Store(S.Store([],64,128),64,160),128,0,64);
  }
  lemma {:isolate_assertions} ValidatorAdmission(relative: Word, bytesRelative: Word, constraintsRelative: Word,
                                                 length: Word, count: Word, data: seq<Byte>)
    requires Admitted(relative,bytesRelative,constraintsRelative,length,count,data)
    ensures D.Admitted(3967,P.Pointer(relative)+constraintsRelative+32,count,160,128,0,0,length,192+S.Round32(length),
                       [531209010,285,P.Pointer(relative),0,1017,P.Pointer(relative),128,0,0,160],
                       H.Construct(P.Prepared(),160,P.Offset(relative,bytesRelative),length,data))
  {
    hide H.Construct();
    Caller(relative,bytesRelative,constraintsRelative,length,count,data);
    H.Built(P.Prepared(),160,P.Offset(relative,bytesRelative),length,data);
  }
  ghost method {:isolate_assertions} Run(code: seq<Byte>, relative: Word, bytesRelative: Word,
                                         constraintsRelative: Word, length: Word, count: Word, self: Word,
                                         data: seq<Byte>, observations: seq<M.Observation>) returns (frames: seq<E.Frame>)
    requires Matches(code) && Admitted(relative,bytesRelative,constraintsRelative,length,count,data)
    ensures Q.Trace(code,Destinations(),self,0,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(0,[],[]),[],0)
    ensures frames[|frames|-1] == E.Frame(S.Reverted(D.Error(length)),[],0)
  {
    hide H.Construct();
    reveal Matches();
    var prefixState, prefixStates := P.Run(code,relative,bytesRelative,constraintsRelative,length,count,data);
    R.WidenTrace(code,P.Destinations(),Destinations(),0,data,prefixStates);
    U.LiftTrace(code,Destinations(),[],0,self,0,data,observations,prefixStates);
    frames := Q.Lift(prefixStates,[],0);
    Caller(relative,bytesRelative,constraintsRelative,length,count,data);
    var beforeState, beforeStates := B.Run(code,1017,P.Pointer(relative),128,0,0,bytesRelative,constraintsRelative,
                                           length,count,160,[531209010,285,P.Pointer(relative),0],P.Prepared(),data,0);
    W.LiftRaw(code,B.Destinations(1017),Destinations(),self,0,data,observations,[],0,beforeStates);
    var body := Q.Lift(beforeStates,[],0);
    assert frames[|frames|-1] == E.Frame(prefixState,[],0);
    assert body[0] == E.Frame(prefixState,[],0);
    W.Join(code,Destinations(),self,0,data,observations,frames,body);
    frames := frames+body[1..];
    ValidatorAdmission(relative,bytesRelative,constraintsRelative,length,count,data);
    var rejected := D.Run(code,3967,P.Pointer(relative)+constraintsRelative+32,count,160,128,0,0,length,192+S.Round32(length),
                          [531209010,285,P.Pointer(relative),0,1017,P.Pointer(relative),128,0,0,160],
                          H.Construct(P.Prepared(),160,P.Offset(relative,bytesRelative),length,data),0,data);
    R.WidenTrace(code,D.Destinations(),Destinations(),0,data,rejected);
    U.LiftTrace(code,Destinations(),[],0,self,0,data,observations,rejected);
    var terminal := Q.Lift(rejected,[],0);
    assert frames[|frames|-1] == E.Frame(beforeState,[],0);
    assert terminal[0] == E.Frame(beforeState,[],0);
    W.Join(code,Destinations(),self,0,data,observations,frames,terminal);
    frames := frames+terminal[1..];
  }
}
