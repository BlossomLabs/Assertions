// SPDX-License-Identifier: MIT
// Exact RAW pick body, all signed word selection branches and complete ABI word RETURN.
include "Spec.dfy"
include "Memory.dfy"
include "Word.dfy"
include "Footer.generated.dfy"
include "Exit.generated.dfy"
module AssertionsPickRawBody {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import P = AssertionsControlPickStart
  import N = AssertionsControlPickWord
  import X = AssertionsPickExit
  import Z = AssertionsPickFooter
  import Q = AssertionsPrimitiveScalar
  import R = AssertionsRawResolve
  import RR = AssertionsRawResolveConnection
  import M = AssertionsRawResolveMemory
  import C = AssertionsCondRawSpec
  import H = AssertionsPrimitivePreparation
  import D = AssertionsGatherCallerSpec
  import W = AssertionsPickWord
  import Y = AssertionsPickMemory
  import F = AssertionsGatherLoopFrame
  import L = AssertionsPrimitiveExternalLift
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) { P.Matches(code) && N.Matches(code) && X.Matches(code) && W.Matches(code) && Z.Matches(code) && R.Matches(code,3159) }
  function Destinations(): set<nat> { P.Destinations(371)+N.Destinations(371)+X.Destinations(371)+W.Destinations(3171)+Z.Destinations()+R.Destinations(3159) }
  function WantedWord(data: seq<Byte>,operand: C.Operand,index: Word): Word
    requires C.Span(data,operand)
  { if Q.Inside(operand.length,index) then S.DataWord(data,(C.Offset(operand)+32*Q.Wanted(operand.length,index))%G.Modulus()) else 0 }
  lemma Labels()
    ensures 3159 in R.FullRuntimeDestinations() && 3171 in D.RuntimeDestinations()
    ensures 371 in X.RuntimeDestinations()
  { reveal X.RuntimeDestinations(); reveal R.FullRuntimeDestinations(); reveal R.DestinationsChunk4(); reveal D.RuntimeDestinations(); reveal D.Chunk4(); reveal D.Chunk0(); }
  ghost method Run(code: seq<Byte>,operand: C.Operand,index: Word,free: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>,returned: seq<Byte>,cursor: nat,self: Word,value: Word,observations: seq<A.Observation>) returns (frame: E.Frame,frames: seq<E.Frame>)
    requires Matches(code) && C.Span(data,operand) && C.Heap(mem,free,operand) && |prefix| <= 930
    ensures L.Trace(code,Destinations(),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(3131,prefix+[371,operand.pointer,index],mem),returned,cursor) && frames[|frames|-1] == frame
    ensures if Q.Inside(operand.length,index) then frame == E.Frame(S.Returned(G.Encode(WantedWord(data,operand,index),32)),returned,cursor)
            else frame == E.Frame(S.Reverted(W.Error(index,operand.length)),returned,cursor)
  {
    hide S.DataWord(); hide S.Window(); hide G.Decode(); hide M.Construct();
    Labels(); C.Prepared(mem,free,operand,data);
    var state,states := P.Run(code,371,operand.pointer,0,0,0,operand.length,index,free,prefix,mem,value,data);
    assert P.Memory2(371,operand.pointer,0,0,0,operand.length,index,free,prefix,mem) == H.EmptyAssertion(mem,free);
    frames := F.Lift(code,P.Destinations(371),Destinations(),self,value,data,observations,states,returned,cursor);
    assert R.Admitted(3159,operand.pointer,free,0,0,operand.bytesRelative,operand.constraintsRelative,operand.length,free+32,prefix+[371,operand.pointer,index,0,0],H.EmptyAssertion(mem,free),data);
    var part: seq<E.Frame>;
    frame,part := RR.Run(code,Destinations(),3159,operand.pointer,free,0,0,operand.bytesRelative,operand.constraintsRelative,operand.length,free+32,prefix+[371,operand.pointer,index,0,0],H.EmptyAssertion(mem,free),data,returned,cursor,self,value,observations);
    F.Join(code,Destinations(),self,value,data,observations,frames,part); frames := frames+part[1..];
    M.Built(H.EmptyAssertion(mem,free),free+32,C.Offset(operand),operand.length,data);
    var image := M.Construct(H.EmptyAssertion(mem,free),free+32,C.Offset(operand),operand.length,data);
    var finalFree: Word := free+64+S.Round32(operand.length);
    state,states := N.Run(code,371,operand.pointer,0,0,free+32,operand.length,index,finalFree,prefix,image,value,data);
    part := F.Lift(code,N.Destinations(371),Destinations(),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(),self,value,data,observations,frames,part); frames := frames+part[1..];
    if Q.Inside(operand.length,index) {
      Q.IndexFacts(operand.length,index);
      Y.Selected(H.EmptyAssertion(mem,free),free+32,C.Offset(operand),operand.length,index,data);
      assert (C.Offset(operand)+32*Q.Wanted(operand.length,index))%G.Modulus() == C.Offset(operand)+32*Q.Wanted(operand.length,index);
    }
    reveal X.Matches(); reveal Z.Matches();
    frame,part := W.Run(code,3171,prefix+[371,operand.pointer,index,0,free+32],image,free+32,operand.length,WantedWord(data,operand,index),index,finalFree,data,returned,cursor,self,value,observations);
    F.Widen(code,W.Destinations(3171),Destinations(),self,value,data,observations,part);
    F.Join(code,Destinations(),self,value,data,observations,frames,part); frames := frames+part[1..];
    if Q.Inside(operand.length,index) {
      state,states := X.Run(code,371,operand.pointer,WantedWord(data,operand,index),0,free+32,operand.length,index,finalFree,prefix,image,value,data);
      part := F.Lift(code,X.Destinations(371),Destinations(),self,value,data,observations,states,returned,cursor);
      F.Join(code,Destinations(),self,value,data,observations,frames,part); frames := frames+part[1..];
      state,states := Z.Run(code,finalFree,WantedWord(data,operand,index),prefix,image,value,data);
      part := F.Lift(code,Z.Destinations(),Destinations(),self,value,data,observations,states,returned,cursor);
      F.Join(code,Destinations(),self,value,data,observations,frames,part); frames := frames+part[1..];
      frame := E.Frame(state,returned,cursor);
    }
  }
}
