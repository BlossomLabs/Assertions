// SPDX-License-Identifier: MIT
// Public empty-array class, from fresh PC0 through real decoder/body/bytes[] RETURN.
include "Dispatch.generated.dfy"
include "Decoder.generated.dfy"
include "EmptySerializer.generated.dfy"
include "../GatherStartZero.generated.dfy"
include "../GatherAllocation.dfy"
include "../gather-composition/CallerGatherDone.generated.dfy"
include "../gather-composition/Frame.dfy"
module AssertionsGatherEmptyPublicConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import D = AssertionsGatherPublicSpec
  import P = AssertionsGatherPublicDispatch
  import C = AssertionsGatherPublicDecoder
  import Z = AssertionsGatherPublicEmptySerializer
  import B = AssertionsControlGatherStartZero
  import H = AssertionsGatherAllocation
  import F = AssertionsGatherLoopFrame
  import Q = AssertionsGatherCallerDone
  import DS = AssertionsGatherCallerSpec
  import R = BytecodeScanRepresentation
  import L = AssertionsPrimitiveExternalLift
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Calldata(data: seq<Byte>, relative: Word) {
    D.Calldata(data,relative,0) && S.ShiftRight(S.DataWord(data,0),224) == D.Selector()
  }
  function Destinations(): set<nat> { P.Destinations()+C.Destinations()+B.Destinations(477)+Q.Destinations(477)+Z.Destinations() }
  lemma InitialHeap()
    ensures S.Load(D.Initial(),64) == 128 && |D.Initial()| == 96
    ensures D.EmptyHeap(H.Header(D.Initial(),128,0))
  {
    R.StoredWord([],64,128);
    var initial := D.Initial();
    R.StoredWord(initial,128,0);
    var first := S.Store(initial,128,0);
    R.StoredWord(first,64,160); R.StoredFrame(first,64,160,128);
  }
  lemma InitialAdmission(args: Word)
    ensures B.Admitted([],477,args,0,0,0,0,0,128,[D.Selector()],D.Initial())
  { InitialHeap(); }
  lemma Caller(data: seq<Byte>, relative: Word)
    requires Calldata(data,relative)
    ensures D.Calldata(data,relative,0) && |data| < G.Modulus()
    ensures P.Admitted(relative,0,[],[],data,0) && C.Admitted(relative,0,[],D.Initial(),data,0)
    ensures B.Admitted([],477,D.Args(relative),0,0,0,0,0,128,[D.Selector()],D.Initial())
    ensures 477 in DS.RuntimeDestinations()
    ensures S.Load(D.Initial(),64) == 128 && |D.Initial()| == 96
    ensures D.EmptyHeap(H.Header(D.Initial(),128,0))
    ensures Z.Admitted(relative,0,[],H.Header(D.Initial(),128,0),data,0)
  {
    InitialHeap();
    reveal Calldata();
    InitialAdmission(D.Args(relative));
    reveal P.Admitted(); reveal C.Admitted(); reveal Z.Admitted();
    reveal DS.RuntimeDestinations(); reveal DS.Chunk0();
  }
  ghost method Serialize(code: seq<Byte>, data: seq<Byte>, relative: Word, self: Word,
                         observations: seq<A.Observation>, mem: seq<Byte>)
    returns (part: seq<E.Frame>)
    requires Z.Matches(code) && |data| < G.Modulus() && D.EmptyHeap(mem)
    ensures L.Trace(code,Destinations(),self,0,data,observations,part)
    ensures part[0] == E.Frame(S.Running(477,[D.Selector(),128],mem),[],0)
    ensures part[|part|-1] == E.Frame(S.Returned(D.EmptyResult()),[],0)
  {
    reveal Z.Admitted();
    var state,states := Z.Run(code,relative,0,[],mem,data,0);
    part := F.Lift(code,Z.Destinations(),Destinations(),self,0,data,observations,states,[],0);
    D.EmptySerialization(mem);
    assert Z.Memory2(mem) == D.EmptyImage(mem);
    assert G.Grow(D.EmptyImage(mem),224) == D.EmptyImage(mem);
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, relative: Word, self: Word, observations: seq<A.Observation>)
    returns (frames: seq<E.Frame>)
    requires P.Matches(code) && C.Matches(code) && B.Matches(code) && Q.Matches(code) && Z.Matches(code)
    requires Calldata(data,relative)
    ensures L.Trace(code,Destinations(),self,0,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(0,[],[]),[],0)
    ensures frames[|frames|-1] == E.Frame(S.Returned(D.EmptyResult()),[],0)
  {
    Caller(data,relative); D.Layout(data,relative,0);
    hide S.DataWord(); hide S.Window(); hide G.Decode(); hide S.ShiftRight(); hide D.Calldata();
    var state,states := P.Run(code,relative,0,[],[],data,0);
    frames := F.Lift(code,P.Destinations(),Destinations(),self,0,data,observations,states,[],0);
    state,states := C.Run(code,relative,0,[],D.Initial(),data,0);
    var part := F.Lift(code,C.Destinations(),Destinations(),self,0,data,observations,states,[],0);
    F.Join(code,Destinations(),self,0,data,observations,frames,part); frames := frames+part[1..];
    H.Images(D.Initial(),128,0,477,D.Args(relative),[D.Selector()]);
    state,states := B.Run(code,477,D.Args(relative),0,0,0,0,0,128,[D.Selector()],D.Initial(),0,data);
    var mem := H.Header(D.Initial(),128,0);
    part := F.Lift(code,B.Destinations(477),Destinations(),self,0,data,observations,states,[],0);
    F.Join(code,Destinations(),self,0,data,observations,frames,part); frames := frames+part[1..];
    assert 477 < |code| && code[477] == 0x5b by { reveal Z.Matches(); }
    state,states := Q.Run(code,477,D.Args(relative),0,0,0,0,0,128,[D.Selector()],mem,0,data);
    part := F.Lift(code,Q.Destinations(477),Destinations(),self,0,data,observations,states,[],0);
    F.Join(code,Destinations(),self,0,data,observations,frames,part); frames := frames+part[1..];
    assert frames[|frames|-1] == E.Frame(S.Running(477,[D.Selector(),128],mem),[],0);
    part := Serialize(code,data,relative,self,observations,mem);
    assert frames[|frames|-1] == part[0];
    F.Join(code,Destinations(),self,0,data,observations,frames,part); frames := frames+part[1..];
  }
}
