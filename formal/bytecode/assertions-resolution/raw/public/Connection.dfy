// SPDX-License-Identifier: MIT
// Complete admitted public resolve RAW/zero-constraints physical path.
include "Prefix.generated.dfy"
include "Return.generated.dfy"
include "../Raw.generated.dfy"
include "Execution.dfy"
module AssertionsRawPublicConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import R = AssertionsRawResolve
  import P = AssertionsRawPublicPrefix
  import T = AssertionsRawPublicReturn
  import A = AssertionsRawResolveMemory
  import I = BytecodeScanRepresentation
  import X = AssertionsRawResolveMachine
  import Q = AssertionsRawResolveFrame
  import C = AssertionsRawPublicExecution
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) {
    P.Matches(code) && R.Matches(code,1017) && T.Matches(code)
  }
  function Destinations(): set<nat> { P.Destinations()+R.Destinations(1017)+T.Destinations() }
  lemma Selectors(data: seq<Byte>)
    ensures P.Selector(data) == T.Selector(data)
  { reveal P.Selector(); reveal T.Selector(); }
  lemma ReturnCertified()
    ensures 1017 in R.FullRuntimeDestinations()
  { reveal R.FullRuntimeDestinations(); reveal R.DestinationsChunk1(); }
  lemma {:isolate_assertions} Caller(relative: Word, bytesRelative: Word, constraintsRelative: Word, length: Word, data: seq<Byte>)
    requires P.Admitted(relative,bytesRelative,constraintsRelative,length,data)
    ensures T.Admitted(relative,bytesRelative,constraintsRelative,length,data)
    ensures R.Admitted(1017,P.Pointer(relative),128,0,0,bytesRelative,constraintsRelative,length,160,
                       [0x1fa99b32,285,P.Pointer(relative),0],P.Prepared(),data)
    ensures P.Prepared() == T.Prepared()
    ensures R.PayloadOffset(P.Pointer(relative),bytesRelative) == P.Offset(relative,bytesRelative) == T.Offset(relative,bytesRelative)
  {
    Selectors(data);
    I.StoredWord([],64,128); I.StoredWord(S.Store([],64,128),64,160);
    I.StoredFrame(S.Store(S.Store([],64,128),64,160),128,0,64);
    assert |P.Prepared()| == 160;
    ReturnCertified();
  }
  ghost method Run(code: seq<Byte>, relative: Word, bytesRelative: Word,
                   constraintsRelative: Word, length: Word, data: seq<Byte>, self: Word,
                   returned: seq<Byte>, cursor: nat, observations: seq<M.Observation>) returns (frame: E.Frame, frames: seq<E.Frame>)
    requires Matches(code) && P.Admitted(relative,bytesRelative,constraintsRelative,length,data)
    ensures Q.Trace(code,Destinations(),self,0,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(0,[],[]),returned,cursor)
    ensures frames[|frames|-1] == frame
    ensures frame == E.Frame(S.Returned(data[P.Offset(relative,bytesRelative)..P.Offset(relative,bytesRelative)+length]),returned,cursor)
  {
    Caller(relative,bytesRelative,constraintsRelative,length,data);
    var state, first := P.Run(code,relative,bytesRelative,constraintsRelative,length,data);
    X.WidenTrace(code,P.Destinations(),Destinations(),0,data,first);
    var after, second := R.Run(code,1017,P.Pointer(relative),128,0,0,bytesRelative,constraintsRelative,length,160,
                               [0x1fa99b32,285,P.Pointer(relative),0],P.Prepared(),data,0);
    X.WidenTrace(code,R.Destinations(1017),Destinations(),0,data,second);
    assert first[|first|-1] == second[0];
    C.Join(code,Destinations(),0,data,first,second);
    var trace := first+second[1..];
    var final, third := T.Run(code,relative,bytesRelative,constraintsRelative,length,data);
    X.WidenTrace(code,T.Destinations(),Destinations(),0,data,third);
    T.MemoryIsConstruct(relative,bytesRelative,constraintsRelative,length,data);
    assert trace[|trace|-1] == third[0];
    C.Join(code,Destinations(),0,data,trace,third);
    trace := trace+third[1..];
    C.LiftTrace(code,Destinations(),returned,cursor,self,0,data,observations,trace);
    frame := E.Frame(final,returned,cursor);frames := Q.Lift(trace,returned,cursor);
  }
}
